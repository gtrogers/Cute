local cute = require("cute")
local shapes = require("src.shapes")

notion("Can execute tests in subfolders", function ()
  check("exterminate").is("exterminate")
end)
