---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global

local virtualtext = require("model_cmp.virtualtext")

local function custom_virtualtext()
    local virt = virtualtext.VirtualText
    virt.ext_ids[1] = 1
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_buf_set_extmark(0, virt.ns_id, cursor[1] - 1, -1, {
        id = virt.ext_ids[1],
        virt_text = { { "This is test text", "CustomVirttextHighlight" } },
        virt_text_pos = "eol",
        right_gravity = true,
    })
    return virt
end


describe("model_cmp.virtualtext.VirtualText", function()
    it("test clear preview via custom previews", function()
        local virt = custom_virtualtext()
        virtualtext.VirtualText.clear_preview(virt)
        assert.are.same(0, #virt.ext_ids)
    end)
    it("test ext_ids for display text", function()
        local text = "This is test is the text that we were waiting for\n"
        local virt = virtualtext.VirtualText
        vim.cmd("startinsert")
        vim.g.model_cmp_virtualtext_auto_trigger = true
        virt:update_preview(text)
        assert.are.same(1, virt.ext_ids[1])
    end)
end)
