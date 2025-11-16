# NUC Setup Guide

This guide covers the setup of two NUC systems configured with Claude Code and your shared Nix infrastructure.

## Systems Overview

### 1. **vanuc** - Van Server (192.168.0.72)
- **Purpose**: 24/7 server for van life
- **Network**: Starlink satellite internet
- **IP**: 192.168.0.72
- **Features**:
  - Claude Code (AI coding assistant)
  - SSH with keepalive for Starlink
  - Docker support
  - Tailscale VPN for remote access
  - Netdata monitoring
  - Development environments (Python, Node.js, Go, Rust)
  - Optimized for satellite internet connectivity

### 2. **homelab** - Homelab Server
- **Purpose**: General homelab development and services
- **Network**: Standard network connection
- **Features**:
  - Claude Code (AI coding assistant)
  - SSH remote access
  - Docker support
  - Tailscale VPN
  - Netdata monitoring
  - Development environments (Python, Node.js, Go, Rust)
  - Ready for additional services (databases, web servers, etc.)

## Quick Start

### Prerequisites
1. NixOS installation USB drive
2. Network connection (ethernet recommended for initial setup)
3. This repository cloned locally

### Installation Steps

For detailed installation instructions, see the respective README files:
- Van NUC: `hosts/vanuc/README.md`
- Homelab NUC: `hosts/homelab/README.md`

### Basic Installation Flow

1. **Boot from NixOS USB**
   ```bash
   # Download from: https://nixos.org/download
   ```

2. **Partition and format disks**
   ```bash
   sudo parted /dev/sda -- mklabel gpt
   sudo parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
   sudo parted /dev/sda -- set 1 esp on
   sudo parted /dev/sda -- mkpart primary 512MiB 100%

   sudo mkfs.fat -F 32 -n boot /dev/sda1
   sudo mkfs.ext4 -L nixos /dev/sda2

   sudo mount /dev/disk/by-label/nixos /mnt
   sudo mkdir -p /mnt/boot
   sudo mount /dev/disk/by-label/boot /mnt/boot
   ```

3. **Generate hardware config**
   ```bash
   sudo nixos-generate-config --root /mnt
   ```

4. **Clone this repo and copy hardware config**
   ```bash
   # Clone to /mnt/etc/nixos/nix-config
   git clone <your-repo-url> /mnt/etc/nixos/nix-config

   # For vanuc:
   sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/nix-config/hosts/vanuc/

   # For homelab:
   sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/nix-config/hosts/homelab/
   ```

5. **Install NixOS**
   ```bash
   cd /mnt/etc/nixos/nix-config

   # For vanuc:
   sudo nixos-install --flake .#vanuc

   # For homelab:
   sudo nixos-install --flake .#homelab
   ```

6. **Set password and reboot**
   ```bash
   sudo nixos-enter
   passwd mackieg
   exit
   sudo reboot
   ```

## Post-Installation Setup

### 1. SSH Access (Already Configured!)
Your SSH key is already added to both configurations:
- Key: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW0z6b1kJpQPh2v9q9EXfvX+eBmhgCCLjo4Dwy7Ep5I`

Test SSH connection:
```bash
# For vanuc (from same network):
ssh mackieg@192.168.0.72

# For homelab:
ssh mackieg@<homelab-ip>
```

### 2. Tailscale VPN Setup
Both systems have Tailscale enabled for secure remote access from anywhere:

```bash
# On the NUC:
sudo tailscale up

# Follow the authentication link
# Now you can access from anywhere:
ssh mackieg@vanuc    # or @homelab
```

### 3. Claude Code Setup
Claude Code is pre-installed on both systems! First time setup:

```bash
# SSH into the NUC
ssh mackieg@vanuc  # or @homelab

# Run Claude Code
claude

# Follow authentication prompts
# You'll need your Anthropic API key
```

### 4. Docker
Docker is pre-configured and your user is in the docker group:
```bash
docker ps  # No sudo needed!
```

## System Monitoring

Both systems include Netdata for real-time monitoring:

```
# For vanuc:
http://192.168.0.72:19999
# Or via Tailscale:
http://vanuc:19999

# For homelab:
http://<homelab-ip>:19999
# Or via Tailscale:
http://homelab:19999
```

## Updating Systems

### From Remote (Recommended)
```bash
# SSH into the system
ssh mackieg@vanuc  # or @homelab

# Update
cd /etc/nixos/nix-config
git pull
sudo nixos-rebuild switch --flake .#vanuc  # or .#homelab
```

### From Your Dev Machine
```bash
# One command update:
ssh mackieg@vanuc "cd /etc/nixos/nix-config && git pull && sudo nixos-rebuild switch --flake .#vanuc"
```

## Key Features

### Claude Code Integration
- **CLI AI assistant**: Use `claude` command in terminal
- **Multi-file editing**: Edit multiple files at once
- **Context-aware**: Understands your codebase
- **Works remotely**: Use over SSH with no lag

### Development Environment
Pre-installed language support:
- **Python**: poetry, pip, common packages
- **Node.js**: npm, yarn, pnpm
- **Go**: go, gopls
- **Rust**: rustc, cargo, rust-analyzer

### Server Tools
- **Docker**: Container orchestration
- **Tailscale**: Zero-config VPN
- **Netdata**: Real-time monitoring
- **System tools**: htop, ncdu, duf, lnav

### Van-Specific (vanuc)
- **Starlink optimized**: SSH keepalive, DNS tuning
- **Network monitoring**: speedtest-cli, iftop, nethogs
- **Power optimized**: Performance governor for 24/7

## Troubleshooting

### Can't Connect via SSH
```bash
# Check if system is reachable
ping 192.168.0.72  # or homelab IP

# Try Tailscale
ssh mackieg@vanuc  # or @homelab
```

### System Updates Fail
```bash
# Free up space
sudo nix-collect-garbage -d

# Check disk space
df -h

# Rebuild
sudo nixos-rebuild switch --flake .#vanuc
```

### Claude Code Not Working
```bash
# Check if installed
which claude

# Re-authenticate
claude --login

# Check API key is set
```

## Next Steps

### For Van NUC (vanuc)
1. Connect to Starlink
2. Set up Tailscale for remote access
3. Configure any specific services you need
4. Set up automated backups

### For Homelab (homelab)
1. Set up Tailscale
2. Install additional services (web server, database, etc.)
3. Configure network storage if needed
4. Set up reverse proxy (Caddy/nginx) for web services

## Configuration Files

- **System configs**: `hosts/{vanuc,homelab}/configuration.nix`
- **Shared packages**: `modules/shared/packages.nix`
- **Language modules**: `modules/nixos/languages/`
- **Flake**: `flake.nix` (defines both systems)

## Getting Help

- See individual README files in `hosts/vanuc/` and `hosts/homelab/`
- Check the main `CLAUDE.md` for project structure
- For Claude Code help: https://code.claude.com/docs

## Summary

Both NUCs are configured with:
- ✅ Claude Code pre-installed
- ✅ SSH access with your public key
- ✅ Docker support
- ✅ Tailscale VPN ready
- ✅ System monitoring (Netdata)
- ✅ Full development environments
- ✅ Automatic garbage collection
- ✅ SSD optimization

The configurations use your existing shared Nix infrastructure from this repository, ensuring consistency across all your systems.
