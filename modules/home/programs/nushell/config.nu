$env.config.show_banner = false
$env.config.history.file_format = "sqlite"
$env.config.rm.always_trash = true
$env.config.completions.algorithm = "fuzzy"
$env.config.use_kitty_protocol = true
$env.config.table.index_mode = "auto"
$env.config.table.mode = "rounded"
$env.LS_COLORS = (vivid generate catppuccin-mocha)

alias _ls = ls
# def --wrapped ls [...args] { _ls --long ...$args | select name mode user group size modified }
alias ll = _ls --long
alias la = ls -a
alias lt = eza -lH --time-style=long-iso -T
alias nv = nvim
alias cat = bat
alias df = dysk --csv | from csv
alias sr = steam-run
alias x = dtrx
alias dl = curl -O

def ns [] {
	if ("NIX_CONFIG_TYPE" in $env) {
		match $env.NIX_CONFIG_TYPE {
			"nixos" => { nh os switch }
			"darwin" => { nh darwin switch }
			"standalone" => { nh home switch }
		}
	} else {
		echo "No nix config activated"
	}
}

alias _rg = rg
def --wrapped rg [...args] {
	match $env.TERM {
		"xterm-kitty" => { kitten hyperlinked-grep ...$args }
		_ => { _rg ...$args }
	}
}

# Run nix stuff
def --wrapped dev [shell, ...args] { nix develop --impure "$HOME/nix#$shell" ...$args --command "$SHELL" }
def --wrapped run [shell, ...args] { nix run nixpkgs#$shell -- ...$args }
def --wrapped runi [shell, ...args] { nix run --impure nixpkgs#$shell -- ...$args }
def --wrapped shell [shell, ...args] { nix shell (string replace -r '(.*)' 'nixpkgs#$shell' ...$args) }

# Git commands
def gc [...msg] { git commit -m "...$msg" }
alias ga = git add -v
alias gu = git add -vu
alias gp = git push
alias st = git status -bs
alias di = git diff
alias lg = git lg
