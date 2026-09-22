" ~/.vimrc - plugin-free, terminal + tmux, macOS
" Requires a vim with +clipboard (brew install vim), vim >= 8.1

" ---- Basics ----------------------------------------------------------------
set nocompatible
syntax enable
filetype plugin indent on
set encoding=utf-8
set hidden                      " switch buffers without saving
set autoread                    " reload files changed outside vim
set nobackup nowritebackup      " backups confuse file watchers; git is the backup
set noswapfile
set undofile                    " persistent undo across sessions
set undodir=~/.vim/undo
if !isdirectory(&undodir) | call mkdir(&undodir, 'p', 0700) | endif
set updatetime=300
set shortmess+=c
set history=1000
set nomodeline                  " security: never execute modelines from files

" ---- Terminal / tmux -------------------------------------------------------
set ttimeout ttimeoutlen=10     " fast <Esc> - no lag leaving insert mode
set ttyfast
set lazyredraw
set mouse=a                     " scroll/resize splits; works inside tmux
set ttymouse=sgr
set clipboard=unnamed           " macOS system clipboard via * register
if exists('+termguicolors')
  " tmux needs these or colors degrade to 8/16
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
" cursor shape: bar in insert, block in normal (works in Terminal.app/iTerm/tmux)
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
" bracketed paste so pasted text isn't auto-indented into garbage
if !has('nvim') && &term =~ 'tmux\|xterm\|screen'
  let &t_BE = "\<Esc>[?2004h"
  let &t_BD = "\<Esc>[?2004l"
  exec "set t_PS=\<Esc>[200~"
  exec "set t_PE=\<Esc>[201~"
endif

" ---- UI --------------------------------------------------------------------
set number relativenumber
set signcolumn=yes
set cursorline
set ruler
set showcmd
set noshowmode                  " statusline shows it
set laststatus=2
set scrolloff=8 sidescrolloff=8
set splitbelow splitright
set nowrap
set list listchars=tab:>-,trail:.,nbsp:+,extends:>,precedes:<
set display=lastline
set colorcolumn=+1              " one past textwidth, only if textwidth set
set belloff=all
set background=dark
colorscheme habamax             " built-in since 9.0; fall back gracefully
if v:errmsg =~ 'E185' | colorscheme desert | endif

" statusline: file, modified, ft, git-free, position
set statusline=\ %f\ %m%r%h%w%=%y\ %{&fenc}\ %l:%c\ %p%%

" ---- Search ----------------------------------------------------------------
set incsearch hlsearch
set ignorecase smartcase
set wrapscan
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>
" keep search matches centered
nnoremap n nzzzv
nnoremap N Nzzzv

" ---- Editing ---------------------------------------------------------------
set expandtab tabstop=2 shiftwidth=2 softtabstop=2
set shiftround
set autoindent smartindent
set backspace=indent,eol,start
set nojoinspaces
set formatoptions+=j            " remove comment leader when joining lines
set nrformats-=octal            " <C-a> on 007 -> 008, not 010
set virtualedit=block
set matchpairs+=<:>

" ---- Completion / wildmenu -------------------------------------------------
set wildmenu wildmode=longest:full,full
set wildoptions=pum
set wildignore+=*/.git/*,*/node_modules/*,*/target/*,*/__pycache__/*,*.pyc,*.o,.DS_Store
set completeopt=menuone,noinsert,noselect
set path+=**                    " :find file<Tab> recursively
set omnifunc=syntaxcomplete#Complete

" ---- Built-in "plugins" ----------------------------------------------------
runtime! macros/matchit.vim     " % on if/else/endif, HTML tags etc.
packadd! comment                " gc / gcc commenting (vim 9.1+; no-op if absent)
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25

" ---- grep -> quickfix ------------------------------------------------------
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden\ --glob\ '!.git'
  set grepformat=%f:%l:%c:%m
endif
command! -nargs=+ -complete=file Grep silent grep! <args> | copen | redraw!

" ---- Mappings --------------------------------------------------------------
let mapleader = ' '
let maplocalleader = ','

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>e :Explore<CR>
nnoremap <leader>f :find<Space>
nnoremap <leader>b :ls<CR>:b<Space>
nnoremap <leader>g :Grep<Space>
nnoremap <leader>/ :Grep <C-r><C-w><CR>

" window nav without <C-w> prefix (plays fine with tmux prefix)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" quickfix / location list
nnoremap ]q :cnext<CR>
nnoremap [q :cprev<CR>
nnoremap ]l :lnext<CR>
nnoremap [l :lprev<CR>
nnoremap <leader>c :cclose<CR>

" buffers
nnoremap ]b :bnext<CR>
nnoremap [b :bprev<CR>
nnoremap <leader>d :bd<CR>

" keep visual selection when indenting
vnoremap < <gv
vnoremap > >gv
" move lines
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" sane Y, and yank-to-end
nnoremap Y y$
" don't clobber register when pasting over a selection
xnoremap p "_dP

" ---- Autocommands ----------------------------------------------------------
augroup vimrc
  autocmd!
  " jump to last position on reopen
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  " strip trailing whitespace on save (not in markdown/diff)
  autocmd BufWritePre * if &ft !~# 'markdown\|diff' | let s:v = winsaveview() | %s/\s\+$//e | call winrestview(s:v) | endif
  " auto-resize splits when terminal/tmux pane changes size
  autocmd VimResized * wincmd =
  " per-language indentation
  autocmd FileType go,make setlocal noexpandtab tabstop=4 shiftwidth=4
  autocmd FileType python,rust setlocal tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType gitcommit setlocal spell textwidth=72
  autocmd FileType markdown setlocal wrap linebreak spell
  " quickfix window: q to close
  autocmd FileType qf nnoremap <buffer> q :cclose<CR>
augroup END
