local config = require("model_cmp.config")
local utils = require("model_cmp.utils")
local logger = require("model_cmp.logger")

---@class ModelCmp.VitualText
---@field aug_id integer augroup id
---@field ns_id integer namespace id
---@field ext_ids integer[] extmark ids

---@class CaptureText
---@field contents string[]
---@field bufferid integer
---@field line_number integer

local M = {}

M.ns_id = vim.api.nvim_create_namespace("model_cmp.virtualtext")
M.augroup = vim.api.nvim_create_augroup("model_cmp_virtualtext", { clear = true })

M.CaptureText = {
    contents = {},
    bufferid = 0,
    line_number = nil,
}

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
        require("model_cmp.logger").info("clearning preview")
        self:clear_preview()
    end
    if not vim.g.model_cmp_virtualtext_auto_trigger or text == nil or text == "" then
        return
    end
    if vim.fn.mode() ~= "i" or vim.g.model_cmp_set_nomode == true then
        return
    end
    require("model_cmp.logger").info("updating preview")

    local cursor = vim.api.nvim_win_get_cursor(0) -- {line, col}
    local current_line_num = cursor[1]
    M.CaptureText.line_number = current_line_num

    vim.b.cursor = cursor

    local lines = {}
    for line in text:gmatch("([^\n]*)[\n]?") do
        logger.info(line)
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    M.CaptureText.contents = lines

    local ns_id = self.ns_id or vim.api.nvim_create_namespace("MyPluginVirtualText")
    self.ns_id = ns_id

    local suggestion, col_num = utils.adjust_suggestion(lines[1])
    local extmark_id = 1
    vim.api.nvim_buf_set_extmark(0, ns_id, current_line_num - 1, col_num - 1, {
        id = extmark_id,
        virt_text = { { suggestion, "CustomVirttextHighlight" } },
        hl_mode = "combine",
    })
    table.insert(self.ext_ids, extmark_id)

    if #lines == 1 then
        return
    end

    for idx = 2, #lines do
        local line_text = lines[idx]
        extmark_id = idx
        vim.api.nvim_buf_set_extmark(0, ns_id, current_line_num + idx - 2, 0, {
            id = extmark_id,
            virt_text = { { line_text, "CustomVirttextHighlight" } },
            right_gravity = true,
            undo_restore = true,
        })
        table.insert(self.ext_ids, extmark_id)
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
    vim.api.nvim_buf_set_lines(0, currline - 1, currline, false, { M.CaptureText.contents[1] })
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
