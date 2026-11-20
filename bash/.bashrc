export TERM=xterm-256color
export EDITOR=/bin/nvim

# reverse search with up and down arrows
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias cdg='cd $(git rev-parse --show-toplevel)'
mkcd () { mkdir "$@" && cd "$@"; }

# start zoxide (z dir)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# start fzf (ctrl+r, ctrl+t, alt+c)
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"
fi

# source: https://github.com/mathiasbynens/dotfiles/blob/main/.bash_prompt
prompt_git() {
	local s='';
	local branchName='';

	# Check if the current directory is in a Git repository.
	git rev-parse --is-inside-work-tree &>/dev/null || return;

	# Check for what branch we’re on.
	# Get the short symbolic ref. If HEAD isn’t a symbolic ref, get a
	# tracking remote branch or tag. Otherwise, get the
	# short SHA for the latest commit, or give up.
	branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
		git describe --all --exact-match HEAD 2> /dev/null || \
		git rev-parse --short HEAD 2> /dev/null || \
		echo '(unknown)')";

    # Check for uncommitted changes in the index.
    if ! git diff --quiet --ignore-submodules --cached; then
        s+='+';
    fi;
    # Check for unstaged changes.
    if ! git diff-files --quiet --ignore-submodules --; then
        s+='!';
    fi;
    # Check for untracked files.
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        s+='?';
    fi;
    # Check for stashed files.
    if git rev-parse --verify refs/stash &>/dev/null; then
        s+='$';
    fi;

	[ -n "${s}" ] && s=" [${s}]";

	echo -e "${branchName}${s} ";
}

reset="\[\e[0m\]";
blue="\[\e[1;34m\]";
green="\[\e[1;32m\]";
purple="\[\e[1;35m\]";

PS1="${blue}\w " # working directory
PS1+="${green}"'$(prompt_git)' # git
PS1+="${purple}"'\$ ' # $ or #
PS1+="${reset}" # reset colors
