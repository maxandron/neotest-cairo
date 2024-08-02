--- This is the main entry point for the neotest-cairo adapter. It follows the
--- Neotest interface: https://github.com/nvim-neotest/neotest/blob/master/lua/neotest/adapters/interface.lua

local async = require("neotest.async")

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
  local output = async.fn.readfile(result.output)

  -- Get package name from Scarb.toml
  --TODO: export into a separate function
  local scarb = lib.files.read("Scarb.toml")
  --TODO: not very robust - maybe parsing the toml file would be better. Maybe with treesitter?
  local package_name = scarb:match("%[package]\nname = \"(%a+)\"")
  local cwd = async.fn.getcwd()

  --- @return table<string, neotest.Result>
  local results = {}

  local parsed_output = require("neotest-cairo.results").parse_output(output)

  for _, node in tree:iter_nodes() do
    --- @type neotest.Position
    local pos = node:data()
    if pos.type == "test" then
      -- +2 to include the slash and because lua is 1-indexed
      local filter = pos.id:sub(#cwd + 2, #pos.id)
      filter = filter:gsub("^src", package_name)
      filter = filter:gsub("/", "::")
      filter = filter.gsub(filter, "%.cairo::", "::")

      results[pos.id] = parsed_output[filter]
    end
  end

  -- Maps pos.id() to the test results
  return results
end

setmetatable(Adapter, {
  __call = function(_, opts)
    -- Adapter.options = options.setup(opts)
    return Adapter
  end,
})

return Adapter
