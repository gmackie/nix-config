# Multi-System Nix Configuration

A modular, flake-based Nix configuration for managing multiple systems including NixOS, macOS (via nix-darwin), and WSL. Includes comprehensive dotfiles management with git submodules for complex configurations.

## Structure

```
.
├── flake.nix              # Main flake configuration
├── flake.lock             # Pinned dependencies
├── hosts/                 # Host-specific configurations
│   ├── brnr/              # ThinkPad T440 (NixOS)
│   ├── homelab/           # Homelab NUC (NixOS)
│   ├── vanuc/             # Van NUC server (NixOS)
│   ├── nixos-laptop/      # Generic NixOS laptop template
│   ├── wsl/               # WSL NixOS configuration
│   └── labtop/            # Mac M2 (Darwin)
├── modules/               # Reusable modules
│   ├── nixos/             # NixOS-specific modules
│   │   └── languages/     # Language development environments
│   ├── darwin/            # macOS-specific modules
│   ├── home-manager/      # Home-manager modules
│   └── shared/            # Shared modules (cross-platform)
├── home/                  # User home configurations
│   └── mackieg/           # User-specific configs
│       ├── common.nix     # Shared home config (includes dotfiles)
│       ├── nixos.nix      # Linux-specific home config
│       └── darwin.nix     # macOS-specific home config
├── dotfiles/              # Dotfiles management
│   ├── config/nvim/       # Neovim config (git submodule - TODO)
│   ├── tmux/              # Oh My Tmux (git submodule)
│   ├── p10k.zsh           # Powerlevel10k configuration
│   ├── zsh.nix            # Zsh configuration
│   ├── tmux.nix           # Tmux settings
│   └── git.nix            # Git configuration
├── secrets/               # SOPS encrypted secrets
├── overlays/              # Custom package overlays
├── scripts/               # Helper scripts
├── templates/             # System templates (nuc, rpi, nas)
└── lib/                   # Helper functions (mkSystem)
```

## Configured Systems

| Host | Platform | Description |
|------|----------|-------------|
| `brnr` | NixOS | ThinkPad T440 laptop |
| `labtop` | Darwin | Mac M2 |
| `homelab` | NixOS | Homelab NUC server |
| `vanuc` | NixOS | Van NUC with Starlink |
| `nixos-laptop` | NixOS | Generic laptop template |
| `wsl` | NixOS-WSL | Windows Subsystem for Linux |

## Usage

### Initial Setup

1. **Clone with submodules:**
   ```bash
   git clone --recursive <repo-url>
   # Or if already cloned:
   ./scripts/dotfiles.sh init
   ```

2. **For NixOS systems:**
   ```bash
   # Generate hardware configuration first
   sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix

   # Build and switch
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

3. **For WSL:**
   ```bash
   sudo nixos-rebuild switch --flake .#wsl
   ```

4. **For macOS:**
   ```bash
   # Install nix-darwin first if not already installed
   nix run nix-darwin -- switch --flake .#labtop

   # Subsequent rebuilds
   darwin-rebuild switch --flake .#labtop
   ```

### Using the Rebuild Script

The included rebuild script auto-detects your system type:

```bash
./scripts/rebuild.sh          # Rebuild current system
./scripts/rebuild.sh build    # Build without switching
./scripts/rebuild.sh update   # Update flake inputs
./scripts/rebuild.sh check    # Check flake configuration
./scripts/rebuild.sh clean    # Garbage collection
```

### Common Commands

```bash
# Update flake inputs
nix flake update

# Check flake
nix flake check

# Show flake outputs
nix flake show

# Enter development shell (includes nixfmt, statix, deadnix)
nix develop

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
3. Generate hardware config on the device
4. Add the system to `flake.nix`:
   ```nix
   nixosConfigurations.rpi = mkSystem "rpi" {
     system = "aarch64-linux";
     user = "mackieg";
   };
   ```

## Secrets Management

Secrets are managed with SOPS and age encryption. See `secrets/README.md` for setup instructions.

```bash
# Setup age key
./scripts/setup-age.sh

# Edit secrets
sops secrets/secrets.yaml
```

## Features

- **Modular Design**: Shared modules for common configurations
- **Multi-Platform**: Support for NixOS, macOS, and WSL
- **Home Manager**: Declarative user environment management
- **Flakes**: Reproducible builds with pinned dependencies
- **SOPS Secrets**: Encrypted secrets management with age
- **Dotfiles Integration**: Git submodules for complex configs, Nix for simple ones
- **CI/CD**: GitHub Actions for validation and builds
- **Language Support**: Dedicated modules for Python, Node.js, Go, Rust

## Customization

- **User Settings**: Edit files in `home/<username>/`
- **System Packages**: Modify `modules/nixos/common.nix` or `modules/darwin/common.nix`
- **Desktop Environment**: Configure in `modules/nixos/desktop.nix`
- **Development Tools**: Add to `modules/shared/common-packages.nix`
- **macOS Settings**: Edit `modules/darwin/common.nix`
- **Homebrew Packages**: Edit `modules/darwin/homebrew.nix`

## Tips

- Keep machine-specific settings in `hosts/<hostname>/`
- Share common configurations through modules
- Use home-manager for user-specific configurations
- Pin flake inputs for reproducibility
- Test changes with `nixos-rebuild build` before switching
- Run `nix flake check` before committing
