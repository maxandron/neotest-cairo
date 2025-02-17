---@diagnostic disable: deprecated
local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local warn = vim.health.warn or vim.health.report_warn
-- local error = vim.health.error or vim.health.report_error
-- local info = vim.health.info or vim.health.report_info
---@diagnostic enable: deprecated

local M = {}

function M.check()
  start("Requirements")
  M.binary_found_on_path("snforge")
  M.treesitter_parser_installed("cairo")
  M.is_plugin_available("neotest")
  M.is_plugin_available("nvim-treesitter")
  M.is_plugin_available("nio")
  M.is_plugin_available("plenary")
end

function M.binary_found_on_path(executable)
  local found = vim.fn.executable(executable)
  if found == 1 then
    ok("Binary '" .. executable .. "' found on PATH: " .. vim.fn.exepath(executable))
    return true
  else
    warn("Binary '" .. executable .. "' not found on PATH")
  end
  return false
end

function M.is_plugin_available(plugin)
  local is_plugin_available = pcall(require, plugin)
  if is_plugin_available then
    ok(plugin .. " is available")
  else
    warn(plugin .. " is not available")
  end
end

function M.treesitter_parser_installed(lang)
  local is_installed = require("nvim-treesitter.parsers").has_parser(lang)
  if is_installed then
    ok("Treesitter parser for " .. lang .. " is installed")
  else
    warn("Treesitter parser for " .. lang .. " is not installed")
  end
end

return M
