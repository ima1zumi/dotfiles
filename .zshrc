# plugin
# abbr
plugins=(... globalias)
my_globalias() {
   zle _expand_alias
   zle expand-word
   zle accept-line
}
zle -N my_globalias

bindkey -M emacs "^m" my_globalias
bindkey -M viins "^m" my_globalias

# nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# qmk_firmware
export PATH="/usr/local/opt/avr-gcc@8/bin:$PATH"

# rustup
export PATH="$HOME/.cargo/bin:$PATH"

# bison
export PATH="/usr/local/opt/bison/bin:$PATH"

# esp tools
export PATH="$HOME/esp/xtensa-esp32-elf/bin:$PATH"
export IDF_PATH="$HOME/esp/esp-idf"

# nvim
export XDG_CONFIG_HOME=~/.config

# macOS で Terminal.app を起動すると LC_CTYPE="UTF-8" になり ssh で警告が出る対策
export LC_CTYPE="ja_JP.UTF-8"

# asdf-ruby
export ASDF_RUBY_BUILD_VERSION="master"

# reline
export WITH_VTERM="1"

# build ruby
export MAKEFLAGS="--jobs $(sysctl -n hw.ncpu)"

# history
# setopt histignorealldups
HISTSIZE=100000
SAVEHIST=1000000
HISTFILE=~/.zsh_history
HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '
setopt share_history
setopt HIST_IGNORE_DUPS           # 前と重複する行は記録しない
setopt HIST_FIND_NO_DUPS          # 履歴検索中、(連続してなくとも)重複を飛ばす
setopt HIST_REDUCE_BLANKS         # 余分な空白は詰めて記録
setopt HIST_NO_STORE              # histroyコマンドは記録しない

# EDITOR setting
export EDITOR='nvim'

# Ctrl+D防止
setopt IGNOREEOF

# emacsモード
bindkey -e

# 色を使用出来るようにする
autoload -Uz colors
colors

# 補完
# 補完機能を有効にする
# asdf
. $HOME/.asdf/asdf.sh
# append completions to fpath
# fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

# nvim
alias v='nvim'
alias vz='nvim ~/.zshrc'
alias vv='nvim ~/.config/nvim/init.vim'
alias vd='nvim ~/.config/nvim/dein.toml'
alias va='nvim ~/.config/alacritty/alacritty.toml'

# source
alias sz='source ~/.zshrc'

# ls alias
alias ls='ls -G'
alias la='ls -la -G'
alias ll='ls -l -G'

# git alias
alias defaultbranch='git remote show origin | grep '\''HEAD branch'\'' | awk '\''{print $NF}'\'''
alias gc='git commit -v'
alias gca='git commit --amend -v'
alias ga='git add'
alias gs='git status'
alias gw='git switch'
alias gwd='git switch $(defaultbranch)'
alias gorf='git branch -a --no-merged | fzf | xargs git switch'
alias gl='git log'
alias glo='git log --oneline'
alias gloa='git log --oneline --graph --all'
alias gd='git diff'
alias gdc='git diff --cached'
alias gp='git push upstream HEAD'
alias gfp='git push --force-with-lease upstream HEAD'
alias gst='git stash'
alias gstp='git stash pop'
alias gpl='git pull --rebase'
alias gplod='git pull --rebase origin $(defaultbranch)'
alias gj='cd $(ghq list -p|fzf)'
alias gprc='gh pr checkout'
alias gwtl='git worktree list'
alias gwta='git worktree add'
alias gwtr='git worktree remove'

function grau() {
  dir=`pwd | sed -e 's/.*\/\([^\/]*\)$/\1/'`
  repo="https://github.com/ima1zumi/${dir}"
  git remote add upstream $repo && git remote -v
}

# https://petitviolet.hatenablog.com/entry/20190708/1562544000#git-branch%E3%81%A8tag%E3%81%8B%E3%82%89%E9%81%B8%E6%8A%9E%E3%81%99%E3%82%8B
# git branchとgit tagの結果からgit logを見ながらbranch/tagを選択する
function select_from_git_branch() {
  local list=$(\
    git branch --sort=refname --sort=-authordate --color --all \
      --format='%(authordate:short) %(objectname:short) %(refname:short) %(if)%(HEAD)%(then)* %(else)%(end)'; \
    git tag --color -l \
      --format='%(creatordate:short) %(objectname:short) %(align:width=45,position=left)%(refname:short)%(end)')

  echo $list | fzf --preview 'f() {
      set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}");
      [ $# -eq 0 ] || git --no-pager log -100 --date=short --color $1;
    }; f {}' |\
    sed -e 's/\* //g' | \
    awk '{print $3}'  | \
    sed -e "s;remotes/;;g" | \
    perl -pe 's/\n/ /g'
}

# ↑の関数で選んだbranch/tagを入力バッファに入れる
function select_to_insert_branch() {
    LBUFFER+=$(select_from_git_branch)
    CURSOR=$#LBUFFER
}

# ↑の関数で選んだbranch/tagにgit switchする
function select_git_switch() {
    local selected_file_to_switch=`select_from_git_branch | sed -e "s;origin/;;g"`
    if [ -n "$selected_file_to_switch" ]; then
      git switch $(echo "$selected_file_to_switch" | tr '\n' ' ')
    fi
}

alias gwf='select_git_switch'

alias gdbr='git branch -D $(git branch | tr -d " " | fzf --height 100% --prompt "DELETE BRANCH>" --preview "git log --color=always {}" | head -n 1 )'

# gh command
alias ghpc='gh pr create'
alias ghpd='gh pr diff'
alias ghpm='gh pr merge'
alias ghpo='gh pr checkout'

# gcc
alias gcc='gcc-13'
alias g++='g++-13'

# ruby

function irbm() {
  echo "ASDF_RUBY_VERSION=ruby-dev ruby -I ~/ghq/github.com/ruby/reline/lib -I ~/ghq/github.com/ruby/irb/lib ~/ghq/github.com/ruby/irb/exe/irb"
  echo "$(ASDF_RUBY_VERSION=ruby-dev ruby -v)"
  echo "IRB    branch: $(cd ~/ghq/github.com/ruby/irb && git rev-parse --abbrev-ref HEAD), HEAD: $(cd ~/ghq/github.com/ruby/irb && git show --format='%h' --no-patch)"
  echo Reline branch: $(cd ~/ghq/github.com/ruby/reline && git rev-parse --abbrev-ref HEAD), HEAD: $(cd ~/ghq/github.com/ruby/reline && git show --format='%h' --no-patch)
  ASDF_RUBY_VERSION=ruby-dev ruby -I ~/ghq/github.com/ruby/reline/lib -I ~/ghq/github.com/ruby/irb/lib ~/ghq/github.com/ruby/irb/exe/irb
}

alias irbm='irbm'

# bundler
alias be='bundle exec'
alias bi='bundle install'

# docker compose
alias dcd='docker compose down'
alias dcdv='docker compose down -v'
alias dcu='docker compose up'
alias dcr='docker compose run --rm'
alias dce='docker compose exec'

### Added by Zinit's installer
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure
zinit light zsh-users/zsh-autosuggestions

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# batのカラースキーマ
export BAT_THEME="ansi"

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Created by `pipx` on 2026-01-01 07:35:29
export PATH="$PATH:/Users/mi/.local/bin"
eval "$(mise activate zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ima1zumi/Downloads/google-cloud-sdk 2/path.zsh.inc' ]; then . '/Users/ima1zumi/Downloads/google-cloud-sdk 2/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ima1zumi/Downloads/google-cloud-sdk 2/completion.zsh.inc' ]; then . '/Users/ima1zumi/Downloads/google-cloud-sdk 2/completion.zsh.inc'; fi
export PATH="$HOME/.local/bin:$PATH"
