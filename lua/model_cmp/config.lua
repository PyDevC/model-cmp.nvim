local M = {}

---@class ModelCmp.Config
---@field delay integer delay between each request in ms
---@field api table<string, table<string, any>> API request or server request config
---@field virtualtext table<string, string> virtual text config
---@field prompt Prompt prompts for api

---@class Prompt
---@field basic_template string
---@field rules string
---@field language string
---@field precontext string

---@return ModelCmp.Config
function M.default()
    return {
        delay = 0,
        api = {
            url = "", -- url to the server, defaults are already set, you just need to setup this up only if the url is different for your server
            key = "", -- None if using local
            type = "" -- EX: OPENAI, Claude, Gemini, llama.cpp(local or none are also valid)
        },
        virtualtext = {
            enable = true,
            type = "inline",
            style = {
            }
        },
        prompt = {
            basic_template = "",
            rules = "",
            language = "",
            precontext = ""
        },
    }
end

return M
