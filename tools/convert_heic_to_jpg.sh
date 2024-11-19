#!/bin/bash

# カレントディレクトリのすべてのHEICファイルを検索してループ処理
find . -iname '*.heic' | while read file; do
    # ファイル名の取得
    filename_with_extension=$(basename "$file")

    # 拡張子以外のファイル名の取得
    filename="${filename_with_extension%.[Hh][Ee][Ii][Cc]}"

    # HEICからJPGへの変換
    magick "$file" "${filename}.jpg"

    mv "$file" ~/.Trash
done

echo "Conversion complete."
