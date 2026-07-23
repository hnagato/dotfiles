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
KeyboardTap = eventtap.new({ eventTypes.flagsChanged, eventTypes.keyDown, eventTypes.keyUp }, handleKeyboardEvent):start()

-- -- Three-finger trackpad swipe gestures.
-- -- macOS has no dedicated swipe API, so we subscribe to raw gesture events and
-- -- follow a single trackpad touch to infer a swipe direction, then send the
-- -- mapped keystroke (left/right = previous/next tab, down = close tab).
-- --
-- -- During a real three-finger swipe the reported touch count fluctuates (resting
-- -- thumb, transient extra contacts), so we latch onto one finger by identity when
-- -- at least three fingers are down and keep tracking it until every finger lifts.
-- -- Left/right fire once per stroke and again on a reversal (so a back-and-forth
-- -- swipe switches tabs repeatedly); the destructive down swipe fires only once per
-- -- gesture.
-- --
-- -- Note: the gesture event tap only reads touches; it cannot swallow the OS-level
-- -- three-finger gestures. Disable or remap the conflicting system gestures
-- -- (Trackpad > More Gestures) to avoid double activation.
-- local swipeMinFingers = 3
--
-- -- Maximum number of fingers allowed for a swipe. Four or more simultaneous
-- -- contacts indicate a different gesture (e.g. a four-finger pinch), whose inward
-- -- motion would otherwise be misread as a downward swipe. Tracking is never
-- -- latched while more fingers are down, and an in-progress swipe is cancelled the
-- -- moment the count exceeds this limit.
-- local swipeMaxFingers = 3
--
-- -- Minimum travel of the tracked finger (in normalized 0..1 units) before a swipe
-- -- fires. Three-finger swipes register as quick flicks and macOS throttles touch
-- -- updates once it recognizes the gesture, so the observable travel is small.
-- local swipeThreshold = 0.05
--
-- -- Short debounce after a fire, purely to absorb jitter at a direction reversal.
-- -- Horizontal repeats are gated by direction change (see lastDir), not by time,
-- -- so this can stay small for responsive back-and-forth swiping.
-- local swipeCooldown = 0.05
--
-- -- Three-finger tap -> Command+left-click. A tap is the same three-finger contact
-- -- as a swipe but released quickly without meaningful travel, so it is detected at
-- -- finger-release time when no swipe has fired.
-- --
-- -- Maximum travel (normalized 0..1) of the tracked finger for the gesture to still
-- -- count as a tap. Kept below swipeThreshold so a swipe never also fires a tap.
-- local tapMaxMovement = 0.02
--
-- -- Maximum time from three fingers landing to all fingers lifting for a tap.
-- local tapMaxDuration = 0.3
--
-- -- Per-gesture state. trackedId follows one finger across callbacks; lastDir is the
-- -- last horizontal direction fired so a single stroke fires once and only a
-- -- reversal fires again; downFired keeps the destructive cmd+w to once per gesture.
-- local swipeState = {
--   tracking = false,
--   trackedId = nil,
--   startX = 0,
--   startY = 0,
--   lastFireTime = 0,
--   lastDir = nil,
--   downFired = false,
--   -- Tap detection: when the gesture started and the tracked finger's latest
--   -- position, used to decide at release time whether it was a tap.
--   gestureStartTime = 0,
--   swipeFired = false,
--   lastX = 0,
--   lastY = 0,
--   -- Set when too many fingers are detected (see swipeMaxFingers); blocks
--   -- re-latching until every finger lifts so a pinch shrinking from 4 to 3
--   -- fingers does not get picked up as a swipe.
--   blockedUntilRelease = false,
-- }
--
-- -- Swipe direction -> keystroke. normalizedPosition.y increases upward, so a
-- -- top-to-bottom swipe decreases y.
-- local function sendSwipeKey(direction)
--   if direction == "left" then
--     eventtap.keyStroke({ "shift", "cmd" }, "[", 0)
--   elseif direction == "right" then
--     eventtap.keyStroke({ "shift", "cmd" }, "]", 0)
--   elseif direction == "down" then
--     eventtap.keyStroke({ "cmd" }, "w", 0)
--   end
-- end
--
-- -- Sends a Command+left-click at the current pointer location for a three-finger
-- -- tap. Deferred with doAfter(0) to avoid posting from inside the event-tap
-- -- callback, mirroring sendKeyStroke.
-- local function sendCommandClick()
--   timer.doAfter(0, function()
--     local position = hs.mouse.absolutePosition()
--     event.newMouseEvent(eventTypes.leftMouseDown, position, { "cmd" }):post()
--     event.newMouseEvent(eventTypes.leftMouseUp, position, { "cmd" }):post()
--   end)
-- end
--
-- -- Counts fingers that are actively touching the trackpad.
-- local function countTouches(touches)
--   local count = 0
--   for _, touch in ipairs(touches) do
--     if touch.touching and touch.normalizedPosition ~= nil then
--       count = count + 1
--     end
--   end
--   return count
-- end
--
-- -- Returns the identity and position of the first actively-touching finger.
-- local function firstTouching(touches)
--   for _, touch in ipairs(touches) do
--     if touch.touching and touch.normalizedPosition ~= nil then
--       return touch.identity, touch.normalizedPosition
--     end
--   end
--   return nil, nil
-- end
--
-- -- Finds a touch by its identity, or nil if that finger is no longer reported.
-- local function findTouch(touches, identity)
--   for _, touch in ipairs(touches) do
--     if touch.identity == identity then
--       return touch
--     end
--   end
--   return nil
-- end
--
-- -- Resets the swipe tracking state between gestures.
-- local function resetSwipeState()
--   swipeState.tracking = false
--   swipeState.trackedId = nil
--   swipeState.lastFireTime = 0
--   swipeState.lastDir = nil
--   swipeState.downFired = false
--   swipeState.gestureStartTime = 0
--   swipeState.swipeFired = false
--   swipeState.lastX = 0
--   swipeState.lastY = 0
--   swipeState.blockedUntilRelease = false
-- end
--
-- -- Fires a Command+click if the just-ended gesture qualifies as a three-finger
-- -- tap: a swipe never fired, the tracked finger barely moved, and the gesture was
-- -- short. Called when all fingers lift, before the state is reset.
-- local function maybeFireTap()
--   if not swipeState.tracking or swipeState.swipeFired then
--     return
--   end
--
--   local movement = math.max(
--     math.abs(swipeState.lastX - swipeState.startX),
--     math.abs(swipeState.lastY - swipeState.startY)
--   )
--   local duration = timer.secondsSinceEpoch() - swipeState.gestureStartTime
--
--   if movement <= tapMaxMovement and duration <= tapMaxDuration then
--     sendCommandClick()
--   end
-- end
--
-- -- Handles gesture events: latches onto one finger once at least three are down,
-- -- fires the mapped keystroke when the tracked finger crosses the threshold on the
-- -- dominant axis, and resets once every finger has lifted.
-- local function handleGesture(eventObject)
--   local touches = eventObject:getTouches()
--   if touches == nil then
--     return false
--   end
--
--   -- Gesture events also fire for non-touch gestures (momentum, magnify, etc.)
--   -- with an empty touch table. Ignore those without resetting, otherwise they
--   -- would constantly clear the swipe start mid-gesture.
--   if #touches == 0 then
--     return false
--   end
--
--   local count = countTouches(touches)
--
--   if count == 0 then
--     maybeFireTap()
--     resetSwipeState()
--     return false
--   end
--
--   -- Too many fingers: this is not a swipe (e.g. a four-finger pinch). Abort any
--   -- in-progress tracking and block re-latching until every finger lifts.
--   if count > swipeMaxFingers then
--     swipeState.tracking = false
--     swipeState.trackedId = nil
--     swipeState.blockedUntilRelease = true
--     return false
--   end
--
--   if swipeState.blockedUntilRelease then
--     return false
--   end
--
--   -- Too few fingers while a gesture is in progress: a finger lifted mid-swipe.
--   -- Block re-latching until every finger lifts, while preserving tracking so the
--   -- release path can still decide whether the gesture was a tap.
--   if swipeState.tracking and count < swipeMinFingers then
--     swipeState.blockedUntilRelease = true
--     return false
--   end
--
--   if not swipeState.tracking then
--     if count >= swipeMinFingers then
--       local identity, position = firstTouching(touches)
--       if identity ~= nil then
--         swipeState.tracking = true
--         swipeState.trackedId = identity
--         swipeState.startX = position.x
--         swipeState.startY = position.y
--         swipeState.lastX = position.x
--         swipeState.lastY = position.y
--         swipeState.lastFireTime = 0
--         swipeState.lastDir = nil
--         swipeState.downFired = false
--         swipeState.gestureStartTime = timer.secondsSinceEpoch()
--         swipeState.swipeFired = false
--       end
--     end
--     return false
--   end
--
--   local trackedTouch = findTouch(touches, swipeState.trackedId)
--   if trackedTouch == nil or trackedTouch.normalizedPosition == nil then
--     return false
--   end
--
--   swipeState.lastX = trackedTouch.normalizedPosition.x
--   swipeState.lastY = trackedTouch.normalizedPosition.y
--
--   local deltaX = trackedTouch.normalizedPosition.x - swipeState.startX
--   local deltaY = trackedTouch.normalizedPosition.y - swipeState.startY
--
--   if timer.secondsSinceEpoch() - swipeState.lastFireTime < swipeCooldown then
--     return false
--   end
--
--   local currentX = trackedTouch.normalizedPosition.x
--   local currentY = trackedTouch.normalizedPosition.y
--
--   local direction = nil
--   if math.abs(deltaX) >= math.abs(deltaY) then
--     if math.abs(deltaX) >= swipeThreshold then
--       direction = deltaX < 0 and "left" or "right"
--     end
--   elseif deltaY <= -swipeThreshold then
--     direction = "down"
--   end
--
--   -- The downward swipe sends cmd+w (close tab), which is destructive, so it may
--   -- only fire once per gesture.
--   if direction == "down" and swipeState.downFired then
--     direction = nil
--   end
--
--   -- Left/right fire once per stroke. While the finger keeps moving the same way
--   -- past the threshold, trail the reference position instead of firing again so a
--   -- single stroke is one tab move; a reversal is then measured from the turning
--   -- point and fires the opposite direction.
--   if (direction == "left" or direction == "right") and direction == swipeState.lastDir then
--     swipeState.startX = currentX
--     swipeState.startY = currentY
--     direction = nil
--   end
--
--   if direction ~= nil then
--     sendSwipeKey(direction)
--     swipeState.swipeFired = true
--     if direction == "down" then
--       swipeState.downFired = true
--     else
--       swipeState.lastDir = direction
--     end
--     -- Re-latch the start at the current position so the next stroke is measured
--     -- fresh, allowing back-and-forth swipes without lifting the fingers.
--     swipeState.startX = currentX
--     swipeState.startY = currentY
--     swipeState.lastFireTime = timer.secondsSinceEpoch()
--   end
--
--   return false
-- end
--
-- -- Keep a global reference so Hammerspoon does not garbage collect the event tap.
-- GestureTap = eventtap.new({ eventTypes.gesture }, handleGesture):start()
