local status, buffer = pcall(require, 'buffer_highlight')
if (not status) then
	print("Bufferline not installed")
	return
end

-- The external plugin creates ungrouped autocmds: do not multiply them on reload.
if vim.g.buffer_highlight_configured then return end
vim.g.buffer_highlight_configured = true
buffer.setup({
	focused_bg = "NONE",
	unfocused_bg = "#3d0d68",
	interpolation = true,
})

