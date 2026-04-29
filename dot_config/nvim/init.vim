" Install vim-plug if it's not installed already
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Syntax / Treesitter (replaces many individual syntax plugins)
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'tpope/vim-haml'           " haml/Sass/SCSS (treesitter parser less mature)
Plug 'chrisbra/csv.vim'
Plug 'tpope/vim-markdown'       " Better markdown folding

Plug 'fatih/vim-go'             " Go commands, testing, debugging
Plug 'Zaptic/elm-vim'           " Elm compiler integration

" JVM things
Plug 'tpope/vim-classpath'
Plug 'tpope/vim-fireplace'
Plug 'venantius/vim-cljfmt'

" Config management
Plug 'google/vim-jsonnet'
Plug 'hashivim/vim-terraform'

Plug 'neomake/neomake'          " async linting

" Colour
Plug 'danielwe/base16-vim'
Plug 'bling/vim-airline'
Plug 'ap/vim-css-color'         " show css colours in the editor

" Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Utilities
Plug 'tpope/vim-endwise'                                          " Adds ends helpfully
Plug 'tpope/vim-surround'                                         " Change/remove surrounding things
Plug 'tpope/vim-repeat'                                           " Make vim-surround work with .
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }               " Fuzzy finding
Plug 'junegunn/fzf.vim'                                           " Fuzzy finding for things within vim
Plug 'christoomey/vim-tmux-navigator'                             " Navigation across vim and tmux splits
Plug 'tpope/vim-eunuch'                                           " Vim wrappers for file changing
Plug 'tpope/vim-commentary'                                       " Commenting out things
Plug 'tpope/vim-fugitive'                                         " Git things
Plug 'tpope/vim-rhubarb'                                          " Open git things in github
Plug 'kana/vim-textobj-user'                                      " Helps with defining custom text objects
Plug 'nelstrom/vim-textobj-rubyblock'                             " Binds 'ar' to around a Ruby block, 'ir' to inside
Plug 'wellle/targets.vim'                                         " More text objects
Plug 'AndrewRadev/splitjoin.vim'                                  " Split (gS) and join (gJ) blocks
Plug 'tmux-plugins/vim-tmux-focus-events'                         " Make vim listen to tmux focus events
Plug 'junegunn/vim-easy-align'                                    " Align things incredibly
Plug 'airblade/vim-rooter'

" Copilot
Plug 'github/copilot.vim'

call plug#end()

lua require("treesitter")

syntax on
filetype plugin indent on
set re=0                        " Auto-select regexp engine (0=auto, 1=old, 2=NFA)

" status bar
set laststatus=2                " Always show a statusline
let g:airline_powerline_fonts = 1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_section_warning = ''
let g:airline#extensions#tabline#enabled = 0

" Elm setup
let g:elm_jump_to_error = 0
let g:elm_make_output_file = "/dev/null"
let g:elm_make_show_warnings = 0
let g:elm_syntastic_show_warnings = 0
let g:elm_browser_command = ""
let g:elm_detailed_complete = 0
let g:elm_format_autosave = 1
let g:elm_format_fail_silently = 0
let g:elm_setup_keybindings = 1

" assume the /g flag on :s substitutions to replace all matches in a line
set gdefault

" Auto-read files when switching back into vim
set autoread

" fix slight delay after pressing ESC then O
set timeout timeoutlen=500 ttimeoutlen=100

" fold with space, but don't autofold when opening
set foldmethod=indent
set foldlevelstart=999
nnoremap <Space> za

" Use jj for getting out of insert mode
inoremap jj <esc>

set textwidth=80
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent                  " Copy indent from current line when starting a new one

set spelllang=en_gb
syntax spell toplevel

" Use system clipboard
set clipboard=unnamedplus

augroup filetype_detect
  autocmd!
  autocmd BufRead,BufNewFile *.md set ft=markdown
  autocmd BufRead,BufNewFile Gemfile set ft=ruby
  autocmd BufRead,BufNewFile Make.*,Makefile,makefile set ft=make
augroup END

augroup filetype_settings
  autocmd!
  autocmd FileType markdown setlocal shiftwidth=4 softtabstop=4 tabstop=4 wrap linebreak nolist lbr colorcolumn=0
  autocmd FileType make,go setlocal noexpandtab
  " Don't add the comment prefix when hitting enter or o/O on a comment line
  autocmd FileType * setlocal formatoptions-=r formatoptions-=o
augroup END

augroup cursor_restore
  autocmd!
  " Reset cursor to last known position, except for git commits
  autocmd BufReadPost * if &filetype != "gitcommit" && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

set linebreak

set incsearch                   " Show where the pattern matches while typing
set hlsearch                    " Highlight all matches of a search pattern
set ignorecase smartcase        " Only do case-sensitive searches when search includes an uppercase letter

set scrolloff=10

set nobackup
set nowritebackup
set noswapfile

set wildmode=full
set wildmenu
set wildoptions=pum
set wildignore+=*.o,*.obj,.git,node_modules,_site,*.class,*.zip,*.aux

let mapleader=","
noremap \ ,

" Show line numbers, and make them relative to the current cursor
set number
set relativenumber

" pretty colours
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

set colorcolumn=100

set list listchars=tab:»·,trail:·

command! Q q
command! WQ wq
command! Wq wq

set splitbelow
set splitright

set lazyredraw

" ~~~ MAPPINGS BELOW ~~~

" gtfo ex mode
map Q <Nop>

map <Leader>nf :e <C-R>=expand("%:p:h") . "/" <CR>

" FZF commands
nnoremap <leader>t :Files<cr>
nnoremap <leader>b :Buffers<cr>
imap <C-x><C-l> <Plug>(fzf-complete-line)
nmap <leader>d :call fzf#run({'source': 'find . -type d \| sed "s\|^\./\|\|"', 'sink': 'e', 'down': '30%', 'options': '--preview "ls {}"', 'window': '10split enew'})<CR>

" Splits
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>s :split<CR>

vnoremap . :norm.<CR>

" Search using ripgrep for word under cursor
nnoremap <Leader>a :Ag <C-r><C-w><CR>

nnoremap <CR> :noh<CR><CR>

set grepprg=rg\ --vimgrep\ --smart-case

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

noremap H ^
noremap L $
vnoremap L g_

" Press <c-u> in insert mode to convert the current word to uppercase.
inoremap <C-u> <esc>mzgUiw`za

" makes fzf never use tmux
" https://github.com/junegunn/fzf.vim/issues/66#issuecomment-169362556
let g:fzf_layout = {}

" --------------- Neomake Config ----------------------------------------------

augroup neomake_on_save
  autocmd!
  autocmd BufWritePost * Neomake
augroup END

let g:terraform_fmt_on_save = 1
let g:neomake_sh_enabled_makers = ['shellcheck']
let g:neomake_zsh_enabled_makers = []
let g:neomake_rust_enabled_makers = ['rustc']
let g:neomake_go_enabled_makers = ['go']
let g:neomake_ruby_enabled_makers = ['bundle', 'mri']
let g:neomake_ruby_bundle_maker = {
    \ 'args': ['--format', 'emacs'],
    \ 'errorformat': '%f:%l:%c: %t: %m',
    \ 'postprocess': function('neomake#makers#ft#ruby#RubocopEntryProcess')
    \ }

" --------------- coc.nvim ----------------------------------------------------

let g:coc_global_extensions = [
      \'coc-eslint',
      \'coc-go',
      \'coc-json',
      \'coc-prettier',
      \'coc-tsserver',
      \]

command! -nargs=0 Prettier :CocCommand prettier.formatFile
command! -nargs=0 ESlint :CocCommand eslint.formatFile

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Make enter confirm autocomplete (enables coc-tsserver autoimport)
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"

" --------------- Golang Preferences ------------------------------------------

let g:go_list_type = "quickfix"

" --------------- Tmux Integration --------------------------------------------

if $TMUX != ''

  " Integrate movement between tmux/vim panes/windows
  function! TmuxMove(direction)
    let old_window = winnr()
    exe 'wincmd ' . a:direction
    let new_window = winnr()
    exe old_window . 'wincmd w'

    if old_window == new_window
      if a:direction == 'j'
        call system("tmux select-pane -D")
      elseif a:direction == 'k'
        call system("tmux select-pane -U")
      elseif a:direction == 'h'
        call system("tmux select-pane -L")
      elseif a:direction == 'l'
        call system("tmux select-pane -R")
      endif
    else
      exe 'wincmd ' . a:direction
    end
  endfun

else

  nmap <C-h> :exe 'wincmd h'<CR>
  nmap <C-j> :exe 'wincmd j'<CR>
  nmap <C-k> :exe 'wincmd k'<CR>
  nmap <C-l> :exe 'wincmd l'<CR>

end
