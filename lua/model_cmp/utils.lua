local pcall = pcall
local M = {}

---@param response string json as string
function M.decode_response(response)
    local ok, response_table = pcall(vim.fn.json_decode, response)
    if not ok or response_table == nil then
        return
    end
    if response_table.error ~= nil then
        return nil
    end
    return response_table.choices[1].message.content
end

---@param input string[]
function M.parse_messages(input)
    local str_input = ""
    for _, k in ipairs(input) do
        str_input = str_input .. k .. '\n'
    end

    local messages = {}
    for role, code in str_input:gmatch("@role:%s*(%w+)%s*@content:%s*<code>(.-)</code>") do
        code = code:gsub("^%s+", ""):gsub("%s+$", "")
        table.insert(messages, {
            role = role,
            content = code
        })
    end

    return messages
end

return M
