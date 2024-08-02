local files = require("neotest-cairo.files")
local lib = require("neotest.lib")

local M = {}

M.tests_query = [[
    ; query for #[cfg(test)]
    (attribute_item
        (identifier) @attribute (#eq? @attribute "cfg")
        (attribute_arguments
            (identifier) @cfg (#eq? @cfg "test")))
    ; query for mod tests {
    ((mod_item
        name: (identifier) @namespace.name
        ) @namespace.definition)

    ; query for #[test]
    ((attribute_item
        (identifier) @attribute
        (#eq? @attribute "test")
      )
      ; query for any other macro (0 or more) (e.g. #[should_panic])
      (attribute_item
        (identifier)
      )*
      . ; means the function should be immediately after the attribute
      ; query for fn test() {}
      (function_definition
        (identifier) @test.name
        (block)
      ) @test.definition)
]]

--- Detect tests in cairo files
---@param file_path string
function M.detect_tests(file_path)
  ---@diagnostic disable-next-line: missing-fields
  return lib.treesitter.parse_positions(file_path, M.tests_query, {})
end

--- Check if a file is a cairo test file
---@param file_path string
---@return boolean
function M.is_test_file(file_path)
  if file_path == nil then
    return false
  end

  if not file_path:match("%.cairo$") then
    return false
  end

  local scarb_path = files.file_upwards("Scarb.toml", file_path)
  if not scarb_path then
    return false
  end
  local root = vim.fn.fnamemodify(scarb_path, ":h") -- remove the file name

  -- Ensure the file is under src/ or tests/ under root
  local relative_to_root = string.sub(file_path, #root + 2)
  if relative_to_root:sub(1, 3) ~= "src" and relative_to_root:sub(1, 5) ~= "tests" then
    return false
  end

  -- #[cfg(test)] can appear in any cairo file. And I suppose pattern matching will not be much slower than
  -- reading the file and using treesitter to parse it.
  -- Still, since there is no convention for test files in cairo - this may become slow for directories with many files.
  local content = lib.files.read(file_path)
  return string.match(content, "#%[cfg%(test%)]") ~= nil
end

return M
