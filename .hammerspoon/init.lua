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

local function hasFlag(rawFlags, mask)
  return mask ~= nil and (rawFlags & mask) ~= 0
end

local function appendModifier(modifiers, rawFlags, modifier, masks)
  for _, mask in ipairs(masks) do
    if hasFlag(rawFlags, mask) then
      table.insert(modifiers, modifier)
      return
    end
  end
end

local function hasAnyModifierExceptCommand(rawFlags)
  return hasFlag(rawFlags, rawFlagMasks.shift)
    or hasFlag(rawFlags, rawFlagMasks.deviceLeftShift)
    or hasFlag(rawFlags, rawFlagMasks.deviceRightShift)
    or hasFlag(rawFlags, rawFlagMasks.alternate)
    or hasFlag(rawFlags, rawFlagMasks.deviceLeftAlternate)
    or hasFlag(rawFlags, rawFlagMasks.deviceRightAlternate)
    or hasFlag(rawFlags, rawFlagMasks.control)
    or hasFlag(rawFlags, rawFlagMasks.deviceLeftControl)
    or hasFlag(rawFlags, rawFlagMasks.deviceRightControl)
    or hasFlag(rawFlags, rawFlagMasks.secondaryFn)
end

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

local function markPressedCommandsAsUsed()
  if commandState.left.isDown then
    commandState.left.wasUsed = true
  end

  if commandState.right.isDown then
    commandState.right.wasUsed = true
  end
end

local function handleFlagsChanged(eventObject)
  local changedKeyCode = eventObject:getKeyCode()
  local rawFlags = eventObject:rawFlags()

  if changedKeyCode == keyCode.leftCommand then
    local isDown = hasFlag(rawFlags, rawFlagMasks.deviceLeftCommand)
      or (hasFlag(rawFlags, rawFlagMasks.command) and not hasFlag(rawFlags, rawFlagMasks.deviceRightCommand))

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

  appendModifier(modifiers, rawFlags, "shift", {
    rawFlagMasks.shift,
    rawFlagMasks.deviceLeftShift,
    rawFlagMasks.deviceRightShift,
  })

  appendModifier(modifiers, rawFlags, "alt", {
    rawFlagMasks.alternate,
    rawFlagMasks.deviceLeftAlternate,
    rawFlagMasks.deviceRightAlternate,
  })

  appendModifier(modifiers, rawFlags, "ctrl", {
    rawFlagMasks.control,
    rawFlagMasks.deviceLeftControl,
    rawFlagMasks.deviceRightControl,
  })

  if hasFlag(rawFlags, rawFlagMasks.deviceLeftCommand)
    or (hasFlag(rawFlags, rawFlagMasks.command) and not hasFlag(rawFlags, rawFlagMasks.deviceRightCommand)) then
    table.insert(modifiers, "cmd")
  end

  appendModifier(modifiers, rawFlags, "fn", {
    rawFlagMasks.secondaryFn,
  })

  return modifiers
end

local function remapRightCommandHjkl(eventObject)
  if eventObject:getType() == eventTypes.keyDown then
    markPressedCommandsAsUsed()
  end

  local arrowKey = arrowByKeyCode[eventObject:getKeyCode()]
  if arrowKey == nil then
    return false
  end

  local rawFlags = eventObject:rawFlags()
  if not hasFlag(rawFlags, rawFlagMasks.deviceRightCommand) then
    return false
  end

  local isKeyDown = eventObject:getType() == eventTypes.keyDown
  local mappedEvent = event.newKeyEvent(modifiersWithoutRightCommand(rawFlags), arrowKey, isKeyDown)

  return true, { mappedEvent }
end

local function handleKeyboardEvent(eventObject)
  if eventObject:getType() == eventTypes.flagsChanged then
    handleFlagsChanged(eventObject)
    return false
  end

  return remapRightCommandHjkl(eventObject)
end

-- Keep a global reference so Hammerspoon does not garbage collect the event tap.
keyboardTap = eventtap.new({ eventTypes.flagsChanged, eventTypes.keyDown, eventTypes.keyUp }, handleKeyboardEvent):start()
