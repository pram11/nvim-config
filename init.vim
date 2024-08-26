call plug#begin(stdpath("data") . '/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'ayu-theme/ayu-vim'
Plug 'Yggdroot/indentLine'
call plug#end()
autocmd VimEnter * if !argc() | NERDTree | endif

if has ("syntax")
	syntax on
endif
set hlsearch
set ts=4
set sts=4
set autoindent
set cindent
set shiftwidth=4
set laststatus=2
set showmatch
set smartcase
set smarttab
set smartindent
set ruler
set fileencodings=utf8,euc-kr

set nu
set termguicolors

let ayucolor="dark"
colorscheme ayu

set exrc
set secure
