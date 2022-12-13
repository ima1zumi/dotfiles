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

# binutils
# export PATH="/usr/local/opt/binutils/bin:$PATH"

# bison
export PATH="/usr/local/Cellar/bison/3.8.2/bin:$PATH"

# nvim
export XDG_CONFIG_HOME=~/.config

# macOS で Terminal.app を起動すると LC_CTYPE="UTF-8" になり ssh で警告が出る対策
export LC_CTYPE="ja_JP.UTF-8"

# asdf-ruby
export ASDF_RUBY_BUILD_VERSION="master"

# history
# setopt histignorealldups
HISTSIZE=100000
SAVEHIST=1000000
HISTFILE=~/.zsh_history
HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '
setopt share_history
setopt HIST_IGNORE_DUPS           # 前と重複する行は記録しない
setopt HIST_IGNORE_ALL_DUPS       # 履歴中の重複行をファイル記録前に無くす
setopt HIST_FIND_NO_DUPS          # 履歴検索中、(連続してなくとも)重複を飛ばす
setopt HIST_REDUCE_BLANKS         # 余分な空白は詰めて記録
setopt HIST_NO_STORE              # histroyコマンドは記録しない

# EDITOR setting
export EDITOR='nvim'

# Ctrl+D防止
setopt IGNOREEOF

# 色を使用出来るようにする
autoload -Uz colors
colors

# 補完
# 補完機能を有効にする
# asdf
. $HOME/.asdf/asdf.sh
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

# nvim
alias v='nvim'
alias vz='nvim ~/.zshrc'
alias vv='nvim ~/.config/nvim/init.vim'
alias vd='nvim ~/.config/nvim/dein.toml'
alias va='nvim ~/.config/alacritty/alacritty.yml'

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
alias ghprc='gh pr create'
alias ghprd='gh pr diff'
alias ghprm='gh pr merge'

# gcc
alias gcc='gcc-12'
alias g++='g++-12'

# ruby
alias irbm='ASDF_RUBY_VERSION=3.2.0-dev ruby -I /Users/mi/ghq/github.com/ruby/reline/lib -I /Users/mi/ghq/github.com/ruby/irb/lib /Users/mi/ghq/github.com/ruby/irb/exe/irb'

# docker compose
alias dcd='docker compose down'
alias dcdv='docker compose down -v'
alias dcu='docker compose up'
alias dcr='docker compose run --rm'
alias dce='docker compose exec'
alias dsss='docker-sync-stack start'

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

source /Users/mi/.zinit/plugins/b4b4r07---enhancd/init.sh
zinit load "b4b4r07/enhancd"
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure
zinit light zsh-users/zsh-autosuggestions

# fzfのキーバインディングを設定
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# batのカラースキーマ
export BAT_THEME="ansi"
