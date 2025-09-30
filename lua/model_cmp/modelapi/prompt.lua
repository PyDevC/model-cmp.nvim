local utils = require("model_cmp.utils")

local M = {}

M.default_systemrole = {
    role = "system",
    content = [[Act as GitHub Copilot. Complete the code where the <missing> token is.
Follow the instructions:
- Output only the current line after replacing the <missing> tag.
- No explanations, no comments, no full files generations allowed.
- Max code generation is 5 lines.
- Match the language and indentation.
]]
}

---@param language string
local function fewshot_lang_parser(language)
    local datadir = vim.fn.stdpath('data') .. "/lazy/model-cmp.nvim/data/"
    local ok, file = pcall(vim.fn.readfile, datadir .. language .. ".txt")
    if not ok then
        return
    end
    return utils.parse_messages(file)
end

---@param language string
---@param ctx table<string>
---@return Singlefewshot
local function generate_context_shot(language, ctx)
    local langprompt = "#language: " .. language
    return {
        role = "user",
        content = langprompt .. "\n" .. ctx
    }
end

---@class Singlefewshot
---@field role string<"user" | "assistant" | "model" | "system">
---@field content string

---@class Prompt
---@field systemrole Singlefewshot
---@field fewshots table<Singlefewshot>
---@field language string
---@field context Singlefewshot

---@param ctx any
---@return Prompt
function M.default_prompt(ctx)
    return {
        systemrole = M.default_systemrole,
        fewshots = nil,
        language = "text",
        context = ctx
    }
end

function M.generate_prompt(language, ctx)
    local prompt = M.default_prompt(ctx)
    prompt.context = generate_context_shot(language, ctx)
    if language == "text" or language == "" then
        return prompt
    end
    local fewshots = fewshot_lang_parser(language)
    if fewshots == nil then
        return prompt
    end
    prompt.fewshots = fewshots
    prompt.language = language
    return prompt
end

return M
