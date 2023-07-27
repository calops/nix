# calops's neovim config

<a href="https://dotfyle.com/calops/nix-programs-cli-neovim-config"><img src="https://dotfyle.com/calops/nix-programs-cli-neovim-config/badges/plugins?style=flat" /></a>
<a href="https://dotfyle.com/calops/nix-programs-cli-neovim-config"><img src="https://dotfyle.com/calops/nix-programs-cli-neovim-config/badges/leaderkey?style=flat" /></a>
<a href="https://dotfyle.com/calops/nix-programs-cli-neovim-config"><img src="https://dotfyle.com/calops/nix-programs-cli-neovim-config/badges/plugin-manager?style=flat" /></a>


## Install Instructions
> ℹ️ This configuration is designed to be installed through nix (which is why the `lazy-lock.json` file is weirdly located), but should be useable stand-alone with the following instructions.

> ⚠️ Install requires Neovim 0.9+. Always review the code before installing a configuration.

Clone the repository and install the plugins:

```sh
git clone git@github.com:calops/nix ~/.config/calops/nix
cp ~/.config/calops/nix/programs/cli/neovim/lazy-lock.json ~/.config/calops/nix/programs/cli/neovim/config
NVIM_APPNAME=calops/nix/programs/cli/neovim/config nvim --headless +Lazy! sync +qa
```

Open Neovim with this config:

```sh
NVIM_APPNAME=calops/nix/programs/cli/neovim/config nvim
```

## Plugins

### bars-and-lines

+ [Bekaboo/dropbar.nvim](https://dotfyle.com/plugins/Bekaboo/dropbar.nvim)
### color

+ [echasnovski/mini.hipatterns](https://dotfyle.com/plugins/echasnovski/mini.hipatterns)
### colorscheme

+ [catppuccin/nvim](https://dotfyle.com/plugins/catppuccin/nvim)
### comment

+ [echasnovski/mini.comment](https://dotfyle.com/plugins/echasnovski/mini.comment)
+ [JoosepAlviste/nvim-ts-context-commentstring](https://dotfyle.com/plugins/JoosepAlviste/nvim-ts-context-commentstring)
### completion

+ [zbirenbaum/copilot.lua](https://dotfyle.com/plugins/zbirenbaum/copilot.lua)
+ [simrat39/rust-tools.nvim](https://dotfyle.com/plugins/simrat39/rust-tools.nvim)
+ [hrsh7th/nvim-cmp](https://dotfyle.com/plugins/hrsh7th/nvim-cmp)
### cursorline

+ [RRethy/vim-illuminate](https://dotfyle.com/plugins/RRethy/vim-illuminate)
### debugging

+ [andrewferrier/debugprint.nvim](https://dotfyle.com/plugins/andrewferrier/debugprint.nvim)
### diagnostics

+ [folke/trouble.nvim](https://dotfyle.com/plugins/folke/trouble.nvim)
### editing-support

+ [echasnovski/mini.move](https://dotfyle.com/plugins/echasnovski/mini.move)
+ [nvim-treesitter/nvim-treesitter-context](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter-context)
+ [Wansmer/treesj](https://dotfyle.com/plugins/Wansmer/treesj)
### file-explorer

+ [stevearc/oil.nvim](https://dotfyle.com/plugins/stevearc/oil.nvim)
+ [nvim-neo-tree/neo-tree.nvim](https://dotfyle.com/plugins/nvim-neo-tree/neo-tree.nvim)
### formatting

+ [elentok/format-on-save.nvim](https://dotfyle.com/plugins/elentok/format-on-save.nvim)
+ [echasnovski/mini.align](https://dotfyle.com/plugins/echasnovski/mini.align)
### fuzzy-finder

+ [nvim-telescope/telescope.nvim](https://dotfyle.com/plugins/nvim-telescope/telescope.nvim)
### git

+ [lewis6991/gitsigns.nvim](https://dotfyle.com/plugins/lewis6991/gitsigns.nvim)
+ [NeogitOrg/neogit](https://dotfyle.com/plugins/NeogitOrg/neogit)
+ [sindrets/diffview.nvim](https://dotfyle.com/plugins/sindrets/diffview.nvim)
### github

+ [pwntester/octo.nvim](https://dotfyle.com/plugins/pwntester/octo.nvim)
### icon

+ [kyazdani42/nvim-web-devicons](https://dotfyle.com/plugins/kyazdani42/nvim-web-devicons)
### indent

+ [lukas-reineke/indent-blankline.nvim](https://dotfyle.com/plugins/lukas-reineke/indent-blankline.nvim)
### keybinding

+ [folke/which-key.nvim](https://dotfyle.com/plugins/folke/which-key.nvim)
### lsp

+ [onsails/lspkind.nvim](https://dotfyle.com/plugins/onsails/lspkind.nvim)
+ [neovim/nvim-lspconfig](https://dotfyle.com/plugins/neovim/nvim-lspconfig)
### lsp-installer

+ [williamboman/mason.nvim](https://dotfyle.com/plugins/williamboman/mason.nvim)
### motion

+ [folke/flash.nvim](https://dotfyle.com/plugins/folke/flash.nvim)
### nvim-dev

+ [kkharji/sqlite.lua](https://dotfyle.com/plugins/kkharji/sqlite.lua)
+ [folke/neodev.nvim](https://dotfyle.com/plugins/folke/neodev.nvim)
+ [MunifTanjim/nui.nvim](https://dotfyle.com/plugins/MunifTanjim/nui.nvim)
+ [nvim-lua/plenary.nvim](https://dotfyle.com/plugins/nvim-lua/plenary.nvim)
### plugin-manager

+ [folke/lazy.nvim](https://dotfyle.com/plugins/folke/lazy.nvim)
### preconfigured

+ [ldelossa/nvim-ide](https://dotfyle.com/plugins/ldelossa/nvim-ide)
### scrollbar

+ [petertriho/nvim-scrollbar](https://dotfyle.com/plugins/petertriho/nvim-scrollbar)
### session

+ [olimorris/persisted.nvim](https://dotfyle.com/plugins/olimorris/persisted.nvim)
### snippet

+ [L3MON4D3/LuaSnip](https://dotfyle.com/plugins/L3MON4D3/LuaSnip)
### statusline

+ [rebelot/heirline.nvim](https://dotfyle.com/plugins/rebelot/heirline.nvim)
+ [freddiehaddad/feline.nvim](https://dotfyle.com/plugins/freddiehaddad/feline.nvim)
+ [b0o/incline.nvim](https://dotfyle.com/plugins/b0o/incline.nvim)
### syntax

+ [kylechui/nvim-surround](https://dotfyle.com/plugins/kylechui/nvim-surround)
+ [nvim-treesitter/nvim-treesitter-textobjects](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter-textobjects)
+ [nvim-treesitter/nvim-treesitter](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter)
### treesitter-based

+ [ziontee113/syntax-tree-surfer](https://dotfyle.com/plugins/ziontee113/syntax-tree-surfer)
### utility

+ [folke/noice.nvim](https://dotfyle.com/plugins/folke/noice.nvim)
+ [rcarriga/nvim-notify](https://dotfyle.com/plugins/rcarriga/nvim-notify)
+ [stevearc/dressing.nvim](https://dotfyle.com/plugins/stevearc/dressing.nvim)
+ [kevinhwang91/nvim-ufo](https://dotfyle.com/plugins/kevinhwang91/nvim-ufo)
## Language Servers



 This readme was generated by [Dotfyle](https://dotfyle.com)
