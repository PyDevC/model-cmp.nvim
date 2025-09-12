local apiconfig = require("model_cmp.modelapi.apiconfig")

local M = {}

local generate_url = function(custom_url)
    local url = custom_url.url .. ":" .. custom_url.port .. "/v1/chat/completions"
    return url
end

function M.start(model_name)
    vim.g.server = ""
end

function M.generate_request(ctx_messages, ctx)
    local custom = apiconfig.default()
    local request = {
        "-s",
        "-X", "POST",
        generate_url(custom.custom_url),
        "-H", "Content-Type: application/json",
        "-d",
        vim.fn.json_encode({
            model = "llama",
            messages = ctx_messages,
            n_predict = 128,
            temperature = 0.1,
            stop = { "</s>" },
            max_token = 50
        }),
    }
    return request
end

return M
