local ghosttext = require("model_cmp.ghosttext")
local llama = require("model_cmp.modelapi.llama")

local M = {}

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local model_cmp_grp = augroup("ModelCmpGrp", {})

-- A lots of autocmds
local function create_autocmd()
    autocmd('BufLeave',
        {
            group = model_cmp_grp,
            pattern = "*",
            callback = function()
                ghosttext.action.clear_preview() --- Need to think about this
            end
        }
    )
    autocmd('BufNewFile', -- When we write in new space where the file does not exists yet
        -- We don't know its file type yet
        {
            group = model_cmp_grp,
            pattern = "*",
            callback = function()
                return -- for now we don't do anything
            end
        }
    )
    autocmd(
        'CmdlineEnter', -- Clear the Screen
        {
            group = model_cmp_grp,
            pattern = "*",
            callback = function()
                return -- this will be update at the same time as BufNewFile
            end
        }
    )
    autocmd(
        'InsertChange',
        {
            group = model_cmp_grp,
            pattern = "*",
            callback = function()
                -- send request
            end
        }
    )
    autocmd(
        'InsertLeave',
        {
            group = model_cmp_grp,
            callback = function()
                ghosttext.action.clear_preview()
            end
        }
    )
    autocmd(
        'TextChangedI', -- after a change was made to the text in the current buffer in insert mode
        {
            group = model_cmp_grp,
            callback = function()
                llama.text_changed()
            end
        }
    )
end


function M.setup()
    create_autocmd()

    -- Key binds
    vim.keymap.set("i", "<C-s>", "<CMD>ModelCmp capture first<CR>", {})
    vim.keymap.set("i", "<C-b>", "<CMD>ModelCmp capture all<CR>",{})
end

-- UserCommands
vim.api.nvim_create_user_command('ModelCmp', function(args)
    local fargs = args.fargs
    local actions = {}

    -- Ghosttext options
    actions.ghosttext = {
        enable = function() ghosttext.action.enable_auto_trigger() end,
        disable = function() ghosttext.action.disable_auto_trigger() end,
        toggle = function() ghosttext.action.toggle_auto_trigger() end
    }
    actions.capture = {
        first = function() ghosttext.action.capturefirstline() end,
        all = function() ghosttext.action.capturealllines() end,
    }

    actions[fargs[1]][fargs[2]]()
end, {
    nargs = '+',
    complete = function(_, cmdline, _)
        cmdline = cmdline or ''

        if cmdline:find 'virtualtext' then
            return {
                'enable',
                'disable',
                'toggle'
            }
        end

        return { 'virtualtext' }
    end,
})

return M
