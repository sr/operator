# devenv

## Installation

First, make sure you have [Homebrew](http://brew.sh/) installed and setup. Then:

```
brew tap Pardot/pd-homebrew git@git.dev.pardot.com:Pardot/pd-homebrew.git

# Install prerequisite: Docker for Mac.
# NOTE: `brew cask` instead of just `brew`:
brew cask install docker

# Install devenv and start its service at boot:
brew install devenv --HEAD
brew services start pardot/pd-homebrew/devenv
```

## Usage

**tl;dr**: prefix any `docker` or `docker-compose` commands with `devenv`:

```
devenv docker ps

devenv compose build
```
