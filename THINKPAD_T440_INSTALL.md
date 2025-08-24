# ThinkPad T440 NixOS Installation Guide (hostname: frmwrk)

This guide will help you install NixOS on your ThinkPad T440 with optimized settings for the hardware and change the hostname from "brnr" to "frmwrk".

## What This Configuration Includes

- **ThinkPad-optimized hardware support** (TrackPoint, fingerprint reader, power management)
- **Intel graphics acceleration** with HD Graphics 4400 support
- **Advanced power management** (TLP, thermal management, CPU frequency scaling)
- **Desktop environment** with optimized touchpad/TrackPoint configuration
- **Development tools** (Docker, multiple language environments)
- **Automatic firmware updates** and hardware monitoring
- **SSH access** with key-based authentication

## Prerequisites

- ThinkPad T440 laptop
- USB drive (4GB minimum)
- Internet connection
- Your SSH public key (optional but recommended)

## Step 1: Create NixOS Installation Media

### Download NixOS ISO
```bash
# Download the latest NixOS ISO
curl -L -o nixos-minimal.iso https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso

# Create bootable USB
sudo dd if=nixos-minimal.iso of=/dev/sdX bs=4M status=progress
```

## Step 2: Boot from USB

1. Insert USB drive into ThinkPad T440
2. Power on and press **F12** (or **Enter** then **F12**) to access boot menu
3. Select your USB drive
4. Boot into NixOS installer

## Step 3: Connect to Internet

```bash
# For WiFi
sudo systemctl start wpa_supplicant
wpa_cli

# In wpa_cli:
> add_network
0
> set_network 0 ssid "YourNetworkName"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit

# For Ethernet (usually works automatically)
# Check connection
ping google.com
```

## Step 4: Partition the Disk

**Warning**: This will erase all data on your disk!

```bash
# Check available disks
lsblk
fdisk -l

# Partition the disk (assuming /dev/sda)
parted /dev/sda -- mklabel gpt

# Create EFI boot partition (512MB)
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on

# Create swap partition (8GB - adjust based on your RAM)
parted /dev/sda -- mkpart primary linux-swap 512MiB 8.5GiB

# Create root partition (rest of the disk)
parted /dev/sda -- mkpart primary 8.5GiB 100%

# Format partitions
mkfs.fat -F 32 -n boot /dev/sda1
mkswap -L swap /dev/sda2
mkfs.ext4 -L nixos /dev/sda3

# Mount filesystems
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/sda2
```

## Step 5: Clone Your Configuration

```bash
# Install git
nix-shell -p git

# Clone your nix-config repository
git clone https://github.com/yourusername/nix-config.git /mnt/etc/nixos-config

# Create /etc/nixos directory and link files
mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos
```

## Step 6: Generate Hardware Configuration

```bash
# Generate hardware configuration
nixos-generate-config --root /mnt

# Replace the template hardware config with the generated one
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos-config/hosts/frmwrk/hardware-configuration.nix

# Create flake configuration
cat > /mnt/etc/nixos/flake.nix << 'EOF'
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nix-config.url = "path:/etc/nixos-config";
  
  outputs = { self, nixpkgs, nix-config }: {
    nixosConfigurations.frmwrk = nix-config.nixosConfigurations.frmwrk;
  };
}
EOF

# Create basic configuration that imports your flake config
cat > /mnt/etc/nixos/configuration.nix << 'EOF'
{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos-config/hosts/frmwrk/configuration.nix
  ];
}
EOF
```

## Step 7: Customize Your Configuration

Before installation, update some key settings:

```bash
# Edit the hardware configuration if needed
nano /mnt/etc/nixos-config/hosts/frmwrk/hardware-configuration.nix

# Edit main configuration to add your SSH keys
nano /mnt/etc/nixos-config/hosts/frmwrk/configuration.nix
```

**Important customizations:**

1. **Add your SSH public key:**
```nix
users.users.mackieg = {
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your-ssh-key-here"
  ];
};
```

2. **Update swap device UUID in configuration.nix:**
```bash
# Find swap UUID
lsblk -f

# Update in configuration.nix:
boot.resumeDevice = "/dev/disk/by-uuid/YOUR-SWAP-UUID";
```

3. **Verify network interfaces match your hardware:**
```bash
# Check interface names
ip link show

# Update networking.interfaces if needed in configuration.nix
```

## Step 8: Install NixOS

```bash
# Install with flakes
nixos-install --flake /mnt/etc/nixos#frmwrk

# Set root password when prompted
# Set user password
passwd mackieg  # Run this after nixos-install completes

# Reboot
reboot
```

## Step 9: Post-Installation Setup

After rebooting, log in as your user:

### Verify Hostname Change

```bash
# Check that hostname is now "frmwrk"
hostname
hostnamectl status
```

### Test ThinkPad Features

```bash
# Test TrackPoint
# Check that the red nub works for scrolling and navigation

# Test function keys
brightnessctl set 50%  # Adjust screen brightness
# Test volume keys, WiFi toggle, etc.

# Check power management
tlp-stat -s

# Test fingerprint reader (if you have one)
sudo fprint-enroll
```

### Configure Development Environment

```bash
# The system should have all development tools installed
# Test Docker
sudo systemctl start docker
docker run hello-world

# Test languages (Python, Node.js, Go, Rust are pre-configured)
python --version
node --version
go version
rustc --version
```

### Update System (if needed)

```bash
# Update flake inputs and rebuild
sudo nixos-rebuild switch --flake /etc/nixos-config#frmwrk --upgrade
```

## Step 10: Optimize for Your Usage

### Power Management Tuning

```bash
# Check TLP status
sudo tlp-stat

# Monitor power usage
powertop

# Check thermal status
sensors
```

### Performance Monitoring

```bash
# Check system performance
htop
iotop

# Monitor temperatures
watch -n 1 sensors
```

## Troubleshooting

### Common Issues

1. **WiFi not working**:
   ```bash
   # Check if firmware is loaded
   lspci -k | grep -A 3 -i network
   
   # Restart NetworkManager
   sudo systemctl restart NetworkManager
   ```

2. **TrackPoint not responsive**:
   ```bash
   # Reload thinkpad_acpi module
   sudo modprobe -r thinkpad_acpi
   sudo modprobe thinkpad_acpi
   ```

3. **Screen brightness not working**:
   ```bash
   # Check backlight devices
   ls /sys/class/backlight/
   
   # Try alternative method
   light -S 50
   ```

4. **Fingerprint reader not detected**:
   ```bash
   # Check if device is detected
   lsusb | grep -i finger
   
   # Restart fprintd
   sudo systemctl restart fprintd
   ```

### Performance Optimization

```bash
# Check what services are running
systemctl list-units --type=service --state=running

# Disable unnecessary services if needed
sudo systemctl disable <service-name>

# Check boot time
systemd-analyze blame
```

## What's Next?

Your ThinkPad T440 "frmwrk" is now ready with:
- Optimized power management for longer battery life
- Full hardware support including TrackPoint and function keys
- Development environment with multiple programming languages
- Automatic updates and maintenance
- SSH access for remote administration

The configuration will automatically manage power states, thermal control, and hardware features specific to the ThinkPad T440.