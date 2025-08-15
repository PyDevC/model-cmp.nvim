local context = require("model_cmp.context")

local M = {}

M.ns_id = vim.api.nvim_create_namespace("model_cmp.ghosttext")
M.augroup = vim.api.nvim_create_augroup("ModelGhosttext", { clear = true }) -- we will this in future for virtual text themes

M.CaptureText = {}

---@class ModelCmp.VitualText
---@field aug_id integer augroup id
---@field ns_id integer namespace id
---@field ext_ids integer[] extmark ids
M.VirtualText = {
    aug_id = M.augroup,
    ns_id = M.ns_id,
    ext_ids = {},
}

function M.VirtualText:clear_preview(ext_ids_arg)
    local ext_ids = ext_ids_arg or self.ext_ids
    for ext_id in pairs(ext_ids) do
        vim.api.nvim_buf_del_extmark(0, self.ns_id, ext_id)
    end
end

function M.VirtualText:update_preview(text)
    if vim.api.nvim_get_mode().mode ~= "i" then
        return
    end
    local ctx = context.ContextEngine:get_ctx()
    local cursor = context.ContextEngine.cursor

    local lines = {}
    for line in text:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local max_line = vim.api.nvim_buf_line_count(0) - cursor[1] + 1
    local extmark = {}
    for idx, line in ipairs(lines) do
        if idx == max_line then
            return
        end
        table.insert(self.ext_ids, idx)
        extmark = {
            id = idx,
            virt_text = { { line, 'Comment' } },
            right_gravity = true,
        }
        vim.api.nvim_buf_set_extmark(0, self.ns_id, cursor[1] + idx - 2, 0, extmark)
    end
    M.CaptureText = lines
end

------------------------------------------------------------------------------
---------------------------------ACTION---------------------------------------
------------------------------------------------------------------------------
local action = {}

function action.capturefirstline()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line, col = cursor[1] - 1, cursor[2]
    M.CaptureText = vim.list_slice(M.CaptureText, 1, 1)
    M.VirtualText:clear_preview()

    vim.api.nvim_buf_set_text(0, line, col, line, col, M.CaptureText)
    local new_col = vim.fn.strcharlen(M.CaptureText[#M.CaptureText])
    if #M.CaptureText == 1 then
        new_col = new_col + col
    end
    vim.api.nvim_win_set_cursor(0, { line + #M.CaptureText, new_col })
    M.CaptureText = {}
end

function action.capturealllines()
end

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

function action.clear_preview(ext_ids_arg)
    M.VirtualText:clear_preview(ext_ids_arg)
end

M.action = action

return M
