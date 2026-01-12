local opt = vim.opt

-- クリップボードをOSのシステムクリップボードと同期させる
vim.opt.clipboard = "unnamedplus"

-- 表示設定
opt.number = true -- 行番号表示
opt.title = true -- 編集中のファイル名を表示
opt.cursorline = true -- カーソル行にラインを表示

-- 空白文字の設定
opt.list = true -- 空白文字の可視化
opt.listchars = { tab = "»-", trail = "-", extends = "»", precedes = "«", nbsp = "%"} -- 空白文字を何で可視化するか
opt.expandtab = true -- 挿入モードでtabを入れるときに空白を使う
opt.shiftround = true -- インデントをshiftwidthの倍数に丸める
opt.shiftwidth = 2 -- >> コマンドなどで行頭に挿入するスペースの数
opt.softtabstop = 2 -- タブキーで入力するスペース数
opt.tabstop = 2 -- タブ１文字の表示幅

opt.scrolloff = 3

-- move the cursor to the previous/next line across the first/last character
vim.opt.whichwrap = 'b,s,h,l,<,>,[,],~'

-- 入力
-- 検索
opt.ignorecase = true -- 大文字・小文字を区別しないで検索
opt.smartcase = true -- 検索パターンに大文字を含むときは大文字・小文字を区別して検索

-- ヘルプ
opt.helplang = 'ja'
