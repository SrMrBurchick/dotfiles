vim.cmd("autocmd!")

vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.cmd 'let $LANG="en"'

vim.wo.number = true

vim.cmd [[ set mouse-=a ]]
vim.cmd [[ set noswapfile ]]

vim.opt.title = true
vim.opt.syntax = on
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.exrc = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.expandtab = true
vim.opt.scrolloff = 10

vim.opt.backupskip = { '/tmp/*', '/private/tmp/*' }
vim.opt.inccommand = 'split'
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.wrap = false -- No Wrap lines
vim.opt.backspace = { 'start', 'eol', 'indent' }
vim.opt.path:append { '**' } -- Finding files - Search down into subfolders
vim.opt.wildignore:append { '*/node_modules/*' }
vim.opt.list = true
vim.opt.listchars = "tab:>-,trail:~,extends:>,precedes:<"
vim.opt.foldmethod = "indent"
vim.opt.foldenable = false
-- vim.o.cmdheight=0
