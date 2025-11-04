local logger = require("model_cmp.logger")

local M = {}

vim.g.server_error_count = 0

---@param response string json as string
---@param type string type of server running
function M.decode_response(response, type)
    local ok, response_table = pcall(vim.fn.json_decode, response)

    if not ok or response_table == nil then
        logger.warning("Error decoding response")
        return
    end

    if response_table.error ~= nil then
        vim.g.server_error_count = vim.g.server_error_count + 1
        return
    end

    if type == "gemini" then
        if response_table.candidates[1].content == nil or response_table.candidates[1].content.parts[1].text == nil then
            logger.warning("Error no candidates available")
            return
        end
        return response_table.candidates[1].content.parts[1].text
    elseif type == "local_llama" then
        if response_table.choices[1].message.content == nil then
            logger.warning("Error no content available")
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

---@param curr string
---@param suggestion string
function M.partial_match(curr, suggestion)
    local original_len = #curr

    curr = curr:match("^%s*(.*)")
    suggestion = suggestion:match("^%s*(.*)")

    if curr == nil or suggestion == nil or curr == suggestion then
        return
    end

    if suggestion:sub(1, #curr) == curr then
        logger.debugging("partial_match: suggestion: ", suggestion:sub(#curr + 1))
        return suggestion:sub(#curr + 1), original_len
    end
end

---@param suggestion string
function M.adjust_suggestion(curr, suggestion)
    return curr .. suggestion
end

return M
