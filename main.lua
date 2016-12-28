local cute = require("cute")

notion("Can compare numbers, strings, etc", function ()
  check(1).is(1)
  check("hello").is("hello")
end)

notion("Can compare tables", function ()
  check({1,2,3}).shallowMatches({1,2,3})
  check({one="two", three="four"}).shallowMatches({one="two", three="four"})
end)

love.load = function (args)
  cute.go(args)
end

love.draw = function ()
  cute.draw(love.graphics)
end

love.keypressed = function (key)
  cute.keypressed(key)
end
