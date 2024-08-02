--- This is the main entry point for the neotest-cairo adapter. It follows the
--- Neotest interface: https://github.com/nvim-neotest/neotest/blob/master/lua/neotest/adapters/interface.lua

local async = require("neotest.async")
local logger = require("neotest-cairo.logging")

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
---@param rel_path string Path to directory, relative to root
---@param root string Root directory of project (absolute path)
---@return boolean
function Adapter.filter_dir(name, rel_path, root)
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
  local lib = require("neotest.lib")
  --- The tree object, describing the AST-detected tests and their positions.
  local tree = args.tree

  if not tree then
    logger.error("Unexpectedly did not receive a neotest.Tree.")
    return
  end

  --- The position object, describing the current directory, file or test.
  local pos = tree:data()

  -- Below is the main logic of figuring out how to execute tests. In short,
  -- a "runspec" is defined for each command to execute.
  -- Neotest also distinguishes between different "position types":
  -- - "dir": A directory of tests
  -- - "file": A single test file
  -- - "namespace": A set of tests, collected under the same namespace
  -- - "test": A single test
  --
  -- If a valid runspec is built and returned from this function, it will be
  -- executed by Neotest. But if, for some reason, this function returns nil,
  -- Neotest will call this function again, but using the next position type
  -- (in this order: dir, file, namespace, test). This gives the ability to
  -- have fallbacks.
  -- For example, if a runspec cannot be built for a file of tests, we can
  -- instead try to build a runspec for each individual test file. The end
  -- result would in this case produce multiple commands to execute (for each
  -- test) rather than one command for the file.
  -- The idea here is not to have such fallbacks take place in the future, but
  -- while this adapter is being developed, it can be useful to have such
  -- functionality.

  local filter = ""
  if pos.type == "test" then
    -- Get package name from Scarb.toml
    --TODO: export into a separate function
    local scarb = lib.files.read("Scarb.toml")
    --TODO: not very robust - maybe parsing the toml file would be better. Maybe with treesitter?
    local package_name = scarb:match("%[package]\nname = \"(%a+)\"")

    local cwd = async.fn.getcwd()
    -- +2 to include the slash and because lua is 1-indexed
    filter = pos.id:sub(#cwd + 2, #pos.id)
    filter = filter:gsub("^src", package_name)
    filter = filter:gsub("/", "::")
    filter = filter.gsub(filter, "%.cairo::", "::")

    filter = "-e " .. filter
  elseif pos.type == "namespace" then
    -- Get package name from Scarb.toml
    --TODO: export into a separate function
    local scarb = lib.files.read("Scarb.toml")
    --TODO: not very robust - maybe parsing the toml file would be better. Maybe with treesitter?
    local package_name = scarb:match("%[package]\nname = \"(%a+)\"")

    local cwd = async.fn.getcwd()
    -- +2 to include the slash and because lua is 1-indexed
    filter = pos.id:sub(#cwd + 2, #pos.id)
    filter = filter:gsub("^src", package_name)
    filter = filter:gsub("/", "::")
    filter = filter.gsub(filter, "%.cairo::", "::")
  elseif pos.type == "file" then
    -- Get package name from Scarb.toml
    --TODO: export into a separate function
    local scarb = lib.files.read("Scarb.toml")
    --TODO: not very robust - maybe parsing the toml file would be better. Maybe with treesitter?
    local package_name = scarb:match("%[package]\nname = \"(%a+)\"")

    local cwd = async.fn.getcwd()
    -- +2 to include the slash and because lua is 1-indexed
    filter = pos.id:sub(#cwd + 2, #pos.id)
    filter = filter:gsub("^src", package_name)
    filter = filter:gsub("/", "::")
    filter = filter.gsub(filter, "%.cairo$", "")
  elseif pos.type == "dir" then
    -- Get package name from Scarb.toml
    --TODO: export into a separate function
    local scarb = lib.files.read("Scarb.toml")
    --TODO: not very robust - maybe parsing the toml file would be better. Maybe with treesitter?
    local package_name = scarb:match("%[package]\nname = \"(%a+)\"")

    local cwd = async.fn.getcwd()
    -- +2 to include the slash and because lua is 1-indexed
    filter = pos.id:sub(#cwd + 2, #pos.id)
    filter = filter:gsub("^src", package_name)
    filter = filter:gsub("/", "::")
  else
    logger.error("position type not supported:" .. pos.type)
  end

  -- TODO: currently only runs all tests, regardless of the position type.
  local runspec = {
    command = "snforge test --color never " .. filter,
    context = {
      file = pos.path,
    },
  }
  P("runspec", runspec)
  return runspec
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

  local parsed_output = require("neotest-cairo.snforge").parse_output(output)

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
