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
        CLAUDE_API_KEY = "",
        GEMINI_API_KEY = ""
    }
end

function M.get_env_keys(type)
    local apikey = os.getenv(type)
    if not apikey or apikey == "" then
        -- log that api key is not set
    end
    return apikey
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
