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
    local str_input = table.concat(input, "\n") .. "\n" -- cleaner concat

    local messages = {}
    for role, code in str_input:gmatch("@role:%s*(%w+)%s*@content:%s*<code>(.-)</code>") do
        -- Remove leading/trailing blank lines, preserve indentation
        code = code:gsub("^%s*\n", ""):gsub("\n%s*$", "")
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
local function get_suffix_if_prefix(currline, suggestion)
    if not currline or not suggestion or #currline == 0 then
        return suggestion or "", 1
    end

    local l1 = #currline
    local l2 = #suggestion

    if l1 > l2 then
        return "", 0
    end

    if suggestion:sub(1, l1) == currline then
        if l1 == l2 then
            return "", l2 + 1
        end

        local remaining_suffix = suggestion:sub(l1 + 1)
        return remaining_suffix, l1 + 1
    else
        return "", 0
    end
end

---@param curr string
---@param suggestion string
function M.partial_match(curr, suggestion)
    if curr == suggestion then
        return
    end
    if suggestion:sub(1, #curr) == curr then
        return suggestion:sub(#curr + 1), #curr
    end
end

---@param suggestion string
function M.adjust_suggestion(curr, suggestion)
    return get_suffix_if_prefix(curr, suggestion)
end

return M
