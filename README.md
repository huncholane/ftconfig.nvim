# ftconfig.nvim

A Neovim plugin for managing per-filetype configuration with ease. Configure indentation, formatters, and other filetype-specific settings in individual Lua files.

## Features

- **Per-filetype configuration**: Create separate config files for each filetype
- **Automatic indentation**: Set custom indentation per filetype (shiftwidth, tabstop, softtabstop)
- **Conform.nvim integration**: Configure formatters per filetype
- **Easy editing**: Quick commands and Telescope integration for editing configs
- **Auto-completion**: Filetype completion for commands

## Installation

### lazy.nvim
```lua
{
  "huncholane/ftconfig.nvim",
  dependencies = {
    "telescope.nvim", -- optional, for telescope integration
    "conform.nvim",   -- optional, for formatter integration
  },
  config = function()
    require("ftconfig").setup()
  end,
}
```

### packer.nvim
```lua
use {
  "huncholane/ftconfig.nvim",
  requires = {
    "nvim-telescope/telescope.nvim", -- optional
    "stevearc/conform.nvim",         -- optional
  },
  config = function()
    require("ftconfig").setup()
  end,
}
```

## Usage

### Commands

- `:FT [filetype]` - Edit or create config for the specified filetype
- `:FT` - Edit config for the current buffer's filetype

### Telescope Extension

Load the telescope extension:
```lua
require("telescope").load_extension("ftconfig")
```

Then use:
- `:Telescope ftconfig` - Browse and select filetypes to configure

The picker shows:
- 󰓎 Current buffer's filetype (prioritized)
- 📝 Filetypes with existing configs
- 󰙴 Other available filetypes

## Configuration

Filetype configs are stored in `~/.config/nvim/lua/ftconfig/` as individual `.lua` files.

### Example Filetype Config

Create `~/.config/nvim/lua/ftconfig/javascript.lua`:

```lua
---@type FTSpec
return {
  -- Set indentation to 2 spaces
  indent = 2,

  -- Configure formatters via conform.nvim
  conform = {
    use = { "prettier", "eslint_d" },
    formatters = {
      prettier = {
        prepend_args = { "--tab-width", "2" }
      }
    }
  },

  -- LSP configuration (placeholder for future features)
  lsp = {
    -- Reserved for future LSP integration
  }
}
```

### Configuration Schema

```lua
---@class FTSpec
---@field indent? integer          -- Indentation size (default: 4)
---@field conform? FTConformSpec   -- Conform.nvim configuration
---@field lsp? table<LSPName, any> -- LSP configuration (reserved)

---@class FTConformSpec
---@field use string[]                                    -- List of formatters to use
---@field formatters? table<string, conform.FileFormatterConfig> -- Formatter-specific config
```

## Examples

### Python with Black formatting
`~/.config/nvim/lua/ftconfig/python.lua`:
```lua
return {
  indent = 4,
  conform = {
    use = { "black", "isort" },
    formatters = {
      black = {
        prepend_args = { "--line-length", "88" }
      }
    }
  }
}
```

### Go with gofmt
`~/.config/nvim/lua/ftconfig/go.lua`:
```lua
return {
  indent = 4,
  conform = {
    use = { "gofmt", "goimports" }
  }
}
```

### Lua with stylua
`~/.config/nvim/lua/ftconfig/lua.lua`:
```lua
return {
  indent = 2,
  conform = {
    use = { "stylua" },
    formatters = {
      stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" }
      }
    }
  }
}
```

## How It Works

1. On setup, the plugin scans `~/.config/nvim/lua/ftconfig/` for `.lua` files
2. Each file is loaded as a filetype configuration
3. FileType autocmds are created to apply indentation settings
4. Conform.nvim is configured with the specified formatters
5. The `:FT` command and Telescope extension provide easy access to edit configs

## Requirements

- Neovim >= 0.7.0
- Optional: [conform.nvim](https://github.com/stevearc/conform.nvim) for formatter integration
- Optional: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for the picker interface

## License

MIT
