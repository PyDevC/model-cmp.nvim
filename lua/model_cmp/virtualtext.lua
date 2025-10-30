local config = require("model_cmp.config")
local utils = require("model_cmp.utils")

---@class ModelCmp.VitualText
---@field aug_id integer augroup id
---@field ns_id integer namespace id
---@field ext_ids integer extmark id

---@class CaptureText
---@field contents string[]
---@field bufferid integer
---@field line_number integer

local M = {}

M.ns_id = vim.api.nvim_create_namespace("model_cmp.virtualtext")
M.augroup = vim.api.nvim_create_augroup("model_cmp_virtualtext", { clear = true })

M.CaptureText = {
    content = nil,
    bufferid = 0,
    line_number = nil,
}

M.VirtualText = {
    aug_id = M.augroup,
    ns_id = M.ns_id,
    ext_ids = nil,
}

function M.VirtualText:clear_preview()
    if self.ext_ids == nil then
        return
    end
    vim.api.nvim_buf_del_extmark(0, self.ns_id, self.ext_ids)
    self.ext_ids = nil
end

---@param text string
function M.VirtualText:update_preview(text)
    -- Checking all conditions before running update preview
    if self.ext_ids ~= nil then
        require("model_cmp.logger").info("clearning preview")
        self:clear_preview()
    end

    if not vim.g.model_cmp_virtualtext_auto_trigger then
        return
    end

    if vim.fn.mode() ~= "i" or vim.g.model_cmp_set_nomode == true then
        return
    end

    require("model_cmp.logger").trace("updating preview")

    local cursor = vim.api.nvim_win_get_cursor(0) -- {line, col}
    M.CaptureText.line_number = cursor[1]
    M.CaptureText.bufferid = vim.api.nvim_get_current_buf()

    vim.b.cursor = cursor

    local lines = {}
    for line in text:gmatch("([^\n]*)[\n]?") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end

    local ns_id = self.ns_id or vim.api.nvim_create_namespace("MyPluginVirtualText")
    self.ns_id = ns_id

    local curr = vim.api.nvim_get_current_line()

    for idx = 1, #lines do
        local suggestion, col_num = utils.partial_match(curr, lines[idx])
        if suggestion ~= nil and col_num ~= nil then
            if suggestion ~= "" then
                M.CaptureText.content = utils.adjust_suggestion(curr, suggestion)
                self.ext_ids = idx
                vim.api.nvim_buf_set_extmark(0, ns_id, cursor[1] - 1, col_num, {
                    id = idx,
                    virt_text = { { suggestion, "CustomVirttextHighlight" } },
                    undo_restore = true,
                    virt_text_pos = "overlay",
                })
                return
            end
        end
    end
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
    -- TODO: check for buffer
    local currline = vim.fn.line(".")
    vim.api.nvim_buf_set_lines(0, currline - 1, currline, false, { M.CaptureText.content })
end

function action.capturealllines() end

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
