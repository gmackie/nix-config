# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Multi-system Nix configuration using flakes to manage NixOS systems, macOS (Darwin), and dotfiles through Home Manager. Uses git submodules for complex configurations like Neovim and Oh My Zsh.

## Essential Commands

### System Rebuild
```bash
# Auto-detects system type (NixOS vs Darwin) and rebuilds
./scripts/rebuild.sh

# Manual rebuild commands
sudo nixos-rebuild switch --flake .#<hostname>  # NixOS
darwin-rebuild switch --flake .#<hostname>       # macOS
```

### Installation & Setup
```bash
# Initial installation with hardware config generation
./scripts/install.sh

# Manage dotfile submodules
./scripts/dotfiles.sh init    # Initialize after fresh clone
./scripts/dotfiles.sh update  # Update all submodules
./scripts/dotfiles.sh pull    # Pull latest submodule changes
```

### Validation & Development
```bash
# Check flake configuration
nix flake check

# Enter development shell with nixfmt and statix
nix develop

# Format Nix files
nixfmt .

# Lint Nix files
statix check
```

## Architecture & Key Components

### System Helper Function
The `lib/mksystem.nix` file contains the core `mkSystem` helper that:
- Automatically configures Home Manager integration
- Sets up hostname and platform-specific modules
- Handles both NixOS and Darwin systems uniformly

### Module Organization
- `modules/nixos/` - NixOS-specific configurations
  - `languages/` - Language-specific development environments (Python, Node.js, Go, Rust, etc.)
  - `services/` - System services (Docker, SSH, etc.)
  - `security/` - Security configurations (sudo, polkit)
- `modules/darwin/` - macOS-specific configurations (casks, homebrew)
- `modules/shared/` - Cross-platform modules used by both NixOS and Darwin
  - `packages.nix` - Common package list
  - `home-manager.nix` - Shared home configurations
- `modules/home-manager/` - User-specific dotfiles and configurations

### Configured Systems
- **brnr**: ThinkPad T440 (NixOS)
- **labtop**: Mac M2 (Darwin)
- **nixos-laptop**: Generic NixOS laptop
- **wsl**: WSL2 system

### Dotfiles Management Strategy
- Simple configs (git, aliases): Managed directly in Nix
- Complex configs: Git submodules in `modules/home-manager/dotfiles/`
  - `.config/nvim/` - Extensive Neovim configuration (800+ lines)
  - `.oh-my-zsh/` - Oh My Zsh with custom themes and plugins

### Secrets Management
Uses SOPS with age encryption. Secrets are stored in `secrets/` and configured in:
- `modules/nixos/sops.nix` - SOPS configuration
- `.sops.yaml` - SOPS rules and key management

## Important Patterns

### Adding New Packages
1. For all systems: Add to `modules/shared/packages.nix`
2. For NixOS only: Add to specific module in `modules/nixos/`
3. For macOS only: Add to `modules/darwin/packages.nix` or `modules/darwin/casks.nix`

### Modifying System Configuration
1. Identify the system in `hosts/<system>/default.nix`
2. System-specific settings go in `hosts/<system>/`
3. Shared settings go in appropriate `modules/` directory

### Working with Dotfiles
1. For Nix-managed configs: Edit in `modules/home-manager/`
2. For submodule configs: 
   - Edit in `modules/home-manager/dotfiles/`
   - Commit changes in the submodule first
   - Then update parent repository reference

## Development Environment

### Neovim Setup
Comprehensive configuration with:
- Mason LSP manager with 20+ language servers
- GitHub Copilot integration
- Treesitter for syntax highlighting
- Harpoon for file navigation
- Telescope for fuzzy finding
- Custom keybindings in `modules/home-manager/dotfiles/.config/nvim/lua/mackieg/remap.lua`

### Language Support
Dedicated modules for each language in `modules/nixos/languages/`:
- Python with poetry and common packages
- Node.js with npm/yarn/pnpm
- Go with development tools
- Rust with cargo and rustup
- C/C++ with gcc and cmake
- Java/Scala with JDK and sbt