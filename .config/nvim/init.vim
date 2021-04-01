" 先頭に記述する
" polyglot の markdown を無効にする
let g:polyglot_disabled = ['markdown']

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
  let s:rc_dir = expand('~/.config/nvim')
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

" v:oldfiles で保存するファイル数を設定
" vimrc に書いておく必要がある
set viminfo+='10000
set viminfo-='100     " デフォルトの設定を削除しておかないと反映されない

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
lang en_US.UTF-8

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
nnoremap <Space>cl :CopyRelativePath<CR>
" 絶対パスを取得するコマンド
command! CopyAbsolutePath call setreg(v:register, expand("%:p"))
nnoremap <Space>ca :CopyAbsolutePath<CR>

" binary mode
"バイナリ編集(xxd)モード（vim -b での起動、もしくは *.bin ファイルを開くと発動します）
augroup BinaryXXD
  autocmd!
  autocmd BufReadPost * if &binary | silent %!xxd -g 1
  autocmd BufReadPost * set ft=xxd | endif
  autocmd BufWritePre * if &binary | %!xxd -r
  autocmd BufWritePre * endif
  autocmd BufWritePost * if &binary | silent %!xxd -g 1
  autocmd BufWritePost * set nomod | endif
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ale
let g:ale_fixers = {'ruby': 'rubocop'}
let g:ale_fix_on_save = 1

" Only run linters named in ale_linters settings.
let g:ale_linters_explicit = 1

let g:ale_completion_enabled = 0
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_echo_msg_warning_str = 'W'

" Quickrun シュッとするやつ
let g:quickrun_config = {
\  "_" : {
\    "runner" : "job",
\    "outputter/buffer/split" : ":botright 8sp",
\    "outputter/setbufline/split" : ":botright 8sp",
\    "hook/extend_config/enable" : 1,
\    "hook/extend_config/force" : 1,
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

"vim-quickrun-neovim-job
if has('nvim')
  " Use 'neovim_job' in Neovim
  let g:quickrun_config._.runner = 'neovim_job'
elseif exists('*ch_close_in')
  " Use 'job' in Vim which support job feature
  let g:quickrun_config._.runner = 'job'
endif

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

" git 現在開いているファイルの master ブランチ時点でのファイルを Vim で開く
function! s:git_show(branch, path, filetype)
    let branch = a:branch == "" ? "master" : a:branch
    let cmd = printf("git show %s:%s", branch, a:path)
    new
    execute "read!" cmd
    let &filetype = a:filetype
    " 一番上の行に移動して空行を削除
    normal! ggdd
endfunction

command! -nargs=* GitShow
\    call s:git_show(<q-args>, "./" . expand("%:."), &filetype)

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

" vim-quickhl
nmap <Space>m <Plug>(quickhl-manual-this)
xmap <Space>m <Plug>(quickhl-manual-this)
nmap <Space>M <Plug>(quickhl-manual-reset)
xmap <Space>M <Plug>(quickhl-manual-reset)

" Denite
" denite-menu の設定
let s:menus = {}

" Denite menu:dotfile
" をすると開くファイルを登録する
let s:menus.dotfile = {
    \ 'description': 'Edit your dotfile'
    \ }
let s:menus.dotfile.file_candidates = [
    \ ['init.vim', '~/.config/nvim/init.vim'],
    \ ['dein.toml', '~/.config/nvim/dein.toml'],
    \ ['zshrc', '~/.zshrc'],
    \ ]

" 登録
call denite#custom#var('menu', 'menus', s:menus)

" 起動
nnoremap <Space>ll :Denite menu -no-start-filter<CR>

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
nnoremap <Space>dfo   :Denite file/old -no-start-filter<CR>
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

" defx
call defx#custom#option('_', {
      \ 'split': 'tab',
      \ 'show_ignored_files': 1,
      \ 'buffer_name': 'explorer',
      \ 'toggle': 1,
      \ 'columns': 'indent:git:icons:filename:mark',
      \ })
" 自動更新
autocmd BufWritePost * call defx#redraw()
autocmd BufEnter * call defx#redraw()
" キーコンフィグ
MyAutocmd FileType defx call s:defx_my_settings()
function! s:defx_my_settings() abort
  " Define mappings
  nnoremap <silent><buffer><expr> <CR>
        \ defx#do_action('open')
  nnoremap <silent><buffer><expr> c
        \ defx#do_action('copy')
  nnoremap <silent><buffer><expr> m
        \ defx#do_action('move')
  nnoremap <silent><buffer><expr> p
        \ defx#do_action('paste')
  nnoremap <silent><buffer><expr> l
        \ defx#do_action('open')
  nnoremap <silent><buffer><expr> E
        \ defx#do_action('open', 'vsplit')
  nnoremap <silent><buffer><expr> t
        \ defx#do_action('open', 'tabnew')
  nnoremap <silent><buffer><expr> P
        \ defx#do_action('preview')
  nnoremap <silent><buffer><expr> o
        \ defx#do_action('open_tree', 'toggle')
  nnoremap <silent><buffer><expr> O
        \ defx#do_action('open_tree', 'recursive')
  nnoremap <silent><buffer><expr> K
        \ defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> N
        \ defx#do_action('new_file')
  nnoremap <silent><buffer><expr> M
        \ defx#do_action('new_multiple_files')
  nnoremap <silent><buffer><expr> C
        \ defx#do_action('toggle_columns',
        \                'mark:indent:icon:filename:type:size:time')
  nnoremap <silent><buffer><expr> S
        \ defx#do_action('toggle_sort', 'time')
  nnoremap <silent><buffer><expr> d
        \ defx#do_action('remove')
  nnoremap <silent><buffer><expr> r
        \ defx#do_action('rename')
  nnoremap <silent><buffer><expr> !
        \ defx#do_action('execute_command')
  nnoremap <silent><buffer><expr> x
        \ defx#do_action('execute_system')
  nnoremap <silent><buffer><expr> yy
        \ defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> .
        \ defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> R
        \ defx#do_action('repeat')
  nnoremap <silent><buffer><expr> h
        \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> ~
        \ defx#do_action('cd')
  nnoremap <silent><buffer><expr> q
        \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> <Space>
        \ defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> *
        \ defx#do_action('toggle_select_all')
  nnoremap <silent><buffer><expr> j
        \ line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k
        \ line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> <C-l>
        \ defx#do_action('redraw')
  nnoremap <silent><buffer><expr> <C-g>
        \ defx#do_action('print')
  nnoremap <silent><buffer><expr> cd
        \ defx#do_action('change_vim_cwd')
endfunction

" 開いているファイルから検索
nnoremap <Space>dfx :Defx `escape(expand('%:p:h'), ' :')` -search=`expand('%:p')`<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" CUI で起動した時にインサートモードのカーソルを | にする
if has('vim_starting') && !has("gui_running")
    " 挿入モード時に非点滅の縦棒タイプのカーソル
    let &t_SI .= "\e[6 q"
    " ノーマルモード時に非点滅のブロックタイプのカーソル
    let &t_EI .= "\e[2 q"
    " 置換モード時に非点滅の下線タイプのカーソル
    let &t_SR .= "\e[4 q"
endif

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
  let title = split(a:buffer, "\n")[0]
  let body = join(split(a:buffer, "\n")[1:], "\n")
  call s:scrapbox_open(a:project_name, title, body)
endfunction

command! -range=% ScrapboxOpenBuffer
  \ call s:scrapbox_open_buffer(g:scrapbox_project_name, join(getline(<line1>, <line2>), "\n"))

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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" rurema
augroup my_rurema
  autocmd!
augroup END

command! -bang -nargs=*
\  MyRuremaAutocmd
\  autocmd<bang> my_rurema <args>

MyRuremaAutocmd BufReadPost *.rd set filetype=rd
MyRuremaAutocmd BufReadPost */doctree/refm/api/src/* set filetype=rd

function! Grurema_target()
  return (expand('%:t:r') =~ '^\u') ? ('--target=' . expand('%:t:r')) : ''
endfunction

let s:config = {
\    "rd" : {
\        "type" : 'rd/bitclust_htmlfile',
\    },
\    "rd/_" : {
\        "command" : "bitclust",
\        "outputter" : "browser",
\        "exec"    : "%c htmlfile %s:p %{ Grurema_target() } %o",
\    },
\    "rd/bitclust_htmlfile" : {
\        "cmdopt"    : "--ruby=latest",
\    },
\    "rd/bitclust_htmlfile 3.0.0" : {
\        "cmdopt"    : "--ruby=3.0.0",
\    },
\    "rd/bitclust_htmlfile 2.7.0" : {
\        "cmdopt"    : "--ruby=2.7.0",
\    },
\    "rd/bitclust_htmlfile 2.6.0" : {
\        "cmdopt"    : "--ruby=2.6.0",
\    },
\    "rd/bitclust_htmlfile 2.5.0" : {
\        "cmdopt"    : "--ruby=2.5.0",
\    },
\    "rd/bitclust_htmlfile 2.0.0" : {
\        "cmdopt"    : "--ruby=2.0.0",
\    },
\    "rd/bitclust_htmlfile 1.9.0" : {
\        "cmdopt"    : "--ruby=1.9.0",
\    },
\}

call extend(g:quickrun_config, s:config)
unlet s:config

function! s:kusa(start, end)
  let view = winsaveview()
  call append(a:start - 1, "#@samplecode ?")
  for lnum in range(a:start + 1, a:end + 1)
    call setline(lnum, matchstr(getline(lnum), '\s\{2}\zs.*'))
  endfor
  call append(a:end + 1, "#@end")
  call winrestview(view)
endfunction

command! -range=% Kusa call s:kusa(<line1>, <line2>)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" カラースキーマ
colorscheme iceberg
" Terminal.app以外のtermguicolors対応端末での設定
if has('termguicolors') && $TERM_PROGRAM !=# 'Apple_Terminal'
  set termguicolors
  " tmux
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  " Vimではset bg=darkを設定しないとlightlineの表示がおかしくなる
  if !has('nvim')
    set bg=dark
  endif
  " 背景透過
  " colorscheme の後に書く
  highlight Normal ctermbg=NONE guibg=NONE
  highlight NonText ctermbg=NONE guibg=NONE
  highlight SpecialKey ctermbg=NONE guibg=NONE
  highlight EndOfBuffer ctermbg=NONE guibg=NONE
  " お好み
  "highlight LineNr ctermbg=NONE guibg=NONE
  "highlight SignColumn ctermbg=NONE guibg=NONE
  "highlight VertSplit ctermbg=NONE guibg=NONE
  "lightline
  let g:lightline = {
          \ 'colorscheme': 'iceberg',
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
" Terminal.app
else
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
end

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

