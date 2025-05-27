local uv = vim.loop
local M = {}

local default_config = {
    virt_text_style = {
        fg = "#333333", -- Slightly grey
        bg = "",        -- transparent background or default
        bold = false,   -- No bolds
        italic = false, -- No italics
    }
}

function M.setup(config)
    M.presets = config.presets or {}
    M.presets.original = config
    config.presets = nil

    M.config = vim.tbl_deep_extend('force', default_config, config or {})

    if vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = 'ModelGhosttext' })) then
        vim.api.nvim_set_hl(0, 'ModelGhosttext', M.config.virt_text_style)
    end
end

M.ns_id = vim.api.nvim_create_namespace("model_cmp.ghosttext")
M.augroup = vim.api.nvim_create_augroup("ModelGhosttext", { clear = true })


---@class virtual_text
---@field aug_id integer: augroup id
---@field ns_id integer: namespace id
---@field ext_id integer: extmark id
---@field ctx table: context window for the text to be sent to the model
---@field suggestion table: suggestion by the model to be displayed as ghosttext
---@field bufnr integer: where to display the ghosttext
---
---Simple Text manager for virtual text
local text_manager = {
    aug_id = M.augroup,
    ns_id = M.ns_id,
    ext_id = 1,
    ctx = {},
    suggestion = {},
    bufnr = vim.api.nvim_get_current_buf(),
}

local clear_preview = function()
    vim.api.nvim_buf_del_extmark(0, text_manager.ns_id, text_manager.ext_id)
end

local reset_ctx = function()
    text_manager.ctx = {}
end

local reset_suggestion = function()
    text_manager.suggestion = {}
end

local reset = function()
    clear_preview()
    reset_ctx()
    reset_suggestion()
end

local update_preview = function(displaytext)
    -- Setup context
    -- Setup Suggestions

    if displaytext == nil then
        return
    end
    -- Get Cursor pos and line
    local cursorcol = vim.fn.col '.'
    local cursorline = vim.fn.line '.'

    local extmark = {
        id = text_manager.ext_id,
        virt_text = { { displaytext, 'ModelGhosttext' } },
        virt_text_pos = 'inline'
    }

    vim.api.nvim_buf_set_extmark(0, text_manager.ns_id, cursorline - 1, cursorcol - 1, extmark)
end

local trigger = function(displaytext)
    if vim.fn.mode() ~= 'i' then
        clear_preview()
        return
    end
    update_preview(displaytext)
end

------------------------------------------------------------------------------
---------------------------------ACTION---------------------------------------
------------------------------------------------------------------------------
local action = {}

function action.disable_auto_trigger()
    vim.g.model_cmp_ghosttext_auto_trigger = false
end

function action.enable_auto_trigger()
    vim.g.model_cmp_ghosttext_auto_trigger = true
end

function action.toggle_auto_trigger()
    vim.g.model_cmp_ghosttext_auto_trigger = function()
        return not vim.b.model_cmp_ghosttext_auto_trigger
    end
end

function action.clear_preview()
    clear_preview()
end

function action.trigger(displaytext)
    trigger(displaytext)
end

vim.api.nvim_create_autocmd('InsertLeave', {
    group = M.augroup,
    callback = clear_preview,
    desc = ''
})


M.action = action

return M
