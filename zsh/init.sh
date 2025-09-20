# just re-use bash aliases
source ~/.config/bash/aliases.sh

# make . behave similar to bash
alias .=source

[ -f ~/.config/bash/local.sh ] && source ~/.config/bash/local.sh

# custom completions
fpath=(~/.config/zsh/completions $fpath)
