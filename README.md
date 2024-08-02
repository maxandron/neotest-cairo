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

## ⛑️ Tips & troubleshooting

### Issues with setting up or using the adapter

You can run `:checkhealth neotest-cairo` to review common issues. If you need
help, please open a discussion
[here](https://github.com/maxandron/neotest-cairo/discussions/new?category=q-a).

You can also enable logging to further inspect what's going on under the hood.
Neotest-cairo piggybacks on the Neotest logger. You can enable it like so:

```lua
require("neotest.logging"):set_level(vim.log.levels.INFO)
```

⚠️ Please note that this could cause tests to run slower, so don't forget to
remove this setting once you have resolved your issue!

Lower the log level further to `DEBUG` to get even more information. The lowest
level is `TRACE`, but is not used by this adapter and is only useful when
debugging issues with Neotest.

You can get ahold of the log file's path using
`require("neotest.logging"):get_filename()`, which usually points to your
`~/.local/state/nvim/neotest.log`.

The logfile tends to be ginormous and if you are only looking for neotest-cairo
related entries, you can search for the `[neotest-cairo]` prefix.

## 🚀 Shoutout

neotest-cairo is heavily inspired by [neotest-golang](https://github.com/fredrikaverpil/neotest-golang).

Having it as a reference made it much easier to write this adapter. The code is clean and well documented.

Thank you!

