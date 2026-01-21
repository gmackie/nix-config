# Dotfiles Integration

This nix-config repository includes comprehensive dotfiles management, integrating all your personal configurations into a single, declarative setup.

## Structure

```
dotfiles/
├── tmux/               # Oh My Tmux (git submodule - gpakosz/.tmux)
├── p10k.zsh            # Powerlevel10k configuration
├── tmux.conf.local     # Local tmux customizations
├── zsh.nix             # Zsh configuration (Nix module)
├── tmux.nix            # Tmux settings (Nix module)
└── git.nix             # Git configuration (Nix module)
```

## Configuration Management

### Nix-Managed Configs

These are configured directly in `home/mackieg/common.nix`:

- **Git**: Complete git configuration with aliases, colors, and LFS support
- **Zsh**: Shell configuration with Powerlevel10k, aliases, and completion
- **Neovim**: Full IDE setup with LSP, Telescope, Treesitter, and more
- **Tmux**: Terminal multiplexer with Oh My Tmux
- **Direnv**: Automatic environment loading
- **FZF**: Fuzzy finder integration
- **Starship**: Cross-shell prompt (alternative to p10k)

### Submodule-Managed Configs

These are managed as git submodules for complex configurations:

- **dotfiles/tmux**: Oh My Tmux configuration (gpakosz/.tmux)

### File-Based Configs

Simple configuration files:

- **dotfiles/p10k.zsh**: Powerlevel10k theme configuration
- **dotfiles/tmux.conf.local**: Local tmux customizations

## Usage

### Normal Operation

Home Manager automatically manages all configurations. Just rebuild:

```bash
# Rebuild home configuration
./scripts/rebuild.sh

# Or specifically rebuild home-manager
home-manager switch --flake .#mackieg@nixos-laptop
```

### Submodule Management

Use the dotfiles script to manage git submodules:

```bash
# Initialize submodules (after fresh clone)
./scripts/dotfiles.sh init

# Update all submodules to latest
./scripts/dotfiles.sh update

# Check submodule status
./scripts/dotfiles.sh status

# Pull latest from submodule remotes
./scripts/dotfiles.sh pull
```

### Manual Testing

For testing configurations outside of Home Manager:

```bash
# Create symlinks manually
./scripts/dotfiles.sh link

# Remove symlinks
./scripts/dotfiles.sh unlink
```

## Key Features

### Git Configuration
- User: gmackie (graham.mackie@gmail.com)
- Aliases from your original dotfiles (`gits`, `gitt`)
- Standard aliases (`st`, `co`, `br`, etc.)
- Color output enabled
- Rebase by default
- Git LFS support
- Comprehensive `.gitignore` patterns

### Zsh Configuration
- **Powerlevel10k** theme with your custom p10k.zsh
- **Oh My Zsh** plugins via nixpkgs: git, docker, kubectl, aws, rust, golang, python, nodejs
- **Auto-suggestions** and **syntax highlighting**
- **Enhanced aliases** using modern tools (eza, bat, rg, fd, etc.)
- **Nix shortcuts** (nrs, nrb, hms, nfu, nfc, nfs)
- **Docker shortcuts** (d, dc, dps, etc.)
- **Kubernetes shortcuts** (k, kgp, kgs, etc.)
- **Custom completion** and history settings

### Neovim Configuration
- **Modern Neovim setup** with Lua configuration
- **LSP support** for multiple languages (Lua, Nix, Go, Python, Rust, TypeScript)
- **Telescope** for fuzzy finding files, grep, and more
- **Treesitter** for syntax highlighting and text objects
- **Completion** with nvim-cmp and LuaSnip
- **Navigation** with Harpoon2 for quick file switching
- **Git integration** with Fugitive and Gitsigns
- **UI enhancements** with Lualine, indent guides, and multiple colorschemes
- **Debug support** with nvim-dap
- **Comprehensive keybindings** following modern Neovim conventions

### Tmux Configuration
- **Oh My Tmux** (gpakosz/.tmux) as base configuration
- **Local customizations** in tmux.conf.local
- **Vi-style keybindings**
- **Mouse support** enabled
- **256-color support**

## Adding Custom Configurations

### For Simple Files
Add files directly to the `dotfiles/` directory and reference them in `common.nix`:

```nix
home.file.".myconfig".source = ../dotfiles/myconfig;
```

### For Complex Git Repositories
Add as a submodule:

```bash
git submodule add https://github.com/user/repo.git dotfiles/myrepo
```

Then reference in `common.nix`:
```nix
xdg.configFile.myapp.source = ../dotfiles/myrepo;
```

### For Nix-Managed Programs
Configure directly in `common.nix` using Home Manager options:

```nix
programs.myprogram = {
  enable = true;
  settings = {
    key = "value";
  };
};
```

## Customization Tips

1. **Colors**: All configurations use consistent color schemes when possible
2. **Keybindings**: Leader key is `<Space>` in Neovim, prefix is `C-b` in Tmux
3. **Aliases**: Modern CLI tools are aliased (ls→eza, cat→bat, grep→rg)
4. **History**: All shells share history and ignore duplicates
5. **Completion**: Enhanced completion in both zsh and nvim

## Migration Notes

- **Zsh plugins**: Managed through Nix packages instead of oh-my-zsh submodule
- **Neovim config**: Planned to use a kickstart.nvim-style submodule in future
- **Git config**: Added modern settings like `zdiff3` merge style
- **Path management**: Handled through Nix and sessionVariables instead of manual exports

## Troubleshooting

### Submodule Issues
```bash
# Reset submodules
git submodule foreach --recursive git clean -fd
git submodule update --init --recursive --force
```

### Configuration Conflicts
If you have existing configs that conflict:
1. Back them up: `./scripts/dotfiles.sh` creates backups automatically
2. Let Home Manager manage the files
3. Merge any custom settings into `common.nix`

### Plugin Issues in Neovim
Since plugins are managed by Nix:
1. Add new plugins to the `plugins` list in `common.nix`
2. Configure them in `extraLuaConfig`
3. Rebuild with `./scripts/rebuild.sh`
