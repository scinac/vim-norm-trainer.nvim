# vim-norm-trainer.nvim

A game-like experience inside Neovim to master the power of the `:norm` (normal) command

REAL true vim users love `:norm`, `:norm`  is power, mastering it makes you insane get it

## Features

* **Progressive Levels**
* **Validation:** The game automatically detects when the buffer matches the target state
* **Buffer UI:** Displays instructions and the goal state directly in your workspace

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "scinac/vim-norm-trainer.nvim",
  lazy = false,
}
```

## How to use

After installing it just run the command `:NormGame` and it should open the buffer for level 1
