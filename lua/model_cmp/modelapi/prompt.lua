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
    -- need to add path for the language context file
    return { { role = "user", content = "nothing" } }
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
        fewshots = M.default_fewshots,
        language = "text",
        context = ctx
    }
end

function M.generate_prompt(language, ctx)
    local prompt = M.default_prompt(ctx)
    if language == "text" or language == "" then
        return prompt
    end
    local fewshots = fewshot_lang_parser(language)
    prompt.fewshots = fewshots
    prompt.language = language
    prompt.context = generate_context_shot(language, ctx)
    return prompt
end

return M
