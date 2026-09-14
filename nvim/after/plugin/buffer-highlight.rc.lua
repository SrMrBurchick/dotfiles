local status, buffer = pcall(require, 'buffer_highlight')
if (not status) then
	print("Bufferline not installed")
	return
end

buffer.setup({
	focused_bg = "NONE",
	unfocused_bg = "#3d0d68",
	interpolation = true,
})

