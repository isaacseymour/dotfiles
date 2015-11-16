DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: symlinks brew ruby nvm npm tpm
	@echo "Reminder: Vim plugins are managed within Vim with Vundle."

symlinks:
	@ln -nsf $(DIR)/zsh/zsh ~/.zsh
	@ln -sf $(DIR)/zsh/zshenv ~/.zshenv
	@ln -sf $(DIR)/zsh/zshrc ~/.zshrc
	@ln -nsf $(DIR)/vim/vim ~/.vim
	@ln -sf $(DIR)/vim/vimrc ~/.vimrc
	@ln -nsf $(DIR)/vim/plugin ~/.vim/plugin
	@ln -sf $(DIR)/tmux/tmux.conf ~/.tmux.conf
	@ln -sf $(DIR)/git/gitconfig ~/.gitconfig
	@ln -sf $(DIR)/git/gitignore_global ~/.gitignore_global
	@ln -sf $(DIR)/ctags/ctags ~/.ctags
	@ln -sf $(DIR)/gem/gemrc ~/.gemrc
	@ln -nsf $(DIR)/bundle ~/.bundle
	@ln -sf $(DIR)/pry/pryrc ~/.pryrc
	@ln -sf $(DIR)/psql/psqlrc ~/.psqlrc
	@mkdir -p ~/.rbenv
	@ln -sf $(DIR)/rbenv/default-gems ~/.rbenv/default-gems
	@ln -sf $(DIR)/editorconfig ~/.editorconfig

brew:
	command -v brew > /dev/null 2>&1 || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	@brew tap Homebrew/bundle || echo ''
	brew bundle

LATEST_RUBY="2.2.3"
ruby: brew symlinks
	[ -d ~/.rbenv/versions/$(LATEST_RUBY) ] || rbenv install $(LATEST_RUBY)
	rbenv global $(LATEST_RUBY)

LATEST_NODE="5"
nvm:
	[ -d ~/.nvm ] || git clone git@github.com:creationix/nvm ~/.nvm
	cd ~/.nvm && git pull
	NVM_DIR=~/.nvm source ~/.nvm/nvm.sh && nvm install $(LATEST_NODE) && nvm alias default $(LATEST_NODE)

npm: nvm
	NVM_DIR=~/.nvm source ~/.nvm/nvm.sh && npm install npm --global --silent
	NVM_DIR=~/.nvm source ~/.nvm/nvm.sh && npm install serve --global --silent

tpm:
	[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	cd ~/.tmux/plugins/tpm && git pull

screensaver:
	[ -f ~/Library/Screen\ Savers/RealSimpleAnniversaryClock.qtz ] || curl http://wayback.archive.org/web/http://simplystated.realsimple.com/files/RealSimpleAnniversaryClock.qtz --output ~/Library/Screen\ Savers/RealSimpleAnniversaryClock.qtz
