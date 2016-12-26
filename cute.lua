local cute = {}


local _tests = {}
local _finishedTests = {}
local _shouldRun
local _headlessMode
local _state = "pending"
local _display = true
local _hideKey = "h"
local _upKey = "j"
local _downKey = "k"
local _offset = 0
local _x = 10
local _y = 10


-- private functions


local _formatFailed = function (test)
  love.graphics.setColor(225, 25, 25)
  return test.name .. " [FAILED] " .. tostring(test.testValue) .. " /= " .. test.refValue
end


local _formatPassed = function (test)
  love.graphics.setColor(245, 245, 245)
  return test.name
end


local _runAllTests = function ()
  _state = "passed"
  for i, test in ipairs(_tests) do
      test.passed = test.runTest()
      table.insert(_finishedTests, test)
      if not test.passed then
        _state = "failed"
      end
  end

  if _headlessMode then
    if _state == "failed" then os.exit(-1) end
    if _state == "passed" then os.exit() end
  end
end


-- Public functions


verify = function (name, testValue)
  local _is = function (refValue)
    table.insert(_tests, {
      runTest = function () return (testValue == refValue) end,
      name = name,
      refValue = refValue,
      testValue = testValue
    })
  end

  local _all = function (predicate)
    table.insert(_tests, {
      runTest = function ()
        local result = true
        for i, v in ipairs(testValue) do
          if not predicate(v) then
            result = false
            break
          end
        end
        return result
      end,
      name = name,
      refValue = "user supplied predicate",
      testValue = testValue
    })
  end

  return {
    is = _is,
    all = _all
  }
end


cute.go = function (args)
  for i, arg in ipairs(args) do
    if (arg == "--cute") then _shouldRun = true end
    if (arg == "--cute-headless") then
      _shouldRun = true
      _headlessMode = true
    end
  end

  if (_shouldRun) then _runAllTests() end
end


cute.draw = function ()
  if (_state == "pending" or not _display) then return end

  for i, test in ipairs(_finishedTests) do
    love.graphics.print(
      "Cute 0.0.1 Ran [".. #_finishedTests .. "] tests result: " .. _state,
      _x,_y
    )
    if (i > _offset) then
      if (test.passed) then
        love.graphics.print(_formatPassed(test), _x + 7, _y + 14*(i - _offset))
      else
        love.graphics.print(_formatFailed(test), _x + 7, _y + 14*(i - _offset))
      end
    end
  end
end


cute.keys = function (key)
  if key == _hideKey then
    _display = not _display
  end

  if key == _upKey and _offset > 0 then
    _offset = _offset - 1
  end

  if key == _downKey and _offset < #_finishedTests then
    _offset = _offset + 1
  end
end


cute.setKeys = function (hideKey, upKey, downKey)
  _hideKey = hideKey
  _upKey = upKey
  _downKey = downKey
end


cute.setResultsPosition = function (x,y)
  _x = x
  _y = y
end


return cute
