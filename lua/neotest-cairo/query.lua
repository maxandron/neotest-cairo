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

function M.is_test_file(file_path)
  -- TODO: ignore files that are in the root directory
  if file_path == nil then
    return false
  end
  if not file_path:match("%.cairo$") then
    return false
  end
  -- #[cfg(test)] can appear in any cairo file. And I suppose pattern matching will not be much slower than
  -- reading the file and using treesitter to parse it.
  -- Still, since there is no convention for test files in cairo - this can be a bit slow for directories with many files.
  --TODO: if the file is already loaded into a buffer maybe it's better to read from there
  --TODO: maybe it's worth just running "detect_tests" on the file and if it returns something then it's a test file
  --TODO: but also since it's async maybe it's not much of a problem
  local content = lib.files.read(file_path)
  return string.match(content, "#%[cfg%(test%)]") ~= nil
end

return M
