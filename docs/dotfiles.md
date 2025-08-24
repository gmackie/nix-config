# Dotfiles Integration

This nix-config repository includes comprehensive dotfiles management, integrating all your personal configurations into a single, declarative setup.

## Structure

```
dotfiles/
├── config/
│   └── nvim/           # Neovim config (git submodule)
├── oh-my-zsh/          # Oh My Zsh with customizations (git submodule)
├── p10k.zsh            # Powerlevel10k configuration
├── screenrc            # GNU Screen configuration
└── taskrc              # Taskwarrior configuration
```

## Configuration Management

### Nix-Managed Configs

These are configured directly in `home/mackieg/common.nix`:

- **Git**: Complete git configuration with aliases, colors, and LFS support
- **Zsh**: Shell configuration with Powerlevel10k, aliases, and completion
- **Neovim**: Full IDE setup with LSP, Telescope, Treesitter, and more
- **Tmux**: Terminal multiplexer with custom keybindings
- **Direnv**: Automatic environment loading
- **FZF**: Fuzzy finder integration
- **Starship**: Cross-shell prompt (alternative to p10k)

### Submodule-Managed Configs

These are managed as git submodules for complex configurations:

- **dotfiles/config/nvim**: Your Neovim configuration (kickstart.nvim fork)
- **dotfiles/oh-my-zsh**: Customized Oh My Zsh installation

### File-Based Configs

Simple configuration files copied from your original dotfiles:

- **dotfiles/p10k.zsh**: Powerlevel10k theme configuration
- **dotfiles/screenrc**: GNU Screen settings
- **dotfiles/taskrc**: Taskwarrior configuration

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
# Update all submodules to latest
./scripts/dotfiles.sh update

# Check submodule status
./scripts/dotfiles.sh status

# Sync changes from submodules
./scripts/dotfiles.sh sync

# Push changes to submodule repositories
./scripts/dotfiles.sh push
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
- **Oh My Zsh** with plugins: git, docker, kubectl, aws, rust, golang, python, nodejs
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
- **Git integration** with Fugitive and Gitsigns
- **UI enhancements** with Lualine, indent guides, and multiple colorschemes
- **Debug support** with nvim-dap
- **Comprehensive keybindings** following modern Neovim conventions

### Tmux Configuration
- **Vi-style keybindings**
- **Mouse support** enabled
- **Custom split shortcuts** (| and -)
- **Pane navigation** with Alt+arrow keys
- **History limit** of 10,000 lines
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
git submodule add https://github.com/user/repo.git dotfiles/config/myapp
```

Then reference in `common.nix`:
```nix
xdg.configFile.myapp.source = ../dotfiles/config/myapp;
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

- **Vim config ignored**: Using Neovim instead (your vim config remains in dotfiles for reference)
- **Git config updated**: Added modern settings like `zdiff3` merge style
- **Zsh plugins**: Converted from oh-my-zsh plugins to nix-managed where possible
- **Path management**: Handled through Nix and sessionVariables instead of manual exports

## Troubleshooting

### Submodule Issues
```bash
# Reset submodules
git submodule foreach --recursive git clean -fd
git submodule update --init --recursive --force

# Update specific submodule
cd dotfiles/config/nvim
git pull origin main
cd ../../..
git add dotfiles/config/nvim
git commit -m "Update nvim submodule"
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