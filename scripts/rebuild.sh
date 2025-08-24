#!/usr/bin/env bash

# Rebuild script for NixOS/nix-darwin configurations
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect system type
detect_system() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "nixos" ]]; then
            if [[ -n "$WSL_DISTRO_NAME" ]]; then
                echo "wsl"
            else
                echo "nixos"
            fi
        fi
    else
        echo "unknown"
    fi
}

# Main rebuild function
rebuild() {
    local action="${1:-switch}"
    local hostname="${2:-}"
    local system_type=$(detect_system)
    
    print_info "Detected system: $system_type"
    
    # Auto-detect hostname if not provided
    if [[ -z "$hostname" ]]; then
        case "$system_type" in
            darwin)
                hostname="mac-m2"
                ;;
            wsl)
                hostname="wsl"
                ;;
            nixos)
                hostname="nixos-laptop"
                ;;
            *)
                print_error "Unknown system type. Please specify hostname."
                exit 1
                ;;
        esac
    fi
    
    print_info "Building configuration for: $hostname"
    print_info "Action: $action"
    
    # Run the appropriate rebuild command
    case "$system_type" in
        darwin)
            print_info "Running darwin-rebuild..."
            darwin-rebuild "$action" --flake ".#$hostname"
            ;;
        nixos|wsl)
            print_info "Running nixos-rebuild..."
            sudo nixos-rebuild "$action" --flake ".#$hostname"
            ;;
        *)
            print_error "Unsupported system type: $system_type"
            exit 1
            ;;
    esac
    
    print_info "Rebuild completed successfully!"
}

# Parse command line arguments
case "${1:-}" in
    switch|build|boot|test|dry-build|dry-activate)
        rebuild "$1" "$2"
        ;;
    update)
        print_info "Updating flake inputs..."
        nix flake update
        print_info "Update complete. Run '$0 switch' to apply changes."
        ;;
    check)
        print_info "Checking flake..."
        nix flake check
        ;;
    show)
        print_info "Showing flake outputs..."
        nix flake show
        ;;
    clean)
        print_info "Running garbage collection..."
        nix-collect-garbage -d
        print_info "Optimizing store..."
        nix-store --optimize
        ;;
    *)
        echo "NixOS/nix-darwin rebuild helper"
        echo ""
        echo "Usage: $0 [command] [hostname]"
        echo ""
        echo "Commands:"
        echo "  switch       Build and activate configuration (default)"
        echo "  build        Build configuration without activating"
        echo "  boot         Build and set as boot default (NixOS only)"
        echo "  test         Build and activate temporarily"
        echo "  dry-build    Build without creating result"
        echo "  dry-activate Test activation without building"
        echo "  update       Update flake inputs"
        echo "  check        Check flake for errors"
        echo "  show         Show flake outputs"
        echo "  clean        Garbage collect and optimize store"
        echo ""
        echo "Hostname is auto-detected if not provided"
        exit 0
        ;;
esac