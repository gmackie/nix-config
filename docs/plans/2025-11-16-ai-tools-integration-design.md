# AI Development Tools Integration Design

**Date**: 2025-11-16
**Status**: Approved

## Overview

Enhance the multi-system Nix configuration with AI development tools while maintaining cross-platform compatibility across NixOS, macOS (Darwin), and WSL systems.

## Goals

1. Add AI development tools: cursor, cursor-cli, codex, gemini-cli
2. Create custom Nix package for `@google/gemini-cli` npm package
3. Maintain cross-platform compatibility
4. Integrate with existing home-manager dotfiles setup
5. Keep configuration DRY using shared modules

## Current State

### Already Configured
- nixpkgs-unstable as primary package source
- nix-darwin for macOS system management
- home-manager integration for dotfiles
- Cross-platform support (NixOS, Darwin, WSL)

### Already Installed Packages
- git, gh (GitHub CLI)
- neovim
- zsh
- ffmpeg
- claude-code

### Current Structure
```
modules/
├── shared/common-packages.nix  # Cross-platform packages
├── nixos/common.nix            # NixOS base config
├── nixos/                      # NixOS-specific modules
├── darwin/                     # macOS-specific modules
└── home-manager/               # User dotfiles
    └── dotfiles/               # Git submodules (nvim, oh-my-zsh)
```

## Proposed Changes

### 1. Custom Packages Directory

Create a new `packages/` directory for custom derivations:

```
packages/
└── gemini-cli/
    └── default.nix   # Custom derivation for @google/gemini-cli
```

### 2. Package Additions

#### Cross-Platform AI Tools
Add to `modules/shared/common-packages.nix`:
- **cursor** - AI-powered code editor built on VSCode
- **cursor-cli** - Cursor CLI tool
- **codex** - Lightweight coding agent for terminal
- **gemini-cli** - Google Gemini CLI (custom package)

All packages available in nixpkgs-unstable except gemini-cli.

### 3. Gemini CLI Custom Package

#### Technical Specification

**Package**: `@google/gemini-cli` (npm package)
**Build Method**: `buildNpmPackage`

```nix
{ pkgs, lib, stdenv, fetchFromGitHub, nodejs }:

pkgs.buildNpmPackage rec {
  pname = "gemini-cli";
  version = "<specific-version>";  # Pin to specific version

  src = fetchFromGitHub {
    owner = "google";
    repo = "generative-ai-js";
    rev = "v${version}";
    sha256 = "sha256-...";
  };

  npmDepsHash = "sha256-...";  # Calculated by Nix

  buildInputs = [ nodejs ];

  meta = with lib; {
    description = "Google Gemini CLI for AI interactions";
    homepage = "https://www.npmjs.com/package/@google/gemini-cli";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
```

**Key Features**:
- Reproducible builds via `buildNpmPackage`
- Proper dependency locking with `npmDepsHash`
- Source fetched from GitHub or npm registry
- Cross-platform support (Linux, macOS)

### 4. Flake Integration

Update `flake.nix` to expose custom package:

```nix
{
  outputs = { ... }: {
    packages = forAllSystems (system: {
      gemini-cli = import ./packages/gemini-cli {
        pkgs = nixpkgs.legacyPackages.${system};
      };
    });
  };
}
```

Benefits:
- Available as `nix build .#gemini-cli`
- Automatically included in all system configurations
- Can be referenced in other modules

### 5. Home-Manager Integration

#### Package Installation
System-level installation via `common-packages.nix` makes tools available globally.

#### Shell Configuration
In `modules/home-manager/`:

```nix
programs.zsh = {
  shellAliases = {
    ai = "codex";
    gem = "gemini-cli";
  };

  sessionVariables = {
    # API keys via SOPS or environment
    GEMINI_API_KEY = "\${GEMINI_API_KEY}";
  };
};
```

#### Dotfile Strategy
- **Simple configs**: Shell aliases, environment vars → Nix-managed
- **Complex configs**: Cursor settings → Existing dotfiles submodule
- **Secrets**: API keys → SOPS (existing setup)

### 6. Cross-Platform Considerations

#### Package Availability Matrix

| Package     | NixOS | macOS | WSL   | Notes                    |
|-------------|-------|-------|-------|--------------------------|
| cursor      | ✅    | ✅    | ✅    | May need FHS variant     |
| cursor-cli  | ✅    | ✅    | ✅    |                          |
| codex       | ✅    | ✅    | ✅    |                          |
| gemini-cli  | ✅    | ✅    | ✅    | Custom package           |
| neovim      | ✅    | ✅    | ✅    | Already installed        |
| gh          | ✅    | ✅    | ✅    | Already installed        |
| ffmpeg      | ✅    | ✅    | ✅    | Already installed        |
| zsh         | ✅    | ✅    | ✅    | Already installed        |
| git         | ✅    | ✅    | ✅    | Already installed        |
| claude-code | ✅    | ✅    | ✅    | Already installed        |

#### Platform-Specific Handling

**WSL**: May need FHS-wrapped cursor variant for extension compatibility:
```nix
cursor = if wsl then pkgs.cursor.override { useFHS = true; } else pkgs.cursor;
```

**macOS**: Standard cursor package works with Darwin

**NixOS**: Standard cursor package

#### Configuration Sharing

**Shared across all platforms**:
- Shell configurations (zsh, aliases)
- Git configuration
- Neovim config (via dotfiles submodule)
- AI tool configurations
- Environment variables

**Platform-specific**:
- NixOS: Desktop/laptop hardware configs
- macOS: Darwin-specific (homebrew, casks)
- WSL: WSL-specific modules (nixos-wsl)

## Implementation Plan

### Phase 1: Custom Package Creation
1. Create `packages/gemini-cli/default.nix`
2. Research npm package details (version, source location)
3. Build derivation with `buildNpmPackage`
4. Calculate `npmDepsHash`
5. Test build: `nix build .#gemini-cli`

### Phase 2: Flake Integration
1. Update `flake.nix` outputs with custom package
2. Verify package exposed in all system configurations
3. Run `nix flake check` to validate

### Phase 3: Package Configuration
1. Update `modules/shared/common-packages.nix`
2. Add cursor, cursor-cli, codex, gemini-cli
3. Handle WSL-specific cursor variant if needed

### Phase 4: Home-Manager Configuration
1. Add shell aliases for AI tools
2. Configure environment variables
3. Set up any tool-specific configurations
4. Document API key setup via SOPS

### Phase 5: Testing & Validation
1. Test build: `nix flake check`
2. Rebuild test system: `./scripts/rebuild.sh`
3. Verify packages installed: `which cursor`, `which gemini-cli`, etc.
4. Test each tool launches successfully
5. Verify cross-platform compatibility (test on NixOS, macOS, WSL if available)

## Testing Strategy

### Build Validation
```bash
# Check flake validity
nix flake check

# Build custom package
nix build .#gemini-cli

# Test each system configuration
nix build .#nixosConfigurations.brnr.config.system.build.toplevel
nix build .#darwinConfigurations.labtop.system
```

### Runtime Validation
```bash
# Verify installations
which cursor
which cursor-cli
which codex
which gemini-cli

# Test launch
cursor --version
codex --help
gemini-cli --version
```

### Platform Testing
- **NixOS**: Test on brnr (ThinkPad T440)
- **macOS**: Test on labtop (Mac M2)
- **WSL**: Test on wsl configuration (if available)

## Success Criteria

- [ ] Custom gemini-cli package builds successfully
- [ ] All AI tools install across all platforms
- [ ] `nix flake check` passes
- [ ] Tools launch and run correctly
- [ ] Home-manager configurations apply without errors
- [ ] Dotfiles remain intact and functional
- [ ] No conflicts with existing packages
- [ ] Configuration remains DRY (shared where possible)

## Rollback Plan

If issues arise:
1. Git revert commits in reverse order
2. Rebuild system: `./scripts/rebuild.sh`
3. Verify system returns to previous state

Changes are isolated to:
- `packages/gemini-cli/` (new directory, safe to remove)
- `modules/shared/common-packages.nix` (additions only)
- `flake.nix` (package output addition)
- Home-manager configs (optional shell aliases)

## Future Considerations

### Additional AI Tools
- GitHub Copilot CLI
- Aider (already in nixpkgs)
- Tabby (already in nixpkgs)

### Configuration Management
- Move API keys to SOPS secrets
- Create shared AI tool configuration module
- Add documentation for tool usage

### Package Maintenance
- Monitor upstream gemini-cli updates
- Consider upstreaming package to nixpkgs
- Add automated version update checks

## References

- Cursor: `modules/shared/common-packages.nix:cursor`
- Codex: `modules/shared/common-packages.nix:codex`
- nixpkgs buildNpmPackage: https://nixos.org/manual/nixpkgs/stable/#javascript-tool-specific
- Home-Manager options: https://nix-community.github.io/home-manager/
