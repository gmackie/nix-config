# Dotfiles Submodules Integration Design

**Date**: 2025-11-16
**Status**: Approved

## Overview

Update git submodules to integrate the correct dotfiles repositories (gmackie/conf.nvim and gmackie/oh-my-zsh) while managing zsh plugins through Nix packages for full declarative configuration.

## Goals

1. Replace kickstart.nvim submodule with gmackie/conf.nvim
2. Initialize gmackie/oh-my-zsh submodule
3. Manage all zsh plugins via nixpkgs (declarative approach)
4. Maintain existing home-manager configuration pattern
5. Ensure reproducibility across all systems

## Current State

### Existing Submodules
```
[submodule "dotfiles/config/nvim"]
  path = dotfiles/config/nvim
  url = git@github.com:gmackie/kickstart.nvim.git  # WRONG REPO

[submodule "dotfiles/oh-my-zsh"]
  path = dotfiles/oh-my-zsh
  url = git@github.com:gmackie/oh-my-zsh.git  # NOT INITIALIZED
```

### Current Zsh Configuration
- File: `dotfiles/zsh.nix`
- Uses home-manager's oh-my-zsh module
- References powerlevel10k theme
- Custom plugins listed but not installed via Nix
- p10k config in `dotfiles/p10k.zsh`

### Reference Dotfiles Repository
Location: `~/dotfiles` (gmackie/dotfiles)
Contains:
- Full oh-my-zsh installation with custom plugins:
  - fast-syntax-highlighting
  - zsh-autosuggestions
  - zsh-completions
  - zsh-syntax-highlighting
  - powerlevel10k theme
- Traditional .zshrc with manual oh-my-zsh setup
- p10k.zsh configuration

## Design Decisions

### Decision 1: Neovim Configuration
**Change:** Replace kickstart.nvim → conf.nvim
**Reason:** conf.nvim is the correct/current neovim configuration repo

### Decision 2: Plugin Management Approach
**Chosen:** Option 1 - Use Nix packages for all plugins
**Alternatives considered:**
- Option 2: Symlink submodule custom directory (traditional approach)

**Rationale for Option 1:**
- ✅ Fully declarative and reproducible
- ✅ Automatic updates via `nix flake update`
- ✅ Consistent across all systems (NixOS, Darwin, WSL)
- ✅ No manual git submodule management for plugins
- ✅ Nix handles dependencies and PATH setup
- ⚠️ Trade-off: Plugin versions managed by nixpkgs, not locked to specific commits

### Decision 3: Oh-My-Zsh Submodule Role
**Purpose:** Reference only (not actively used for plugins)
**Reason:** Keep it available for:
- Comparing configurations
- Extracting custom scripts if needed
- Historical reference

## Proposed Changes

### 1. Submodule Updates

#### Remove Old Neovim Submodule
```bash
git submodule deinit -f dotfiles/config/nvim
git rm -f dotfiles/config/nvim
rm -rf .git/modules/dotfiles/config/nvim
```

#### Add New Neovim Submodule
```bash
git submodule add git@github.com:gmackie/conf.nvim.git dotfiles/config/nvim
git submodule update --init --recursive dotfiles/config/nvim
```

#### Initialize Oh-My-Zsh Submodule
```bash
git submodule update --init --recursive dotfiles/oh-my-zsh
```

### 2. Zsh Plugin Configuration

#### Install Plugins via Nixpkgs

Update `dotfiles/zsh.nix` to include:

```nix
{ config, pkgs, lib, ... }:

{
  # Install zsh plugins as packages
  home.packages = with pkgs; [
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-fast-syntax-highlighting
    zsh-completions
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # ... existing history, options, aliases ...

    # Plugin configuration
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions";
      }
    ];

    # Oh My Zsh configuration (base framework only)
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "kubectl"
        "aws"
        "rust"
        "golang"
        "python"
        "nodejs"
        "npm"
        "yarn"
        "systemd"
        "ssh-agent"
        "gpg-agent"
        "direnv"
      ];
      # Note: theme is loaded via plugins array above
    };

    # ... existing initExtra with p10k config ...
  };
}
```

### 3. Home-Manager Module Structure

**No changes needed to:**
- `dotfiles/p10k.zsh` - Powerlevel10k configuration stays the same
- `dotfiles/git.nix` - Git configuration unchanged
- `modules/home-manager/default.nix` - Module imports unchanged

**Files to update:**
- `.gitmodules` - Update nvim submodule URL
- `dotfiles/zsh.nix` - Add plugin declarations
- `dotfiles/config/nvim/` - Will contain conf.nvim after submodule update

## Implementation Plan

### Phase 1: Submodule Management
1. Deinitialize and remove old nvim submodule (kickstart.nvim)
2. Add new nvim submodule (gmackie/conf.nvim)
3. Initialize oh-my-zsh submodule (gmackie/oh-my-zsh)
4. Update `.gitmodules` with correct references

### Phase 2: Zsh Plugin Configuration
1. Update `dotfiles/zsh.nix` with Nix plugin declarations
2. Add plugin packages to `home.packages`
3. Configure plugin loading in `programs.zsh.plugins`
4. Keep existing oh-my-zsh framework and built-in plugins
5. Maintain p10k configuration reference

### Phase 3: Testing & Validation
1. Verify submodules initialized: `git submodule status`
2. Check neovim config exists: `ls dotfiles/config/nvim/`
3. Test configuration builds: `nix flake check`
4. Rebuild a test system
5. Verify plugins load correctly in zsh
6. Test powerlevel10k theme renders properly

## File Structure After Changes

```
nix-config/
├── .gitmodules                    # Updated with conf.nvim
├── dotfiles/
│   ├── config/
│   │   └── nvim/                 # gmackie/conf.nvim (submodule)
│   ├── oh-my-zsh/                # gmackie/oh-my-zsh (submodule, reference)
│   ├── p10k.zsh                  # Powerlevel10k config (unchanged)
│   ├── zsh.nix                   # Updated with Nix plugins
│   └── git.nix                   # Unchanged
└── modules/
    └── home-manager/
        └── default.nix           # Unchanged
```

## Plugin Mapping

| Plugin from ~/dotfiles | Nix Package | Purpose |
|------------------------|-------------|---------|
| powerlevel10k | `zsh-powerlevel10k` | Theme |
| zsh-autosuggestions | `zsh-autosuggestions` | Command suggestions |
| zsh-syntax-highlighting | `zsh-syntax-highlighting` | Syntax highlighting |
| fast-syntax-highlighting | `zsh-fast-syntax-highlighting` | Faster highlighting |
| zsh-completions | `zsh-completions` | Additional completions |

## Benefits

### Declarative Management
- All plugins defined in Nix configuration
- Version-controlled and reproducible
- No manual plugin installation needed

### Cross-Platform Consistency
- Same plugin versions across NixOS, Darwin, WSL
- Nix handles platform-specific differences
- Centralized configuration in one place

### Easy Updates
- Update all plugins: `nix flake update`
- Roll back if issues: `nixos-rebuild switch --rollback`
- Test before deploying across systems

### Integration with Home-Manager
- Plugins installed to correct locations automatically
- PATH setup handled by Nix
- No conflicts with system packages

## Risks and Mitigation

### Risk 1: Plugin Version Differences
**Issue:** Nixpkgs versions may differ from gmackie/oh-my-zsh submodule
**Mitigation:**
- Using nixpkgs-unstable provides recent versions
- Can pin specific versions if needed via overrides
- Submodule kept as reference for comparison

### Risk 2: Custom Plugin Configurations
**Issue:** Some plugins in submodule may have custom configs
**Mitigation:**
- Review oh-my-zsh/custom/ for any custom scripts
- Port important customizations to zsh.nix
- Keep submodule available for reference

### Risk 3: Powerlevel10k Configuration Compatibility
**Issue:** Nix powerlevel10k version may not match submodule version
**Mitigation:**
- Existing p10k.zsh should be compatible
- Can regenerate with `p10k configure` if needed
- Test on one system before deploying to all

## Success Criteria

- [ ] Neovim submodule points to gmackie/conf.nvim
- [ ] Oh-my-zsh submodule initialized successfully
- [ ] All zsh plugins installed via Nix packages
- [ ] `nix flake check` passes
- [ ] Zsh starts without errors
- [ ] Powerlevel10k theme renders correctly
- [ ] Plugin features work (autosuggestions, syntax highlighting)
- [ ] Configuration applies across all systems
- [ ] Git status shows clean submodule state

## Rollback Plan

If issues arise:

### Immediate Rollback
```bash
git checkout HEAD~1 .gitmodules
git submodule update --init --recursive
git checkout HEAD~1 dotfiles/zsh.nix
./scripts/rebuild.sh
```

### Partial Rollback Options
- Revert just zsh.nix changes (keep submodule updates)
- Revert just submodule changes (keep zsh.nix updates)
- Both are independent and can be rolled back separately

## Future Considerations

### Custom Neovim Configuration
- gmackie/conf.nvim may have specific dependencies
- May need to add Neovim plugins via Nix
- Consider creating `dotfiles/nvim.nix` for Neovim home-manager config

### Plugin Customization
- If Nix plugin versions lack features, consider:
  - Using `fetchFromGitHub` for specific commits
  - Creating custom derivations for plugins
  - Contributing updates to nixpkgs

### Submodule Maintenance
- Periodically update submodules: `git submodule update --remote`
- Review changes before incorporating
- Document any manual steps needed for updates

## References

- Home-Manager Zsh Options: https://nix-community.github.io/home-manager/options.html#opt-programs.zsh
- Nixpkgs Zsh Plugins: Search nixpkgs for "zsh-"
- Powerlevel10k Docs: https://github.com/romkatv/powerlevel10k
- gmackie/dotfiles: https://github.com/gmackie/dotfiles
- gmackie/conf.nvim: https://github.com/gmackie/conf.nvim
