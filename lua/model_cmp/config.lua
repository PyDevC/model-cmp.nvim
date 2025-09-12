local apiconfig = require("model_cmp.modelapi.apiconfig")

local M = {}

---@class ModelCmp.Config
---@field api ModelCmp.Modelapi.Config
---@field virtualtext table<string, string> virtual text config

---@return ModelCmp.Config
function M.default()
    return {
        delay = 1000,
        api = apiconfig.default(),

        virtualtext = {
            enable = false,
            type = "inline",
            style = { -- This is just a highlight group
                fg = "#b53a3a",
                italic = false,
                bold = false
            }
        },
    }
end

return M
