local M = {}

--- Returns a query string for the treesitter parser.
--- capture groups conform to the neotest format.
function M.ts_query()
  return [[
            ((mod_item
               name: (identifier) @namespace.name
            ) @namespace.definition)

            (
              (attribute_item
                (identifier) @attribute
              ) 
              (attribute_item
                (identifier)
              )*
              (function_definition
                (identifier) @test.name
                (block)
              ) @test.definition
              (#match? @attribute "test")
            )
        ]]
end

return M
