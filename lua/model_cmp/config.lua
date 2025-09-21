---@class ModelCmp.Config
---@field integrations table<string, boolean>
---@field request_delay integer
---@field api ModelCmp.Modelapi.Config
---@field virtualtext table<string, string> virtual text config

local M = {}

---@return ModelCmp.Config
function M.default()
    return {
        -- These integrations are future integrations so setting these will not work
        integrations = {
            lspconfig = true,
            cmp = true,
            coq = true,
            blink = true
        },
        request_delay = 1000,
        api = require("model_cmp.modelapi.apiconfig").default,
        virtualtext = {
            enable = false,
            type = "inline",
            style = {
                -- Setup the Highlight group for Virtual text suggestions
                fg = "#b53a3a",
                italic = false,
                bold = false
            }
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
    return options
end

return setmetatable(M, {
  __index = function(_, key)
    options = options or M.setup()
    return options[key]
  end,
})
