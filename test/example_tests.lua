local cute = require("cute")
local shapes = require("src.shapes")

notion("Can compare numbers, strings, etc", function ()
  check(1).is(1)
  check("hello").is("hello")
end)

notion("Can compare tables", function ()
  check({1,2,3}).shallowMatches({1,2,3})
  check({one="two", three="four"}).shallowMatches({one="two", three="four"})
end)

local tiles = function (g)
  w = g.getWidth() / 16
  h = g.getHeight() / 16
  for i=0, w do
    for j=0, h do
      g.setColor(i*4 % 255, j*4 % 255, i*j*16 % 255)
      g.rectangle('fill', i*16, j*16, 16, 16)
    end
  end
end

notion("Can check things that draw", function ()
  minion("rectangleMinion", love.graphics, 'rectangle')
  minion("setColorMinion", love.graphics, 'setColor')

  shapes.tiles(love.graphics)

  check(report("rectangleMinion").calls).is(1938)
  check(report("setColorMinion").calls).is(1938)
  check(report("rectangleMinion").args[1][1]).is('fill')
end)

notion("Minions get reset after each call", function ()
  minion("setColorMinion", love.graphics, "setColor")
  minion("circleMinion", love.graphics, "circle")

  shapes.circle(100)

  check(report("setColorMinion").calls).is(1)
  check(report("circleMinion").args[1]).shallowMatches({"line", 400, 300, 0, 100})
end)

return {
  tiles=tiles,
  circle=circle
}
