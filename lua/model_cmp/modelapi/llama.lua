local curl = require("model_cmp.modelapi.curl")
local context = require("model_cmp.context")
local systemprompt = require("model_cmp.modelapi.prompt")
local ghosttext = require("model_cmp.ghosttext")
local utils = require("model_cmp.utils")

local M = {}

vim.b.request_sent = false

local get_server_url = function() -- get server url from the user or from the config
    return "http://127.0.0.1:8080/v1/chat/completions"
end

function M.send_request()
    local prompt = context.generate_context_text()
    local lang = context.ContextEngine:get_currlang()
    local complete_prompt = "# language: " .. lang .. prompt

    local few_shots = systemprompt.complete_few_shots

    local messages = {}
    table.insert(messages, systemprompt.default)
    for _, msg in ipairs(few_shots) do
        table.insert(messages, msg)
    end

    table.insert(messages, { role = "user", content = complete_prompt })
    local request = {
        "-s",
        "-X", "POST",
        get_server_url(),
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
    vim.b.request_sent = true
    curl.send(request,
        function(response)
            vim.schedule(function()
                local text = utils.decode_response(response)
                ghosttext.VirtualText:update_preview(text)
                vim.b.request_sent = false
            end)
        end
    )
end

--- TEMPORARY ACTIONS


function M.text_changed()
    if vim.b.request_sent then
        return
    end
    ghosttext.action.clear_preview()
    M.send_request()
end

return M
