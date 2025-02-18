#!/bin/bash

# Function to ask user for confirmation before proceeding
ask_for_confirmation() {
    while true; do
        read -p "$1 (y/n): " choice
        case "$choice" in
            [Yy]*) return 0 ;;  # Proceed
            [Nn]*) return 1 ;;  # Skip
            *) echo "Please answer y or n." ;;
        esac
    done
}

# Ensure script runs as non-root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run as root"
    exit 1
fi

# Update macOS software
if ask_for_confirmation "Do you want to update macOS software? (recommended)"; then
    sudo softwareupdate --install --all
fi

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
    if ask_for_confirmation "Do you want to install Homebrew? (recommended)"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Install Git if not installed
if ! command -v git &>/dev/null; then
    if ask_for_confirmation "Do you want to install Git? (recommended)"; then
        brew install git
    fi
fi

# Install Applications using Homebrew Cask
APPS=(
    slack
    arc
    sublime-text
    cursor
    dbeaver-community
    sourcetree
    hey
    postman
    docker
    todoist
    avg-antivirus
    zoom
    core-tunnel
    chatgpt
)

for app in "${APPS[@]}"; do
    if ! brew list --cask $app &>/dev/null; then
        if ask_for_confirmation "Do you want to install $app? (recommended)"; then
            brew install --cask $app
        fi
    else
        echo "$app is already installed. Skipping..."
    fi
done

# Prompt user for details
echo "Enter your full name (for Git config):"
read FULL_NAME
echo "Enter your Bitbucket email:"
read BITBUCKET_EMAIL
echo "Enter your GitHub email:"
read GITHUB_EMAIL

# Generate SSH key if not exists
SSH_KEY="$HOME/.ssh/id_rsa"
if [ ! -f "$SSH_KEY" ]; then
    if ask_for_confirmation "Do you want to generate an SSH key? (recommended)"; then
        ssh-keygen -t rsa -b 4096 -C "$FULL_NAME@$(hostname)" -f "$SSH_KEY" -N ""
        eval "$(ssh-agent -s)"
        ssh-add "$SSH_KEY"
    fi
fi

# Print public key for user to copy
echo "Your SSH public key is:"
cat "$SSH_KEY.pub"

# Create development directories
DEV_DIR="$HOME/dev"
BITBUCKET_DIR="$DEV_DIR/bitbucket"
GITHUB_DIR="$DEV_DIR/github"

if ask_for_confirmation "Do you want to create development directories? (recommended)"; then
    mkdir -p "$DEV_DIR"
    [ ! -d "$BITBUCKET_DIR" ] && mkdir "$BITBUCKET_DIR"
    [ ! -d "$GITHUB_DIR" ] && mkdir "$GITHUB_DIR"
fi

# Configure Git for Bitbucket
BITBUCKET_SSH_KEY="$HOME/.ssh/id_rsa_bitbucket"
if [ ! -f "$BITBUCKET_SSH_KEY" ]; then
    if ask_for_confirmation "Do you want to generate an SSH key for Bitbucket? (recommended)"; then
        ssh-keygen -t rsa -b 4096 -C "$BITBUCKET_EMAIL" -f "$BITBUCKET_SSH_KEY" -N ""
        echo "Your Bitbucket SSH public key is:"
        cat "$BITBUCKET_SSH_KEY.pub"
    fi
fi

# Configure Git for GitHub
GITHUB_SSH_KEY="$HOME/.ssh/id_rsa_github"
if [ ! -f "$GITHUB_SSH_KEY" ]; then
    if ask_for_confirmation "Do you want to generate an SSH key for GitHub? (recommended)"; then
        ssh-keygen -t rsa -b 4096 -C "$GITHUB_EMAIL" -f "$GITHUB_SSH_KEY" -N ""
        echo "Your GitHub SSH public key is:"
        cat "$GITHUB_SSH_KEY.pub"
    fi
fi

# Add SSH keys to SSH agent
if ask_for_confirmation "Do you want to add SSH keys to the SSH agent? (recommended)"; then
    ssh-add "$BITBUCKET_SSH_KEY"
    ssh-add "$GITHUB_SSH_KEY"
fi

# Configure SSH for multiple Git accounts
SSH_CONFIG="$HOME/.ssh/config"
if ask_for_confirmation "Do you want to configure SSH for Bitbucket? (recommended)"; then
    if ! grep -q "Host bitbucket.org" "$SSH_CONFIG"; then
        cat <<EOL >> "$SSH_CONFIG"

Host bitbucket.org
    HostName bitbucket.org
    User git
    IdentityFile $BITBUCKET_SSH_KEY
EOL
    fi
fi

if ask_for_confirmation "Do you want to configure SSH for GitHub? (recommended)"; then
    if ! grep -q "Host github.com" "$SSH_CONFIG"; then
        cat <<EOL >> "$SSH_CONFIG"

Host github.com
    HostName github.com
    User git
    IdentityFile $GITHUB_SSH_KEY
EOL
    fi
fi

# Instructions for using SSH keys
echo "\n\nINSTRUCTIONS:\n"
echo "To add your SSH keys to Bitbucket:"
echo "1. Copy the following key:"
echo "\n"
cat "$BITBUCKET_SSH_KEY.pub"
echo "\n2. Go to https://bitbucket.org/account/settings/"
echo "3. Click 'SSH Keys' and add a new key."
echo "4. Paste the copied key and save."

echo "\nTo add your SSH key to GitHub:"
echo "1. Copy the following key:"
echo "\n"
cat "$GITHUB_SSH_KEY.pub"
echo "\n2. Go to https://github.com/settings/keys"
echo "3. Click 'New SSH Key' and add a new key."
echo "4. Paste the copied key and save."

# Final message
echo "\nSetup complete! Enjoy your new MacBook Pro."
