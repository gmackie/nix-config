# Legacy Configuration Files

These files are from the pre-flake configuration era and have been superseded by the flake-based setup.

## Files

- **configuration.nix** - Old WSL configuration, replaced by `hosts/wsl/configuration.nix`
- **darwin-configuration.nix** - Old macOS configuration, replaced by `hosts/labtop/configuration.nix`
- **syschdemd.nix** / **syschdemd.sh** - WSL systemd helper, replaced by nixos-wsl module

## Note

These files are kept for reference only. Do not import them into new configurations.
The flake-based setup in `flake.nix` is the current active configuration.
