DIR=$(HOME)/dotfiles

all: base16_shell symlinks brew ruby nvm npm tpm
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
	@ln -sf $(DIR)/task/taskrc ~/.taskrc
	@ln -nsf $(DIR)/bundle ~/.bundle
	@ln -sf $(DIR)/pry/pryrc ~/.pryrc
	@ln -sf $(DIR)/psql/psqlrc ~/.psqlrc
	@mkdir -p ~/.rbenv
	@ln -sf $(DIR)/rbenv/default-gems ~/.rbenv/default-gems

brew:
	command -v brew >/dev/null 2>&1 && brew tap Homebrew/bundle && brew bundle

base16_shell:
	-mkdir ~/.config
	[ -d ~/.config/base16-shell ] || git clone git@github.com:isaacseymour/base16-shell.git ~/.config/base16-shell
	cd ~/.config/base16-shell && git pull

LATEST_RUBY="2.2.3"
ruby: brew symlinks
	[ -d ~/.rbenv/versions/$(LATEST_RUBY) ] || rbenv install $(LATEST_RUBY)
	[ -d ~/.rbenv/versions/2.0.0-p353 ] || rbenv install 2.0.0-p353
	rbenv global $(LATEST_RUBY)

nvm:
	[ -d ~/.nvm ] || git clone git@github.com:creationix/nvm ~/.nvm
	cd ~/.nvm && git pull
	NVM_DIR=~/.nvm source ~/.nvm/nvm.sh && nvm install 4 && nvm alias default 4

npm: nvm
	NVM_DIR=~/.nvm source ~/.nvm/nvm.sh && npm install npm --global --silent
	NVM_DIR=~/.nvm source ~/.nvm/nvm.sh && npm install serve --global --silent

tpm:
	[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	cd ~/.tmux/plugins/tpm && git pull
