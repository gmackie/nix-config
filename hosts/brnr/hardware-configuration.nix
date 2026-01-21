# PLACEHOLDER: Generate this file on the actual hardware
#
# Run the following command on the target machine:
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# Or during installation:
#   sudo nixos-generate-config --root /mnt
#   Then copy /mnt/etc/nixos/hardware-configuration.nix here
#
# This file should contain:
# - File system mounts (fileSystems."/", fileSystems."/boot", etc.)
# - Swap devices
# - Hardware-specific kernel modules
# - CPU microcode updates
#
# ThinkPad T440 typical modules:
# - boot.initrd.availableKernelModules: xhci_pci, ehci_pci, ahci, usb_storage, sd_mod
# - boot.kernelModules: kvm-intel
# - hardware.cpu.intel.updateMicrocode

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # TODO: Replace with actual hardware configuration
  # boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
  # boot.kernelModules = [ "kvm-intel" ];

  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
  #   fsType = "ext4";
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/XXXX-XXXX";
  #   fsType = "vfat";
  # };

  # swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
