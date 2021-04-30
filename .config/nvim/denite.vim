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

