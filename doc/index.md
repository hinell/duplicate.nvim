## OVERVIEW
This plugin provides text duplication commands.

## INSTALL
Use your favorite package manager (Packer, Plug, Lazy.nvim etc.) 
```
"hinell/duplicate.nvim"
```

## UPDATE

You may want to reinstall this plugin manually, because of specific dev-apprach:
repo of this plugin may be force-rebased, rendering all previous commits obsolete.

## API

```lua
-- init.lua
local config  = require("duplicate.config")
local editor  = require("duplicate.editor")
local duplicatedRange = editor:duplicateByOffset(5, config)
      editor:selectVisual(duplicatedRange)

```

## COMMANDS

Plugin exports the following user commands:

* *:LineDuplicate* <arg> - Duplicate linewise 
* *:VisualDuplicate* <arg> - Charwise, linewise, and blockwise duplication 
* Where `<arg>: Number` - an offset to put duplicated lines at;
* * `0` - no action;
* * `<empty>` - error in cmd 
* * `-1` - duplicates 1 line upward; relateive to the top of the selection; 
* * `+1` - duplicates 1 line downward; relative to the bottom of selection
* * `N` - duplicates `N` lines up/downard depending on the sign of the Number;
 duplicated text is always put relative to the nearest cursor relative to the offset.

### EXAMPLES
You can call commands directly in command pane: 
* `:LineDuplicate` - duplicate currently focused line downwards
* `:LineDuplicate 0` - no action
* `:LineDuplicate +2` - duplicate line 2 lines downwards
* `'<,'>:VisualDuplicate -5` - duplicate selection upwards 5 lines from the top of the selection 
* `'<,'>:VisualDuplicate +3` - same, but 3 lines from the bottom of the selection 

### KEYBINDINGS

By default, **NO** keybindings are set up.

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
        description = "Line: duplicate down",
        mode = { "n" }, "<C-S-A-Down>", "<CMD>LineDuplicate +1<CR>"
    },
    {
        description = "Selection: duplicate up",
        mode = { "v" }, "<C-S-A-Up>", "<CMD>VisualDuplicate -1<CR>"
    },
    {
        description = "Selection: duplicate down",
        mode = { "v" }, "<C-S-A-Down>", "<CMD>VisualDuplicate +1<CR>"
    }
})
```

[Legendary.nvim]: https://github.com/mrjones2014/legendary.nvim

#### ⚙️ CONFIGURATION
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
