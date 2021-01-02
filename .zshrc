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

# history
# setopt histignorealldups
HISTSIZE=100000
SAVEHIST=1000000
HISTFILE=~/.zsh_history
HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '
setopt share_history

# EDITOR setting
export EDITOR='vim'

# prompt setting
source ~/.git-prompt.sh

# Ctrl+D防止
setopt IGNOREEOF

# 色を使用出来るようにする
autoload -Uz colors
colors

# 補完
# 補完機能を有効にする
autoload -Uz compinit
compinit

# prompt_pure
autoload -U promptinit; promptinit
prompt pure

# nvm
# node.js重いので一旦消す
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#zsh-autosuggestions
#https://github.com/zsh-users/zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH=/usr/local/Cellar/vim/8.2.1600/bin:$PATH

# vim
alias v='vim'
alias vz='vim ~/.zshrc'
alias vv='vim ~/.vimrc'

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
alias ga='git add'
alias gs='git status'
alias gco='git checkout'
alias gl='git log'
alias glo='git log --oneline'
alias gloa='git log --oneline --graph --all'
alias gd='git diff'
alias gdc='git diff --cached'
alias gp='git push'
alias gpl='git pull --rebase'

# bundler
alias bi='bundle install'
alias be='bundle exec'

# rails
alias br='bin/rails'

# ruby
alias rubyw='ruby -W'
alias irbw='irb -W'

