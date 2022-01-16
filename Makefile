DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: base16 symlinks brew-bundle vim ruby npm tpm powerline-fonts gpg

symlinks:
	@mkdir -p ~/.config
	@ln -nsf $(DIR)/zsh ~/.zsh
	@ln -sf $(DIR)/zsh/zshrc ~/.zshrc
	@ln -sf $(DIR)/zsh/profile ~/.zprofile
	@ln -sf $(DIR)/vim/vimrc ~/.vimrc
	@ln -shf $(DIR)/vim ~/.config/nvim
	@ln -sf $(DIR)/vim ~/.vim
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
	command -v brew || /bin/bash -c '/usr/bin/ruby -e "`curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install`"'

brew-bundle: symlinks brew
	# Chrome updates too frequently to have SHAsums
	HOMEBREW_CASK_OPTS="" brew install google-chrome
	@brew tap Homebrew/bundle || echo ''
	brew bundle
	brew unlink ruby # vim 8 depends on ruby, but we want to manage Ruby with rbenv

LATEST_RUBY="3.1.0"
ruby: brew-bundle symlinks
	[ -d ~/.rbenv/versions/$(LATEST_RUBY) ] || rbenv install $(LATEST_RUBY)
	rbenv global $(LATEST_RUBY)


npm: brew-bundle
	fnm install
	zsh -c 'eval "$(fnm env)" && \
		npm install npm --global --silent && \
		npm install serve --global --silent'

tpm:
	[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	cd ~/.tmux/plugins/tpm && git pull

base16: brew-bundle
	[ -d ~/.config/base16-shell ] || git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
	(cd ~/.config/base16-shell && git pull)
	[ -d ~/.config/base16-kitty ] || git clone https://github.com/kdrag0n/base16-kitty.git ~/.config/base16-kitty
	(cd ~/.config/base16-kitty && git pull)

powerline-fonts:
	[ -d ~/.config/powerline ] || git clone https://github.com/powerline/fonts.git ~/.config/powerline
	(cd ~/.config/powerline && git pull && ./install.sh)

gpg: brew-bundle symlinks
	gpg --import $(DIR)/gpg/pubkey.gpg
	gpgconf --launch gpg-agent
	gpg-agent
	ssh-add -L | grep cardno > ~/.ssh/id_rsa_yubikey.pub
	chmod 0700 ~/.ssh/id_rsa_yubikey.pub
	@echo "NOTE: SSH public key is available in ~/.ssh/id_rsa_yubikey.pub!"

vim: symlinks brew-bundle npm
	nvim +PlugInstall +CocInstall +qall
