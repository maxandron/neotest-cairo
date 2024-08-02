--- Helpers around filepaths.

local lib = require("neotest.lib")
local logger = require("neotest-cairo.logging")

local M = {}

M.os_path_sep = lib.files.path.sep

--- Check if a path is a root directory or at the bottom of the heirarchy if the path is relative.
--- @param path string
--- @return boolean
function M.is_root_dir(path)
  return path:match("^%a:\\?$") ~= nil or path == M.os_path_sep or path == "." or path == "." .. M.os_path_sep
end

--- Find a file upwards in the directory tree and return its path, if found.
--- @param filename string
--- @param start_path string
--- @return string | nil
function M.file_upwards(filename, start_path)
  -- Ensure start_path is a directory
  local start_dir = vim.fn.isdirectory(start_path) == 1 and start_path or vim.fn.fnamemodify(start_path, ":h")

  while not M.is_root_dir(start_dir) do
    logger.debug("Searching for " .. filename .. " in " .. start_dir)

    local try_path = start_dir .. M.os_path_sep .. filename
    if vim.fn.filereadable(try_path) == 1 then
      logger.debug("Found " .. filename .. " at " .. try_path)
      return try_path
    end

    -- Go up one directory
    start_dir = vim.fn.fnamemodify(start_dir, ":h")
  end

  return nil
end

return M
