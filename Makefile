DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: base16 symlinks brew-bundle vim ruby npm tpm powerline-fonts pinentry gpg mac-settings

symlinks:
	@mkdir -p ~/.config
	@ln -sf $(DIR)/bin ~/.bin
	@ln -nsf $(DIR)/zsh ~/.zsh
	@ln -sf $(DIR)/zsh/zshrc ~/.zshrc
	@ln -sf $(DIR)/zsh/profile ~/.zprofile
	@ln -sf $(DIR)/vim/vimrc ~/.vimrc
	@ln -shf $(DIR)/vim ~/.config/nvim
	@mkdir -p ~/.vim
	@ln -sf $(DIR)/vim/lua ~/.vim/lua
	@ln -sf $(DIR)/tmux/tmux.conf ~/.tmux.conf
	@ln -sf $(DIR)/git/gitconfig ~/.gitconfig
	@ln -sf $(DIR)/git/gitignore_global ~/.gitignore_global
	@ln -sf $(DIR)/ctags/ctags ~/.ctags
	@ln -sf $(DIR)/gem/gemrc ~/.gemrc
	@ln -nsf $(DIR)/bundle ~/.bundle
	@ln -sf $(DIR)/pry/pryrc ~/.pryrc
	@ln -sf $(DIR)/psql/psqlrc ~/.psqlrc
	@mkdir -p ~/.ssh
	@ln -sf $(DIR)/ssh/config ~/.ssh/config
	@mkdir -p ~/.rbenv
	@ln -sf $(DIR)/rbenv/default-gems ~/.rbenv/default-gems
	@ln -sf $(DIR)/editorconfig ~/.editorconfig
	@mkdir -p ~/.gnupg
	@chmod 700 ~/.gnupg
	@ln -sf $(DIR)/gpg/gpg.conf ~/.gnupg/gpg.conf
	@ln -sf $(DIR)/gpg/gpg-agent.conf ~/.gnupg/gpg-agent.conf
	@rm -rf ~/.config/kitty && ln -shf $(DIR)/kitty ~/.config/kitty

brew:
	which brew || make install-brew

install-brew:
	mkdir -p tmp
	curl -fsSL -o tmp/install-brew.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
	/bin/bash tmp/install-brew.sh
	rm tmp/install-brew.sh

brew-bundle: symlinks brew
	# Chrome updates too frequently to have SHAsums
	HOMEBREW_CASK_OPTS="" brew install google-chrome
	HOMEBREW_CASK_OPTS="" brew install google-cloud-sdk --cask
	@brew tap Homebrew/bundle || echo ''
	brew bundle

LATEST_RUBY="3.2.0"
ruby:
	[ -d ~/.rbenv/versions/$(LATEST_RUBY) ] || rbenv install $(LATEST_RUBY)
	rbenv global $(LATEST_RUBY)


npm:
	zsh -c 'mise x node -- npm install npm --location=global && \
		mise x node -- npm install serve --location=global && \
		mise x node -- npm install --location=global typescript typescript-language-server eslint eslint_d prettier'

tpm:
	[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	cd ~/.tmux/plugins/tpm && git pull

base16:
	[ -d ~/.config/base16-shell ] || git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
	(cd ~/.config/base16-shell && git pull)
	[ -d ~/.config/base16-kitty ] || git clone https://github.com/kdrag0n/base16-kitty.git ~/.config/base16-kitty
	(cd ~/.config/base16-kitty && git pull)

powerline-fonts:
	[ -d ~/.config/powerline ] || git clone https://github.com/powerline/fonts.git ~/.config/powerline
	(cd ~/.config/powerline && git pull && ./install.sh)

pinentry:
	$(shell brew --prefix)/bin/pinentry-touchid -fix

.PHONY: gpg
gpg:
	gpg --import $(DIR)/gpg/pubkey.gpg
	gpgconf --launch gpg-agent
	gpg-agent

vim: symlinks npm
	nvim +PlugInstall +CocInstall +qall

mac-settings:
	@echo 'setting up screensaver'
	@defaults -currentHost write com.apple.screensaver idleTime 300
	@defaults -currentHost write com.apple.screensaver moduleDict -dict \
		moduleName Aerial \
		path '$(HOME)/Library/Screen Savers/Aerial.saver' \
		type 0
	@echo 'enabling three finger drag'
	@defaults -currentHost write -globalDomain com.apple.trackpad.threeFingerDragGesture -int 1
	@echo "reducing motion"
	@defaults write com.apple.Accessibility ReduceMotionEnabled 1
	@echo "configuring mission control"
	@defaults write com.apple.dock showDesktopGestureEnabled -int 0
	@defaults write com.apple.dock showLaunchpadGestureEnabled -int 0
	@defaults write com.apple.dock showMissionControlGestureEnabled -int 0
	@defaults write com.apple.dock mru-spaces -int 0
