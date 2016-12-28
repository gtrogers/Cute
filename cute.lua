local cute = {}
local version = "0.1.0"
local padding = 16
local margin = 8
local show = true
local enabled = true
local hideKey = "h"
local downKey = "j"
local upKey = "k"
local offset = 0

local tests = {}

local runAllTests = function (headlessMode)
  for i, test in ipairs(tests) do
    passed, errorMsg = pcall(test.run)
    if (not passed) then
      test.errorMsg = errorMsg
      if headlessMode then os.exit(-1) end
    else
      test.passed = true
    end
  end

  if headlessMode then os.exit(0) end
end

-- controls

local keypressed = function (key)
  if not enabled then return end

  if key == hideKey then show = not show end

  if show then
    if (key == downKey and offset < #tests) then offset = offset + 1 end
    if (key == upKey and offset > 0) then offset = offset - 1 end
  end
end

-- drawing functions

local _setColour = function (colour, g)
  local colours = {
    green = {122,158,53},
    black = {45,45,45},
    red = {170, 57, 57},
    lightGrey = {238,238,238, 200}
  }

  g.setColor(unpack(colours[colour]))
end

local _drawResultsBox = function(g, w, h)
  _setColour('lightGrey', g)
  g.rectangle('fill', padding, padding, w - padding*2, h - padding*2)

  _setColour('green', g)
  g.rectangle('fill', padding, padding, w - padding*2, padding)
  _setColour('black', g)
  g.printf('Cute ' .. version .. "- [h] hide [j] scroll up [k] scroll down",
    padding,
    padding + 1,
    w - padding*2,
    'center')
end

local _drawLine = function(g, i, offset, test)
  if test.passed then
    _setColour("black", g)
    msg = "Passed: " .. test.title
  else
    _setColour("red", g)
    msg = "Failed: " .. test.title .. " - " .. test.errorMsg
  end
  g.print(msg, padding + margin, (padding * 1.5) + margin * 2 + (i - 1 - offset)*14)
end

local _drawResults = function(g, w, h)
  for i, test in ipairs(tests) do
    local msg
    if offset == #tests then break end
    if i > offset then
      _drawLine(g, i, offset, test)
    end
  end
end

local display = function (g)
  if not show then return end
  if not enabled then return end

  local w = g.getWidth()
  local h = g.getHeight()

  g.push('all')
  _drawResultsBox(g, w, h)
  _drawResults(g, w, h)
  g.pop()
end

-- Testing functions

notion = function (title, testMethod)
  table.insert(tests, {
    title=title,
    run=testMethod
  })
end

local _is = function (testVal, refVal)
  if type(testVal) == "table" or type(refVal) == "table" then
    error("Can't compare tables with .is try .matchesTable")
  end
  if testVal ~= refVal then error(testVal .. " ~= " .. refVal, 3) end
  return true
end

local _shallowMatches = function (testTable, refTable)
  if #testTable ~= #refTable then
    error("Tables are different sizes", 3)
  end

  for k, item in pairs(testTable) do
    if item ~= refTable[k] then
      error("Mismatch for element with key " .. k ..
            ": " .. item .. " ~= " ..
            refTable[k], 3)
    end
  end

  return true
end

check = function (testVal)
  return {
    is = function (refVal) _is(testVal, refVal) end,
    shallowMatches = function (refTable) _shallowMatches(testVal, refTable) end
  }
end

-- options and running

cute.go = function (args)
  for i, arg in ipairs(args) do
    if arg == "--cute" then
      enabled = true
      runAllTests(false)
      break
    end
    if arg == "--cute-headless" then
      runAllTests(true)
    end
  end
end

cute.draw = function () display(love.graphics) end
cute.keypressed = keypressed
cute.setKeys = function (hide, down, up)
  hideKey = hide
  downKey = down
  upKey = up
end

-- fakeGraphics
local callCounts = {}
local fakes = {}

local countCall = function (funcName)
  if not callCounts[funcName] then
    callCounts[funcName] = 1
  else
    callCounts[funcName] = callCounts[funcName] + 1
  end
end

cute.fakeGraphics = function ()
  callCounts = {}
  fakes = {}
  for funcName, f in pairs(love.graphics) do
    if string.sub(funcName, 1, 3) == "get" then
      fakes[funcName] = f
    else
      fakes[funcName] = function (...) countCall(funcName) end
    end
  end

  return fakes
end

cute.graphicsCalls = function(funcName)
  if callCounts[funcName] == nil then return 0 end
  return callCounts[funcName]
end

return cute
