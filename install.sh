#!/usr/bin/env bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to check if a command succeeded
check_status() {
	if [ $? -ne 0 ]; then
		echo -e "${RED}Error: $1 failed. Exiting.${NC}"
		exit 1
	fi
}

# Function to prompt for yes/no and return 0 (yes) or 1 (no)
prompt_yes_no() {
	while true; do
		read -p "$1 (y/n): " yn
		case $yn in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes (y) or no (n).";;
		esac
	done
}

# Update system and install base dependencies
echo -e "${GREEN}Updating system and installing base packages...${NC}"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git hyprland waybar xdg-desktop-portal-hyprland \
	polkit-gnome dunst sddm qt5-wayland qt6-wayland pipewire pipewire-pulse
check_status "Base package installation"

# Check if an AUR helper is already installed
echo -e "${GREEN}Checking for existing AUR helper...${NC}"
if command -v paru > /dev/null 2>&1; then
	AUR_HELPER="paru"
	echo -e "${GREEN}paru is already installed. Using it.${NC}"
elif command -v yay > /dev/null 2>&1; then
	AUR_HELPER="yay"
	echo -e "${GREEN}yay is already installed. Using it.${NC}"
else
	# Choose AUR helper
	echo -e "${GREEN}Select an AUR helper:${NC}"
	echo "1) paru (default)"
	echo "2) yay"
	read -p "Enter your choice (1 or 2): " aur_choice

	case $aur_choice in
		2)
			AUR_HELPER="yay"
			echo -e "${GREEN}Installing yay...${NC}"
			git clone https://aur.archlinux.org/yay.git /tmp/yay
			cd /tmp/yay
			makepkg -si --noconfirm
			check_status "yay installation"
			cd -
			;;
		*)
			AUR_HELPER="paru"
			echo -e "${GREEN}Installing paru...${NC}"
			git clone https://aur.archlinux.org/paru.git /tmp/paru
			cd /tmp/paru
			makepkg -si --noconfirm
			check_status "paru installation"
			cd -
			;;
	esac

# Install AUR packages for Hyprland setup
echo -e "${GREEN}Installing AUR packages with $AUR_HELPER...${NC}"
$AUR_HELPER -S --noconfirm hyprpaper hyprsunset swww rofi-lbonn-wayland-git
check_status "AUR package installation"

# Optional packages
echo -e "${GREEN}Optional packages installation:${NC}"

# Terminal emulator
if prompt_yes_no "Install Alacritty terminal?"; then
	sudo pacman -S --noconfirm alacritty
	check_status "Alacritty installation"
fi

# Web browser
if prompt_yes_no "Install Firefox?"; then
	sudo pacman -S --noconfirm firefox
	check_status "Firefox installation"
fi

# File manager
if prompt_yes_no "Install Thunar file manager?"; then
	sudo pacman -S --noconfirm thunar
	check_status "Thunar installation"
fi

# Text editor
if prompt_yes_no "Install Neovim?"; then
	sudo pacman -S --noconfirm neovim
	check_status "Neovim installation"
fi

# Enable SDDM
echo -e "${GREEN}Enabling SDDM display manager...${NC}"
sudo systemctl enable sddm
check_status "SDDM enabling"

# Final message
echo -e "${GREEN}Installation complete! Reboot to start Hyprland.${NC}"
echo "You may want to copy your Hyprland/Waybar configs to ~/.config/ after reboot."
