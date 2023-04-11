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

" for denite, defx
let g:python3_host_prog = expand('/usr/local/bin/python3')

set clipboard=unnamed

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
set textwidth=0 " 自動改行をオフにする
set laststatus=2 "ステータス行を表示
set cursorline "カーソル行にラインを表示
set wildmenu "コマンドライン補完
set nocompatible "viとの互換性を無効にする
" set autochdir "ファイルを開いたらカレントディレクトリを移動する
set autoread " ファイルがVimの内部では変更されてないが、Vimの外部で変更されたことが判明したとき、自動的に読み直す

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
" 置換のハイライトをONにするために有効にした ref: neovim/neovim #12308
set inccommand=nosplit
filetype plugin on

" 縦分割したら右に出す
set splitright
" 横分割したら下に出す
set splitbelow

" rg があれば vimgrep の代わりに使う
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

" encoding
set fileformats=unix,dos,mac
set fileencodings=utf-8,sjis
lang en_US.UTF-8

"#####keybind#####
"クリップボード
xnoremap p "_dP
set whichwrap=b,s,h,l,<,>,[,],~
set mouse=a
"#折返しで下にいけるようにする
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
" 検索したら必ずカーソルを画面中央に移動
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz

" TerminalをEscで抜ける
tnoremap <Esc> <C-\><C-n>

" esc 2回でハイライトを削除
nnoremap <Esc><Esc> :nohl<CR>

"BSで削除できるものを指定する
" indent  : 行頭の空白
" eol     : 改行
" start   : 挿入モード開始位置より手前の文字
set backspace=indent,eol,start

" ヘルプの日本語化
set helplang=ja

" 相対パスを取得するコマンド
command! CopyRelativePath call setreg(v:register, expand("%:p:."))
" .git からの相対パスを取得する
function! ProjectRelativePath() abort
  let project_dir = denite#project#path2project_directory(expand("%"), "")
  let full_path = expand("%:p")
  let relative_path = substitute(full_path, project_dir, "", "")[1:-1]
  return relative_path
endfunction
command! CopyProjectRelativePath call setreg(v:register, ProjectRelativePath())
nnoremap <silent> <Space>cl :CopyProjectRelativePath<CR>
" 絶対パスを取得するコマンド
command! CopyAbsolutePath call setreg(v:register, expand("%:p"))
nnoremap <Space>ca :CopyAbsolutePath<CR>

" json を整形する (jq に依存)
command! JSONFormatter %!jq '.'

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

" 重いときの調査用
command! Profile call s:command_profile()
function! s:command_profile() abort
  profile start /tmp/profile.log
  profile func *
  profile file *
endfunction

" tab
nnoremap <silent> <C-l> :tabnext<CR>
nnoremap <silent> <C-h> :tabprevious<CR>
nnoremap <silent> <C-Tab> :tabnext<CR>
command! -bar TabMoveNext :execute "tabmove " tabpagenr() % tabpagenr("$") + (tabpagenr("$") == tabpagenr() ? 0 : 1)
command! -bar TabMovePrev :execute "tabmove" (tabpagenr() + tabpagenr("$") - 2) % tabpagenr("$") + (tabpagenr() == 1 ? 1 : 0)
nnoremap <silent> <S-l> :TabMoveNext<CR>
nnoremap <silent> <S-h> :TabMovePrev<CR>
nnoremap tt :tabnew<CR>

" Terminalを開くとデフォルトでインサートにする
autocmd TermOpen * startinsert

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fzf
set rtp+=/usr/local/opt/fzf
" setting FZF_DEFAULT_COMMAND for rg
" https://github.com/junegunn/fzf.vim/issues/583
let $FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
" bat でプレビューの色をつける
" https://github.com/junegunn/fzf.vim/issues/1179#issuecomment-817194906
let $FZF_PREVIEW_COMMAND="bat --color=always --style=numbers --line-range=:500 {}"
nnoremap <silent> <C-p> :GFiles<CR>
nnoremap <silent> <space>fh :History<CR>

" .git があるディレクトリで grep する
" --hidden で隠しファイルも含める
" --glob '!.git' で .git は対象から取り除く
command! -bang -nargs=* GGrep
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case --hidden --glob ''!.git'' -- '.shellescape(<q-args>), 1,
      \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0],}), <bang>0)

" ref: https://zenn.dev/ktakayama/articles/19551f703fe7c0
command! -bang FzfGitBranchFiles
  \ call fzf#run({'source':
  \   "git diff --name-only $(git show-branch --sha1-name $(git symbolic-ref --short refs/remotes/origin/HEAD) $(git rev-parse --abbrev-ref HEAD) | tail -1 | awk -F'[]~^[]' '{print $2}')",
  \   'sink': 'e',
  \   'options': '-m --prompt "GitBranchFiles> " --preview "bat --color=always --style=numbers {}"',
  \   'window': { 'width': 0.9, 'height': 0.6 },
  \   'dir': systemlist('git rev-parse --show-toplevel')[0]
  \   })

nnoremap <silent> <space>fg :FzfGitBranchFiles<CR>

execute "nnoremap <Space>re :GGrep "

" operator-replace
nmap s <Plug>(operator-replace)
vmap s <Plug>(operator-replace)

" git 変更行
highlight GitGutterAdd ctermfg=blue ctermbg=brown

" 常に左端のサイン列を表示させる
set signcolumn=yes
" ファイルを変更してサイン列に表示されるまでの時間を100ms
set updatetime=100

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

" vim-better-whitespace
" 警告の色をicebergっぽくする
let g:better_whitespace_guicolor='#cc517a'

" gina
nnoremap <Space>gs  :Gina status<CR>
nnoremap <Space>gb  :Gina blame<CR>
nnoremap <Space>gr  :Gina browse --exact :<CR>
nnoremap <Space>gca :Gina commit --amend -v<CR>
nnoremap <Space>gc  :Gina commit -v -q<CR>
nnoremap <Space>gd  :Gina compare --opener=split<CR>
nnoremap <Space>gp  :!git push upstream head<CR>
nnoremap <Space>gfp :!git push --force-with-lease upstream head<CR>
nnoremap <Space>gl  :Gina log<CR>

" Echo chunk info with j/k
call gina#custom#mapping#nmap(
      \ 'blame', 'j',
      \ 'j<Plug>(gina-blame-echo)'
      \)
call gina#custom#mapping#nmap(
      \ 'blame', 'k',
      \ 'k<Plug>(gina-blame-echo)'
      \)
call gina#custom#mapping#nmap(
      \ 'blame', 's',
      \ ':call gina#action#call(''show:commit:tab'')<CR>',
      \ {'noremap': 1, 'silent': 1},
      \)
call gina#custom#mapping#nmap('blame', 'dd', '<Plug>(gina-diff-tab)')

" \{'noremap': 1, 'silent': 1, 'buffer': 1, 'nowait': 1}
" vim-gitgutter
" 変更へジャンプ
nmap <Space>gn <Plug>(GitGutterNextHunk)
nmap <Space>gN <Plug>(GitGutterPrevHunk)

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
nnoremap <Space>gpr :call <SID>openpre_open()<CR>

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

" vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2

" vim-operator-stay-cursor
" yank したときにカーソルを動かさない
map y <Plug>(operator-stay-cursor-yank)

" vim-operator-surround
" operator mappings
" saaw'
map <silent>sa <Plug>(operator-surround-append)
" sda'
map <silent>sd <Plug>(operator-surround-delete)
" sra'"
map <silent>sr <Plug>(operator-surround-replace)

" fugitive の設定を上書きする
augroup my_fugitive
  autocmd FileType gitcommit setlocal textwidth=0
augroup END

" nvim-treesitter
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "c",
    "javascript",
    "json",
    "lua",
    "ruby",
    "rust",
    "toml",
    "vim",
    "vue",
    "yaml"
  },
  highlight = {
    enable = true,
    disable = {},
    },
  --- nvim-treesitter-endwise
  endwise = {
    enable = true,
},
}
EOF

" vim-slim
MyAutocmd BufNewFile,BufRead *.slim setlocal filetype=slim

" Comment.nvim
lua << EOF
require('Comment').setup {
  ---Add a space b/w comment and the line
  padding = true,
  ---Whether the cursor should stay at its position
  sticky = true,
  ---Lines to be ignored while (un)comment
  ignore = nil,
  ---LHS of toggle mappings in NORMAL mode
  toggler = {
    ---Line-comment toggle keymap
    line = '<space>c',
    ---Block-comment toggle keymap
    block = '<space>bc',
  },
  ---LHS of operator-pending mappings in NORMAL and VISUAL mode
  opleader = {
    ---Line-comment keymap
    line = '<space>c',
    ---Block-comment keymap
    block = '<space>b',
  },
  ---LHS of extra mappings
  extra = {
    ---Add comment on the line above
    above = '<space>cO',
    ---Add comment on the line below
    below = '<space>co',
    ---Add comment at the end of line
    eol = '<space>cA',
  },
  ---Enable keybindings
  ---NOTE: If given `false` then the plugin won't create any mappings
  mappings = {
    ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
    basic = true,
    ---Extra mapping; `gco`, `gcO`, `gcA`
    extra = true,
  },
  ---Function to call before (un)comment
  pre_hook = nil,
  ---Function to call after (un)comment
  post_hook = nil,
}
EOF

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 外部ファイル読み込み
source <sfile>:h/coc.vim
source <sfile>:h/defx.vim
source <sfile>:h/denite.vim
source <sfile>:h/quickrun.vim
source <sfile>:h/rurema.vim
source <sfile>:h/secrets.vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" カラースキーマ
" Terminal.app以外のtermguicolors対応端末での設定
if has('termguicolors') && $TERM_PROGRAM !=# 'Apple_Terminal'
  " 256色にする
  set termguicolors
  " termguicolors のあとで tokyonight に設定
  "   let g:tokyonight_style = 'night'
  colorscheme duskfox
  " 背景を透明にする
  " colorscheme の後に書く
  highlight Normal ctermbg=NONE guibg=NONE
  highlight NonText ctermbg=NONE guibg=NONE
  highlight SpecialKey ctermbg=NONE guibg=NONE
  highlight EndOfBuffer ctermbg=NONE guibg=NONE
  " tmux
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

lua <<END
require'lualine'.setup {
  options = {
    theme = 'iceberg_dark',
    },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {'ProjectRelativePath'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
},
}
END
