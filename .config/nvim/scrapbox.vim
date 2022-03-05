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
