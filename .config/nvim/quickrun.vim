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
