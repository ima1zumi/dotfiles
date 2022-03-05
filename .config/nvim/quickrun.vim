" Quickrun シュッとするやつ
"  -c -fd --tty をつけているところは明示的にエスケープシーケンスを出力するための設定
let g:quickrun_config = {
      \ '*': {
        \    'split': 'vertical'
        \  },
        \  "_" : {
          \    "runner" : "job",
          \    "outputter/buffer/split" : ":botright 8sp",
          \    "outputter/setbufline/split" : ":botright 8sp",
          \    "hook/extend_config/enable" : 1,
          \    "hook/extend_config/force" : 1,
          \    "outputter/buffer/close_on_empty": 1
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
                \    "exec"    : "bundle exec %c %s:p\\:%{line('.')} -c -fd --tty",
                \    "errorformat" : "%f:%l: %tarning: %m, %E%.%#:in `load': %f:%l:%m, %E%f:%l:in `%*[^']': %m, %-Z     # %f:%l:%.%#, %E  %\\d%\\+)%.%#, %C     %m, %-G%.%#",
                \  },
                \  "ruby.rspec/docker" : {
                  \    "command" : "docker-compose",
                  \    "cmdopt" : "exec -T web bin/rspec -c -fd --tty",
                  \    "exec" : "%c %o %s:.\\:%{line('.')}",
                  \    },
                  \  "ruby.rspec/docker-bin-rspec" : {
                    \    "command" : "docker-compose",
                    \    "cmdopt" : "exec -T web bin/rspec",
                    \    "exec" : "%c %o",
                    \    },
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
autocmd BufEnter *_spec.rb set ft=ruby.rspec

" ANSI escape をハイライトする
augroup my-quickrun
  autocmd!
  autocmd FileType quickrun AnsiEsc
augroup END

" <C-c> で quickrun の実行を中断する
nnoremap <expr><silent> <C-c> quickrun#session#exists() ? quickrun#session#sweep() : "\<C-c>"
