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
" rigprepを使う
call denite#custom#var('grep', {
      \ 'command': ['rg'],
      \ 'default_opts': ['-i', '--vimgrep', '--no-heading'],
      \ 'recursive_opts': [],
      \ 'pattern_opt': ['--regexp'],
      \ 'separator': ['--'],
      \ 'final_opts': [],
      \ })

" 起動
nnoremap <Space>ll :Denite menu -no-start-filter<CR>

augroup my_denite
    autocmd!
    autocmd FileType denite-filter call s:denite_filter_my_settings()
augroup END
function! s:denite_filter_my_settings() abort
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
  nnoremap <silent><buffer><expr> v
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
  \ denite#do_map('toggle_select').'j'
  nnoremap <silent><buffer><expr><nowait> t
        \ denite#do_map('do_action', 'tabswitch')
  nnoremap <silent><buffer><expr> a
        \ denite#do_map('choose_action')
endfunction

command! DeniteQuickRunConfig :Denite quickrun_config -buffer-name=quickrun_config
nnoremap <silent> <Space>qr :DeniteQuickRunConfig<CR>

command! DeniteDotfiles :Denite file/rec:~/ghq/github.com/ima1zumi/dotfiles/.config/nvim file:hidden:~/ghq/github.com/ima1zumi/dotfiles -source-names=hide
nnoremap <silent> <Space>do :DeniteDotfiles<CR>

" ファイルの表示履歴一覧
nnoremap <Space>dfo   :Denite file/old -no-start-filter<CR>
" プロジェクト直下のファイル一覧を表示する + 新規ファイル作成
nnoremap <Space>dff   :DeniteProjectDir file/rec file:new<CR>
" 最後に開いた Denite を開き直す
nnoremap <Space>drm   :Denite -resume<CR>

" denite grep で第二引数にパスを受け取れるようにする
function! s:grep(...)
    let pattern = get(a:000, 0, "")
    if empty(pattern)
        let pattern = input("Pattern: ")
    endif
    let path = get(a:000, 1, "")
    let current = getcwd()
    call denite#start([{'name': 'grep', 'args': [current . "/" . path, "", pattern] }], { "buffer_name": "grep", "post_action": 'jump' })
endfunction
command! -nargs=* -complete=dir
\    DeniteGrep call s:grep(<f-args>)

" 末尾のスペースが消える対策にexecuteを使ってnnoremapする
execute "nnoremap <Space>re   :DeniteGrep "

" :Denite のデフォルトの設定
let s:denite_default_options = {}

" 絞り込んだワードをハイライトする
call extend(s:denite_default_options, {
\    'highlight_matched_char': 'None',
\    'highlight_matched_range': 'Search',
\    'match_highlight': v:true,
\})

" denite を上に持っていく
" call extend(s:denite_default_options, {
"\    'direction': "top",
"\    'filter_split_direction': "top",
"\})

" フィルタのプロンプトを設定
call extend(s:denite_default_options, {
\    'prompt': '> ',
\})

" デフォルトで絞り込みウィンドウを開く
" call extend(s:denite_default_options, {
"\    'start_filter': v:true,
"\})

call denite#custom#option('default', s:denite_default_options)
call denite#custom#option('grep', s:denite_default_options)
call denite#custom#option('filter', s:denite_default_options)

" denite-quickrun_config の並び順を単語順にする
call denite#custom#source('quickrun_config', 'sorters', ['sorter/word'])

