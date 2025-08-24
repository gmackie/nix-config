# NUC K3S Headless Installation Guide

This guide will help you install NixOS with a complete K3S homelab setup on your Intel NUC at 192.168.0.6.

## What This Sets Up

- **K3S Kubernetes cluster** (single node)
- **Container runtime** (Docker + Podman)
- **Monitoring stack** (Prometheus + Grafana)  
- **Development services** (PostgreSQL + Redis)
- **Reverse proxy** (Nginx)
- **Hardware optimization** for Intel NUC
- **SSH access** with key-based authentication
- **Auto-updates** and garbage collection

## Step 1: Build Custom ISO

```bash
# Build the NUC-specific ISO with pre-configured K3S setup
./build-nuc-iso.sh
```

This creates `nixos-nuc-k3s-installer.iso` with your NUC configuration embedded.

## Step 2: Create Bootable USB

```bash
# Find your USB device
lsblk

# Flash the custom ISO (replace /dev/sdX with your USB device)
sudo dd if=nixos-nuc-k3s-installer.iso of=/dev/sdX bs=4M status=progress oflag=sync

# Safely eject
sudo eject /dev/sdX
```

## Step 3: Boot NUC from USB

1. Insert USB into NUC
2. Enter BIOS/UEFI settings (F2 or DEL during startup)
3. Set USB as primary boot device
4. Save and reboot

## Step 4: SSH into Installer

```bash
# SSH into the installer (password: nixos)
ssh root@192.168.0.6

# Or scan network if IP changed
nmap -sn 192.168.0.0/24 | grep -B2 -A2 "Nmap scan report"
```

**Default Credentials:**
- Username: `root`
- Password: `nixos`

## Step 5: Partition and Prepare Installation

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

# Generate hardware configuration
nixos-generate-config --root /mnt

# Copy the pre-configured NUC setup
cp /etc/nixos-nuc-config.nix /mnt/etc/nixos/configuration.nix
```

## Step 6: Customize Configuration

Edit `/mnt/etc/nixos/configuration.nix` to customize:

```bash
vim /mnt/etc/nixos/configuration.nix
```

**Important changes to make:**

1. **Add your SSH keys** (replace the comment):
```nix
users.users.mackieg.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your-key-here"
];
```

2. **Verify network interface name** (check with `ip link`):
```nix
networking.interfaces.enp3s0.ipv4.addresses = [{  # Adjust interface name
  address = "192.168.0.6";
  prefixLength = 24;
}];
```

3. **Update gateway/DNS if needed**:
```nix
networking.defaultGateway = "192.168.0.1";  # Your router IP
networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
```

## Step 7: Install NixOS

```bash
# Install the system
nixos-install

# Set root password when prompted
# Set user password
nixos-install --root /mnt --option extra-users 'mackieg:1000:100:mackieg:/home/mackieg:/run/current-system/sw/bin/bash'

# Reboot
reboot
```

## Step 8: Post-Installation Setup

After reboot, SSH in with your user account:

```bash
# SSH with your user account
ssh mackieg@192.168.0.6
```

### Verify K3S Installation

```bash
# Check K3S status
sudo systemctl status k3s

# Get kubeconfig
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config

# Test cluster
kubectl get nodes
kubectl get pods -A
```

### Access Services

- **Grafana**: http://192.168.0.6/grafana/
- **Prometheus**: http://192.168.0.6/prometheus/
- **Kubernetes API**: https://192.168.0.6:6443

### Deploy Your First App

```bash
# Example: Deploy a simple web app
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

# Check the service
kubectl get services
```

## Step 9: Security Hardening (Recommended)

1. **Disable root SSH** (after verifying user access works):
```bash
sudo nixos-rebuild switch
```

2. **Update firewall** as needed for your applications

3. **Set up proper TLS certificates** for production use

## Troubleshooting

- **SSH connection refused**: Check if NUC got a different IP
- **K3S not starting**: Check logs with `journalctl -u k3s`
- **Static IP not working**: Verify interface name with `ip link`
- **Services not accessible**: Check firewall rules and service status

## What's Next?

Your NUC is now ready for:
- Deploying containerized applications
- Setting up CI/CD pipelines  
- Running development workloads
- Monitoring with Grafana/Prometheus
- Database applications (PostgreSQL/Redis included)

The system will auto-update daily at 4 AM and clean up old generations weekly.