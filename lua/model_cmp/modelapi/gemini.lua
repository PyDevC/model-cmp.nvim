local apiconfig = require("model_cmp.modelapi.apiconfig")
local logger = require("model_cmp.logger")

local M = {}

---@param model_name string
local function generate_url(model_name)
    return "https://generativelanguage.googleapis.com/v1beta/models/"
        .. model_name
        .. ":generateContent"
end

function M.start(model_name)
    vim.g.model_cmp_connection_server = "gemini"
end

---@param prompt Prompt
local function transform_fewshots(prompt)
    local new_chat = {}
    for _, msg in ipairs(prompt.fewshots) do
        local gemini_message = {}

        if msg.role == "user" then
            gemini_message = {
                role = "user",
                parts = {
                    { text = msg.content },
                },
            }
        elseif msg.role == "assistant" then
            gemini_message = {
                role = "model",
                parts = {
                    { text = msg.content },
                },
            }
        end

        table.insert(new_chat, gemini_message)
    end
    return new_chat
end

---@param prompt Prompt
function M.generate_request(prompt)
    local messages
    if prompt.language == "text" then
        messages = {}
    else
        messages = transform_fewshots(prompt)
    end
    local mainmsg = {
        role = "user",
        parts = {
            { text = prompt.context.content },
        },
    }

    table.insert(messages, { mainmsg })
    local apikey = "x-goog-api-key: " .. os.getenv("GEMINI_API_KEY")
    local request = {
        -- TODO: ask user to add model of their choice
        generate_url("gemini-2.0-flash"),
        "-H",
        "Content-Type: application/json",
        "-H",
        apikey,
        "-X",
        "POST",
        "-d",
        vim.fn.json_encode({
            system_instruction = {
                parts = {
                    text = prompt.systemrole.content,
                },
            },
            contents = messages,
            generationConfig = {
                temperature = 0.1,
                maxOutputTokens = 128,
                stopSequences = { "</s>" },
            },
        }),
    }
    return request
end

return M
