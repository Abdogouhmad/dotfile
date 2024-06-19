#!/usr/bin/env bash
# colors
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
NC='\033[0m' 

# print function 
function cprintln() {
    local color=$1
    local message=$2
    local nc=$NC
    echo -e "${color}${message}${nc}"
}

# install the needed packages
function install_packages() {
    # print colored msg
    cprintln "${MAGENTA}" "Installing packages..."

    PACKAGES=(
        # Important for sys
        "kitty"
        "polybar"
        "picom"
        "zsh"
        "starship" # shell prompt
        "git"
        "dunst"
        "thunar"
        "xorg"
        "xorg-xinit"
        "xorg-server"
        "playerctl"
        # tools
        "xdotool"
        "maim"
        "htop"
        "neofetch"
        "curl"
        "tree"
        "xclip"
        "fzf"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "wget"
        # media
        "feh"
        "mpv"
        "viewnior"
        "atril"
        # fonts
        "ttf-jetbrains-mono-nerd"
        # internet
        "firefox"
        "uget" # internet download manager
        # programming
        "vim"
        "helix" # GF text editor 
        # languages
        "rust"
        "clang"
        "nodejs"
        "python"
        # lsps
        "bash-language-server"
        "pyright"
        "typescript-language-server"
        # dev tools
        "docker"
        "terraform"
        # entertainment
        "discord"
        "telegram-desktop"
        "obsidian"
        "spotify"
    )

    for package in "${PACKAGES[@]}"; do
        sudo pacman -S "$package" --noconfirm
        if [ $? -ne 0 ]; then
            cprintln "${RED}" "Failed to install $package"
            exit 1
        fi
    done

    cprintln "${GREEN}" "Packages installed"
}

# step yay
function step_yay() {
    cprintln "${YELLOW}" "Installing yay..."
    # install needed development tools
    sudo pacman -S --needed git base-devel xorg --noconfirm
    if [ $? -ne 0 ]; then
        cprintln "${RED}" "Failed to install development tools"
        exit 1
    fi

    # clone yay from AUR
    git clone https://aur.archlinux.org/yay.git || { cprintln "${RED}" "Failed to clone yay"; exit 1; }
    cd yay || { cprintln "${RED}" "Failed to enter yay directory"; exit 1; }
    makepkg -si || { cprintln "${RED}" "Failed to build yay"; exit 1; }
    yay -Sua --noconfirm || { cprintln "${RED}" "Failed to update with yay"; exit 1; }
    cprintln "${GREEN}" "yay installed"
}

# yay packages
function yay_packages() {
    YAY_PACKAGES=(
        "stremio"
    )
    cprintln "${YELLOW}" "Installing yay packages..."
    for package in "${YAY_PACKAGES[@]}"; do
        yay -S "$package" --noconfirm
        if [ $? -ne 0 ]; then
            cprintln "${RED}" "Failed to install $package with yay"
            exit 1
        fi
    done
    cprintln "${GREEN}" "yay packages installed"
}

# create bspwm folder in config and cp default config in usr/share
function create_bspwm() {
    cprintln "${YELLOW}" "Creating bspwm folder..."
    mkdir -p "$HOME/.config/bspwm"
    cp /usr/share/doc/bspwm/examples/bspwmrc "$HOME/.config/bspwm/bspwmrc" || { cprintln "${RED}" "Failed to copy bspwmrc"; exit 1; }
    curl -o "$HOME/.config/bspwm/sxhkdrc" https://raw.githubusercontent.com/Abdogouhmad/dotfile/main/bspwm/sxhkdrc || { cprintln "${RED}" "Failed to copy sxhkdrc"; exit 1; }
    cprintln "${GREEN}" "bspwm folder created"
}

# create polybar folder in config and cp default config in usr/share
function create_polybar() {
    cprintln "${YELLOW}" "Creating polybar folder..."
    mkdir -p "$HOME/.config/polybar"
    cp /usr/share/doc/polybar/examples/config.ini "$HOME/.config/polybar/" || { cprintln "${RED}" "Failed to copy polybar config"; exit 1; }
    cprintln "${GREEN}" "polybar folder created"
}

# dunst clone the repo for dunst notification
function create_dunst() {
    cprintln "${YELLOW}" "Creating dunst folder..."
    mkdir -p "$HOME/.config/dunst"
    curl -o "$HOME/.config/dunst/dunstrc" https://raw.githubusercontent.com/Abdogouhmad/dotfile/main/config/dunstrc || { cprintln "${RED}" "Failed to download dunstrc"; exit 1; }
    cprintln "${GREEN}" "dunst folder created"
}

# create helix folder in config and curl the config
function create_helix() {
    cprintln "${YELLOW}" "Creating helix folder..."
    mkdir -p "$HOME/.config/helix"
    curl -o "$HOME/.config/helix/config.toml" https://raw.githubusercontent.com/Abdogouhmad/dotfile/main/config/helix/config.toml || { cprintln "${RED}" "Failed to download helix config"; exit 1; }
    curl -o "$HOME/.config/helix/languages.toml" https://raw.githubusercontent.com/Abdogouhmad/dotfile/main/config/helix/languages.toml || { cprintln "${RED}" "Failed to download helix languages config"; exit 1; }
    cprintln "${GREEN}" "helix folder created"
}

# create kitty folder in config and curl the configs
function create_kitty() {
    cprintln "${YELLOW}" "Creating kitty folder..."
    mkdir -p "$HOME/.config/kitty"
    curl -o "$HOME/.config/kitty/kitty.conf" https://raw.githubusercontent.com/Abdogouhmad/dotfile/main/config/kitty/kitty.conf || { cprintln "${RED}" "Failed to download kitty config"; exit 1; }
    curl -o "$HOME/.config/kitty/theme.conf" https://raw.githubusercontent.com/Abdogouhmad/dotfile/main/config/kitty/theme.conf || { cprintln "${RED}" "Failed to download kitty theme"; exit 1; }
    cprintln "${GREEN}" "kitty folder created"
}

# call the functions
install_packages
step_yay
yay_packages
create_bspwm
create_polybar
create_dunst
create_helix
create_kitty
