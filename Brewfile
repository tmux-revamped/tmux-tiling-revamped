toolset = ENV.fetch("HOMEBREW_REVAMPED_TOOLSET", "all")

brew "bats-core"
brew "tmux"
brew "fzf"

unless toolset == "system"
  brew "bash"
  brew "zsh"
  brew "gnu-sed"
  brew "grep"
  brew "gawk"
end

if %w[all gnu].include?(toolset)
  brew "coreutils"
  brew "findutils"
  brew "diffutils", link: false
end

if %w[all uutils].include?(toolset)
  brew "uutils-coreutils"
  brew "uutils-findutils"
  brew "uutils-diffutils"
end

unless ENV.key?("CI")
  brew "shellcheck"
end
