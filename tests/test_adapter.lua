-- Define helper aliases
local MiniTest = require('mini.test')
local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

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
      child.restart({ '-u', 'scripts/minimal_init.lua' })
      -- Load tested plugin
      child.lua([[M = require('neotest-cairo.utils')]])
    end,
    -- This will be executed one after all tests from this set are finished
    post_once = child.stop,
  },
})

-- Test set fields define nested structure
T["ts_query()"] = new_set()

-- Define test action as callable field of test set.
-- If it produces error - test fails.
T["ts_query()"]["works"] = function()
  child.cmd('edit tests/example.cairo')
  eq(child.lua_get([[
      local query = vim.treesitter.query.parse(
        "cairo",
        M.ts_query()
      )
  ]]), {})
end

-- Return test set which will be collected and execute inside `MiniTest.run()`
return T
