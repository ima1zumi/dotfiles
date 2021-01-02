" https://knowledge.sakura.ad.jp/23248/
" dein.vim settings {{{
" install dir {{{
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
" }}}

" dein installation check {{{
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . s:dein_repo_dir
endif
" }}}

" begin settings {{{
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " .toml file
  let s:rc_dir = expand('~/.vim')
  if !isdirectory(s:rc_dir)
    call mkdir(s:rc_dir, 'p')
  endif
  let s:toml = s:rc_dir . '/dein.toml'

  " read toml and cache
  call dein#load_toml(s:toml, {'lazy': 0})

  " end settings
  call dein#end()
  call dein#save_state()
endif
" }}}

" plugin installation check {{{
if dein#check_install()
  call dein#install()
endif
" }}}

" plugin remove check {{{
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
  call map(s:removed_plugins, "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endif
" }}}

"############################################
"############################################
"############################################

set clipboard+=unnamed

"#####表示設定#####
set number "行番号を表示する
set title "編集中のファイル名を表示
set showmatch "括弧入力時の対応する括弧を表示
syntax on "コードの色分け
set expandtab " タブ入力を複数の空白入力に置き換える
set tabstop=2 " 画面上でタブ文字が占める幅
set softtabstop=2 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent " 改行時に前の行のインデントを継続する
set smartindent " 改行時に前の行の構文をチェックし次の行のインデントを増減する
set shiftwidth=2 " smartindentで増減する幅

set laststatus=2 "ステータス行を表示
set cursorline "カーソル行にラインを表示
set wildmenu "コマンドライン補完
set nocompatible "viとの互換性を無効にする

"#####検索設定#####
set ignorecase "大文字/小文字の区別なく検索する
set smartcase "検索文字列に大文字が含まれている場合は区別して検索する
set wrapscan "検索時に最後まで行ったら最初に戻る
set incsearch "インクリメントサーチ

" rg があれば使う
if executable('rg')
  set grepprg=rg\ --vimgrep
  set grepformat=%f:%l:%c:%m
endif

" 自動QuickFix
au QuickfixCmdPost make,grep,grepadd,vimgrep copen

"空白文字の可視化
set list
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%
hi NonText    ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE
hi SpecialKey ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE

"#####keybind#####
"jjをEscに
inoremap jj <Esc>
":と;の入れ替え
nnoremap : ;
nnoremap ; :
vnoremap : ;
vnoremap ; :
"クリップボード
xnoremap p "_dP
set whichwrap=b,s,h,l,<,>,[,],~
set mouse=a
"#折返しで下にいけるようにする
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Esc><Esc> :nohlsearch<CR>

"#####NERDTree#####
"#####NERDTree#####
"#####NERDTree#####
"C-nでNERDTree起動
nnoremap <C-n> :NERDTreeToggle<CR>
"ファイル未指定で起動した時に自動でNERDTreeを起動
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"NERDTreeだけのこったら消す
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"dotfilesを表示
let NERDTreeShowHidden=1

"BSで削除できるものを指定する
" indent  : 行頭の空白
" eol     : 改行
" start   : 挿入モード開始位置より手前の文字
set backspace=indent,eol,start

"言語ごと
"space enter
let $AFTER_FTPLUGIN = $NEOBUNDLE_ORIGIN."/after/after/ftplugin"
nnoremap <silent> <Space><CR> :execute ":tab drop ".$AFTER_FTPLUGIN."/".&filetype.".vim"<CR>

" ヘルプの日本語化
set helplang=ja

" swapをtmp配下に作る
:set directory=~/.vim/tmp

" Quickrun シュッとするやつ
let g:quickrun_config = {
\  "_" : {
\    "runner" : "job",
\    "outputter/buffer/split" : ":botright 8sp",
\    "outputter/setbufline/split" : ":botright 8sp",
\  },
\  "ruby/minitest" : {
\    "command" : "rails",
\    "exec"    : "%c test %s:p\\:%{line('.')}",
\  },
\  "ruby/minitest_file" : {
\    "command" : "rails",
\    "exec"    : "%c test %s:p",
\  },
\}

" git 変更行
highlight GitGutterAdd ctermfg=blue ctermbg=brown

" github の pr を開く openpr
" gitconfig に設定してある openpr が前提
" function! openpr#open() abort
"   let line = line('.')
"   let fname = expand('%')
"   let cmd = printf('git blame -L %d,%d %s | cut -d " " -f 1', line, line, fname)
"   let sha1 = system(cmd)
"   let cmd = printf('git openpr %s', sha1)
"   echo system(cmd)
" endfunction
" nnoremap <F5> :call openpr#open()<CR>

" カラースキーム
colorscheme iceberg

"previm
let g:previm_open_cmd = 'open -a Google\ Chrome'
