require('base')

require('configuration')
require('highlights')
require('maps')
require('plugins')
require('workspaces')

local local_vimrc = vim.fn.getcwd() .. '/.nvim.rc.lua'
if vim.loop.fs_stat(local_vimrc) then
    vim.cmd('source ' .. local_vimrc)
end

local has = vim.fn.has
local is_win = has "win32"
local is_linux = has "linux"

if 0 ~= is_win then
    require('win')
elseif 0 ~= is_linux then
    require('linux')
else
    print("Uknown system!")
end

if vim.g.neovide then
    vim.g.neovide_cursor_vfx_mode = "torpedo"
    vim.g.neovide_opacity = 0.85
    vim.g.transparency = 0.8
    vim.g.neovide_background_color = "#000000"
    vim.g.neovide_floating_blur_amount_x = 15.0
    vim.g.neovide_floating_blur_amount_y = 15.0
    vim.o.guifont = "Hack:h16:b"
end


-- Better colors in terminal
vim.opt.termguicolors = true
-- Seed RNG once
math.randomseed(os.time())
local ns = vim.api.nvim_create_namespace("split_random_bg")
-- Cache random colors per buffer (bufnr -> hex color)
local buf_colors = {}
local function random_soft_color()
  -- Soft-ish range so text remains readable
  local r = math.random(25, 70)
  local g = math.random(25, 70)
  local b = math.random(25, 70)
  return string.format("#%02x%02x%02x", r, g, b)
end
local function get_buf_color(bufnr)
  if not buf_colors[bufnr] then
    buf_colors[bufnr] = random_soft_color()
  end
  return buf_colors[bufnr]
end
local function apply_split_backgrounds()
  local current_win = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    -- skip floating windows
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative == "" then
      if win == current_win then
        -- Focused: transparent
        vim.api.nvim_set_hl(ns, "WinBg_" .. win, { bg = "NONE" })
      else
        -- Unfocused: random per-buffer color
        vim.api.nvim_set_hl(ns, "WinBg_" .. win, { bg = get_buf_color(buf) })
      end
      vim.wo[win].winhighlight =
        "Normal:WinBg_" .. win .. ",NormalNC:WinBg_" .. win
    end
  end
end
vim.api.nvim_create_autocmd({
  "WinEnter",
  "WinLeave",
  "BufEnter",
  "BufWinEnter",
  "VimResized",
}, {
  callback = apply_split_backgrounds,
})
-- Optional: cleanup cache when buffer is wiped
vim.api.nvim_create_autocmd("BufWipeout", {
  callback = function(args)
    buf_colors[args.buf] = nil
  end,
})
