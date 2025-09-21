local config = require("model_cmp.config")

---@class ModelCmp.VitualText
---@field aug_id integer augroup id
---@field ns_id integer namespace id
---@field ext_ids integer[] extmark ids

local M = {}

M.ns_id = vim.api.nvim_create_namespace("model_cmp.virtualtext")
M.augroup = vim.api.nvim_create_augroup("model_cmp_virtualtext", { clear = true })

M.VirtualText = {
    aug_id = M.augroup,
    ns_id = M.ns_id,
    ext_ids = {},
}

function M.VirtualText:clear_preview()
    for ext_id in pairs(self.ext_ids) do
        vim.api.nvim_buf_del_extmark(0, self.ns_id, ext_id)
    end
    self.ext_ids = {}
end

---@param text string
function M.VirtualText:update_preview(text)
    -- Checking all conditions before running update preview
    if #self.ext_ids > 0 then
        self:clear_preview()
    end
    if not vim.g.model_cmp_virtualtext_auto_trigger or text == nil or text == "" then
        return
    end
    if vim.fn.mode() ~= "i" or vim.g.model_cmp_set_nomode == true then
        return
    end

    local cursor = vim.api.nvim_win_get_cursor(0) -- {line, col}
    local current_line_num = cursor[1]
    local current_line_text = vim.api.nvim_get_current_line()

    vim.b.cursor = cursor

    local lines = {}
    for line in text:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    lines = { text }

    local ns_id = self.ns_id or vim.api.nvim_create_namespace("MyPluginVirtualText")
    self.ns_id = ns_id

    for idx = 1, #lines do
        local line_text = lines[idx]
        local extmark_id = idx
        vim.api.nvim_buf_set_extmark(0, ns_id, current_line_num + idx - 2, 0, {
            id = extmark_id,
            virt_text = { { line_text, "CustomVirttextHighlight" } },
            right_gravity = true,
            undo_restore = true,
        })
        table.insert(self.ext_ids, extmark_id)
    end

    M.CaptureText = lines
end

function M.setup()
    vim.g.model_cmp_virtualtext_auto_trigger = config.virtualtext.enable
    vim.api.nvim_set_hl(0, "CustomVirttextHighlight", config.virtualtext.style)
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
    vim.g.model_cmp_virtualtext_auto_trigger = false
    M.VirtualText:clear_preview()
end

function action.enable_auto_trigger()
    vim.g.model_cmp_virtualtext_auto_trigger = true
end

function action.toggle_auto_trigger()
    vim.g.model_cmp_virtualtext_auto_trigger = function()
        return not vim.b.model_cmp_virtualtext_auto_trigger
    end
    if not vim.g.model_cmp_virtualtext_auto_trigger then
        M.VirtualText:clear_preview()
    end
end

function action.clear_preview()
    M.VirtualText:clear_preview()
end

M.action = action

return M
