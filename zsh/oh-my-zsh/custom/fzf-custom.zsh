# Fuzzy Setup
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

####### Fuzzy Integrations

#### Find File with Preview
alias ff="fzf --height 60% --layout reverse --info inline --border     --preview 'printf \"\$(file {}) \n\n \$(cat {})\"' --preview-window up,15,border-horizontal     --color 'fg:#bbccdd,fg+:#ddeeff,bg:#334455,preview-bg:#223344,border:#778899'"

## Consumers of 'ff'
alias vf='vi -o `ff`'

#### Git Operations

## Define git branch preview presentation for fzf
alias _git_fzf_preview="fzf --height 60% --layout reverse --info inline --border     --preview 'printf \"Files Modified vs Current Branch\n---------------\n\$(git diff {} --name-only)\n\n================\n\$(git log {} -n 3)\n\"' --preview-window up,20,border-horizontal     --color 'fg:#bbccdd,fg+:#ddeeff,bg:#334455,preview-bg:#223344,border:#778899'"

## Send all branches in the current repo to the git-specific fzf
alias _git_branch_fzf="git for-each-ref --format='%(refname:short)' refs/heads | _git_fzf_preview"

## consumers of _git_branch_fzf: checkout and delete
alias gdel="_git_branch_fzf | xargs git branch -D"
alias gc="_git_branch_fzf | xargs git checkout"
