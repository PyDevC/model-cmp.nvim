local req = require("model_cmp.modelapi.request")
local virtualtext = require("model_cmp.virtualtext")
local utils = require("model_cmp.utils")
local apiconfig = require("model_cmp.modelapi.apiconfig")

-- server channels
local llama = require("model_cmp.modelapi.llama")

local M = {}

vim.g.server = "url" -- llama is default available options are openai, claude

-- 0 means not avaiable and 1 means avaiable
local available_keys = {
    OPENAI_API_KEY = 0,
    CLAUDE_API_KEY = 0,
}

local function servername_to_key()
    local server = vim.g.server
    if server == "openai" then
        return "OPENAI_API_KEY"
    elseif server == "claude" then
        return "CLAUDE_API_KEY"
    else
        return
    end
end


--Check for availability for both apikeys and server urls
local function check_available()
    for keyname, key in ipairs(M.apikeys) do
        if key ~= "" then
            available_keys[keyname] = 1
        end
    end
    if M.custom_url ~= nil then
        if M.custom_url.url == "" or M.custom_url.port == "" then
            M.custom_url = { url = "http://127.0.0.1", port = "8080" }
        end
    else
        M.custom_url = apiconfig.default().custom_url
    end
end

M.requests = {} -- only store buffer id

local function add_request(bufid)
    local index = #M.requests + 1
    table.insert(M.requests, bufid)
    return index
end

local function remove_request(index)
    table.remove(M.requests, index)
end

-- we will check if there is a request already made for the given buffer
local function check_already_requested(bufnr)
    for buffer in pairs(M.requests) do
        if bufnr == buffer then
            return true
        end
    end
    return false
end

function M.send_request()
    local request, bufnr

    local server = vim.g.server
    if server == "url" then
        bufnr, request = llama.generate_request()
    elseif server == "openai" then
        if available_keys[servername_to_key()] then
            -- Working on openai services
        end
    elseif server == "claude" then
        if available_keys[servername_to_key()] then
            -- Working on claude services
        end
    end

    if request == nil then
        return
    end
    if check_already_requested(bufnr) then
        return
    end

    add_request(bufnr)
    req.send(request,
        function(response)
            vim.schedule(function()
                local text = utils.decode_response(response)
                virtualtext.VirtualText:update_preview(text)
                remove_request(bufnr)
            end)
        end
    )
end

function M.setup(config)
    local api = config.api
    M.apikeys = api.apikeys
    M.custom_url = api.custom_url
    check_available()
end

return M
