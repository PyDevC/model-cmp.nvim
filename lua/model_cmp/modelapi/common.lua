local config = require("model_cmp.config")
local context = require("model_cmp.context")
local logger = require("model_cmp.logger")
local prompter = require("model_cmp.modelapi.prompt")
local req = require("model_cmp.modelapi.request")
local utils = require("model_cmp.utils")
local virtualtext = require("model_cmp.virtualtext")

local gemini = require("model_cmp.modelapi.gemini")
local llama = require("model_cmp.modelapi.llama")

local M = {}

vim.g.model_cmp_connection_server = nil

local available_keys = {
    GEMINI_API_KEY = 0,
}

local function check_available()
    for keyname, key in pairs(config.api.apikeys) do
        local envkey = os.getenv(keyname)
        if key ~= "" or envkey ~= "" then
            available_keys[keyname] = 1
        end
    end

    if M.custom_url ~= nil then
        if M.custom_url.url == "" or M.custom_url.port == "" then
            M.custom_url = { url = "http://127.0.0.1", port = "8080" }
        else
            M.custom_url = config.api.custom_url
        end
    end
end

function M.send_request()
    local ctx = context.generate_context_text()
    local currlang = context.ContextEngine.currlang

    local prompt = prompter.generate_prompt(currlang, ctx)
    local request

    local server = vim.g.model_cmp_connection_server
    if server == nil then
        logger.trace("NO server setup")
        return
    end
    if server == "local_llama" then
        request = llama.generate_request(prompt)
    elseif server == "gemini" then
        if available_keys.GEMINI_API_KEY ~= 1 then
            logger.error("GEMINI_API_KEY is not set")
            return
        end
        request = gemini.generate_request(prompt)
    end

    if request == nil then
        return
    end

    req.send(request, function(response)
        vim.schedule(function()
            local text = nil
            local type = vim.g.model_cmp_connection_server
            text = utils.decode_response(response, type)
            if text == nil or text == "" then
                return
            end
            virtualtext.VirtualText:update_preview(text)
        end)
    end)
end

function M.stop()
    vim.g.model_cmp_connection_server = nil
end

---@param opts? ModelCmp.Config
function M.setup(opts)
    local api = config.api
    check_available()
end

return M
