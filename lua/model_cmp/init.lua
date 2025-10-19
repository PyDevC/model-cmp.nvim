local M = {}

M.MainAutoGrp = vim.api.nvim_create_augroup("model_cmp_maingrp", {})

---@param opts? ModelCmp.Config
function M.setup(opts)
    require("model_cmp.config").setup(opts, M.MainAutoGrp)
end

return M
