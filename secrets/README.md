# Secrets Management with SOPS

This directory contains encrypted secrets managed by [sops-nix](https://github.com/Mic92/sops-nix).

## Setup

### 1. Generate an age key (if you don't have one)

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

### 2. Get your public key

```bash
cat ~/.config/sops/age/keys.txt | grep "public key:"
```

### 3. Add your public key to `.sops.yaml`

Edit `.sops.yaml` in the repository root and replace the example age public key with yours.

### 4. Create and encrypt secrets

```bash
# Create a new secrets file (will open in editor)
sops secrets/secrets.yaml

# Or encrypt an existing file
sops -e -i secrets/secrets.yaml
```

### 5. Edit encrypted secrets

```bash
sops secrets/secrets.yaml
```

## Using Secrets in NixOS Configuration

In your host configuration:

```nix
{
  imports = [ ../../modules/nixos/secrets.nix ];

  # Secrets will be available at /run/secrets/<name>
  sops.secrets.example_password = {
    sopsFile = ../../secrets/secrets.yaml;
  };

  # Use in services
  services.someservice = {
    passwordFile = config.sops.secrets.example_password.path;
  };
}
```

## Host-Specific Secrets

For secrets that should only be available on specific hosts:

```bash
# Create host-specific secrets
sops secrets/hosts/hostname/secrets.yaml
```

Then in that host's configuration:

```nix
sops.secrets.host_specific_secret = {
  sopsFile = ../../secrets/hosts/hostname/secrets.yaml;
};
```

## Converting SSH Keys to Age

If you want to use your SSH key instead of generating a new age key:

```bash
nix-shell -p ssh-to-age --run 'cat ~/.ssh/id_ed25519.pub | ssh-to-age'
```

## File Structure

```
secrets/
├── README.md           # This file
├── secrets.yaml        # Shared secrets (encrypted)
└── hosts/              # Host-specific secrets
    ├── brnr/
    │   └── secrets.yaml
    ├── homelab/
    │   └── secrets.yaml
    └── ...
```
