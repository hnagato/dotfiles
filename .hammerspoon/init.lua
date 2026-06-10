local eventtap = hs.eventtap
local event = eventtap.event
local keycodes = hs.keycodes
local timer = hs.timer

local eventTypes = event.types
local rawFlagMasks = event.rawFlagMasks

local keyCode = {
  leftCommand = 0x37,
  rightCommand = 0x36,
  jisEisu = 0x66,
  jisKana = 0x68,
}

local arrowByKeyCode = {
  [keycodes.map.h] = "left",
  [keycodes.map.j] = "down",
  [keycodes.map.k] = "up",
  [keycodes.map.l] = "right",
}

-- Groups of physical-modifier masks, ordered for building modifier lists and
-- checking whether any non-command modifier is active.
local modifierGroups = {
  { "shift", { rawFlagMasks.shift, rawFlagMasks.deviceLeftShift, rawFlagMasks.deviceRightShift } },
  { "alt",   { rawFlagMasks.alternate, rawFlagMasks.deviceLeftAlternate, rawFlagMasks.deviceRightAlternate } },
  { "ctrl",  { rawFlagMasks.control, rawFlagMasks.deviceLeftControl, rawFlagMasks.deviceRightControl } },
  { "fn",    { rawFlagMasks.secondaryFn } },
}

-- Returns true if the given raw flag bitmask has the specified flag bit set.
local function hasFlag(rawFlags, mask)
  return mask ~= nil and (rawFlags & mask) ~= 0
end

-- Appends modifier to the list if any of the given masks is set in rawFlags.
-- Stops at the first match so the modifier is never added twice.
local function appendModifier(modifiers, rawFlags, modifier, masks)
  for _, mask in ipairs(masks) do
    if hasFlag(rawFlags, mask) then
      table.insert(modifiers, modifier)
      return
    end
  end
end

-- Returns true if any non-Command modifier key (shift, alt, ctrl, fn) is active.
-- Used to decide whether a lone Command tap should send its replacement key.
local function hasAnyModifierExceptCommand(rawFlags)
  for _, group in ipairs(modifierGroups) do
    for _, mask in ipairs(group[2]) do
      if hasFlag(rawFlags, mask) then return true end
    end
  end
  return false
end

-- Returns true if the physical left Command key is currently held.
-- Falls back to the generic Command flag when the device-specific bit is absent,
-- excluding right Command to avoid false positives.
local function isLeftCommandDown(rawFlags)
  return hasFlag(rawFlags, rawFlagMasks.deviceLeftCommand)
    or (hasFlag(rawFlags, rawFlagMasks.command) and not hasFlag(rawFlags, rawFlagMasks.deviceRightCommand))
end

-- Posts a key-down + key-up pair for the given key code.
-- doAfter(0) defers posting until after the current event-tap callback returns,
-- avoiding re-entrancy issues with the flagsChanged handler.
local function sendKeyStroke(keyCodeToSend)
  timer.doAfter(0, function()
    event.newKeyEvent({}, keyCodeToSend, true):post()
    event.newKeyEvent({}, keyCodeToSend, false):post()
  end)
end

local commandState = {
  left = {
    isDown = false,
    wasUsed = false,
  },
  right = {
    isDown = false,
    wasUsed = false,
  },
}

-- Updates the tracked state for one Command key (left or right) and sends the
-- replacement key when the key is released without having been used as a modifier.
local function handleCommandChange(side, isDown, replacementKeyCode, rawFlags)
  local state = commandState[side]

  if isDown then
    if state.isDown then
      return
    end

    state.isDown = true
    state.wasUsed = hasAnyModifierExceptCommand(rawFlags)
    return
  end

  local shouldSendReplacement = state.isDown and not state.wasUsed
  state.isDown = false
  state.wasUsed = false

  if shouldSendReplacement then
    sendKeyStroke(replacementKeyCode)
  end
end

-- Marks any currently-held Command key as "used" so its solo-tap replacement
-- is suppressed. Called whenever a non-Command key is pressed.
local function markPressedCommandsAsUsed()
  if commandState.left.isDown then
    commandState.left.wasUsed = true
  end

  if commandState.right.isDown then
    commandState.right.wasUsed = true
  end
end

-- Handles flagsChanged events to track Command key press/release.
-- When both Command keys are held simultaneously, both are marked as used
-- so neither solo-tap replacement fires.
local function handleFlagsChanged(eventObject)
  local changedKeyCode = eventObject:getKeyCode()
  local rawFlags = eventObject:rawFlags()

  if changedKeyCode == keyCode.leftCommand then
    local isDown = isLeftCommandDown(rawFlags)

    if isDown and commandState.right.isDown then
      commandState.right.wasUsed = true
    end

    handleCommandChange("left", isDown, keyCode.jisEisu, rawFlags)

    if isDown and commandState.right.isDown then
      commandState.left.wasUsed = true
    end

    return
  end

  if changedKeyCode == keyCode.rightCommand then
    local isDown = hasFlag(rawFlags, rawFlagMasks.deviceRightCommand)

    if isDown and commandState.left.isDown then
      commandState.left.wasUsed = true
    end

    handleCommandChange("right", isDown, keyCode.jisKana, rawFlags)

    if isDown and commandState.left.isDown then
      commandState.right.wasUsed = true
    end

    return
  end

  markPressedCommandsAsUsed()
end

local function modifiersWithoutRightCommand(rawFlags)
  -- Right Command is the layer trigger; keep the other physical modifiers.
  local modifiers = {}

  for _, group in ipairs(modifierGroups) do
    appendModifier(modifiers, rawFlags, group[1], group[2])
  end

  if isLeftCommandDown(rawFlags) then
    table.insert(modifiers, "cmd")
  end

  return modifiers
end

-- Remaps right Command + h/j/k/l to arrow keys, preserving any other active
-- modifiers (e.g. shift for selection, cmd for word-level movement).
-- isKeyDown is passed in from the caller to avoid a redundant getType() call.
-- Returns false to pass the event through unchanged if the conditions are not met.
local function remapRightCommandHjkl(eventObject, isKeyDown)
  local arrowKey = arrowByKeyCode[eventObject:getKeyCode()]
  if arrowKey == nil then
    return false
  end

  local rawFlags = eventObject:rawFlags()
  if not hasFlag(rawFlags, rawFlagMasks.deviceRightCommand) then
    return false
  end

  local mappedEvent = event.newKeyEvent(modifiersWithoutRightCommand(rawFlags), arrowKey, isKeyDown)

  return true, { mappedEvent }
end

-- Top-level event-tap callback. Routes flagsChanged events to the Command-key
-- tracker and all other events to the hjkl remapper.
local function handleKeyboardEvent(eventObject)
  local eventType = eventObject:getType()

  if eventType == eventTypes.flagsChanged then
    handleFlagsChanged(eventObject)
    return false
  end

  if eventType == eventTypes.keyDown then
    markPressedCommandsAsUsed()
  end

  return remapRightCommandHjkl(eventObject, eventType == eventTypes.keyDown)
end

-- Keep a global reference so Hammerspoon does not garbage collect the event tap.
keyboardTap = eventtap.new({ eventTypes.flagsChanged, eventTypes.keyDown, eventTypes.keyUp }, handleKeyboardEvent):start()
