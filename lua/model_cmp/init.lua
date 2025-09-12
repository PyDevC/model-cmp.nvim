local api = require("model_cmp.modelapi.common")
local commands = require("model_cmp.commands")
local logger = require("model_cmp.logger")
local mainconfig = require("model_cmp.config")
local virtualtext = require("model_cmp.virtualtext")

local M = {}

local model_cmp_grp = vim.api.nvim_create_augroup("model_cmp_grp", {})

function M.setup(config)
    config = config or {}
    local default_config = mainconfig.default()
    config = vim.tbl_deep_extend('force', default_config, config)

    commands.setup(config)
    commands.create_autocmds(model_cmp_grp)
    commands.create_usercmds()

    virtualtext.setup(config)
    api.setup(config)
    logger.trace("Setup Completed for model-cmp.nvim")
end

return M
