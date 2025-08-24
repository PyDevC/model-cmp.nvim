local M = {}

---@class ModelCmp.Modelapi.Config
---@field apikeys APIKeyHolder
---@field custom_url table<string, string>

---@class APIKeyHolder
---@field OPENAI_API_KEY string
---@field CLAUDE_API_KEY string

---@return APIKeyHolder
local function get_apikeys()
    return {
        OPENAI_API_KEY = "",
        CLAUDE_API_KEY = ""
    }
end

---@return ModelCmp.Modelapi.Config
function M.default()
    return {
        apikeys = get_apikeys(),
        custom_url = {
            url = "http://127.0.0.1",
            port = "8080"
        }
    }
end

return M
