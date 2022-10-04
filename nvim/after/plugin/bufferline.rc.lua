local status, bufferline = pcall(require, 'bufferline')
if (not status) then
    print("Bufferline not installed")
    return
end

bufferline.setup {
    options = {
        mode = 'tabs',
        separator_style = 'slant',
        always_show_bufferline = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        color_icons = true
    }
}

vim.api.nvim_set_keymap('n', '<Tab>', '<cmd>BufferLineCycleNext<cr>', {})
vim.api.nvim_set_keymap('n', '<S-Tab>', '<cmd>BufferLineCyclePrev<cr>', {})
