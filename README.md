https://github.com/hinell/duplicate.nvim/assets/8136158/d136146f-fb84-4a66-9a04-6152e49d411a

<div align="center">
  <h1 align="center">🔌  duplicate.nvim</h2>
</div>

<!-- Use badges from https://shields.io/badges/ -->
[![PayPal](https://img.shields.io/badge/-PayPal-880088?style=flat-square&logo=pay&logoColor=white&label=DONATE)](https://www.paypal.me/biteofpie)
[![License](https://img.shields.io/badge/FOSSIL-007744?style=flat-square&label=LICENSE)](https://github.com/hinell/fossil-license)

> _Duplicate visual selection & lines_

## ⚡Features

- Duplicate lines in different directions (up/down) by specified offset 
- Duplicate visual selection & line-wise blocks

## 🔒Requirements

- [Neovim 0.8+](https://github.com/neovim/neovim/releases)

## 📦 Installation

#### [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
packer.setup(function(use)
    use({
        "hinell/duplicate.nvim",
        setup = function()
            vim.g["duplicate-nvim-config"] = {
                visual = {
                    selectAfter = true, -- true to select duplicated text
                    block       = true  -- true to enable block-wise duplication
                }
            }
        end
    })
end)
```

#### [lazy.vim](https://github.com/folke/lazy.nvim)
```lua
require("lazy").setup(
    { "hinell/duplicate.nvim" },
	dependencies={ }
)
```

#### [vim-plug](https://github.com/junegunn/vim-plug)
``` vim
Plug "hinell/duplicate.nvim"
```

<!-- ### CREDITS -->
### [DOCUMENTATION]

[DOCUMENTATION]: doc/index.md
### [CONTRIBUTING]

[CONTRIBUTING]: CONTRIBUTING.md 'Devloper documentation (see also source code files)'
[d]: #project

### SUPPORT DISCLAIMER
[ps]: #production-status--support 'Production use disclaimer & support info'

_NO GUARANTEES UNTIL PAID. This project is supported and provided AS IS. See also [LICENSE]._



## SEE ALSO
* [hinell/move.nvim](https://github.com/hinell/move.nvim) - move chunks of text around; fork
* [@smjonas/duplicate.nvim](https://github.com/smjonas/duplicate.nvim) - archived
* [echasnovski/mini.nvim](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-operators.md)
* [booperlv/nvim-gomove](https://github.com/booperlv/nvim-gomove) - both move & duplicate chunks of text; poor commands

[LICENSE]: LICENSE

----

September 29, 2023</br>
Copyright ©  - Alexander Davronov (a.k.a Hinell), et.al.</br>
