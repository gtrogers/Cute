# Cute
Embedded unit testing for Love2d

Now with Love 11 support.

## What?

Cute lets you write [unit tests](https://en.wikipedia.org/wiki/Unit_testing) for
your game code and run the tests inside of your game.

Cute is designed to be light weight, easy to use and focus on the minimum needed
set of features to be confident your code works.

You can also run the tests headlessly on a CI server if that's your jam.

You can find an example of some tests [here](https://github.com/gtrogers/Cute/blob/main/test/example_tests.lua)

## Current Features

- Simple test discovery
- 'Spy' on hard to test side effects (e.g. graphics calls)
- Display test results in an in-game GUI
- Can also be run as part of an automate build process with the `--cute-headless` flag

## What do tests look like?

```lua
local cute = require("cute")

notion("Foo is Zap", function ()
  local Foo = "Zap"
  check(Foo).is("Zap") -- passes
end)

notion("1000 circles get drawn", function ()
  minion("circle minion", love.graphics, circle)

  draw_circles(1000)

  check(report("circle minion").calls).is(1000)
end)
```

## How to use

- Download `cute.lua` and add it to your your source code.
- Add `cute.go(args)` to love.load in your main.lua file - [example](https://github.com/gtrogers/Cute/blob/main/main.lua)
- Optionaly add `cute.draw()` and `cute.keypressed(key)` to your love.draw and love.keypressed functions for sweet GUI action (also in main.lua)
- Run your game with `path/to/love game_directory --cute`
- Cute will detect and run any tests in the `test` directory and every subdirectory ending with `_tests.lua`

## GUI Mode

By default GUI mode has the following controls:
- `h` hide the test results
- `j` scroll results up
- `k` scroll results down

The controls can be remapped with `cute.setKeys("hideKey","upKey","downKey")`

## Matchers

Cute currently has two matchers:
- `check("something", a).is(b)` will test if a == b
- `check("some table", {1,2,3}).shallowMatches({1,2,3})` will check that table length and keys and values are the same for both tables

## Minions

You can temporarily intercept and record calls to functions. This is useful when you want to
test the result of drawing to the screen (or some other hard to test action).

You do this using minions...

```lua
local cute = require("cute")

notion("The circles are pink", function ()
  minion("color minion", love.graphics, setColor) -- creates a minion to inspect setColor

  draw_circles(1000)

  check(report("color minion").args).shallowMatches({255, 0, 255}) -- checks what the minion observed
end)
```

_Note: unlike Jasmine or Busted spies minions always call through to the function
they are inspecting._

## Future Features

Very happy to receive feature requests and pull requests. Currently adding features as I need them.
