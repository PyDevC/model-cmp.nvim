local M = {}

---@class ModelCmp.Modelapi.Config
---@field apikeys APIKeyHolder
---@field custom_url table<string, string>
---@field default string

---@class APIKeyHolder
---@field GEMINI_API_KEY string

---@type ModelCmp.Modelapi.Config
M.default = {
    apikeys = {
        GEMINI_API_KEY = "",
    },
    default = "local_llama",
    custom_url = {
        url = "http://127.0.0.1",
        port = "8080",
    },
}

return M
