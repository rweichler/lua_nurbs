# Lua NURBS

## Setup

### Prerequisites

* Mac OS X
* Xcode command line tools
* LuaJIT (`brew install luajit`)

### Building

`make`

### Running

`./a.out`

## How to use the program

### Cycling through the modes

Click the button in the top left corner of the screen. Or press `q`.

### Camera Mode

This is on by default. Square should be green.

So, the camera basically behaves like Doom. Use `wasd` to move, use the arrow keys to look around.

Press `r` to move up, and `f` to move down.

### Point manipulation mode

This is off by default. Square should be gray.

All of the points should be highlighted white, and one of them should be highlighted green.

Use `wasd` and `rf` to move the point around in 3D space. Use the arrow keys to change the highlighted point.

# The Console

This program heavily uses a lua console for manipulation. Press ~ (next to ESC and 1 on the keyboard) to open it. These are the commands you can type:

## Finding values

Let's say you want to know the x position of the selected point.

`return grid.selected_point.x`

## Setting values

Let's say you want to change the x position of the selected point.

`grid.selected_point.x = 5`

Then, have the grid re-evaluate itself:

`grid:eval()`

## Adding/deleting rows

Type these commmands. Insert `true` or `false` in the parentheses in order to add or delete from the opposite side.

`grid:delete_row()`

`grid:delete_column()`

`grid:add_row()`

`grid:add_column()`

## Changing the weights of the points

As per the instructions above, highlight green the point whose weight you want to change.

Then, open the console and type:

`grid.selected_point.weight = 12`

Replace 12 with whatever you want it to be.

Then type this to refresh the grid:

`grid:eval()`


## Changing the order

Change the value for `grid.column_order` and `grid.row_order`.
