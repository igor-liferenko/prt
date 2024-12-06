stty erase ^H
PS1=$'\[\e[1m\e[32m\]pts/\l'
PS1=$PS1$'\[\e[m\]:'
PS1=$PS1$'\[\e[1m\e[34m\]\w'
PS1=$PS1$'\[\e[m\]$ '
alias grep='grep --color=auto'
