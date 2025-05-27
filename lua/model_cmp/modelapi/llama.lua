local curl = require("model_cmp.modelapi.curl")
local context = require("model_cmp.context")
local systemprompt = require("model_cmp.modelapi.prompt")
local ghosttext = require("model_cmp.ghosttext")

local M = {}

vim.b.request_sent = false

local get_server_url = function() -- get server url from the user or from the config
    return "http://127.0.0.1:8080/v1/chat/completions"
end

function M.send_request()
    local prompt = context.generate_context_text()
    local request = {
        "-s",
        "-X", "POST",
        get_server_url(),
        "-H", "Content-Type: application/json",
        "-d",
        vim.fn.json_encode({
            model = "llama",
            messages = {
                { role = "system", content = systemprompt[1] },
                { role = "user",   content = prompt },
            },
            n_predict = 64,
            temperature = 0.1,
            stop = { "</s>" }
        }),
    }
    vim.b.request_sent = true
    curl.send(request,
        function(response)
            vim.schedule(function()
                -- Use vim.json.decode with error handling
                local ok, decoded = pcall(vim.json.decode, response)
                if not ok then
                    vim.notify("Failed to decode response:\n" .. tostring(response), vim.log.levels.ERROR)
                    return
                end

                local text = ""
                if decoded.choices and decoded.choices[1] and decoded.choices[1].message then
                    text = decoded.choices[1].message.content
                elseif decoded.choices and decoded.choices[1].text then
                    text = decoded.choices[1].text
                elseif decoded.content then
                    text = decoded.content
                end

                ghosttext.action.trigger(text)
                vim.b.request_sent = false
            end)
        end
    )
end

--- TEMPORARY ACTIONS

local autocmd = {}

function autocmd.text_changed()
    if vim.b.request_sent then
        return
    end
    ghosttext.action.clear_preview()
    M.send_request()
end

function M.create_autocmd()
    vim.api.nvim_create_autocmd('TextChangedI', {
        group = ghosttext.augroup,
        callback = autocmd.text_changed,
        desc = '',
    })
end

return M
