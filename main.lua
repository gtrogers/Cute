local cute = require("cute")
local tests = require("example_tests")

love.load = function (args)
  cute.go(args)
end

love.draw = function ()
  tests.tiles(love.graphics)
  cute.draw(love.graphics)
end

love.keypressed = function (key)
  cute.keypressed(key)
end
