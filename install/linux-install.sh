#!/usr/bin/env bash

# https://www.reddit.com/r/bash/comments/1l1r0sj/how_would_i_make_a_script_that_can_install
# install packages
source /etc/os-release
case "$ID" in
  debian|ubuntu)
    sudo apt-get install -y neovim tmux fd-find fzf
    ;;
  fedora)
    sudo dnf install -y neovim tmux fd-find fzf
    ;;
  alpine)
    sudo apk add neovim tmux fd fzf
    ;;
  arch)
    sudo pacman -Sy --noconfirm neovim tmux fd fzf
    ;;
  # etc...
esac

# symlink dotfiles
new_symlink() {
    local path="$1"
    local target="$2"

    if [[ -e "$path" ]] || [[ -L "$path" ]]; then
        echo
        echo "$path already exists:"
        echo "[S] Skip  [F] Delete file  [D] Delete folder contents"
        read -rp "Choice (default: S): " choice

        case "${choice^^}" in
            F) rm -f "$path" ;;
            D)
                # Never wipe the home directory (for ~/.bashrc)
                if [[ "$(dirname "$path")" = "$HOME" ]]; then
                    echo "Refusing to delete $HOME, skipping: $path"
                    return
                fi
                rm -rf "$(dirname "$path")"
                ;;
            *) echo "Skipping: $path"; return ;;
        esac
    fi

    mkdir -p "$(dirname "$path")"
    ln -s "$(realpath "$target")" "$path"
    echo "Linked: $path"
}

# Symlink config files
new_symlink "$HOME/.bashrc" "../bash/.bashrc"
new_symlink "$HOME/.config/nvim/init.lua" "../nvim/init.lua"
new_symlink "$HOME/.config/tmux/tmux.conf" "../tmux/tmux.conf"

echo "All done. You can source ~/.bashrc"
