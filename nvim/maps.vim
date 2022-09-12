" C-c copy remap
vnoremap <C-c> "+y

" shift+arrow selection
nmap <S-Up> v<Up>
nmap <S-Down> v<Down>
nmap <S-Left> v<Left>
nmap <S-Right> v<Right>
vmap <S-Up> <Up>
vmap <S-Down> <Down>
vmap <S-Left> <Left>
vmap <S-Right> <Right>
imap <S-Up> <Esc>v<Up>
imap <S-Down> <Esc>v<Down>
imap <S-Left> <Esc>v<Left
imap <S-Right> <Esc>v<Right>

" Arrow resize
nmap <C-Left> :vertical resize -5 <CR>
nmap <C-Right> :vertical resize +5 <CR>

nnoremap <C-g>s :Gstatus<CR>
nnoremap <C-g>a :Git add -p<CR>
nnoremap <C-g>m :GitMessenger <CR>


" TogTERM
function! OpenToggleTerm()
    let nerd_root = g:NERDTree.ForCurrentTab().getRoot().path.str()
    execute "ToggleTerm dir=" . nerd_root
endfunction

nnoremap <silent><c-t> :call OpenToggleTerm() <CR>

" VS tasks
nnoremap <c-t>a :lua require("telescope").extensions.vstask.tasks()<CR>
nnoremap <c-t>i :lua require("telescope").extensions.vstask.inputs()<CR>
nnoremap <c-t>t :lua require("telescope").extensions.vstask.close()<CR>

" Vim templates
let g:tmpl_author_email = 'serhiibura@gmail.com'
let g:tmpl_author_name = 'Serhii Bura'
let g:tmpl_search_paths = ['~/.config/nvim/templates']

" Open Config
nmap <M-c>o :e ~/.config/nvim/init.vim <CR>
nmap <M-c>a :so ~/.config/nvim/init.vim <CR>

" NerdTREE toggle
nmap <c-E> :NERDTreeToggle<CR>
