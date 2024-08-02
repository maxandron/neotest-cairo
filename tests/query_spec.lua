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
      child.lua([[M = require('neotest-cairo.query')]])
    end,
    post_once = child.stop,
  },
})

T["is_test_file()"] = new_set()

T["is_test_file()"]["no path"] = function()
  local result = child.lua_get("M.is_test_file()")
  eq(result, false)
end

T["is_test_file()"]["not a cairo file"] = function()
  local result = child.lua_get("M.is_test_file('/opt/wow.lua')")
  eq(result, false)
end

T["is_test_file()"]["not in a project"] = function()
  child.b.path = vim.fn.getcwd() .. "/tests/files/example.cairo"
  local result = child.lua_get("M.is_test_file(vim.b.path)")
  eq(result, false)
end

T["is_test_file()"]["not in src or tests"] = function()
  child.b.path = vim.fn.getcwd() .. "/tests/files/projroot/example.cairo"
  local result = child.lua_get("M.is_test_file(vim.b.path)")
  eq(result, false)
end

local function async_get(command)
  child.lua([[require('nio').run(function() vim.b.result = ]] .. command .. [[ end)]])
  vim.uv.sleep(20)
  return child.b.result
end

T["is_test_file()"]["does not contain cfg(test)"] = function()
  child.b.path = vim.fn.getcwd() .. "/tests/files/projroot/src/example.cairo"
  local result = async_get("M.is_test_file(vim.b.path)")
  eq(result, false)
end

T["is_test_file()"]["contains cfg(test)"] = function()
  child.b.path = vim.fn.getcwd() .. "/tests/files/projroot/tests/example.cairo"
  local result = async_get("M.is_test_file(vim.b.path)")
  eq(result, true)
end

return T
