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

#### Setup oh-my-zsh

Download/install oh-my-zsh, then

```
rm ~/.zshrc
ln -s ~/repo/dotfiles/zsh/zshrc ~/.zshrc

mv ~/.oh-my-zsh  ~/.config/oh-my-zsh

rm -rf ~/.config/oh-my-zsh/custom
ln -s ~/repo/dotfiles/zsh/oh-my-zsh/custom ~/.config/oh-my-zsh/custom

exec zsh
```

Note: powerlevel10k config file not currently versioned. Will need configuration on first start.

#### Setup Other Symlinks

**TMUX**
* `rm ~/.tmux.conf`
* `ln -s ~/repo/dotfiles/tmux ~/.config/tmux`

**VIM** (doesn't support XDG_CONFIG_HOME)
* `ln -s ~/repo/dotfiles/vim/vimrc ~/.vimrc`
* `ln -s ~/repo/dotfiles/vim ~/.vim`

**K9s**
* 'ln -s ~/repo/dotfiles/.k9s/themes/solarized-dark.yml ~/.k9s/themes/skin.yml'

### Configuration Notes

Add secrets.zsh for any secret setup

#### zsh

* oh-my-zsh
* powerlevel10k (git submodule)
* not currently using a package manager
* XDG_CONFIG_HOME set to `~/.config`

**Customizations**
- .zshrc is vanilla oh-my-zsh with powerlevel10k additions for instant prompt and configuration check (beginning and end of file)
- Find other shell customizations in `dotfiles/oh-my-zsh/custom/*.zsh`

#### tmux

* sensible tmux
* tpm (git submodule at `dotfiles/tmux/.tmux/plugins/tpm` and initilized in `.tmux.conf`)
* tmux yank, ressurect, open, copycat plugins

**Customizations**
- prefix set to C-a
- vim bindings

#### Vim

* sensible vim
* fzf
* vim-fugative
* solarized theme (along with iterm2)

**Customizations**
- grep uses `rg`
- easier navigation keybindings


#### fzf

- uses ripgrep (`rg`) for base command

### TODO

- ohmyzsh vim plugin
- ensure proper filename find and file content pattern find
- vim navigation improvements
- vim window managing improvement
- tmux window managing improvement
- tmux vim navigator
- tmux plugins
- gutentags / universal-tags
- yaml editing/linting
- typescript editing/linting
- node debugging
- go editing
- go debugging


