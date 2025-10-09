---@class ModelCmp.Config
---@field requests RequestConfig
---@field api ModelCmp.Modelapi.Config
---@field virtualtext table<string, string> virtual text config

---@class RequestConfig
---@field delay_ms integer Request Delay time in ms
---@field max_retries integer Number of retries possible in given timeout
---@field timeout_ms integer Time delay for requests max_retries option

local M = {}

---@return ModelCmp.Config
function M.default()
    return {
        requests = {
            delay_ms = 1000,
            max_retries = 5,
            timeout_ms = 300000,
        },
        api = require("model_cmp.modelapi.apiconfig").default,
        virtualtext = {
            enable = false,
            type = "inline",
            style = {
                -- Setup the Highlight group for Virtual text suggestions
                fg = "#b53a3a",
                italic = false,
                bold = false,
            },
        },
    }
end

---@type ModelCmp.Config
local options

---@param opts? ModelCmp.Config
---@return ModelCmp.Config
function M.setup(opts)
    opts = opts or {}
    ---@type ModelCmp.Config
    options = vim.tbl_deep_extend("force", M.default(), opts)
    require("model_cmp.commands").setup()
    require("model_cmp.virtualtext").setup()
    require("model_cmp.modelapi.common").setup(opts)
    require("model_cmp.utils").MAX_ERROR_COUNT = options.requests.max_retries
    return options
end

return setmetatable(M, {
    __index = function(_, key)
        options = options or M.setup()
        return options[key]
    end,
})
