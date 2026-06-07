local touchdevice = require("hs._asm.undocumented.touchdevice")
local mouse = require("hs.mouse")

local mouseEventTypes = hs.eventtap.event.types

local swipeBindings = {
  left = { modifiers = { "shift", "cmd" }, key = "[" },
  right = { modifiers = { "shift", "cmd" }, key = "]" },
  down = { modifiers = { "cmd" }, key = "w" },
}

local swipeThresholds = {
  horizontal = 0.12,
  vertical = 0.16,
}

local tapThresholds = {
  duration = 0.35,
  movement = 0.025,
}

local swipeState = {
  touchIds = nil,
  startX = nil,
  startY = nil,
  fired = false,
}

local tapState = {
  touchIds = nil,
  startX = nil,
  startY = nil,
  endX = nil,
  endY = nil,
  startTime = nil,
  cancelled = false,
}

local function resetSwipeState()
  swipeState.touchIds = nil
  swipeState.startX = nil
  swipeState.startY = nil
  swipeState.fired = false
end

local function resetTapState()
  tapState.touchIds = nil
  tapState.startX = nil
  tapState.startY = nil
  tapState.endX = nil
  tapState.endY = nil
  tapState.startTime = nil
  tapState.cancelled = false
end

local function isActiveTouch(touch)
  local stage = touch.stage
  return touch.normalizedVector
    and touch.normalizedVector.position
    and stage ~= "breakTouch"
    and stage ~= "outOfRange"
    and stage ~= "notTracking"
end

local function centroid(touches)
  local x = 0
  local y = 0

  for _, touch in ipairs(touches) do
    x = x + touch.normalizedVector.position.x
    y = y + touch.normalizedVector.position.y
  end

  return x / #touches, y / #touches
end

local function activeTouches(touches)
  local filteredTouches = {}

  for _, touch in ipairs(touches) do
    if isActiveTouch(touch) then
      table.insert(filteredTouches, touch)
    end
  end

  return filteredTouches
end

local function sameTouches(touchIds, touches)
  if not touchIds then
    return false
  end

  local count = 0
  for _, touch in ipairs(touches) do
    if not touchIds[touch.pathIndex] then
      return false
    end
    count = count + 1
  end

  return count == 3
end

local function touchIdsFor(touches)
  local touchIds = {}
  for _, touch in ipairs(touches) do
    touchIds[touch.pathIndex] = true
  end

  return touchIds
end

local function beginSwipe(touches)
  local startX, startY = centroid(touches)

  swipeState.touchIds = touchIdsFor(touches)

  swipeState.startX = startX
  swipeState.startY = startY
  swipeState.fired = false
end

local function beginTap(touches, now)
  local startX, startY = centroid(touches)

  tapState.touchIds = touchIdsFor(touches)
  tapState.startX = startX
  tapState.startY = startY
  tapState.endX = startX
  tapState.endY = startY
  tapState.startTime = now
  tapState.cancelled = false
end

local function cancelTap()
  if tapState.touchIds then
    tapState.cancelled = true
  end
end

local function triggerBinding(direction)
  local binding = swipeBindings[direction]
  if not binding then
    return
  end

  hs.timer.doAfter(0, function()
    hs.eventtap.keyStroke(binding.modifiers, binding.key, 0)
  end)
end

local function triggerCommandTap()
  local position = mouse.absolutePosition()

  hs.timer.doAfter(0, function()
    hs.eventtap.event.newMouseEvent(mouseEventTypes.leftMouseDown, position, { "cmd" }):post()
    hs.eventtap.event.newMouseEvent(mouseEventTypes.leftMouseUp, position, { "cmd" }):post()
  end)
end

local function finalizeTap(now)
  if not tapState.touchIds or tapState.cancelled then
    return
  end

  local duration = now - tapState.startTime
  local deltaX = tapState.endX - tapState.startX
  local deltaY = tapState.endY - tapState.startY
  local movement = math.abs(deltaX) + math.abs(deltaY)

  if duration <= tapThresholds.duration and movement <= tapThresholds.movement then
    triggerCommandTap()
  end
end

local function handleTouches(_, touches)
  local now = hs.timer.secondsSinceEpoch()
  local currentTouches = activeTouches(touches)

  if #currentTouches == 0 then
    finalizeTap(now)
    resetSwipeState()
    resetTapState()
    return
  end

  if #currentTouches < 3 then
    finalizeTap(now)
    resetSwipeState()
    resetTapState()
    return
  end

  if #currentTouches > 3 then
    cancelTap()
    resetSwipeState()
    return
  end

  if not sameTouches(tapState.touchIds, currentTouches) then
    beginTap(currentTouches, now)
  elseif not tapState.cancelled then
    local endX, endY = centroid(currentTouches)
    local duration = now - tapState.startTime
    local movement = math.abs(endX - tapState.startX) + math.abs(endY - tapState.startY)

    tapState.endX = endX
    tapState.endY = endY

    if duration > tapThresholds.duration or movement > tapThresholds.movement then
      tapState.cancelled = true
    end
  end

  if not sameTouches(swipeState.touchIds, currentTouches) then
    beginSwipe(currentTouches)
    return
  end

  if swipeState.fired then
    return
  end

  local currentX, currentY = centroid(currentTouches)
  local deltaX = currentX - swipeState.startX
  local deltaY = currentY - swipeState.startY
  local absX = math.abs(deltaX)
  local absY = math.abs(deltaY)

  if absX >= swipeThresholds.horizontal and absX > absY * 1.25 then
    triggerBinding(deltaX < 0 and "left" or "right")
    swipeState.fired = true
    cancelTap()
  elseif deltaY <= -swipeThresholds.vertical and absY > absX * 1.25 then
    triggerBinding("down")
    swipeState.fired = true
    cancelTap()
  end
end

local function selectTrackpad()
  for _, deviceId in ipairs(touchdevice.devices()) do
    local device = touchdevice.forDeviceID(deviceId)
    if device and device:builtin() then
      return device
    end
  end

  return touchdevice.default()
end

local trackpad = assert(selectTrackpad(), "No multi-touch trackpad found")
local swipeWatcher = trackpad:frameCallback(handleTouches)
swipeWatcher:start()
