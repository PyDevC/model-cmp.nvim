local M = {}

---@param opts? ModelCmp.Config
function M.setup(opts)
    require("model_cmp.config").setup(opts)
end

return M
