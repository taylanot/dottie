
#!/usr/bin/env bash

set -e

echo "Starting installation..."

# Detect OS
OS="$(uname -s)"
echo "Detected OS: $OS"

install_linux() {
  # Check if sudo exists
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    SUDO=""
  fi

  echo "Updating package lists..."
  $SUDO apt update -y

  echo "Installing packages..."
  $SUDO apt install -y neovim btop podman ranger zsh curl kitty tmux xclip fonts-font-awesome git golang-go make wget unzip

  echo "Installing go and zk..."
  git clone https://github.com/zk-org/zk.git $HOME/zk-git; cd $HOME/zk-git; make build; mv zk /usr/local/bin; cd -; rm -rf zk-git;

  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  echo "Installing vim-plug..."
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

  echo "Setting up oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  echo "Setting up powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k

  echo "Setting up plugins-fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

  echo "Setting up plugins-zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

  echo "Setting up plugins-zsh-substring-search..."
  git clone https://github.com/zsh-users/zsh-history-substring-search $HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search

  echo "Setting up kitty..."
  THEME=https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/gruvbox_dark.conf
  wget "$THEME" -P ~/.config/kitty/kitty-themes/themes
  git clone --depth 1 https://github.com/dexpota/kitty-themes.git $HOME/.config/kitty/kitty-themes
  cp $PWD/kitty.conf ~/.config/kitty/kitty.conf

  echo "Setting up my font Hasklug..."
  mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts && \
  curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hasklig.zip && \
  unzip Hasklug.zip -d HasklugNerdFont && \
  fc-cache -fv && \
  rm -rf Hasklug.zip && cd ~/workspace

  echo "Setting up the the configs for me..."
  ln -sf $PWD/zshrc ~/.zshrc
  ln -sf $PWD/nvim ~/.config/nvim
  ln -sf $PWD/tmux ~/.config/tmux
  ln -sf $PWD/zk ~/.config/zk
  echo "Run zsh to setup powerlevel10k and :PlugInstall in nvim and you are good to go! (mostly)"
}

install_macos() {
  # Check if Homebrew is installed
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH
    eval "$(/opt/homebrew/bin/brew shellenv || /usr/local/bin/brew shellenv)"
  fi

  echo "Installing packages via Homebrew..."
  brew update
  brew install neovim btop podman ranger zsh curl tmux xclip fontawesome zk
  brewn install --cask kitty
  echo "Setting up kitty..."
  THEME=https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/gruvbox_dark.conf
  wget "$THEME" -P ~/.config/kitty/kitty-themes/themes
  git clone --depth 1 https://github.com/dexpota/kitty-themes.git $HOME/.config/kitty/kitty-themes
  cp $PWD/kitty.conf ~/.config/kitty/kitty.conf

  echo "Setting up oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  echo "Setting up powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k

  echo "Setting up plugins-fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

  echo "Setting up plugins-zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

  echo "Setting up plugins-zsh-substring-search..."
  git clone https://github.com/zsh-users/zsh-history-substring-search $HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search

echo "Setting up the the configs for me..."
  ln -sf $PWD/zshrc ~/.zshrc
  ln -sf $PWD/nvim ~/.config/nvim
  ln -sf $PWD/tmux ~/.config/tmux
  ln -sf $PWD/zk ~/.config/zk
  echo "Run zsh to setup powerlevel10k, :PlugInstall in nvim, Prefix+I in tmux and you are good to go! (I hope)"
}

case "$OS" in
  Linux*)  install_linux ;;
  Darwin*) install_macos ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "All requested tools have been installed successfully!"
