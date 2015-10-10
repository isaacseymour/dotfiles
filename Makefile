DIR=$(HOME)/dotfiles

all: symlinks brew ruby nvm npm vundle
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
	@ln -sf $(DIR)/base16-shell ~/.config/base16-shell

brew:
	command -v brew >/dev/null 2>&1 && brew tap Homebrew/bundle && brew bundle

vundle: symlinks
	[ -d ~/.vim/bundle/Vundle.vim ] || git clone git@github.com:gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	cd ~/.vim/bundle/Vundle.vim && git pull

ruby: brew symlinks
	[ -d ~/.rbenv/versions/2.2.3 ] || rbenv install 2.2.3
	[ -d ~/.rbenv/versions/2.0.0-p353 ] || rbenv install 2.0.0-p353
	rbenv global 2.2.3

nvm: brew symlinks
	[ -d ~/.nvm ] || mkdir ~/.nvm
	source `brew --prefix nvm`/nvm.sh && nvm install 4

npm: nvm
	npm install npm --global --silent
	npm install serve --global --silent

