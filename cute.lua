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
local foundFailingTest = false
local testLocation = "test"

local tests = {}
local focusTests = {}

local stringEnds = function(s, _end)
   return _end == '' or string.sub(s,-string.len(_end)) == _end
end

local addTests = function (files, currentPath)
  for i, f in ipairs(files) do
    local file = currentPath .. "/" .. f
    if stringEnds(f, "_tests.lua") then
      local chunk = love.filesystem.load(file)
      chunk()
    end
  end
end

local discover = function()
  local dir = love.filesystem.getDirectoryItems(testLocation)
  addTests(dir, testLocation)
end

local getTests = function ()
  local testsToRun
  if #focusTests > 0 then
    testsToRun = focusTests
  else
    testsToRun = tests
  end
  return testsToRun
end

local runAllTests = function (headlessMode)
  for i, test in ipairs(getTests()) do
    passed, errorMsg = pcall(test.run)
    if (not passed) then
      foundFailingTest = true
      test.errorMsg = errorMsg
      if headlessMode then
        print("Test Failed! " .. tostring(errorMsg))
        os.exit(-1)
      end
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
    if (key == downKey and offset < #getTests()) then offset = offset + 1 end
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

  if foundFailingTest then
    _setColour('red', g)
  else
    _setColour('green', g)
  end
  g.rectangle('fill', padding, padding, w - padding*2, padding)
  _setColour('black', g)
  g.printf('Cute ' .. version .. "- [h] hide [j] scroll up [k] scroll down",
    padding,
    padding + 1,
    w - padding*2,
    'center')
end

local _drawLine = function(g, i, offset, test)
  if test.focused then
    msg = "FOCUSED "
  else
    msg = ""
  end
  if test.passed then
    _setColour("black", g)
    msg = msg .. "Passed: " .. test.title
  else
    _setColour("red", g)
    msg = msg .. "Failed: " .. test.title .. " - " .. tostring(test.errorMsg)
  end
  g.print(msg, padding + margin, (padding * 1.5) + margin * 2 + (i - 1 - offset)*14)
end

local _drawResults = function(g, w, h)
  for i, test in ipairs(getTests()) do
    local msg
    if offset == #getTests() then break end
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

f_notion = function (title, testMethod)
  table.insert(focusTests, {
    title=title,
    run=testMethod,
    focused=true
  })
end


x_notion = function (title, testMethod)
  -- do nothing
end

local _is = function (testVal, refVal)
  if type(testVal) == "table" or type(refVal) == "table" then
    error("Can't compare tables with .is try .matchesTable")
  end
  if testVal ~= refVal then error(
    tostring(testVal) .. " ~= " .. tostring(refVal), 3) end
  return true
end

local _shallowMatches = function (testTable, refTable)
  if #testTable ~= #refTable then
    error("Tables are different sizes", 3)
  end

  for k, item in pairs(testTable) do
    if item ~= refTable[k] then
      error("Mismatch for element with key " .. tostring(k) ..
            ": " .. tostring(item) .. " ~= " ..
            tostring(refTable[k]), 3)
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
  local shouldGo = true
  local headless = false
  for i, arg in ipairs(args) do
    if arg == "--cute" then
      shouldGo = true
    end
    if arg == "--cute-headless" then
      headless = true
    end
  end

  if shouldGo then
    discover()
    runAllTests(headless)
  else
    enabled = false
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
