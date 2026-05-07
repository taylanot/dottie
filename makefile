DOTFILES_DIR := $(shell pwd)
BREW := /home/linuxbrew/.linuxbrew/bin/brew
OS := $(shell uname -s)

.PHONY: install minimal symlinks fonts plugins check help bootstrap brew packages minimal-packages shell

# ── Guards ────────────────────────────────────────────────
define git_clone
	@[ -d $(2) ] || git clone $(1) $(2)
endef

define safe_link
	@[ -L $(2) ] || ln -sf $(1) $(2)
endef

# ── Entry points ──────────────────────────────────────────
install: bootstrap brew packages plugins fonts symlinks shell
	@echo "→ brew PATH written to ~/.profile. Run: source ~/.profile"
	@echo "✓ Full install complete. Run: zsh"

minimal: bootstrap brew minimal-packages symlinks plugins-minimal shell
	@echo "→ brew PATH written to ~/.profile. Run: source ~/.profile"
	@echo "✓ Minimal install complete. Run: zsh"

# ── Pre-brew: native deps (Linux only) ───────────────────
bootstrap:
ifeq ($(OS),Linux)
	@echo "→ Installing curl and git via apt..."
	@command -v sudo >/dev/null 2>&1 && SUDO=sudo || SUDO=""; \
	$$SUDO apt-get install -y curl git build-essential
else
	@command -v sudo >/dev/null 2>&1 && SUDO=sudo || SUDO=""; \
	$$SUDO xcode-select --install
endif

# ── Homebrew ──────────────────────────────────────────────
brew:
	@command -v brew >/dev/null 2>&1 || \
	  /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ifeq ($(OS),Linux)
	@eval "$$($(BREW) shellenv)" && brew --version
	@grep -qxF 'eval "$$($(BREW) shellenv)"' $(HOME)/.profile 2>/dev/null || \
	  echo 'eval "$$($(BREW) shellenv)"' >> $(HOME)/.profile
endif

# ── Packages ──────────────────────────────────────────────
packages: brew
	@eval "$$($(BREW) shellenv 2>/dev/null)"; \
	brew update && \
	brew install neovim btop podman yazi zsh tmux zk wget unzip \
	             font-fontawesome font-hack-nerd-font
	@eval "$$($(BREW) shellenv 2>/dev/null)"; brew install --cask kitty

minimal-packages: brew
	@eval "$$($(BREW) shellenv 2>/dev/null)"; \
	brew install neovim zsh tmux btop wget yazi fzf

# ── Plugins (idempotent) ────────────────────────────
_plugins-common:
	$(call git_clone,https://github.com/ohmyzsh/ohmyzsh.git,$(HOME)/.oh-my-zsh)
	$(call git_clone,https://github.com/romkatv/powerlevel10k.git,$(HOME)/.oh-my-zsh/custom/themes/powerlevel10k)
	$(call git_clone,https://github.com/zsh-users/zsh-syntax-highlighting.git,$(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting)
	$(call git_clone,https://github.com/zsh-users/zsh-history-substring-search.git,$(HOME)/.oh-my-zsh/custom/plugins/zsh-history-substring-search)
	@curl -fLo "$${XDG_DATA_HOME:-$$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@eval "$$($(BREW) shellenv 2>/dev/null)"; nvim --headless +PlugInstall +qall 2>/dev/null || true
	@echo "✓ neovim plugins installed"

plugins-minimal: _plugins-common

plugins: _plugins-common
	$(call git_clone,https://github.com/tmux-plugins/tpm.git,$(HOME)/.tmux/plugins/tpm)
	$(call git_clone,https://github.com/dexpota/kitty-themes.git,$(HOME)/.config/kitty/kitty-themes)

# ── Fonts ─────────────────────────────────────────────────
fonts:
	@eval "$$($(BREW) shellenv 2>/dev/null)"; \
	brew install --cask font-ubuntu-mono-nerd-font
	@fc-cache -fv 2>/dev/null || true

# ── Symlinks (safe, idempotent) ───────────────────────────
symlinks:
	@mkdir -p $(HOME)/.config/kitty
	$(call safe_link,$(DOTFILES_DIR)/zshrc,$(HOME)/.zshrc)
	$(call safe_link,$(DOTFILES_DIR)/nvim,$(HOME)/.config/nvim)
	$(call safe_link,$(DOTFILES_DIR)/tmux,$(HOME)/.config/tmux)
	$(call safe_link,$(DOTFILES_DIR)/zk,$(HOME)/.config/zk)
	$(call safe_link,$(DOTFILES_DIR)/kitty.conf,$(HOME)/.config/kitty/kitty.conf)

# ── Utility ───────────────────────────────────────────────
check:
	@eval "$$($(BREW) shellenv 2>/dev/null)"; \
	echo "=== Checking installs ==="; \
	for cmd in brew nvim zsh tmux fzf zk git; do \
	  command -v $$cmd >/dev/null && echo "✓ $$cmd" || echo "✗ $$cmd MISSING"; \
	done

shell:
	@eval "$$($(BREW) shellenv 2>/dev/null)"; \
	BREW_ZSH="$$(brew --prefix)/bin/zsh"; \
	grep -qxF "$$BREW_ZSH" /etc/shells || echo "$$BREW_ZSH" | sudo tee -a /etc/shells; \
	chsh -s "$$BREW_ZSH"
	@echo "✓ Default shell changed to brew zsh. Re-login to take effect."

help:
	@echo "make install         – full setup (bootstrap + brew + packages + plugins + fonts + symlinks)"
	@echo "make minimal         – neovim, zsh, tmux, git, fzf + symlinks"
	@echo "make symlinks        – (re)link dotfiles only"
	@echo "make fonts           – install UbuntuMono Nerd Font via brew cask"
	@echo "make check           – verify all tools are installed"
