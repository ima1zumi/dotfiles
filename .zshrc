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

# ruby rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# qmk_firmware
export PATH="/usr/local/opt/avr-gcc@8/bin:$PATH"

# history
# setopt histignorealldups
HISTSIZE=100000
SAVEHIST=1000000
HISTFILE=~/.zsh_history
HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '
setopt share_history

# EDITOR setting
export EDITOR='vim'

# Ctrl+D防止
setopt IGNOREEOF

# 色を使用出来るようにする
autoload -Uz colors
colors

# 補完
# 補完機能を有効にする
autoload -Uz compinit
compinit

#zsh-autosuggestions
#https://github.com/zsh-users/zsh-autosuggestions
# source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# export PATH=/usr/local/Cellar/vim/8.2.1600/bin:$PATH

# vim
alias v='vim'
alias vz='vim ~/.zshrc'
alias vv='vim ~/.vimrc'
alias vd='vim ~/.vim/dein.toml'

# source
alias sz='source ~/.zshrc'

# cd alias
alias ..='cd ..'
alias ..2='cd ../../'
alias ..3='cd ../../'

# ls alias
alias ls='ls -G'
alias la='ls -la -G'
alias ll='ls -l -G'

# git alias
alias gc='git commit'
alias gc='git commit -v'
alias ga='git add'
alias gs='git status'
alias gco='git checkout'
alias gl='git log'
alias glo='git log --oneline'
alias gloa='git log --oneline --graph --all'
alias gd='git diff'
alias gdc='git diff --cached'
alias gp='git push'
alias gst='git stash'
alias gstp='git stash pop'
alias gpl='git pull --rebase'
function gplod() {
  defaultbranch=`git symbolic-ref refs/remotes/origin/HEAD | awk -F'[/]' '{print $NF}'`
  git pull --rebase origin $defaultbranch
}

# gh command
alias ghprc='gh pr create'
alias ghprd='gh pr diff'
alias ghprm='gh pr merge'

# bundler
alias bi='bundle install'
alias be='bundle exec'

# rails
alias br='bin/rails'

# ruby
alias rubyw='ruby -W'
alias irbw='irb -W'
alias irbm='RBENV_VERSION=3.1.0-dev ruby -I /Users/mi/ghq/github.com/ruby/reline/lib -I /Users/mi/ghq/github.com/ruby/irb/lib /Users/mi/ghq/github.com/ruby/irb/exe/irb'


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
