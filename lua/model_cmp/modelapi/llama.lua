local context = require("model_cmp.context")
local systemprompt = require("model_cmp.modelapi.prompt")
local apiconfig = require("model_cmp.modelapi.apiconfig")

local M = {}

vim.b.request_sent = false

local generate_url = function(custom_url)
    local url = custom_url.url .. ":" .. custom_url.port .. "/v1/chat/completions"
    return url
end

function M.generate_request()
    local bufnr = context.ContextEngine.bufnr
    local prompt = context.generate_context_text()
    local lang = context.ContextEngine:get_currlang()
    local complete_prompt = "# language: " .. lang .. prompt

    local few_shots = systemprompt.complete_few_shots

    local custom = apiconfig.default()
    local messages = {}
    table.insert(messages, systemprompt.default)
    for _, msg in ipairs(few_shots) do
        table.insert(messages, msg)
    end

    table.insert(messages, { role = "user", content = complete_prompt })
    local request = {
        "-s",
        "-X", "POST",
        generate_url(),
        "-H", "Content-Type: application/json",
        "-d",
        vim.fn.json_encode({
            model = "llama",
            messages = messages,
            n_predict = 128,
            temperature = 0.1,
            stop = { "</s>" },
            max_token = 50
        }),
    }
    return bufnr, request
end

return M
