local status, toggleterm = pcall(require, "toggleterm")
if (not status) then return end

local powershell_options = {
  shell = vim.fn.executable "powershell" and "powershell" or "powershell",
  shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
  shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
  shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
  shellquote = "",
  shellxquote = "",
}

for option, value in pairs(powershell_options) do
  vim.opt[option] = value
end

toggleterm.setup{
}

--[[ " TogTERM
function! OpenToggleTerm()
    let nerd_root = g:NERDTree.ForCurrentTab().getRoot().path.str()
    execute "ToggleTerm dir=" . nerd_root
endfunction

nnoremap <silent><c-t> :call OpenToggleTerm() <CR>
tnoremap <silent><c-t>  <C-\><C-n> :call OpenToggleTerm() <CR> ]]
