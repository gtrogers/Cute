local cute = require("cute")
local shapes = require("src.shapes")

love.load = function (args)
  cute.go(args)
end

local _dt = 0

love.update = function (dt)
  _dt = _dt + dt
end

love.draw = function (dt)
  shapes.tiles(love.graphics)
  shapes.circle(_dt % 100)
  cute.draw(love.graphics)
end

love.keypressed = function (key)
  cute.keypressed(key)
end
