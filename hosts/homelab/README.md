# Homelab NUC Server Setup Guide

This NUC (hostname: homelab) is configured as a 24/7 homelab server for general development and services.

## Initial Installation

### 1. Boot into NixOS Installation Media
Download and create a NixOS USB installer from https://nixos.org/download

### 2. Connect to the NUC
Once booted into the installer:
```bash
# Connect to WiFi if needed
sudo systemctl start wpa_supplicant
wpa_cli

# Or use ethernet if available
```

### 3. Partition and Format Disks
```bash
# List disks
lsblk

# Partition the disk (example for /dev/sda)
sudo parted /dev/sda -- mklabel gpt
sudo parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/sda -- set 1 esp on
sudo parted /dev/sda -- mkpart primary 512MiB 100%

# Format partitions
sudo mkfs.fat -F 32 -n boot /dev/sda1
sudo mkfs.ext4 -L nixos /dev/sda2

# Mount filesystems
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
```

### 4. Generate Hardware Configuration
```bash
sudo nixos-generate-config --root /mnt
```

### 5. Transfer This Configuration
From your development machine:
```bash
# Clone this repo to the NUC
git clone <your-repo-url> /mnt/etc/nixos/nix-config

# Copy the generated hardware config
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/nix-config/hosts/homelab/
```

### 6. Install NixOS
```bash
cd /mnt/etc/nixos/nix-config
sudo nixos-install --flake .#homelab
```

### 7. Set User Password
```bash
sudo nixos-enter
passwd mackieg
exit
```

### 8. Reboot
```bash
sudo reboot
```

## Post-Installation Setup

### 1. SSH Access
Add your SSH public key to the configuration:
```nix
# In hosts/homelab/configuration.nix
users.users.mackieg = {
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3... your-key-here"
  ];
};
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#homelab
```

### 2. Tailscale Setup (Recommended for Remote Access)
```bash
# Start Tailscale
sudo tailscale up

# Follow the authentication link
# This creates a secure VPN tunnel to your homelab from anywhere
```

### 3. Claude Code Setup
Claude Code is already installed! To authenticate:
```bash
# Run Claude Code for the first time
claude

# Follow the authentication prompts
# You'll need your Anthropic API key
```

### 4. Docker Setup
Docker is enabled. To use it:
```bash
# Your user is already in the docker group
# Test it:
docker ps

# No sudo needed!
```

## Remote Access from Anywhere

### Via Tailscale (Recommended)
```bash
# From any device with Tailscale installed:
ssh mackieg@homelab

# Or use the Tailscale IP:
ssh mackieg@100.x.x.x
```

### Via Direct IP (if on same network)
```bash
ssh mackieg@<homelab-ip>
```

## Updating the System

### From Remote
```bash
# SSH into the homelab
ssh mackieg@homelab

# Pull latest config changes
cd /etc/nixos/nix-config
git pull

# Rebuild
sudo nixos-rebuild switch --flake .#homelab
```

### From Your Dev Machine
```bash
# SSH in and rebuild
ssh mackieg@homelab "cd /etc/nixos/nix-config && git pull && sudo nixos-rebuild switch --flake .#homelab"
```

## Monitoring

Access Netdata dashboard:
```
http://<homelab-ip>:19999
# Or via Tailscale:
http://homelab:19999
```

## Key Features

- **Claude Code**: AI-powered coding assistant in your terminal
- **Docker**: Run containerized applications
- **Tailscale**: Secure remote access from anywhere
- **Netdata**: System monitoring and metrics
- **Development Tools**: Python, Node.js, Go, Rust environments
- **Automatic Updates**: Garbage collection runs weekly
- **Power Optimized**: Performance governor for 24/7 operation

## Common Homelab Services

Consider adding these services to your homelab:

### Web Services
```nix
# In configuration.nix, add:
services.caddy = {
  enable = true;
  # Configure as reverse proxy
};
```

### Database
```nix
services.postgresql = {
  enable = true;
  # Configure databases
};
```

### Media Server
```bash
# Using Docker:
docker run -d \
  --name=plex \
  -p 32400:32400 \
  plexinc/pms-docker
```

## Troubleshooting

### Can't connect via SSH
1. Check if homelab is online: `ping <homelab-ip>`
2. Check network connection
3. Try Tailscale: `ssh mackieg@homelab`

### System Updates Failing
```bash
# Check space
df -h

# Clean old generations
sudo nix-collect-garbage -d

# Rebuild
sudo nixos-rebuild switch --flake .#homelab
```

### Docker Not Working
```bash
# Restart Docker service
sudo systemctl restart docker

# Check status
sudo systemctl status docker
```

## Next Steps

1. Set up any additional services (web servers, databases, etc.)
2. Configure automated backups
3. Set up monitoring alerts
4. Consider setting up a reverse proxy (nginx/caddy)
5. Set up network storage/NAS functionality

For more information, see the main repository README.
