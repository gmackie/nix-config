# Multi-System Nix Configuration

A modular, flake-based Nix configuration for managing multiple systems including NixOS, macOS (via nix-darwin), and WSL.

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
│       ├── common.nix     # Shared home config
│       ├── nixos.nix      # Linux-specific home config
│       └── darwin.nix     # macOS-specific home config
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
