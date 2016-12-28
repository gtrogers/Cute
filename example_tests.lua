local cute = require("cute")

notion("Can compare numbers, strings, etc", function ()
  check(1).is(1)
  check("hello").is("hello")
end)

notion("Can compare tables", function ()
  check({1,2,3}).shallowMatches({1,2,3})
  check({one="two", three="four"}).shallowMatches({one="two", three="four"})
end)

tiles = function (g)
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
  tiles(cute.fakeGraphics())
  check(cute.graphicsCalls("rectangle")).is(1938)
end)

return {tiles=tiles}
