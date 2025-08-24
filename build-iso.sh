#!/usr/bin/env bash

set -euo pipefail

echo "Building custom NixOS ISO with SSH enabled..."

# Build the custom ISO
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./build-headless-iso.nix

echo "ISO built successfully!"
echo "You can find it in: result/iso/nixos-*.iso"

# Optional: Copy to a more convenient location
if [ -f result/iso/nixos-*.iso ]; then
    cp result/iso/nixos-*.iso ./nixos-headless-installer.iso
    echo "Copied to: nixos-headless-installer.iso"
fi

echo ""
echo "To flash to USB, use:"
echo "  sudo dd if=nixos-headless-installer.iso of=/dev/sdX bs=4M status=progress"
echo "  (Replace /dev/sdX with your USB device)"