#!/usr/bin/env bash

# Installation and setup script for the nix-config
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

SYSTEM_TYPE=""
HOSTNAME=""

detect_system() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SYSTEM_TYPE="darwin"
        HOSTNAME="mac-m2"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "nixos" ]]; then
            if [[ -n "$WSL_DISTRO_NAME" ]]; then
                SYSTEM_TYPE="wsl"
                HOSTNAME="wsl"
            else
                SYSTEM_TYPE="nixos"
                HOSTNAME="nixos-laptop"
            fi
        fi
    else
        print_error "Unsupported system type"
        exit 1
    fi
}

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    if ! command -v nix &> /dev/null; then
        print_error "Nix is not installed. Please install Nix first:"
        echo "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
        exit 1
    fi
    
    if ! nix --version | grep -q "flakes"; then
        print_warn "Experimental features may not be enabled"
        echo "Add these to your nix configuration:"
        echo "experimental-features = nix-command flakes"
    fi
    
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        exit 1
    fi
    
    print_info "Prerequisites check passed"
}

setup_hardware_config() {
    if [[ "$SYSTEM_TYPE" == "nixos" ]]; then
        print_step "Setting up hardware configuration..."
        
        if [[ -f "hosts/${HOSTNAME}/hardware-configuration.nix" ]]; then
            print_warn "Hardware configuration already exists"
            echo -n "Do you want to regenerate it? (y/N): "
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                print_info "Keeping existing hardware configuration"
                return
            fi
        fi
        
        print_info "Generating hardware configuration..."
        sudo nixos-generate-config --show-hardware-config > "hosts/${HOSTNAME}/hardware-configuration.nix"
        
        if [[ $? -eq 0 ]]; then
            print_info "Hardware configuration generated successfully"
        else
            print_error "Failed to generate hardware configuration"
            exit 1
        fi
    fi
}

install_configuration() {
    print_step "Installing configuration..."
    
    case "$SYSTEM_TYPE" in
        darwin)
            print_info "Installing nix-darwin configuration..."
            if command -v darwin-rebuild &> /dev/null; then
                darwin-rebuild switch --flake ".#${HOSTNAME}"
            else
                print_info "nix-darwin not found, installing..."
                nix run nix-darwin -- switch --flake ".#${HOSTNAME}"
            fi
            ;;
        nixos|wsl)
            print_info "Installing NixOS configuration..."
            sudo nixos-rebuild switch --flake ".#${HOSTNAME}"
            ;;
        *)
            print_error "Unsupported system type: $SYSTEM_TYPE"
            exit 1
            ;;
    esac
}

setup_git_user() {
    if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
        print_step "Setting up Git user configuration..."
        echo -n "Enter your Git username: "
        read -r git_name
        echo -n "Enter your Git email: "
        read -r git_email
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        
        # Update home-manager configuration
        if [[ -f "home/mackieg/common.nix" ]]; then
            sed -i.bak "s/Mackie G/$git_name/g" home/mackieg/common.nix
            sed -i.bak "s/mackieg@example.com/$git_email/g" home/mackieg/common.nix
            print_info "Updated home-manager Git configuration"
        fi
    fi
}

show_next_steps() {
    print_step "Installation complete! 🎉"
    echo ""
    print_info "Next steps:"
    echo "1. Review and customize configurations in:"
    echo "   - hosts/${HOSTNAME}/configuration.nix (system config)"
    echo "   - home/mackieg/common.nix (user config)"
    echo ""
    echo "2. For secrets management:"
    echo "   - Run: ./scripts/setup-age.sh"
    echo "   - Create encrypted secrets in secrets/"
    echo ""
    echo "3. Useful commands:"
    echo "   - Rebuild: ./scripts/rebuild.sh"
    echo "   - Update: ./scripts/rebuild.sh update"
    echo "   - Clean: ./scripts/rebuild.sh clean"
    echo ""
    print_info "Happy nixing! 🚀"
}

main() {
    print_info "Starting nix-config installation"
    echo ""
    
    detect_system
    print_info "Detected system: $SYSTEM_TYPE (hostname: $HOSTNAME)"
    
    check_prerequisites
    setup_git_user
    setup_hardware_config
    
    print_step "Checking flake..."
    if nix flake check --no-build; then
        print_info "Flake check passed"
    else
        print_error "Flake check failed"
        exit 1
    fi
    
    echo ""
    print_warn "This will replace your current system configuration"
    echo -n "Do you want to continue? (y/N): "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi
    
    install_configuration
    show_next_steps
}

# Parse command line arguments
case "${1:-}" in
    --dry-run)
        print_info "Dry run mode - no changes will be made"
        detect_system
        check_prerequisites
        setup_hardware_config
        nix flake check --no-build
        ;;
    --help|-h)
        echo "Usage: $0 [--dry-run] [--help]"
        echo ""
        echo "Install and configure the nix-config for your system"
        echo ""
        echo "Options:"
        echo "  --dry-run    Check configuration without installing"
        echo "  --help, -h   Show this help message"
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac