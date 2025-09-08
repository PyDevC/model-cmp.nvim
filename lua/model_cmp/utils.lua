local pcall = pcall
local M = {}

function M.decode_response(response)
    local ok, response_table = pcall(vim.fn.json_decode, response)
    if not ok or response_table == nil then
        -- log this
        return
    end
    return response_table.choices[1].message.content
end

return M
