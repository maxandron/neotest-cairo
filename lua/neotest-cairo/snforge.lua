local async = require("neotest.async")
local logger = require("neotest-cairo.logging")

local M = {}

-- The pattern to match the test output from snforge test
-- The status is either FAIL, PASS, or IGNORE
-- PASS cases also end with the estimated gas cost of the test
local test_query_pattern = "%[([FPI][AAG][ISN][LSO]R?E?)] ([%w%p]+) *%(?g?a?s?:? ?~?(%d*)%)?"

-- Parses the output from running snforge test and
-- map between snforge filter names and neotest results
---@param output string[] The output from running snforge test. Split into lines.
---@return table<string, neotest.Result>
function M.parse_output(output)
  local test_results = {}

  local i = 1
  while i <= #output do
    local line = output[i]
    if line:match(test_query_pattern) then
      local status, filter, _ = line:match(test_query_pattern)

      local output_data = { line }
      local result = { status = "passed" }
      if status == "FAIL" then
        i = i + 2
        if output[i] ~= "Failure data:" then
          -- Sanity check: mainly to ensure scarb output format didn't change and that the output is not corrupted
          logger.error("expected 'Failure data:' to appear after every failed test.")
        end
        output_data = vim.list_extend(output_data, { "", output[i] })
        i = i + 1

        local fail_data = {} ---@type string[]

        -- The Failure data: ends with one empty line before the next test
        while i <= #output and output[i] ~= "" do
          table.insert(fail_data, output[i])
          i = i + 1
        end

        result.status = "failed"
        result.errors = { { message = table.concat(fail_data, "\n") } }
        output_data = vim.list_extend(output_data, fail_data)
      elseif status == "PASS" then
        result.status = "passed"
      elseif status == "IGNORE" then
        result.status = "skipped"
      else
        logger.error("Unrecognized status in output" .. status)
      end

      local test_output_path = vim.fn.tempname()
      async.fn.writefile(output_data, test_output_path)
      result.output = test_output_path
      test_results[filter] = result
    end
    i = i + 1
  end
  return test_results
end

return M
