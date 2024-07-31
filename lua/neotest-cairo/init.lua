local filetype = require("plenary.filetype")
local lib = require("neotest.lib")

---@class neotest.Adapter
local adapter = { name = "neotest-cairo" }

-- Temporarily needed because cairo is not in plenary which neotest relies on for filetype detection
-- TODO: move to setup
filetype.add_table({
  extension = {
    cairo = "cairo",
  },
})

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function adapter.discover_positions(file_path)
  local query = [[
            ((mod_item
                name: (identifier) @namespace.name
                ) @namespace.definition)

            ((attribute_item
                (identifier) @attribute
                (#eq? @attribute "test")
              )
              (attribute_item
                (identifier)
              )*
              .
              (function_definition
                (identifier) @test.name
                (block)
              ) @test.definition)
        ]]

  ---@diagnostic disable-next-line: missing-fields
  return lib.treesitter.parse_positions(file_path, query, {})
end

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
function adapter.root(dir)
  return lib.files.match_root_pattern("Scarb.toml")(dir)
end

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@param rel_path string Path to directory, relative to root
---@param root string Root directory of project
---@return boolean
function adapter.filter_dir(name, rel_path, root)
  return true
end

---@param file_path string
---@return boolean
function adapter.is_test_file(file_path)
  if file_path == nil then
    return false
  end
  -- TODO: looks for cfg(test) using treesitter
  return string.match(file_path, ".*_t.cairo") ~= nil
end

---@param args neotest.RunArgs
---@return neotest.RunSpec | nil
function adapter.build_spec(args)
  local node = args.tree:data()
  return {
    command = "snforge test",
    cwd = lib.files.match_root_pattern("Scarb.toml")(node.path),
    context = {
      file = node.path,
    },
  }
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function adapter.results(spec, result, tree)
  error("not implemented")
end

setmetatable(adapter, {
  __call = function(_, opts) end,
})

return adapter
