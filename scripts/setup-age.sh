#!/usr/bin/env bash

# Setup script for age encryption keys
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

AGE_DIR="$HOME/.config/sops/age"
AGE_KEY_FILE="$AGE_DIR/keys.txt"

# Check if age key already exists
if [[ -f "$AGE_KEY_FILE" ]]; then
    print_warn "Age key already exists at $AGE_KEY_FILE"
    echo -n "Do you want to regenerate it? (y/N): "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Reading existing key..."
        PUBLIC_KEY=$(grep "public key:" "$AGE_KEY_FILE" | cut -d' ' -f4)
        print_info "Your public key: $PUBLIC_KEY"
        exit 0
    fi
fi

# Create directory if it doesn't exist
print_info "Creating age directory..."
mkdir -p "$AGE_DIR"

# Generate new age key
print_info "Generating new age key..."
age-keygen -o "$AGE_KEY_FILE"

# Set proper permissions
chmod 600 "$AGE_KEY_FILE"

# Extract public key
PUBLIC_KEY=$(grep "public key:" "$AGE_KEY_FILE" | cut -d' ' -f4)

print_info "Age key generated successfully!"
print_info "Private key stored at: $AGE_KEY_FILE"
print_info "Your public key: $PUBLIC_KEY"
print_warn "Keep your private key safe and backed up!"

echo ""
print_info "Next steps:"
echo "1. Update .sops.yaml with your public key"
echo "2. Create encrypted secrets with: sops secrets/example.yaml"
echo "3. Edit encrypted secrets with: sops secrets/example.yaml"

# Offer to update .sops.yaml
echo ""
echo -n "Would you like to update .sops.yaml with your new key? (y/N): "
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    SOPS_FILE=".sops.yaml"
    if [[ -f "$SOPS_FILE" ]]; then
        # Replace the example age key with the actual one
        sed -i.bak "s/age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p/$PUBLIC_KEY/g" "$SOPS_FILE"
        print_info "Updated $SOPS_FILE with your public key"
        print_info "Backup saved as ${SOPS_FILE}.bak"
    else
        print_error "$SOPS_FILE not found"
    fi
fi