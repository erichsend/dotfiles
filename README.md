## My Dotfiles

Configurations for:

* `tmux`
* `vim`
* `zsh`

Goals
* support workflows using golang, typescript, and various frameworks
* support monitoring and infrastructure workflows
* cli over websites where possible
* vim bindings for everything

### Setup

#### Install Dependencies

Must have the following in path:
* `fzf`
* `jira-cli`
* `kube-ps1`
* `kubectx`
* `kubectl`
* 'rg'
* `tmux`

Also download/setup `oh-my-zsh`

#### Setup Symlinks

Delete the following files/folders to be replaced with symlinks
* `rm -rf ~/.oh-my-zsh/custom`
* `rm ~/.tmux.conf`
* `rm ~/.zshrc`

Add Symlinks (assuming this repo is at ~/repo/dotfiles)
* `ln -s ~/repo/dotfiles/tmux/.tmux.conf ~/.tmux.conf`
* `ln -s ~/repo/dotfiles/zsh/.zshrc ~/.zshrc`
* `ln -s ~/repo/dotfiles/zsh/.oh-my-zsh/custom ~/.oh-my-zsh/custom`

Add secrets.zsh for any secret setup

### Configuration Notes

#### zsh

* oh-my-zsh
* powerlevel10k (git submodule)
* not currently using a package manager

**Customizations**
- .zshrc is vanilla oh-my-zsh with powerlevel10k additions for instant prompt and configuration check (beginning and end of file)
- .intputrc sets up vim bindings
- Find other shell customizations in `dotfiles/.oh-my-zsh/custom/*.zsh`

#### tmux

* sensible tmux
* tpm (owns `dotfiles/tmux/.tmux/` and initilized in `.tmux.conf`)
* tmux yank, ressurect, open, copycat plugins

**Customizations**
- prefix set to C-a
- vim bindings

#### Vim

* sensible vim
* fzf
* vim-fugative


**Customizations**
- grep uses `rg`
- easier navigation keybindings


#### fzf

- uses ripgrep (`rg`) for base command




