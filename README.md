# Cute
Micro unit testing for Love2d

## What?

Cute lets you [unit test](https://en.wikipedia.org/wiki/Unit_testing) your game code and provides a nice GUI for seeing the results in game.

You can also run the tests headlessly on a CI server if that's your jam.

## Installation

- Download `cute.lua` and add it to your your source code.
- Write some tests:
```lua
notion("Adding some numbers", function ()
  check(1 + 1).is(2) -- passes
  check(2 + 2).is(4) -- passes
  check(4 + 4).is(9) -- fails
end)
```
- Add `cute.go(args)` to love.load in your main.lua file (remember to require cute and your tests)
- Optionaly add `cute.draw()` and `cute.keypressed(key)` to your love.draw and love.keypressed functions (also in main.lua)
- Run your game with `path/to/love game_directory --cute` or `path/to/love game_directory --cute-headless`

## GUI Mode

By default GUI mode has the following controls:
- `h` hide the test results
- `j` scroll results up
- `k` scroll results down

The controls can be remapped with `cute.setKeys("hideKey","upKey","downKey")`

## Matchers

Cute currently has two matchers:
- `verify("something", a).is(b)` will test if a == b
- `verify("some table", {1,2,3}).matchesTable({1,2,3})` will check that table length and keys and values are the same for both tables
- ... more to come as I need them

## Fake Graphics

Cute provides a fake `love.graphics` object for spying on rendering. You are then able to check the number of call made to the fake graphics function. For example:

```lua
-- text box test

local textBox = {}

textBox.draw = function (graphics, x, y, text)
  graphics.print(text, x, y)
end

textBox.draw(cute.fakeGraphics(), 10, 10, "this is a test")

verify("Text is drawn once", cute.graphicsCall("print")).is(1) -- passes
```

## Future features

Let me know what you'd like or raise a pull request :)
