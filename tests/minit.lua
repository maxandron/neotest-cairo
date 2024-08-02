vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

-- Setup lazy.nvim
require("lazy.minit").setup({
  spec = {
    {
      dir = vim.uv.cwd(),
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = function()
        require("nvim-treesitter.install").update({ with_sync = true })()
      end,
      config = function()
        require("nvim-treesitter.configs").setup({
          modules = {},
          auto_install = true,
          ignore_install = {},
          ensure_installed = { "cairo" },
          sync_install = true,
        })
      end,
    },
    {
      "nvim-neotest/neotest",
      lazy = true,
      dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
      },
      opts = {},
    },
  },
})
