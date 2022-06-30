## Neovim Config

This folder must be located at the ~/.config folder

#### Vim Plug
For plugins work must be instaled [vim-plug](https://github.com/junegunn/vim-plug.git)

For neovim:
```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

### Code completion
This configuration using [CoC extension](https://github.com/neoclide/coc.nvim.git)
NodeJS must be installed for correct work CoC plugin

For C/C++ development:
`:CocInstall coc-clangd`

For web development must be installed next coc-utils:
`:CocInstall coc-tsserver coc-eslint coc-json coc-prettier coc-css`


### Debuging
[Vimspector](https://github.com/puremourning/vimspector.git)
