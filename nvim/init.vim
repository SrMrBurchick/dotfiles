" Specify a directory for plugins
call plug#begin()
    Plug 'https://github.com/preservim/nerdtree.git'
    Plug 'vim-airline/vim-airline'
    Plug 'https://github.com/Xuyuanp/nerdtree-git-plugin.git'
    Plug 'airblade/vim-gitgutter'
    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
    Plug 'vim-syntastic/syntastic'
    Plug 'ParamagicDev/vim-medic_chalk'
    Plug 'https://github.com/sainnhe/sonokai.git'
    Plug 'https://github.com/rafi/awesome-vim-colorschemes.git'
    Plug 'rhysd/git-messenger.vim'
    Plug 'https://github.com/APZelos/blamer.nvim.git'
    Plug 'vim-scripts/OmniCppComplete'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'https://github.com/puremourning/vimspector'
    Plug 'ryanoasis/vim-devicons'
    Plug 'arithran/vim-delete-hidden-buffers'
    Plug 'https://github.com/ivalkeen/nerdtree-execute.git'
    Plug 'https://github.com/pboettch/vim-cmake-syntax.git'
    Plug 'https://github.com/preservim/tagbar.git'
    " Plug 'https://github.com/mattn/vim-nyancat.git'
    " Plug 'edluffy/hologram.nvim'
    " Plug 'qaiviq/vim-imager'
    " Plug 'ipod825/vim-netranger'
call plug#end()
set nocp
filetype plugin on

set nocompatible
set noswapfile
set lazyredraw

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

" Global configuration
set mouse-=a

syntax on

set mouse=a

set termguicolors
colorscheme PaperColor

set number
set hidden
set cursorline
set expandtab
set autoindent
set smartindent
set tabstop=4 shiftwidth=4 expandtab
set encoding=UTF-8
set history=5000
set clipboard=unnamedplus

hi Normal guibg=NONE ctermbg=NONE
highlight clear LineNr
set colorcolumn=81
highlight ColorColumn ctermbg=102
hi CursorLine gui=underline cterm=underline

set list
set listchars=tab:>-,trail:~,extends:>,precedes:<

set exrc

" NERD Tree config
let NERDTreeShowHidden=1
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'~',
                \ 'Staged'    :'+',
                \ 'Untracked' :'*',
                \ 'Renamed'   :'->',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'-',
                \ 'Dirty'     :'~',
                \ 'Ignored'   :' ',
                \ 'Clean'     :'OK',
                \ 'Unknown'   :'?',
                \ }

" Git configuration
let g:git_messenger_include_diff = 1
let g:blamer_enabled = 1
let g:blamer_delay = 100
let g:blamer_show_in_visual_modes = 1
let g:blamer_show_in_insert_modes = 0
let g:blamer_template = '<commit-short>: <author>, <committer-time> • <summary>'
let g:blamer_date_format = '%d.%m.%y %H:%M'
set updatetime=100

nnoremap <C-g>s :Gstatus<CR>
nnoremap <C-g>a :Git add -p<CR>
nnoremap <C-g>m :GitMessenger <CR>

" NERD Tree config
let NERDTreeShowHidden=1

" sync open file with NERDTree
" " Check if NERDTree is open or active
function! IsNERDTreeOpen()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

" Call NERDTreeFind iff NERDTree is active, current window contains a modifiable
" file, and we're not in vimdiff
function! SyncTree()
  if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
    NERDTreeFind
    wincmd p
    execute "\<c-t>"
  endif
endfunction

" Start NERDTree when Vim is started without file arguments.
if argc() != 0
        let f = escape(fnameescape(argv(0)), '.')
        if f == "pr"
            autocmd VimEnter * NERDTree
        endif
endif

nmap <c-E> :NERDTreeToggle<CR>

" Autocomplete config
"inoremap <silent> <c-space> coc#refresh()
inoremap <silent><expr> <c-space> coc#refresh()
" inoremap <silent> ,s <C-r>=CocActionAsync('showSignatureHelp')<CR>

autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

function! FloatScroll(forward) abort
  let float = coc#util#get_float()
  if !float | return '' | endif
  let buf = nvim_win_get_buf(float)
  let buf_height = nvim_buf_line_count(buf)
  let win_height = nvim_win_get_height(float)
  if buf_height < win_height | return '' | endif
  let pos = nvim_win_get_cursor(float)
  if a:forward
    if pos[0] == 1
      let pos[0] += 3 * win_height / 4
    elseif pos[0] + win_height / 2 + 1 < buf_height
      let pos[0] += win_height / 2 + 1
    else
      let pos[0] = buf_height
    endif
  else
    if pos[0] == buf_height
      let pos[0] -= 3 * win_height / 4
    elseif pos[0] - win_height / 2 + 1  > 1
      let pos[0] -= win_height / 2 + 1
    else
      let pos[0] = 1
    endif
  endif
  call nvim_win_set_cursor(float, pos)
  return ''
endfunction

"   inoremap <silent><expr> <down> coc#util#has_float() ? FloatScroll(1) : "\<down>"
"   inoremap <silent><expr>  <up>  coc#util#has_float() ? FloatScroll(0) :  "\<up>"

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

"autocmd BufEnter * exec 'set omnifunc=ale#completion#OmniFunc'

" Terminal configuration
let g:term_buf = 0
let g:term_win = 0

function! Term_toggle(height)
        if win_gotoid(g:term_win)
                hide
        else
                botright new
                exec "resize " . a:height
                try
                        exec "buffer " . g:term_buf
                catch
                        call termopen($SHELL, {"detach": 0})
                        let g:term_buf = bufnr("")
                endtry
                startinsert!
                let g:term_win = win_getid()
        endif
endfunction

tnoremap <ESC> <C-\><C-n>

set completeopt-=preview
set completeopt+=menuone
set completeopt+=noinsert

set nohlsearch

function! Refactor(search, replace)
        let command = "!grep -rwl " . a:search . " | xargs sed -i 's/" . a:search ."/" . a:replace . "/g'"
        execute "!grep -rl" shellescape(a:search)
        execute command
        unlet command
endfunction

let g:vimspector_enable_mappings = 'HUMAN'

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" autocmd BufEnter NERD_tree_* DeleteHiddenBuffers
let g:git_gutter_enabled = 0


# Colors Highlight
autocmd CursorHold * silent call CocActionAsync('highlight')
nnoremap <C-c>s : call CocAction('colorPresentation') <CR>
nnoremap <C-c>p : call CocAction('pickColor') <CR>
