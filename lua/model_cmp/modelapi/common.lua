local apiconfig = require("model_cmp.modelapi.apiconfig")
local context = require("model_cmp.context")
local logger = require("model_cmp.logger")
local preprompt = require("model_cmp.modelapi.prompt")
local req = require("model_cmp.modelapi.request")
local utils = require("model_cmp.utils")
local virtualtext = require("model_cmp.virtualtext")

local gemini = require("model_cmp.modelapi.gemini")
local llama = require("model_cmp.modelapi.llama")

local M = {}

vim.g.server = "local_llama"

local available_keys = {
    GEMINI_API_KEY = 0
}

local function check_available()
    for keyname, key in pairs(apiconfig.default().apikeys) do
        local envkey = apiconfig.get_env_keys(keyname)
        if key ~= "" or envkey ~= "" then
            available_keys[keyname] = 1
        end
    end

    if M.custom_url ~= nil then
        if M.custom_url.url == "" or M.custom_url.port == "" then
            M.custom_url = { url = "http://127.0.0.1", port = "8080" }
        else
            M.custom_url = apiconfig.default().custom_url
        end
    end
end

function M.send_request()
    local bufnr = context.ContextEngine.bufnr
    local few_shots = preprompt.complete_few_shots
    local request

    local server = vim.g.server
    if vim.g.server == "" or vim.g.server == nil then
        logger.error("NO server setup")
        return
    end
    if server == "default" or server == "local_llama" then
        request = llama.generate_request(few_shots)
    elseif server == "gemini" then
        if available_keys.GEMINI_API_KEY ~= 1 then
            logger.error("GEMINI_API_KEY is not set")
            return
        end
        request = gemini.generate_request(few_shots)
    end

    if request == nil then
        return
    end

    req.send(request,
        function(response)
            vim.schedule(function()
                local text = ""
                if vim.g.server == "gemini" then
                    text = gemini.decode_response(response)
                else
                    text = utils.decode_response(response)
                end
                if text == nil or text == "" then
                    return
                end
                virtualtext.VirtualText:update_preview(text)
            end)
        end
    )
end

function M.stop()
    vim.g.server = ""
end

function M.setup(config)
    local api = config.api
    M.apikeys = api.apikeys

    for type, keys in pairs(M.apikeys) do
        keys = apiconfig.get_env_keys(type)
    end

    M.custom_url = api.custom_url
    check_available()
end

return M
