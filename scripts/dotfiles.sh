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
    print_step "Syncing changes from submodules..."
    
    cd "$REPO_ROOT"
    
    # Check if nvim submodule has changes
    if [[ -d "$DOTFILES_DIR/config/nvim" ]]; then
        cd "$DOTFILES_DIR/config/nvim"
        if [[ -n "$(git status --porcelain)" ]]; then
            print_warn "Neovim config has uncommitted changes"
            git status --short
        else
            print_info "Neovim config is clean"
        fi
        cd "$REPO_ROOT"
    fi
    
    # Check if oh-my-zsh submodule has changes  
    if [[ -d "$DOTFILES_DIR/oh-my-zsh" ]]; then
        cd "$DOTFILES_DIR/oh-my-zsh"
        if [[ -n "$(git status --porcelain)" ]]; then
            print_warn "Oh My Zsh has uncommitted changes"
            git status --short
        else
            print_info "Oh My Zsh is clean"
        fi
        cd "$REPO_ROOT"
    fi
}

# Push changes to submodule remotes
push_submodules() {
    print_step "Pushing submodule changes..."
    
    cd "$REPO_ROOT"
    
    # Push nvim config changes
    if [[ -d "$DOTFILES_DIR/config/nvim" ]]; then
        cd "$DOTFILES_DIR/config/nvim"
        if [[ -n "$(git status --porcelain)" ]]; then
            print_info "Committing nvim config changes..."
            git add -A
            git commit -m "Update nvim config from nix-config"
            git push
        fi
        cd "$REPO_ROOT"
    fi
    
    # Push oh-my-zsh changes
    if [[ -d "$DOTFILES_DIR/oh-my-zsh" ]]; then
        cd "$DOTFILES_DIR/oh-my-zsh"
        if [[ -n "$(git status --porcelain)" ]]; then
            print_info "Committing oh-my-zsh changes..."
            git add -A
            git commit -m "Update oh-my-zsh from nix-config"
            git push
        fi
        cd "$REPO_ROOT"
    fi
    
    # Update main repo with new submodule commits
    git add .
    if [[ -n "$(git status --porcelain)" ]]; then
        git commit -m "Update submodule references"
        print_info "Updated submodule references in main repo"
    fi
}

# Link dotfiles (for testing without home-manager)
link_dotfiles() {
    print_step "Creating symlinks for dotfiles..."
    
    # Create backup directory
    BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Link p10k config
    if [[ -f "$HOME/.p10k.zsh" ]]; then
        print_warn "Backing up existing .p10k.zsh"
        mv "$HOME/.p10k.zsh" "$BACKUP_DIR/"
    fi
    ln -sf "$DOTFILES_DIR/p10k.zsh" "$HOME/.p10k.zsh"
    print_info "Linked .p10k.zsh"
    
    # Link nvim config (if not managed by home-manager)
    if [[ ! -L "$HOME/.config/nvim" ]] && [[ -d "$HOME/.config/nvim" ]]; then
        print_warn "Backing up existing nvim config"
        mv "$HOME/.config/nvim" "$BACKUP_DIR/"
    fi
    if [[ ! -L "$HOME/.config/nvim" ]]; then
        mkdir -p "$HOME/.config"
        ln -sf "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
        print_info "Linked nvim config"
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
    
    if [[ -L "$HOME/.config/nvim" ]]; then
        rm "$HOME/.config/nvim"
        print_info "Removed nvim config symlink"
    fi
}

# Show help
show_help() {
    echo "Dotfiles management script for nix-config"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  update       Update all submodules to latest"
    echo "  status       Show status of all submodules"
    echo "  sync         Sync changes from submodules"
    echo "  push         Push submodule changes to remotes"
    echo "  link         Create symlinks (for testing)"
    echo "  unlink       Remove symlinks"
    echo "  help         Show this help message"
    echo ""
    echo "Submodules:"
    echo "  • dotfiles/config/nvim    - Neovim configuration"
    echo "  • dotfiles/oh-my-zsh      - Oh My Zsh with custom plugins"
    echo ""
    echo "Note: Home Manager automatically manages dotfile linking."
    echo "Use 'link/unlink' only for testing outside of Home Manager."
}

# Main function
main() {
    case "${1:-help}" in
        update)
            update_submodules
            ;;
        status)
            status_submodules
            ;;
        sync)
            sync_from_submodules
            ;;
        push)
            push_submodules
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