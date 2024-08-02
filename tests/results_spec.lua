-- Define helper aliases
local MiniTest = require("mini.test")
local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local not_nil = function(v)
  expect.no_equality(nil, v)
end

local function remove_output(parsed)
  for _, result in pairs(parsed) do
    not_nil(result.output)
    result.output = nil
  end
end

-- Create (but not start) child Neovim object
---@type child
local child = MiniTest.new_child_neovim()

-- Define main test set of this file
local T = new_set({
  -- Register hooks
  hooks = {
    -- This will be executed before every (even nested) case
    pre_case = function()
      -- Restart child process with custom 'init.lua' script
      child.restart({ "-u", "tests/minit.lua" })
      -- Load tested plugin
      child.lua([[M = require('neotest-cairo.results')]])
    end,
    -- This will be executed one after all tests from this set are finished
    post_once = child.stop,
  },
})

-- Test set fields define nested structure
T["parse_output()"] = new_set()

-- Define test action as callable field of test set.
-- If it produces error - test fails.
T["parse_output()"]["parses valid output"] = function()
  child.lua([[Output = vim.fn.readfile("./tests/files/snforge_out.txt")]])
  local parsed = child.lua_get("M.parse_output(Output)")
  remove_output(parsed)

  eq(parsed, {
    ["projname::byte_array_extra::tests::bytearray_long_serialize"] = {
      status = "passed",
    },
    ["projname::byte_array_extra::tests::from_felt252"] = {
      errors = {
        {
          message = "    \"assertion `e.pending_word_len == 19` failed: Wrong pending word len\n    e.pending_word_len: 18\n    19: 19\"",
        },
      },
      status = "failed",
    },
    ["projname::byte_array_extra::tests::from_span_felt252_bytearray_shortstring"] = {
      status = "passed",
    },
    ["projname::byte_array_extra::tests::from_span_felt252_felt252"] = {
      errors = {
        {
          message = "    \"assertion `e == \"hello!\"` failed: String mismatch\n    e: \"hello\"\n    \"hello!\": \"hello!\"\"",
        },
      },
      status = "failed",
    },
    ["projname::byte_array_extra::tests::from_span_felt252_none"] = {
      status = "passed",
    },
  })
end

T["parse_output()"]["parses cut off valid output"] = function()
  child.lua([[Output = vim.fn.readfile("./tests/files/snforge_out_cut_valid.txt")]])
  local parsed = child.lua_get("M.parse_output(Output)")
  -- remove output
  for _, result in pairs(parsed) do
    not_nil(result.output)
    result.output = nil
  end

  eq(parsed, {
    ["projname::byte_array_extra::tests::bytearray_long_serialize"] = {
      status = "passed",
    },
    ["projname::byte_array_extra::tests::from_felt252"] = {
      errors = {
        {
          message = "    \"assertion `e.pending_word_len == 19` failed: Wrong pending word len\n    e.pending_word_len: 18\n    19: 19\"",
        },
      },
      status = "failed",
    },
    ["projname::byte_array_extra::tests::from_span_felt252_bytearray_shortstring"] = {
      status = "passed",
    },
    ["projname::byte_array_extra::tests::from_span_felt252_felt252"] = {
      errors = {
        {
          message = "    \"assertion `e == \"hello!\"` failed: String mismatch\n    e: \"hello\"\n    \"hello!\": \"hello!\"\"",
        },
      },
      status = "failed",
    },
    ["projname::byte_array_extra::tests::from_span_felt252_none"] = {
      status = "passed",
    },
  })
end

T["parse_output()"]["errors on invalid output"] = function()
  child.lua([[Output = vim.fn.readfile("./tests/files/snforge_out_cut_invalid.txt")]])
  expect.error(function()
    child.lua_get("M.parse_output(Output)")
  end, ".*Failure data.*")
end

T["parse_output()"]["doesnt fail on compilation errors"] = function()
  child.lua([[Output = vim.fn.readfile("./tests/files/compilation_fail.txt")]])
  eq(child.lua_get("M.parse_output(Output)"), {})
end

T["parse_output()"]["works with skipped tests"] = function()
  child.lua([[Output = vim.fn.readfile("./tests/files/skipped.txt")]])
  local parsed = child.lua_get("M.parse_output(Output)")
  remove_output(parsed)

  eq(parsed, {
    ["projname::byte_array_extra::tests::from_felt252"] = {
      status = "skipped",
    },
    ["projname::byte_array_extra::tests::bytearray_long_serialize"] = {
      status = "passed",
    },
    ["projname::byte_array_extra::tests::from_span_felt252_bytearray_shortstring"] = {
      status = "passed",
    },
    ["projname::byte_array_extra::tests::from_span_felt252_felt252"] = {
      errors = {
        {
          message = "    \"assertion `e == \"hello!\"` failed: String mismatch\n    e: \"hello\"\n    \"hello!\": \"hello!\"\"",
        },
      },
      status = "failed",
    },
    ["projname::byte_array_extra::tests::from_span_felt252_none"] = {
      status = "passed",
    },
  })
end

-- Return test set which will be collected and execute inside `MiniTest.run()`
return T
