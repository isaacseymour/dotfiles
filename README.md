#Isaac's Dotfiles

My dotfiles for Vim, git, and ZSH. Shamelessly stolen from @jackfranklin, who stole them from other people. 
The theme is a modified version of @agnoster's, but with a magic asynchronous right-prompt, taken from
http://www.anishathalye.com/2015/02/07/an-asynchronous-shell-prompt/

`make symlink` to symlink the right stuff into `$HOME`

# Installing

```bash
chsh -s /bin/zsh # Use zsh
cd ~
git clone git@github.com:isaacseymour/dotfiles
cd dotfiles
make
```

Then `:PlugInstall` in vim to get that stuff installed.

Install Node from [NodeJS.org](http://nodejs.org/) before `make` if you care about node.

# node & npm
- Node is installed via the installer on nodejs.org.
- packages are managed in `scripts/npm_bundles.rb`. Add a new package, and run `make node`.

# gems
- Add gem to `scripts/gems.rb`
- `make gems`

# Updating
You can run `make` at any time to keep things nice and tidy.

# Requirements

You'll need Ruby and Git installed initially, to first clone this repo and then to run `./scripts/make.sh` (which in turn calls various Ruby & Sh files. Once that's done, you'll have Ruby properly setup through `rbenv` and the latest Git installed also through homebrew, but you'll need some version of Ruby & Git to get started.

I'm using these dotfiles on OS X Yosemite and Ubuntu 14.04. There's a lot of brew-specific stuff but they work reasonably well on Ubuntu - just need to run `make clone_vundle` and `make symlink` instead of just `make`, and `sudo apt-get install zsh` before installing.
