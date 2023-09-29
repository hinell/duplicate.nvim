## OVERVIEW
This plugin provides text duplication commands.

## INSTALL
Use your favorite package manager (Packer, Plug, Lazy.nvim etc.) 
```
"hinell/duplicate.nvim"
```

## API

Plugin exports the following user commands:
* `LineDuplicate [ <arg> ]` - Duplicates lines only
* `LinesDuplicate [ <arg> ]` - Duplicates visual blockwise chunks
* Where `<arg>: Number` - optional;
    * 0 - no action;
    * no value - duplicates 1 line downward by default
    * `N` - duplicates `N` line depending on the sign of the Number

### EXAMPLES
You can call commands directly in command pane: 
* `:LineDuplicate` - duplicate currently focused line downwards
* `:LineDuplicate 0` - no action
* `:LineDuplicate +2` - duplicate line 2 lines downwards
* `'<,'>:LinesDuplicate -5` - duplicate selection upwards 5 lines

### KEYBINDINGS

By default, **NO** keybindings are exported. Use [Legendary.nvim] 

```lua
-- The followng binds 
-- CTRL+SHIFT+ALT+<UP/DOWN> keymap
-- Sign of the number is mandatory
vim.keymap.set({ "n" }, "<C-S-A-Up>"   ,"<CMD>LineDuplicate -1<CR>")
vim.keymap.set({ "n" }, "<C-S-A-Down>" ,"<CMD>LineDuplicate +1<CR>")
```

#### LEGENDARY

It's advised to use [Legendary.nvim] plugin to config your keymaps.
You can use the following config to specify your own keymaps: 
```lua
local legendary = require("legendary")
legendary.keymaps({
    {
        description = "Line: duplicate up",
        mode = { "n" }, "<C-S-A-Up>"  , "<CMD>LineDuplicate -1<CR>"
    },
    {
        description = "Line: duplicate down"
        mode = { "n" }, "<C-S-A-Down>", "<CMD>LineDuplicate +1<CR>"
    },
    {
        description = "Selection: duplicate up"
        mode = { "v" }, "<C-S-A-Up>", "<CMD>VisualDuplicate -1<CR>"
    },
    {
        description = "Selection: duplicate down"
        mode = { "v" }, "<C-S-A-Down>", "<CMD>VisualDuplicate +1<CR>"
    },
    ...
})
```

[Legendary.nvim]: https://github.com/mrjones2014/legendary.nvim

##### ⚙️ CONFIGURATION
```lua

vim.g["duplicate-nvim-config"] = {
	visual = {
		selectAfter = true, -- do not select duplicated text
		block       = true  -- disable block-wise duplication
	}
}
```

----

September 24, 2023</br>
Copyright ©  - Alexander Davronov, et.al.</br>
