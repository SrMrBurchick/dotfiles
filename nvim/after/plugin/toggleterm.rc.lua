local status, toggleterm = pcall(require, "toggleterm")
if (not status) then return end

toggleterm.setup {
}

--[[ " TogTERM
function! OpenToggleTerm()
    let nerd_root = g:NERDTree.ForCurrentTab().getRoot().path.str()
    execute "ToggleTerm dir=" . nerd_root
endfunction

nnoremap <silent><c-t> :call OpenToggleTerm() <CR>
tnoremap <silent><c-t>  <C-\><C-n> :call OpenToggleTerm() <CR> ]]
