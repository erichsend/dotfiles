omz_update() {
  rm -f ~/.oh-my-zsh/custom
  omz update
  rm -rf ~/.oh-my-zsh/custom
  ln -s ~/repo/dotfiles/zsh/oh-my-zsh/custom ~/.config/oh-my-zsh/custom
}
