local logger = require("model_cmp.logger")

local M = {}

vim.g.server_error_count = 0

---@param response string json as string
---@param type string type of server running
function M.decode_response(response, type)
    local ok, response_table = pcall(vim.fn.json_decode, response)
    if not ok or response_table == nil then
        return
    end
    if response_table.error ~= nil then
        logger.warning("response has error")
        vim.g.server_error_count = vim.g.server_error_count + 1
        return
    end
    if type == "gemini" then
        if response_table.candidates[1].content.parts[1].text == nil then
            return
        end
        return response_table.candidates[1].content.parts[1].text
    elseif type == "local_llama" then
        if response_table.choices[1].message.content == nil then
            return
        end
        return response_table.choices[1].message.content
    end
end

---@param input string[]
function M.parse_messages(input)
    local str_input = ""
    for _, k in ipairs(input) do
        str_input = str_input .. k .. "\n"
    end

    local messages = {}
    for role, code in str_input:gmatch("@role:%s*(%w+)%s*@content:%s*<code>(.-)</code>") do
        code = code:gsub("^%s+", ""):gsub("%s+$", "")
        table.insert(messages, {
            role = role,
            content = code,
        })
    end

    return messages
end

---@param currline string
---@param suggestion string
---@return string, integer
---Longest Common Suffix
local function lcs(currline, suggestion)
    if currline == suggestion or not currline or not suggestion then
        return "", 0
    end
    local l1 = #currline
    local l2 = #suggestion

    if l1 > l2 then
        return lcs(suggestion, currline)
    end

    local lcp_length = 0
    for i = 1, l1 do
        if currline:sub(i, i) == suggestion:sub(i, i) then
            lcp_length = i
        else
            break
        end
    end
    local lcs_length = 0
    for i = 1, l1 - lcp_length do
        local index1 = l1 - i + 1
        local index2 = l2 - i + 1

        if currline:sub(index1, index1) == suggestion:sub(index2, index2) then
            lcs_length = i
        else
            break
        end
    end
    local start_index = lcp_length + 1
    local end_index = l2 - lcs_length
    if start_index > end_index then
        return "", 0
    end
    return suggestion:sub(start_index, end_index), start_index
end

---@param suggestion string
function M.adjust_suggestion(suggestion)
    local curr = vim.api.nvim_get_current_line()
    return lcs(curr, suggestion)
end

return M
