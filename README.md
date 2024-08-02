# neotest-cairo

Neotest adapter for running Cairo tests in Neovim.

![image](https://github.com/user-attachments/assets/d85348c5-b706-4f57-84ea-508d31e6f475)

## 🏗 WIP

Although the adapter works, it is still early in development and may have some rough edges.

For instance:

- I didn't test it on Windows (though I did take Windows into account when writing the code)
- Only tested on snforge 0.19.0
  - I expect output to change slightly between version in which case we will need to add support for multiple versions

Also - see TODO.md for a list of things that may need to be done.

## ✨ Features

- Supports passing, failing, and ignored tests.
- Supports running from all positions (test, module, file, directory).
- Finds test outside the current working directory.
- Inline diagnostics.
- Supports tests combined with sources.
- Finds tests in both src and tests directories.

## ⚡️ Requirements

- Neovim >= 0.10.0
  - Probably works on older versions, but not tested yet.
- **Starknet Foundry** - for snforge
- [Neotest](https://github.com/nvim-neotest/neotest) as this is an adapter for it.
  - and the rest of Neotest's dependencies (nio, plenary, FixCursorHold)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/) with the `cairo` parser installed.

## 📦 Installation

Install the plugin with your favorite package manager.

### Lazy.nvim

```lua
{
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- This is where you install the adapter:
    "maxandron/neotest-cairo",
  },
  opts = function()
    return {
      adapters = {
        -- This is where you add the adapter:
        require("neotest-cairo"),
      },
      -- The rest of your Neotest configuration
    }
  end,
}
```

## ⚙️ Configuration

There are none.

Open an issue if you would like to configure something.

## 🚀 Shoutout

neotest-cairo is heavily inspired by [neotest-golang](https://github.com/fredrikaverpil/neotest-golang).

Having it as a reference made it much easier to write this adapter.

