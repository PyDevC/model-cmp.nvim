local context = require("model_cmp.context")

local M = {}

M.ns_id = vim.api.nvim_create_namespace("model_cmp.virtualtext")
M.augroup = vim.api.nvim_create_augroup("model_cmp_virtualtext", { clear = true })

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

local function remove_empty_lines()
    local start_line = vim.b.start_line
    local count = vim.b.count
    if start_line and count and count > 0 then
        vim.api.nvim_buf_set_lines(0, start_line - 1, start_line + count, false, {})
        vim.b.start_line = nil
        vim.b.count = nil
    end
    vim.api.nvim_win_set_cursor(0, vim.b.cursor)
end

function M.VirtualText:clear_preview(ext_ids_arg)
    if vim.b.start_line == nil then
        return
    end
    local ext_ids = ext_ids_arg or self.ext_ids
    for ext_id in pairs(ext_ids) do
        vim.api.nvim_buf_del_extmark(0, self.ns_id, ext_id)
    end
    remove_empty_lines()
end

local function insert_empty_lines(current_line, no_line)
    local lines = {}
    for i = 1, no_line do
        table.insert(lines, "")
    end
    vim.b.start_line = current_line
    vim.b.count = no_line
    vim.api.nvim_buf_set_lines(0, current_line - 1, current_line - 1, false, lines)
end

function M.VirtualText:update_preview(text)
    if vim.b.count ~= nil or vim.b.start_line ~= nil then
        self:clear_preview()
    end
    if not vim.g.model_cmp_virtualtext_auto_trigger or text == nil then
        return
    end
    if vim.api.nvim_get_mode().mode ~= "i" then
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

    local ns_id = self.ns_id or vim.api.nvim_create_namespace("MyPluginVirtualText")
    self.ns_id = ns_id
    self.ext_ids = {}

    local match_inline = false
    if #lines > 0 then
        local first_line = lines[1]
        -- Check if current line ends with a prefix of the first virtual line
        for i = #first_line, 1, -1 do
            local prefix = first_line:sub(1, i)
            if current_line_text:sub(- #prefix) == prefix then
                match_inline = true
                break
            end
        end
    end

    local start_index = 1
    if match_inline then
        -- Put the first line as virtual text inline with current line
        vim.api.nvim_buf_set_extmark(0, ns_id, current_line_num - 1, -1, {
            id = 1,
            virt_text = { { lines[1], "CustomVirttextHighlight" } },
            virt_text_pos = "eol",
            right_gravity = true,
        })
        table.insert(self.ext_ids, 1)
        start_index = 2
    end

    local num_remaining = #lines - (start_index - 1)
    if num_remaining > 0 then
        local original_ul = vim.api.nvim_get_option_value("undolevels", { buf = 0 })
        vim.api.nvim_set_option_value("undolevels", -1, { buf = 0 })
        insert_empty_lines(current_line_num + 1, num_remaining)
        vim.api.nvim_set_option_value("undolevels", original_ul, { buf = 0 })
    end

    for idx = start_index, #lines do
        local line_text = lines[idx]
        local extmark_id = idx
        vim.api.nvim_buf_set_extmark(0, ns_id, current_line_num + idx - 2, 0, {
            id = extmark_id,
            virt_text = { { line_text, "CustomVirttextHighlight" } },
            right_gravity = true,
        })
        table.insert(self.ext_ids, extmark_id)
    end

    M.CaptureText = lines
end

function M.setup(config)
    vim.g.model_cmp_virtualtext_auto_trigger = config.virtualtext.enable
    M.virt_text_style = config.virtualtext.style
    vim.api.nvim_set_hl(0, "CustomVirttextHighlight", M.virt_text_style)
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

function action.clear_preview(ext_ids_arg)
    M.VirtualText:clear_preview(ext_ids_arg)
end

M.action = action

return M
