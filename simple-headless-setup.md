# Simple Alternative: Regular NixOS ISO + Manual Config

If the custom ISO build takes too long or fails, here's a simpler approach:

## Download Regular NixOS ISO

```bash
curl -L -o nixos-minimal.iso https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso
sudo dd if=nixos-minimal.iso of=/dev/sdX bs=4M status=progress
```

## Boot NUC and Configure SSH

1. Boot from USB, login as `nixos` (no password)
2. Set root password and enable SSH:

```bash
sudo su
passwd  # Set root password
systemctl start sshd
systemctl enable sshd

# Configure networking if needed
sudo systemctl start dhcpcd
ip addr  # Check IP address
```

3. SSH in from your machine:

```bash
ssh root@192.168.0.6  # Use the IP you found above
```

## Then Follow Standard Installation

Continue with the installation steps from `HEADLESS_INSTALL_INSTRUCTIONS.md` starting from "Step 4: Partition and Install NixOS".