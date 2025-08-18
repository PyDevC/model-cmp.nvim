local commands = require("model_cmp.commands")

local M = {}

local model_cmp_grp = vim.api.nvim_create_augroup("model_cmp_grp", {})

function M.setup()
    vim.g.model_cmp_virtualtext_auto_trigger = true
    commands.create_autocmds(model_cmp_grp)
end

return M
