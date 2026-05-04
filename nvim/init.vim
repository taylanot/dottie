syntax on

set modelines=0

" " cursor style
" set guicursor=a:hor20-Cursor

" Show line numbers
set number relativenumber
set nu rnu

" Show file stats
set ruler
" Ignore cases
set ignorecase

" Encoding
set encoding=utf-8

set wrap
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround
augroup ColorColumn
  autocmd!
  autocmd FileType python,c,cpp setlocal cc=80
augroup END

:set autoindent
:set smarttab
:set mouse=a

call plug#begin()

Plug 'http://github.com/tpope/vim-surround' " Surrounding ysw)
Plug 'https://github.com/preservim/nerdtree' " NerdTree
Plug 'https://github.com/tpope/vim-commentary' " For Commenting gcc & gc
Plug 'https://github.com/vim-airline/vim-airline' " Status bar
Plug 'https://github.com/ap/vim-css-color' " CSS Color Preview
Plug 'https://github.com/rafi/awesome-vim-colorschemes' " Retro Scheme
" Plug 'https://github.com/neoclide/coc.nvim'  " Auto Completion
Plug 'https://github.com/ryanoasis/vim-devicons' " Developer Icons
Plug 'https://github.com/tc50cal/vim-terminal' " Vim Terminal
Plug 'https://github.com/preservim/tagbar' " Tagbar for code navigation
Plug 'https://github.com/terryma/vim-multiple-cursors' " CTRL + N for multiple cursors

set encoding=UTF-8

call plug#end()

nnoremap <C-f> :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-e> :TagbarToggle<CR>
nnoremap <C-l> :call CocActionAsync('jumpDefinition')<CR>

set clipboard=unnamed "adds unnamed to existing values
set clipboard=unnamedplus

:colorscheme gruvbox

let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="~"

let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
let g:tagbar_ctags_bin='/usr/local/bin/ctags'

noremap <Leader>y "*y
noremap <Leader>p "*p
vnoremap <Leader>Y "+y
vnoremap <Leader>P "+p

"wrapping related maps
noremap <silent> k gk
noremap <silent> j gj
noremap <silent> 0 g0
noremap <silent> $ g$
" spell check for .tex files
autocmd BufRead,BufNewFile *.tex setlocal spell
autocmd BufRead,BufNewFile *.tex syntax spell toplevel
autocmd BufRead,BufNewFile *.tex setlocal nolist 
autocmd BufRead,BufNewFile *.tex set cc=0

" spell check for .mdfiles
autocmd BufRead,BufNewFile *.md setlocal spell
map('', '<leader>y', '"+y', 'Yank to clipboard') " -- E.g: <leader>yy will yank current line to os clipboard
map('', '<leader>Y', '"+y$', 'Yank until EOL to clipboard')

map('n', '<leader>p', '"+p', 'Paste after cursor from clipboard')
map('n', '<leader>P', '"+P', 'Paste before cursor from clipboard')
set clipboard+=unnamedplus

" let g:autocompile_tex = 1
" command! ShowTexAutocompile echo "Auto-compile is " . (g:autocompile_tex ? "enabled" : "disabled")
" " if I have a tex file after each save my comptex will try to run 
" augroup tex_autocommands
"     autocmd!
"     autocmd BufWritePost *.tex if g:autocompile_tex | !comptex % | endif
" augroup END
