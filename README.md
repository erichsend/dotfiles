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

Basic Utilities:
* `fzf`
* `rg`
* `fd`
* `jq`

Specific CLI-type tools
* `kubectl`
* `kubectx/kubens`
* `jira-cli`
* `k9s`
* `volta`

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
* `ln -s ~/repo/dotfiles/tmuxp ~/.config/tmuxp`

**VIM** (doesn't support XDG_CONFIG_HOME)
* `ln -s ~/repo/dotfiles/vim/vimrc ~/.vimrc`
* `ln -s ~/repo/dotfiles/vim ~/.vim`

**K9s**
* 'ln -s ~/repo/dotfiles/.k9s/themes/solarized-dark.yml ~/.k9s/themes/skin.yml'

### Configuration Notes

Add secrets.zsh for any secret setup

#### zsh

* oh-my-zsh
* powerlevel10k (git submodule) -- Using built-in vi_mode!
* not currently using a package manager
* XDG_CONFIG_HOME set to `~/.config`

**Customizations**
- .zshrc is fairly vanilla oh-my-zsh with powerlevel10k additions for instant prompt and configuration check (beginning and end of file)
- Find other shell customizations in `dotfiles/oh-my-zsh/custom/*.zsh`

#### tmux

* sensible tmux
* tpm (git submodule at `dotfiles/tmux/.tmux/plugins/tpm` and initilized in `.tmux.conf`)
* tmux copycat plugin (should replace with bindings for native regex search)
* tmux open
* tmux-vim-navigator

**Customizations**
- prefix set to C-a
- vim bindings

#### Vim

* sensible vim
* fzf
* solarized theme
* open-browser.vim
* tmux-vim-navigator

**Customizations**
- easier navigation keybindings

#### fzf

- uses ripgrep (`rg`) for base command

### TODO

- replace tmux copycat with saved searches

- vim replace grep?
```
set grepprg=rg\ --vimgrep\ --smart-case
set grepformat=%f:%l:%c:%m,%f:%l:%m
```

- vim keybindings:
  - fzf: gfiles/files/buffers
  - split management
  - tab management

- vim surround

- CoC
- yaml editing/linting
- typescript editing/linting
- node debugging
- go editing
- go debugging

- tmuxp workspaces

### Mac-only restore note

```
❯ brew leaves
ankitpokhrel/jira-cli/jira-cli
awscli
fd
fzf
gnupg
go
httpie
jenv
jq
k9s
kubectx
md5sha1sum
plantuml
pre-commit
ripgrep
saml2aws
tmuxp
volta
```

