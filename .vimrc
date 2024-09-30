syntax on
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set guifont=Hack\ 18
set relativenumber
set number
set ignorecase
set smartcase
set incsearch

autocmd BufEnter * if &filetype == "go" | setlocal noexpandtab
