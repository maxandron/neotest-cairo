local files = require("neotest-cairo.files")
local lib = require("neotest.lib")
local logger = require("neotest-cairo.logging")

local M = {}

--- Get the package name from the Scarb.toml file.
---@async
---@param toml_path string The path to the Scarb.toml file.
---@return string
function M.get_package(toml_path)
  local toml = lib.files.read(toml_path)
  local package_name = toml:match("%[package].-name[^%w]-\"(%a+)\"")
  assert(package_name, "package name not found in Scarb.toml")

  return package_name
end

--- Build the runspec, which describes what command(s) are to be executed.
---@async
---@param args neotest.RunArgs
---@return neotest.RunSpec | nil
function M.build_spec(args)
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

  local toml = files.file_upwards("Scarb.toml", pos.path)
  assert(toml, "expected Scarb.toml to be found")
  local package_name = M.get_package(toml)

  local cwd = lib.files.parent(toml)

  -- +2 to include the slash and because lua is 1-indexed
  local filter = pos.id:sub(#cwd + 2, #pos.id)
  filter = filter:gsub("^src", package_name)
  filter = filter:gsub("/", "::")

  if pos.type == "test" then
    filter = filter.gsub(filter, "%.cairo::", "::")
    -- This is the only time we can create an exact filter
    filter = "-e " .. filter
  elseif pos.type == "namespace" then
    filter = filter.gsub(filter, "%.cairo::", "::")
  elseif pos.type == "file" then
    filter = filter.gsub(filter, "%.cairo$", "")
  elseif pos.type == "dir" then
    -- No need to do anything
  else
    logger.error("position type not supported:" .. pos.type)
  end

  local runspec = {
    command = "snforge test --color never " .. filter,
    cwd = cwd,
  }
  return runspec
end

return M
