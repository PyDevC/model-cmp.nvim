local os = os
local M = {}

M.API_KEYS = {
    OPENAI = "",
}

M.API_KEY_TYPE = {
    "OPENAI_API_KEY",
}

function M.api_is_set()
    if vim.g.API_KEYS == nil then
        return false
    end
    return true
end

function M.is_available(config)
    -- check if the api key is there in config
    local available = false
    local next = next
    local api_keys = config.api_keys
    if api_keys ~= nil and next(api_keys) ~= nil then
        vim.g.OPENAI_API_KEY = api_keys.OPENAI_API_KEY
        available = true
    end

    -- check if there is any environment variable for API KEY
    for idx, key in pairs(M.API_KEY_TYPE) do
        local currkey = os.getenv(key)
        if currkey ~= nil then
            if key == "OPENAI_API_KEY" then
                M.API_KEYS.OPENAI = currkey
                available = true
            end
        end
    end

    vim.g.API_KEYS = M.API_KEYS

    return available
end

function M.get_api_key(keytype)
    return vim.g.API_KEYS[keytype]
end

return M
