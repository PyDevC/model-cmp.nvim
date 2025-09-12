local apiconfig = require("model_cmp.modelapi.apiconfig")
local logger = require("model_cmp.logger")

local M = {}

-- The same is in utils but this one is for gemini specific output
function M.decode_response(response)
    local ok, response_table = pcall(vim.fn.json_decode, response)
    if not ok or response_table == nil then
        logger.warning("No response recorded, please check the API key or internet connection.")
        return
    end

    if response_table.error ~= nil then
        logger.error("Something wrong with your api key")
    end
    return response_table.candidates[1].content.parts[1].text
end

local function generate_url(model_name)
    return "https://generativelanguage.googleapis.com/v1beta/models/" .. model_name .. ":generateContent"
end

function M.start(model_name)
    vim.g.server = "gemini"
end

local function transform_ctx_messages(ctx_messages)
    -- Transforming few shot messages
    local new_chat = {}
    for _, msg in ipairs(ctx_messages) do
        local gemini_message = {}
        if msg.role == 'user' then
            gemini_message = {
                role = 'user',
                parts = {
                    { text = msg.content },
                },
            }
        elseif msg.role == 'assistant' then
            gemini_message = {
                role = 'model',
                parts = {
                    { text = msg.content },
                },
            }
        end
        table.insert(new_chat, gemini_message)
    end
    return new_chat
end

function M.generate_request(ctx_messages, content, mainctx)
    local messages = transform_ctx_messages(ctx_messages)
    local mainmsg = {
        role = 'user',
        parts = {
            { text = mainctx },
        },
    }

    table.insert(messages, mainmsg)
    local apikey = "x-goog-api-key: " .. apiconfig.get_env_keys("GEMINI_API_KEY")
    local request = {
        -- TODO: ask user to add model of their choice
        generate_url("gemini-1.5-flash"),
        "-H", "Content-Type: application/json",
        "-H", apikey,
        "-X", "POST",
        "-d",
        vim.fn.json_encode({
            system_instruction = {
                parts = {
                    text = content
                }
            },
            contents = messages,
            generationConfig = {
                temperature = 0.1,
                maxOutputTokens = 128,
                stopSequences = { "</s>" }
            }
        })
    }
    return request
end

return M
