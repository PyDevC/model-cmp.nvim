local string = string
local M = {}

local ctx_before = function(cursorcol, cursorline)
    -- do not include the currentline
    local lines = vim.api.nvim_buf_get_lines(0, 0, cursorline - 1, false)
    return lines
end

local ctx_after = function(cursorcol, cursorline)
    -- do not include the currentline
    local lines = vim.api.nvim_buf_get_lines(0, cursorline, -1, false)
    return lines
end

local ctx_currentline = function(cursorcol, cursorline)
    local cursoralias = "<|cursor|><|cursor/|>"
    local line = vim.api.nvim_get_current_line()

    local before_cursor = string.sub(line, 0, cursorcol - 1)
    local after_cursor = string.sub(line, cursorcol)
    return { before_cursor .. cursoralias .. after_cursor }
end

function M.get_ctx()
    -- current position of cursor
    local cursorcol = vim.fn.col '.'
    local cursorline = vim.fn.line '.'

    local lines_before = ctx_before(cursorcol, cursorline)
    local lines_curr = ctx_currentline(cursorcol, cursorline)
    local lines_after = ctx_after(cursorcol, cursorline)

    table.insert(lines_before, lines_curr[1])

    for k, v in ipairs(lines_after) do
        table.insert(lines_before, v)
    end

    return lines_before
end

function M.generate_context_text()
    local text = [[]]
    local ctx = M.get_ctx()
    for _, v in ipairs(ctx) do
        text = text .. v .. "\n"
    end
    return text
end

return M
