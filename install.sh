#!/usr/bin/env bash

# Exit on error
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed
package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

# Function to detect AUR helper
detect_aur_helper() {
    for helper in paru yay; do
        if command_exists "$helper"; then
            echo "$helper"
            return 0
        fi
    done
    return 1
}

# Function to install paru if no AUR helper is found
install_paru() {
    echo "No AUR helper found. Installing paru..."
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/paru
}

# List of official Arch packages
PACMAN_PACKAGES=(
    hyprland
    waybar
    xdg-desktop-portal-hyprland
	fastfetch
	bat
    polkit-gnome
    qt5-wayland
    qt6-wayland
    sddm
)

# List of AUR packages
AUR_PACKAGES=(
	zen-browser-bin
    hyprlock
)

# Services to enable
SERVICES=(
    sddm
)

# Check if script is run from the repo directory
if [[ ! -d "configs" ]]; then
    echo "Error: 'configs' directory not found. Please run this script from the repository root."
    exit 1
fi

# Check if script has sudo
if ! sudo -n true 2>/dev/null; then
    echo "Error: This script requires sudo privileges."
    exit 1
fi

# Update system
echo "Updating system..."
sudo pacman -Syu --needed --noconfirm

# Detect or install AUR helper
AUR_HELPER=$(detect_aur_helper)
if [[ -z "$AUR_HELPER" ]]; then
    install_paru
    AUR_HELPER="paru"
fi
echo "Using AUR helper: $AUR_HELPER"

# Install official Arch packages
echo "Installing official Arch packages..."
for pkg in "${PACMAN_PACKAGES[@]}"; do
    if package_installed "$pkg"; then
        echo "$pkg is already installed, skipping..."
    else
        echo "Installing $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg"
    fi
done

# Install AUR packages
echo "Installing AUR packages..."
for pkg in "${AUR_PACKAGES[@]}"; do
    if package_installed "$pkg"; then
        echo "$pkg is already installed, skipping..."
    else
        echo "Installing $pkg..."
        "$AUR_HELPER" -S --noconfirm "$pkg"
    fi
done

# Copy configuration files
echo "Copying configuration files..."
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$CONFIG_DIR"
cp -r configs/* "$CONFIG_DIR/"
echo "Configuration files copied to ~/{$CONFIG_DIR}/"

# Enable and start services
echo "Enabling and starting services..."
for service in "${SERVICES[@]}"; do
    if systemctl is-enabled --quiet "$service"; then
        echo "$service is already enabled, skipping..."
    else
        echo "Enabling $service..."
        sudo systemctl enable "$service"
    fi
    if systemctl is-active --quiet "$service"; then
        echo "$service is already running, skipping..."
    else
        echo "Starting $service..."
        sudo systemctl start "$service"
    fi
done

echo "Installation complete! You can now log in with Hyprland via SDDM."
