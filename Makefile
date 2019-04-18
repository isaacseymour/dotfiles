DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: base16 symlinks brew-bundle ruby nvm npm vim-plug tpm screensaver

symlinks:
	@ln -nsf $(DIR)/zsh/zsh ~/.zsh
	@ln -sf $(DIR)/zsh/zshenv ~/.zshenv
	@ln -sf $(DIR)/zsh/zshrc ~/.zshrc
	@ln -sf $(DIR)/vim/vimrc ~/.vimrc
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

brew:
	command -v brew || /bin/bash -c '/usr/bin/ruby -e "`curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install`"'

brew-bundle: brew
	@brew tap Homebrew/bundle || echo ''
	brew bundle
	brew unlink ruby # vim 8 depends on ruby, but we want to manage Ruby with rbenv

LATEST_RUBY="2.6.2"
ruby: brew-bundle symlinks
	[ -d ~/.rbenv/versions/$(LATEST_RUBY) ] || rbenv install $(LATEST_RUBY)
	rbenv global $(LATEST_RUBY)

LATEST_NODE="10"
NVM_VERSION="v0.33.11"
nvm:
	[ -d ~/.nvm ] || git clone https://github.com/creationix/nvm.git ~/.nvm
	cd ~/.nvm && git fetch && git checkout -f $(NVM_VERSION)
	NVM_DIR=~/.nvm source ~/.nvm/nvm.sh && nvm install $(LATEST_NODE) && nvm alias default $(LATEST_NODE)

npm: nvm
	NVM_DIR=~/.nvm source ~/.nvm/nvm.sh && npm install npm --global --silent
	NVM_DIR=~/.nvm source ~/.nvm/nvm.sh && npm install serve --global --silent

vim-plug:
	[ -f ~/.vim/autoload/plug.vim ] || curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

tpm:
	[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	cd ~/.tmux/plugins/tpm && git pull

screensaver:
	[ -f ~/Library/Screen\ Savers/RealSimpleAnniversaryClock.qtz ] || curl -sL http://wayback.archive.org/web/http://simplystated.realsimple.com/files/RealSimpleAnniversaryClock.qtz --output ~/Library/Screen\ Savers/RealSimpleAnniversaryClock.qtz

base16:
	[ -d ~/.config/base16-shell ] || git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
	(cd ~/.config/base16-shell && git pull)
	[ -d ~/.config/base16-iterm2 ] || git clone https://github.com/martinlindhe/base16-iterm2.git ~/.config/base16-iterm2
	(cd ~/.config/base16-iterm2 && git pull)
	open ~/.config/base16-iterm2/itermcolors/base16-material-darker.itermcolors
