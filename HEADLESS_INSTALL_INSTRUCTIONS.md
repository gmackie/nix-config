# NixOS Headless Installation Instructions

## Prerequisites

1. **Custom ISO**: Use the built `nixos-headless-installer.iso` 
2. **USB Drive**: At least 4GB
3. **Network Connection**: Ethernet recommended for NUC

## Step 1: Create Bootable USB

```bash
# Find your USB device
lsblk

# Flash the ISO (replace /dev/sdX with your USB device)
sudo dd if=nixos-headless-installer.iso of=/dev/sdX bs=4M status=progress oflag=sync

# Safely eject
sudo eject /dev/sdX
```

## Step 2: Boot NUC from USB

1. Insert USB into NUC (192.168.0.6)
2. Boot and enter BIOS/UEFI settings (usually F2 or DEL during startup)
3. Set USB as primary boot device
4. Save and reboot

## Step 3: SSH Access

After the NUC boots from USB:

```bash
# SSH into the installer (password: nixos)
ssh root@192.168.0.6

# Or if the IP changed, scan the network
nmap -sn 192.168.0.0/24 | grep -B2 -A2 "Nmap scan report"
```

**Default Credentials:**
- Username: `root`
- Password: `nixos`

## Step 4: Partition and Install NixOS

Once connected via SSH:

```bash
# Check available disks
lsblk
fdisk -l

# Partition the disk (example for /dev/sda)
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 512MiB 100%

# Format partitions
mkfs.fat -F 32 -n boot /dev/sda1
mkfs.ext4 -L nixos /dev/sda2

# Mount filesystems
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# Generate initial configuration
nixos-generate-config --root /mnt

# Edit configuration for your k3s setup
nano /mnt/etc/nixos/configuration.nix
```

## Step 5: Configure for K3S

Add to `/mnt/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking = {
    hostName = "k3s-node";
    useDHCP = false;
    interfaces.enp0s3.useDHCP = true; # Adjust interface name
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 6443 ]; # SSH and k3s
      allowedTCPPortRanges = [
        { from = 2379; to = 2380; } # etcd
        { from = 10250; to = 10255; } # kubelet
      ];
    };
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Add your SSH key here
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 YOUR_SSH_KEY_HERE"
  ];

  # K3s dependencies
  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    htop
  ];

  # Enable container runtime
  virtualisation.docker.enable = true;
  
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";
}
```

## Step 6: Install and Reboot

```bash
# Install NixOS
nixos-install

# Set root password when prompted
# Enter your desired root password

# Reboot
reboot
```

## Step 7: Post-Installation K3s Setup

After reboot, SSH back in:

```bash
# Install k3s
curl -sfL https://get.k3s.io | sh -

# Check status
sudo systemctl status k3s

# Get kubeconfig
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config

# Test
kubectl get nodes
```

## Troubleshooting

- **Can't SSH**: Check if the NUC got a different IP with `nmap -sn 192.168.0.0/24`
- **Boot issues**: Verify UEFI/Legacy boot settings match your setup
- **Network issues**: Try ethernet cable instead of WiFi for initial setup

## Security Notes

- **Change default password immediately** after SSH access
- **Add your SSH keys** to the configuration
- **Disable password auth** once key auth is working
- **Update firewall rules** based on your k3s requirements