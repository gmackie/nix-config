# Van NUC (vanuc) Server Setup Guide

This NUC (hostname: vanuc) is configured as a 24/7 server for van life, connected via Starlink at 192.168.0.72.

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
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/nix-config/hosts/vanuc/
```

### 6. Install NixOS
```bash
cd /mnt/etc/nixos/nix-config
sudo nixos-install --flake .#vanuc
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
# In hosts/vanuc/configuration.nix
users.users.mackieg = {
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3... your-key-here"
  ];
};
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#vanuc
```

### 2. Tailscale Setup (Recommended for Remote Access)
```bash
# Start Tailscale
sudo tailscale up

# Follow the authentication link
# This creates a secure VPN tunnel to your NUC from anywhere
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
ssh mackieg@vanuc

# Or use the Tailscale IP:
ssh mackieg@100.x.x.x
```

### Via Direct IP (if on same network)
```bash
ssh mackieg@192.168.0.72
```

## Updating the System

### From Remote
```bash
# SSH into the NUC
ssh mackieg@vanuc

# Pull latest config changes
cd /etc/nixos/nix-config
git pull

# Rebuild
sudo nixos-rebuild switch --flake .#vanuc
```

### From Your Dev Machine
```bash
# SSH in and rebuild
ssh mackieg@vanuc "cd /etc/nixos/nix-config && git pull && sudo nixos-rebuild switch --flake .#vanuc"
```

## Monitoring

Access Netdata dashboard:
```
http://192.168.0.72:19999
# Or via Tailscale:
http://vanuc:19999
```

## Starlink Optimization

The configuration includes:
- KeepAlive settings for SSH to maintain connection
- DNS optimizations
- Connection monitoring

To check your Starlink connection:
```bash
# Speed test
speedtest-cli

# Network monitoring
nethogs  # Real-time bandwidth by process
iftop    # Network interface monitoring
```

## Key Features

- **Claude Code**: AI-powered coding assistant in your terminal
- **Docker**: Run containerized applications
- **Tailscale**: Secure remote access from anywhere
- **Netdata**: System monitoring and metrics
- **Development Tools**: Python, Node.js, Go, Rust environments
- **Automatic Updates**: Garbage collection runs weekly
- **Power Optimized**: Performance governor for 24/7 operation

## Troubleshooting

### Can't connect via SSH
1. Check if NUC is online: `ping 192.168.0.72`
2. Check Starlink connection on the NUC
3. Try Tailscale: `ssh mackieg@vanuc`

### System Updates Failing
```bash
# Check space
df -h

# Clean old generations
sudo nix-collect-garbage -d

# Rebuild
sudo nixos-rebuild switch --flake .#vanuc
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

For more information, see the main repository README.
