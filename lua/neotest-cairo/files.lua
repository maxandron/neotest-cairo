local M = {}

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@param rel_path string Path to directory, relative to root
---@param _ string Root directory of project (absolute path)
---@return boolean
function M.filter_dir(name, rel_path, _)
  local ignore_dirs = { ".git", "node_modules", ".venv", "venv", ".snfoundry_cache" }
  for _, ignore in ipairs(ignore_dirs) do
    if name == ignore then
      return false
    end
  end
  if not (rel_path:sub(1, 3) == "src" or rel_path:sub(1, 5) == "tests") then
    return false
  end
  return true
end

return M
