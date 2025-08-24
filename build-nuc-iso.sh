#!/usr/bin/env bash

set -euo pipefail

echo "Building custom NixOS ISO with NUC K3S configuration..."

# Build the custom ISO
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./build-nuc-iso.nix

echo "ISO built successfully!"
echo "You can find it in: result/iso/nixos-*.iso"

# Copy to a more convenient location
if [ -f result/iso/nixos-*.iso ]; then
    cp result/iso/nixos-*.iso ./nixos-nuc-k3s-installer.iso
    echo "Copied to: nixos-nuc-k3s-installer.iso"
fi

echo ""
echo "To flash to USB, use:"
echo "  sudo dd if=nixos-nuc-k3s-installer.iso of=/dev/sdX bs=4M status=progress"
echo "  (Replace /dev/sdX with your USB device)"
echo ""
echo "After booting, the NUC configuration will be available at:"
echo "  /etc/nixos-nuc-config.nix"
echo ""
echo "Copy it to use during installation:"
echo "  cp /etc/nixos-nuc-config.nix /mnt/etc/nixos/configuration.nix"