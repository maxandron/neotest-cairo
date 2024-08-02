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
      child.lua([[M = require('neotest-cairo.files')]])
    end,
    post_once = child.stop,
  },
})

T["is_root_dir()"] = new_set()

local function is_root_dir(dir)
  return child.lua_get("M.is_root_dir([[" .. dir .. "]])")
end

T["is_root_dir()"]["windows roots"] = function()
  eq(is_root_dir("C:\\"), true)
  eq(is_root_dir("C:"), true)
  eq(is_root_dir("z:"), true)
  eq(is_root_dir("K:\\"), true)

  eq(is_root_dir("K:\\awef"), false)
  eq(is_root_dir("K:awef"), false)
  eq(is_root_dir("K:\\awef\\awef"), false)
end

T["is_root_dir()"]["linux roots"] = function()
  eq(is_root_dir("/"), true)
  eq(is_root_dir("/home"), false)
  eq(is_root_dir("/home/awef"), false)

  eq(is_root_dir("."), true)
  eq(is_root_dir("./"), true)
  eq(is_root_dir("./fewafw"), false)
end

T["file_upwards"] = new_set()

T["file_upwards"]["works"] = function()
  child.lua([[Path = vim.fn.getcwd() .. "/tests/files/projroot/tests/example.cairo"]])
  local scarb_path = child.lua_get("M.file_upwards('Scarb.toml', Path)")
  eq(scarb_path, vim.fn.getcwd() .. "/tests/files/projroot/Scarb.toml")
end

T["file_upwards"]["nil if not found"] = function()
  child.lua([[Path = vim.fn.getcwd() .. "/tests/files/projroot/tests/example.cairo"]])
  local scarb_path = child.lua_get(
    "M.file_upwards('some_really-unusualfile-name-that-will-not-be-foundInAnyUniverse123XX---X', Path)"
  )
  eq(scarb_path, vim.NIL)
end

return T
