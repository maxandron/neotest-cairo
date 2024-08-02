--- This is the main entry point for the neotest-cairo adapter. It follows the
--- Neotest interface: https://github.com/nvim-neotest/neotest/blob/master/lua/neotest/adapters/interface.lua

-- Temporarily needed because cairo is not in plenary which neotest relies on for filetype detection
require("plenary.filetype").add_table({
  extension = {
    cairo = "cairo",
  },
})

--- See neotest.Adapter for the full interface.
--- @class CairoAdapter : neotest.Adapter
local Adapter = { name = "neotest-cairo" }

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
function Adapter.root(dir)
  -- To make test finding flexible, we simply return the current directory as the root and
  -- then set the CWD before running the test command.
  -- This way, neotest can search for tests in any directory.
  return dir
end

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@return boolean
function Adapter.filter_dir(name)
  local ignore_dirs = { ".git", "node_modules", ".venv", "venv", ".snfoundry_cache" }
  for _, ignore in ipairs(ignore_dirs) do
    if name == ignore then
      return false
    end
  end
  return true
end

---@param file_path string
---@return boolean
function Adapter.is_test_file(file_path)
  return require("neotest-cairo.query").is_test_file(file_path)
end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function Adapter.discover_positions(file_path)
  return require("neotest-cairo.query").detect_tests(file_path)
end

--- Build the runspec, which describes what command(s) are to be executed.
---@param args neotest.RunArgs
---@return neotest.RunSpec | nil
function Adapter.build_spec(args)
  return require("neotest-cairo.runspec").build_spec(args)
end

--- Process the test command output and result. Populate test outcome into the
--- Neotest internal tree structure.
--- @async
--- @param spec neotest.RunSpec
--- @param result neotest.StrategyResult
--- @param tree neotest.Tree
--- @return table<string, neotest.Result> | nil
function Adapter.results(spec, result, tree)
  local lib = require("neotest.lib")
  local async = require("neotest.async")
  local runspec = require("neotest-cairo.runspec")
  local results = require("neotest-cairo.results")

  local output = async.fn.readfile(result.output)

  local parsed_output = results.parse_output(output)

  -- Currently the position of any will do for finding the package name
  -- because we don't support running tests from multiple packages yet
  local package_name = runspec.get_package(spec.cwd .. lib.files.path.sep .. "Scarb.toml")

  --- Maps pos.id() to the test results
  --- @return table<string, neotest.Result>
  local pos_results = {}

  for _, node in tree:iter_nodes() do
    --- @type neotest.Position
    local pos = node:data()
    if pos.type == "test" then
      -- +2 to include the slash and because lua is 1-indexed
      local filter = pos.id:sub(#spec.cwd, #pos.id)
      filter = filter:gsub("^src", package_name)
      filter = filter:gsub("/", "::")
      filter = filter.gsub(filter, "%.cairo::", "::")

      pos_results[pos.id] = parsed_output[filter]
    end
  end

  return pos_results
end

setmetatable(Adapter, {
  --- Currently there are no configuration options.
  --- The call is here to allow for future expansion and to keep the interface consistent with other adapters.
  __call = function(_, _)
    return Adapter
  end,
})

return Adapter
