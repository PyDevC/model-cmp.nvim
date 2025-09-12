local M = {}

---@class ModelCmp.Modelapi.Config
---@field apikeys APIKeyHolder
---@field custom_url table<string, string>

---@class APIKeyHolder
---@field GEMINI_API_KEY string

---@return APIKeyHolder
local function get_apikeys()
    return {
        GEMINI_API_KEY = ""
    }
end

function M.get_env_keys(type)
    local apikey = os.getenv(type)
    if not apikey or apikey == "" then
        return ""
    end
    return apikey
end

---@return ModelCmp.Modelapi.Config
function M.default()
    local keys = get_apikeys()
    return {
        apikeys = keys,
        custom_url = {
            url = "http://127.0.0.1",
            port = "8080"
        }
    }
end

return M
