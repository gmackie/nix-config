#!/usr/bin/env bash

# Dotfiles management script for nix-config
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
DOTFILES_DIR="$REPO_ROOT/dotfiles"

# Initialize submodules (for fresh clones)
init_submodules() {
    print_step "Initializing git submodules..."

    cd "$REPO_ROOT"

    git submodule update --init --recursive

    print_info "Submodules initialized successfully"
}

# Update all submodules
update_submodules() {
    print_step "Updating git submodules..."

    cd "$REPO_ROOT"

    print_info "Initializing submodules..."
    git submodule update --init --recursive

    print_info "Updating submodules to latest..."
    git submodule update --remote --recursive

    print_info "Submodules updated successfully"
}

# Pull latest changes from submodule remotes
pull_submodules() {
    print_step "Pulling latest submodule changes..."

    cd "$REPO_ROOT"

    # Pull tmux updates
    if [[ -d "$DOTFILES_DIR/tmux" ]]; then
        print_info "Pulling tmux updates..."
        cd "$DOTFILES_DIR/tmux"
        git pull origin master
        cd "$REPO_ROOT"
    fi

    # Update parent repo reference
    git add dotfiles/
    if [[ -n "$(git status --porcelain dotfiles/)" ]]; then
        print_info "Submodule references updated"
    fi
}

# Check submodule status
status_submodules() {
    print_step "Checking submodule status..."

    cd "$REPO_ROOT"
    git submodule status

    echo ""
    print_info "Submodule remotes:"
    git submodule foreach 'echo "=== $name ===" && git remote -v'
}

# Sync changes from submodules
sync_from_submodules() {
    print_step "Checking submodule status..."

    cd "$REPO_ROOT"

    # Check if tmux submodule has changes
    if [[ -d "$DOTFILES_DIR/tmux" ]]; then
        cd "$DOTFILES_DIR/tmux"
        if [[ -n "$(git status --porcelain)" ]]; then
            print_warn "tmux config has uncommitted changes"
            git status --short
        else
            print_info "tmux config is clean"
        fi
        cd "$REPO_ROOT"
    fi
}

# Link dotfiles (for testing without home-manager)
link_dotfiles() {
    print_step "Creating symlinks for dotfiles..."

    # Create backup directory
    BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # Link p10k config
    if [[ -f "$HOME/.p10k.zsh" ]] && [[ ! -L "$HOME/.p10k.zsh" ]]; then
        print_warn "Backing up existing .p10k.zsh"
        mv "$HOME/.p10k.zsh" "$BACKUP_DIR/"
    fi
    ln -sf "$DOTFILES_DIR/p10k.zsh" "$HOME/.p10k.zsh"
    print_info "Linked .p10k.zsh"

    # Link tmux config
    mkdir -p "$HOME/.config/tmux"
    if [[ -f "$HOME/.config/tmux/tmux.conf" ]] && [[ ! -L "$HOME/.config/tmux/tmux.conf" ]]; then
        print_warn "Backing up existing tmux.conf"
        mv "$HOME/.config/tmux/tmux.conf" "$BACKUP_DIR/"
    fi
    ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
    print_info "Linked tmux.conf"

    if [[ -f "$DOTFILES_DIR/tmux.conf.local" ]]; then
        ln -sf "$DOTFILES_DIR/tmux.conf.local" "$HOME/.config/tmux/tmux.conf.local"
        print_info "Linked tmux.conf.local"
    fi

    print_info "Backup created at: $BACKUP_DIR"
}

# Remove symlinks
unlink_dotfiles() {
    print_step "Removing dotfiles symlinks..."

    if [[ -L "$HOME/.p10k.zsh" ]]; then
        rm "$HOME/.p10k.zsh"
        print_info "Removed .p10k.zsh symlink"
    fi

    if [[ -L "$HOME/.config/tmux/tmux.conf" ]]; then
        rm "$HOME/.config/tmux/tmux.conf"
        print_info "Removed tmux.conf symlink"
    fi

    if [[ -L "$HOME/.config/tmux/tmux.conf.local" ]]; then
        rm "$HOME/.config/tmux/tmux.conf.local"
        print_info "Removed tmux.conf.local symlink"
    fi
}

# Show help
show_help() {
    echo "Dotfiles management script for nix-config"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  init         Initialize submodules (after fresh clone)"
    echo "  update       Update all submodules to latest"
    echo "  pull         Pull latest changes from submodule remotes"
    echo "  status       Show status of all submodules"
    echo "  sync         Check for uncommitted changes in submodules"
    echo "  link         Create symlinks (for testing)"
    echo "  unlink       Remove symlinks"
    echo "  help         Show this help message"
    echo ""
    echo "Submodules:"
    echo "  - dotfiles/tmux    - Oh My Tmux configuration (gpakosz/.tmux)"
    echo ""
    echo "Nix-managed dotfiles:"
    echo "  - dotfiles/zsh.nix       - Zsh configuration"
    echo "  - dotfiles/tmux.nix      - Tmux settings"
    echo "  - dotfiles/git.nix       - Git configuration"
    echo "  - dotfiles/p10k.zsh      - Powerlevel10k theme"
    echo "  - dotfiles/tmux.conf.local - Local tmux customizations"
    echo ""
    echo "Note: Home Manager automatically manages dotfile linking."
    echo "Use 'link/unlink' only for testing outside of Home Manager."
}

# Main function
main() {
    case "${1:-help}" in
        init)
            init_submodules
            ;;
        update)
            update_submodules
            ;;
        pull)
            pull_submodules
            ;;
        status)
            status_submodules
            ;;
        sync)
            sync_from_submodules
            ;;
        link)
            link_dotfiles
            ;;
        unlink)
            unlink_dotfiles
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
