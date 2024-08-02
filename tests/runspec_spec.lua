local MiniTest = require("mini.test")

local expect = MiniTest.expect
local eq = expect.equality

local new_set = MiniTest.new_set

---@type child
local child = MiniTest.new_child_neovim()

local T = new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "tests/minit.lua" })
      child.lua([[M = require('neotest-cairo.runspec')]])
    end,
    post_once = child.stop,
  },
})

T["get_package()"] = new_set()

local function async_get(command)
  child.lua([[require('nio').run(function() vim.b.result = ]] .. command .. [[ end)]])
  vim.uv.sleep(5)
  return child.b.result
end

local function get_package(path)
  child.b.path = path
  return async_get("M.get_package(vim.b.path)")
end

T["get_package()"]["parses package from scarb"] = function()
  local package = get_package(vim.fn.getcwd() .. "/tests/files/projroot/Scarb.toml")
  eq(package, "projname")
end

T["get_package()"]["error on bad toml"] = function()
  local package = get_package(vim.fn.getcwd() .. "/tests/files/badproj/Scarb.toml")
  eq(package, vim.NIL)
end

T["build_spec()"] = new_set()

T["build_spec()"]["dir"] = function()
  child.b.pos = {
    id = vim.fn.getcwd() .. "/tests/files/projroot/tests",
    name = "tests",
    path = vim.fn.getcwd() .. "/tests/files/projroot/tests",
    type = "dir",
  }
  local spec = async_get("M.build_spec({ tree = { data = function() return vim.b.pos end } })")
  eq(spec, {
    command = "snforge test --color never tests",
    cwd = vim.fn.getcwd() .. "/tests/files/projroot",
  })
end

T["build_spec()"]["file"] = function()
  child.b.pos = {
    id = vim.fn.getcwd() .. "/tests/files/projroot/tests/example.cairo",
    name = "example.cairo",
    path = vim.fn.getcwd() .. "/tests/files/projroot/tests/example.cairo",
    range = { 0, 0, 99, 0 },
    type = "file",
  }
  local spec = async_get("M.build_spec({ tree = { data = function() return vim.b.pos end } })")
  eq(spec, {
    command = "snforge test --color never tests::example",
    cwd = vim.fn.getcwd() .. "/tests/files/projroot",
  })
end

T["build_spec()"]["namespace"] = function()
  child.b.pos = {
    id = vim.fn.getcwd() .. "/tests/files/projroot/tests/example.cairo::tests",
    name = "tests",
    path = vim.fn.getcwd() .. "/tests/files/projroot/tests/example.cairo",
    range = { 37, 0, 98, 1 },
    type = "namespace",
  }
  local spec = async_get("M.build_spec({ tree = { data = function() return vim.b.pos end } })")
  eq(spec, {
    command = "snforge test --color never tests::example::tests",
    cwd = vim.fn.getcwd() .. "/tests/files/projroot",
  })
end

T["build_spec()"]["test"] = function()
  child.b.pos = {
    id = vim.fn.getcwd() .. "/tests/files/projroot/tests/example.cairo::tests::from_felt252",
    name = "from_felt252",
    path = vim.fn.getcwd() .. "/tests/files/projroot/tests/example.cairo",
    range = { 43, 4, 54, 5 },
    type = "test",
  }
  local spec = async_get("M.build_spec({ tree = { data = function() return vim.b.pos end } })")
  eq(spec, {
    command = "snforge test --color never -e tests::example::tests::from_felt252",
    cwd = vim.fn.getcwd() .. "/tests/files/projroot",
  })
end

return T
