local Helpers = {}

local MiniTest = require("mini.test")

Helpers.expect = vim.deepcopy(MiniTest.expect)

Helpers.expect.eq = Helpers.expect.equality
Helpers.expect.neq = Helpers.expect.no_equality
Helpers.expect.is_nil = function(value)
  return Helpers.expect.eq(nil, value)
end

setmetatable(Helpers.expect, {
  __call = function(_, value)
    if not value then
      error("Expected not nil or false, got " .. vim.inspect(value))
    end
  end,
})

return Helpers
