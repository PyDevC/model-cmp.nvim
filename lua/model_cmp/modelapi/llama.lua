local apiconfig = require("model_cmp.modelapi.apiconfig")

local M = {}

local generate_url = function(custom_url)
    local url = custom_url.url .. ":" .. custom_url.port .. "/v1/chat/completions"
    return url
end

function M.start()
    vim.g.model_cmp_connection_server = "local_llama"
end

---@param prompt Prompt
function M.generate_request(prompt)
    local custom = apiconfig.default

    local messages = { prompt.systemrole }
    if prompt.language ~= "text" then
        for _, k in ipairs(prompt.fewshots) do
            table.insert(messages, k)
        end
    end
    local context = {
        role = "user",
        content = prompt.context.content,
    }
    table.insert(messages, context)

    local request = {
        "-s",
        "-X",
        "POST",
        generate_url(custom.custom_url),
        "-H",
        "Content-Type: application/json",
        "-d",
        vim.fn.json_encode({
            model = "llama",
            messages = messages,
            n_predict = 128,
            temperature = 0.1,
            stop = { "</s>" },
            max_token = 50,
        }),
    }
    return request
end

return M
