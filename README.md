# Multi-System Nix Configuration

A modular, flake-based Nix configuration for managing multiple systems including NixOS, macOS (via nix-darwin), and WSL. Includes comprehensive dotfiles management with git submodules for complex configurations.

## Structure

```
.
├── flake.nix              # Main flake configuration
├── flake.lock             # Pinned dependencies
├── hosts/                 # Host-specific configurations
│   ├── nixos-laptop/      # NixOS laptop configuration
│   ├── wsl/               # WSL NixOS configuration
│   └── mac-m2/            # macOS M2 configuration
├── modules/               # Reusable modules
│   ├── nixos/             # NixOS-specific modules
│   ├── home-manager/      # Home-manager modules
│   └── shared/            # Shared modules (cross-platform)
├── home/                  # User home configurations
│   └── mackieg/           # User-specific configs
│       ├── common.nix     # Shared home config (includes dotfiles)
│       ├── nixos.nix      # Linux-specific home config
│       └── darwin.nix     # macOS-specific home config
├── dotfiles/              # Dotfiles management
│   ├── config/nvim/       # Neovim config (git submodule)
│   ├── oh-my-zsh/         # Oh My Zsh (git submodule)
│   ├── p10k.zsh           # Powerlevel10k configuration
│   ├── screenrc           # GNU Screen config
│   └── taskrc             # Taskwarrior config
├── overlays/              # Custom package overlays
├── pkgs/                  # Custom packages
└── lib/                   # Helper functions
```

## Usage

### Initial Setup

1. **For NixOS laptop:**
   ```bash
   # Generate hardware configuration first
   sudo nixos-generate-config --show-hardware-config > hosts/nixos-laptop/hardware-configuration.nix
   
   # Build and switch
   sudo nixos-rebuild switch --flake .#nixos-laptop
   ```

2. **For WSL:**
   ```bash
   sudo nixos-rebuild switch --flake .#wsl
   ```

3. **For macOS:**
   ```bash
   # Install nix-darwin first if not already installed
   nix run nix-darwin -- switch --flake .#mac-m2
   
   # Subsequent rebuilds
   darwin-rebuild switch --flake .#mac-m2
   ```

### Common Commands

```bash
# Update flake inputs
nix flake update

# Check flake
nix flake check

# Show flake outputs
nix flake show

# Build without switching
sudo nixos-rebuild build --flake .#<hostname>

# Update home-manager configuration
home-manager switch --flake .#<username>@<hostname>

# Garbage collection
nix-collect-garbage -d

# Optimize store
nix-store --optimize

# Manage dotfiles submodules
./scripts/dotfiles.sh update   # Update submodules
./scripts/dotfiles.sh status   # Check status
```

## Adding New Systems

To add a new system (e.g., Raspberry Pi):

1. Create a new host directory: `mkdir hosts/rpi`
2. Add configuration in `hosts/rpi/configuration.nix`
3. Add the system to `flake.nix`:
   ```nix
   nixosConfigurations.rpi = mkSystem "rpi" {
     system = "aarch64-linux";
     user = "mackieg";
   };
   ```

## Features

- **Modular Design**: Shared modules for common configurations
- **Multi-Platform**: Support for NixOS, macOS, and WSL
- **Home Manager**: Declarative user environment management
- **Flakes**: Reproducible builds with pinned dependencies
- **Dotfiles Integration**: Git submodules for complex configs, Nix for simple ones
- **Organized Structure**: Clear separation of concerns

## Customization

- **User Settings**: Edit files in `home/<username>/`
- **System Packages**: Modify `modules/nixos/common.nix` or host-specific configs
- **Desktop Environment**: Configure in `modules/nixos/desktop.nix`
- **Development Tools**: Add to `modules/shared/common-packages.nix`

## Tips

- Keep machine-specific settings in `hosts/<hostname>/`
- Share common configurations through modules
- Use home-manager for user-specific configurations
- Pin flake inputs for reproducibility
- Test changes with `nixos-rebuild build` before switching
