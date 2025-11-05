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
function M.partial_match(curr, suggestion, cursor)
    -- Extract prefix from current line
    local prefix = curr:sub(1, cursor[2])
    local suffix = nil
    local original_len = #prefix

    -- Triming all blank spaces
    curr = curr:match("^%s*(.*)")
    prefix = prefix:match("^%s*(.*)")
    suggestion = suggestion:match("^%s*(.*)")

    -- if prefix is not equal to suffix after triming then there must be suffix
    if prefix ~= curr then
        local s, e = string.find(curr, prefix)
        if s then
            suffix = curr:sub(e, -1)
        end
    end

    if prefix == nil or suggestion == nil or curr == suggestion then
        return
    end

    if suggestion:sub(1, #prefix) == prefix then
        local virtual_suggestion = suggestion:sub(1, #prefix)
        if suffix then
            local s, _ = string.find(virtual_suggestion, suffix)
            if not s then
                return
            end
        end
        return suggestion:sub(#prefix + 1), original_len
    end
end

---@param virtual_suggestion string virtual_suggestion that was displayed
---@param curr string current line
---@param original_len number length of prefix
function M.adjust_suggestion(curr, virtual_suggestion, original_len)
    local prefix = curr:sub(1, original_len)
    return prefix .. virtual_suggestion
end

return M
