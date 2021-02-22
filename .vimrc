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
" vimrc を読み込むたびに autocmd の設定をリセットする設定
augroup my_vimrc
    autocmd!
augroup END

" MyAutocmd で autocmd を設定しておく
command! -bang -nargs=*
\   MyAutocmd
\   autocmd<bang> my_vimrc <args>

" vimrc を何回読み込んでも autocmd は 1回しか追加されない

" altercmdを先に読み込んでおく
call altercmd#load()

set clipboard+=unnamed

"#####表示設定#####
set number "行番号を表示する
set title "編集中のファイル名を表示
set showmatch "括弧入力時の対応する括弧を表示
syntax on "コードの色分け
let g:markdown_syntax_conceal = 0 "markdown
set expandtab " タブ入力を複数の空白入力に置き換える
set tabstop=2 " 画面上でタブ文字が占める幅
set softtabstop=2 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent " 改行時に前の行のインデントを継続する
set smartindent " 改行時に前の行の構文をチェックし次の行のインデントを増減する
set shiftwidth=2 " smartindentで増減する

set laststatus=2 "ステータス行を表示
set cursorline "カーソル行にラインを表示
set wildmenu "コマンドライン補完
set nocompatible "viとの互換性を無効にする

"#####検索設定#####
set ignorecase "大文字/小文字の区別なく検索する
set smartcase "検索文字列に大文字が含まれている場合は区別して検索する
set wrapscan "検索時に最後まで行ったら最初に戻る
set incsearch "インクリメントサーチ
set hlsearch
filetype plugin on

" rg があれば vimgrep の代わりに使う
if executable('rg')
  set grepprg=rg\ --vimgrep
  set grepformat=%f:%l:%c:%m
endif
" 自動QuickFix
au QuickfixCmdPost make,grep,grepadd,vimgrep copen
" lg で :lgrep
AlterCommand lg lgrep

"空白文字の可視化
set list
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%
hi NonText    ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE
hi SpecialKey ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE

" encoding
set fileformats=unix,dos,mac
set fileencodings=utf-8,sjis

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
"nnoremap <Esc><Esc> :nohlsearch<CR>
" スペースを挿入
nnoremap <C-Space> i<Space><Esc><Right>

" vim-anzu
nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)

" clear status
"nmap <Esc><Esc> <Plug>(anzu-clear-search-status):nohlsearch<CR>
nnoremap <silent> <Plug>(nohlsearch) :nohlsearch<CR>
nmap <Esc><ESc> <Plug>(anzu-clear-search-status)<Plug>(nohlsearch)

" statusline
set statusline=%{anzu#search_status()}

"#####NERDTree#####
"C-nでNERDTree起動
nnoremap <C-n> :NERDTreeToggle<CR>
"ファイル未指定で起動した時に自動でNERDTreeを起動
MyAutocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"NERDTreeだけのこったら消す
MyAutocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
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
:set directory=/tmp

" 相対パスを取得するコマンド
command! CopyRelativePath call setreg(v:register, expand("%:p:."))
" キーマッピング
nnoremap <Space>cl :CopyRelativePath<CR>
" 絶対パスを取得するコマンド
command! CopyAbsolutePath call setreg(v:register, expand("%:p"))
" キーマッピング
nnoremap <Space>ca :CopyAbsolutePath<CR>


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
\  "ruby.rspec" : {
\    "command" : "rspec",
\    "exec"    : "bundle exec %c %s:p\\:%{line('.')}",
\    "errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
\  },
\}

" QuickRun
nnoremap <Space>r :QuickRun<CR>
MyAutocmd BufEnter *_spec.rb set ft=ruby.rspec

" operator-replace
nmap s <Plug>(operator-replace)
vmap s <Plug>(operator-replace)

" tab
nnoremap <silent> <C-l> :tabnext<CR>
nnoremap <silent> <C-h> :tabprevious<CR>
nnoremap <silent> <C-Tab> :tabnext<CR>
command! -bar TabMoveNext :execute "tabmove " tabpagenr() % tabpagenr("$") + (tabpagenr("$") == tabpagenr() ? 0 : 1)
command! -bar TabMovePrev :execute "tabmove" (tabpagenr() + tabpagenr("$") - 2) % tabpagenr("$") + (tabpagenr() == 1 ? 1 : 0)
nnoremap <silent> <S-l> :TabMoveNext<CR>
nnoremap <silent> <S-h> :TabMovePrev<CR>
nnoremap tt :tabnew<CR>

" git 変更行
highlight GitGutterAdd ctermfg=blue ctermbg=brown

" github の pr を開く openpr
" gitconfig に設定してある openpr が前提
function! s:openpre_open() abort
  let line = line('.')
  let fname = expand('%')
  let cmd = printf('git blame -L %d,%d %s | cut -d " " -f 1', line, line, fname)
  let sha1 = system(cmd)
  let cmd = printf('gh openpr %s', sha1)
  echo system(cmd)
endfunction
nnoremap <F5> :call <SID>openpre_open()<CR>

" undo
function! s:mkdir(dir)
    if !isdirectory(a:dir)
        call mkdir(a:dir, "p")
    endif
endfunction

" undo ファイルを保存するディレクトリ
set undodir=$HOME/.vimundo
call s:mkdir(&undodir)
set undofile
set undolevels=5000

" Denite
MyAutocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
  call deoplete#custom#buffer_option('auto_complete', v:false)
  imap <silent><buffer> <Esc> <Plug>(denite_filter_quit)
  inoremap <silent><buffer> <Down> <Esc>
      \:call denite#move_to_parent()<CR>
      \:call cursor(line('.')+1,0)<CR>
      \:call denite#move_to_filter()<CR>A
  inoremap <silent><buffer> <Up> <Esc>
      \:call denite#move_to_parent()<CR>
      \:call cursor(line('.')-1,0)<CR>
      \:call denite#move_to_filter()<CR>A
  inoremap <silent><buffer> <C-j> <Esc>
      \:call denite#move_to_parent()<CR>
      \:call cursor(line('.')+1,0)<CR>
      \:call denite#move_to_filter()<CR>A
  inoremap <silent><buffer> <C-k> <Esc>
      \:call denite#move_to_parent()<CR>
      \:call cursor(line('.')-1,0)<CR>
      \:call denite#move_to_filter()<CR>A
  inoremap <silent><buffer> <C-CR> <Esc>
      \:call denite#move_to_parent()<CR>
      \<CR>
  inoremap <silent><buffer> <C-m> <Esc>
      \:call denite#move_to_parent()<CR>
      \<CR>
endfunction

" Define mappings
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
  \ denite#do_map('toggle_select').'j'
endfunction

command! -nargs=* -complete=customlist,denite#helper#complete
\    DeniteCtrlp Denite file/rec -start-filter -default-action=tabswitch <args>
command! -nargs=* -complete=customlist,denite#helper#complete
\    DeniteGrep Denite grep -start-filter -default-action=tabswitch <args>

command! DeniteQuickRunConfig :Denite quickrun_config -buffer-name=quickrun_config
nnoremap <silent> <Space>qr :DeniteQuickRunConfig<CR>

" ファイルの表示履歴一覧
nnoremap <Space>dfo   :Denite file/old<CR>
" プロジェクト直下のファイル一覧を表示する + 新規ファイル作成
nnoremap <Space>dff   :DeniteProjectDir file/rec file:new<CR>
" Grep する
nnoremap <Space>dgr   :DeniteGrep<CR>
" 最後に開いた Denite を開き直す
nnoremap <Space>drm   :Denite -resume<CR>

" :Denite のデフォルトの設定
let s:denite_default_options = {}

" 絞り込んだワードをハイライトする
call extend(s:denite_default_options, {
\    'highlight_matched_char': 'None',
\    'highlight_matched_range': 'Search',
\    'match_highlight': v:true,
\})

" denite を上に持っていく
call extend(s:denite_default_options, {
\    'direction': "top",
\    'filter_split_direction': "top",
\})

" フィルタのプロンプトを設定
call extend(s:denite_default_options, {
\    'prompt': '> ',
\})

" デフォルトで絞り込みウィンドウを開く
call extend(s:denite_default_options, {
\    'start_filter': v:true,
\})

call denite#custom#option('default', s:denite_default_options)


" denite-quickrun_config の並び順を単語順にする
call denite#custom#source('quickrun_config', 'sorters', ['sorter/word'])

" deoplete.nvim
let g:deoplete#enable_at_startup = 1
" deoplete 対象外
MyAutocmd FileType markdown
\ call deoplete#custom#buffer_option('auto_complete', v:false)
MyAutocmd FileType scrapbox
\ call deoplete#custom#buffer_option('auto_complete', v:false)


" CUI で起動した時にインサートモードのカーソルを | にする
if has('vim_starting') && !has("gui_running")
    " 挿入モード時に非点滅の縦棒タイプのカーソル
    let &t_SI .= "\e[6 q"
    " ノーマルモード時に非点滅のブロックタイプのカーソル
    let &t_EI .= "\e[2 q"
    " 置換モード時に非点滅の下線タイプのカーソル
    let &t_SR .= "\e[4 q"
endif

" カーソル位置の上に改行を挿入
" カーソル位置のテキストを下に動かすような挙動
nnoremap <silent> <C-j> :call append(line(".")-1, "")<CR>

" カーソル位置の上の行を削除
" カーソル位置を上に動かすような挙動
nnoremap <silent> <C-k> <Up>dd
" indentline"
let g:indentLine_color_term =239
let g:indentLine_char = '¦'

"previm
let g:previm_open_cmd = 'open -a Google\ Chrome'

"Scrapbox
"" 必須プラグイン
"  - https://github.com/vim-jp/vital.vim
"
" 概要
"   :ScrapboxOpenBuffer で現在のバッファを scrapbox で開く
"   1行目がタイトルでそれ以降が本文になる
"
" 設定
"   `g:scrapbox_project_name` にプロジェクト名を設定する

let g:scrapbox_project_name = "ima1zumi"

let s:File = vital#vital#new().import("System.File")
let s:URI = vital#vital#new().import("Web.URI")

function! s:scrapbox_open(project_name, title, body)
    let title = s:URI.encode(a:title)
    let body = s:URI.encode(a:body)
    let url = printf('https://scrapbox.io/%s/%s?body=%s', a:project_name, title, body)
    echo url
    call s:File.open(url)
endfunction

function! s:scrapbox_open_buffer(project_name, buffer)
    let title = a:buffer->split("\n")[0]
    let body = a:buffer->split("\n")[1:]->join("\n")
    call s:scrapbox_open(a:project_name, title, body)
endfunction

"command! ScrapboxOpenBuffer
"    \ call s:scrapbox_open_buffer(g:scrapbox_project_name, getline(1, "$")->join("\n"))
command! -range=% ScrapboxOpenBuffer
	\ call s:scrapbox_open_buffer(g:scrapbox_project_name, getline(<line1>, <line2>)->join("\n"))

" ft=scrapbox で buffer を開く
function! s:scrapbox_edit(cmd)
    execute a:cmd
    setlocal filetype=scrapbox
endfunction

command! -complete=command -nargs=1
\    ScrapboxEditOpen
\    call s:scrapbox_edit(<q-args>)

" 編集画面を新しいタブでシュッと開く
nnoremap <silent> <Space>ss ScrapboxEditOpen tabnew<CR>

"lightline
let g:lightline = {
        \ 'colorscheme': 'wombat',
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
        \ },
        \ 'component_function': {
        \   'modified': 'LightlineModified',
        \   'readonly': 'LightlineReadonly',
        \   'fugitive': 'LightlineFugitive',
        \   'filename': 'LightlineFilename',
        \   'fileformat': 'LightlineFileformat',
        \   'filetype': 'LightlineFiletype',
        \   'fileencoding': 'LightlineFileencoding',
        \   'mode': 'LightlineMode'
        \ }
        \ }

function! LightlineModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightlineReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
endfunction

function! LightlineFilename()
  return ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != LightlineModified() ? ' ' . LightlineModified() : '')
endfunction

function! LightlineFugitive()
  if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
    return fugitive#head()
  else
    return ''
  endif
endfunction

function! LightlineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineFileencoding()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction

function! LightlineMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

" カラースキーマ
" Vim の起動中だけ処理を呼ぶ
if has('vim_starting')
  colorscheme iceberg
  set bg=dark
"  set termguicolors
"  
"  let g:tokyonight_style = 'night' " available: night, storm
"  let g:tokyonight_enable_italic = 1
"  
"  colorscheme tokyonight
endif

