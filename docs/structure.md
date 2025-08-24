# Nix Configuration Structure

## Directory Layout

```
nix-config/
├── flake.nix                 # Main flake entry point
├── flake.lock                # Locked input versions
├── README.md                 # Main documentation
├── .gitignore               # Git ignore patterns
├── .sops.yaml               # SOPS encryption configuration
│
├── docs/                    # Documentation
│   └── structure.md         # This file
│
├── hosts/                   # Host-specific configurations
│   ├── nixos-laptop/        # NixOS laptop
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── wsl/                 # Windows Subsystem for Linux
│   │   └── configuration.nix
│   └── mac-m2/              # macOS with Apple Silicon
│       └── configuration.nix
│
├── modules/                 # Reusable configuration modules
│   ├── nixos/               # NixOS-specific modules
│   │   ├── default.nix      # Module index
│   │   ├── common.nix       # Base system configuration
│   │   ├── desktop.nix      # Desktop environment
│   │   ├── laptop.nix       # Laptop-specific settings
│   │   ├── docker.nix       # Docker configuration
│   │   ├── development.nix  # Development tools
│   │   ├── secrets.nix      # Secret management
│   │   └── languages/       # Language-specific tools
│   │       ├── python.nix
│   │       ├── nodejs.nix
│   │       ├── go.nix
│   │       └── rust.nix
│   ├── shared/              # Cross-platform modules
│   │   └── common-packages.nix
│   └── home-manager/        # Home Manager modules
│       └── default.nix
│
├── home/                    # User configurations
│   └── mackieg/             # User-specific configs
│       ├── common.nix       # Shared user config
│       ├── nixos.nix        # Linux-specific user config
│       └── darwin.nix       # macOS-specific user config
│
├── lib/                     # Helper functions
│   └── mksystem.nix         # System builder function
│
├── overlays/                # Custom package overlays
│   └── default.nix          # Package overrides
│
├── pkgs/                    # Custom packages
│   └── (empty - add custom packages here)
│
├── secrets/                 # Encrypted secrets (SOPS)
│   └── (empty - add secrets here)
│
├── scripts/                 # Utility scripts
│   ├── install.sh           # Installation script
│   ├── rebuild.sh           # Rebuild helper
│   └── setup-age.sh         # Age key setup
│
└── templates/               # Templates for new systems
    ├── rpi/                 # Raspberry Pi
    ├── nuc/                 # Intel NUC
    └── nas/                 # Network Attached Storage
```

## Module Organization

### NixOS Modules (`modules/nixos/`)

- **common.nix**: Base system configuration shared across all NixOS systems
- **desktop.nix**: Desktop environment, fonts, and GUI applications
- **laptop.nix**: Laptop-specific settings (power management, TLP, etc.)
- **docker.nix**: Docker and container runtime configuration
- **development.nix**: Development tools and debugging utilities
- **secrets.nix**: Secret management with age/SOPS

### Language Modules (`modules/nixos/languages/`)

Each language module provides:
- Language runtime(s)
- Package managers
- Development tools
- Language servers
- Common libraries
- Environment variables

### Home Manager Configuration (`home/`)

User-specific configurations managed by Home Manager:
- Shell configuration (zsh, starship)
- Development tools (git, tmux, neovim)
- Command-line utilities
- GUI applications (VS Code)

## System Definitions

Systems are defined in `flake.nix` using the `mkSystem` helper function:

```nix
nixos-laptop = mkSystem "nixos-laptop" {
  system = "x86_64-linux";
  user = "mackieg";
};
```

The `mkSystem` function automatically:
- Loads the host configuration from `hosts/<name>/configuration.nix`
- Sets up Home Manager integration
- Configures the hostname
- Includes WSL modules if specified

## Adding New Systems

1. Create directory: `mkdir hosts/new-system`
2. Add configuration: `hosts/new-system/configuration.nix`
3. Add to `flake.nix`:
   ```nix
   new-system = mkSystem "new-system" {
     system = "x86_64-linux";  # or appropriate architecture
     user = "mackieg";
   };
   ```

## Secrets Management

Uses SOPS (Secrets OPerationS) with age encryption:

1. Generate age key: `./scripts/setup-age.sh`
2. Update `.sops.yaml` with your public key
3. Create encrypted files: `sops secrets/example.yaml`
4. Import in configurations with sops-nix

## Build Commands

- `./scripts/rebuild.sh` - Rebuild current system
- `./scripts/rebuild.sh update` - Update flake inputs
- `./scripts/rebuild.sh clean` - Garbage collect
- `nix flake show` - Show available configurations
- `nix flake check` - Validate flake

## Customization Guidelines

- Keep machine-specific settings in `hosts/<hostname>/`
- Use modules for shared functionality
- Put user configs in `home/<username>/`
- Add custom packages to `pkgs/`
- Use overlays for package modifications
- Keep secrets encrypted with SOPS