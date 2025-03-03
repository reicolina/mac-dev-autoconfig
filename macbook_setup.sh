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
    visual-studio-code
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
    mongodb-compass
    google-chrome
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

# Prompt user for details only if needed
if [ ! -f "$SSH_KEY" ] || [ ! -f "$BITBUCKET_SSH_KEY" ] || [ ! -f "$GITHUB_SSH_KEY" ]; then
    if ask_for_confirmation "Do you want to set up Git user details? (recommended)"; then
        if [ ! -f "$SSH_KEY" ]; then
            echo "Enter your full name (for Git config):"
            read FULL_NAME
        fi
        
        if [ ! -f "$BITBUCKET_SSH_KEY" ]; then
            echo "Enter your Bitbucket email:"
            read BITBUCKET_EMAIL
        fi
        
        if [ ! -f "$GITHUB_SSH_KEY" ]; then
            echo "Enter your GitHub email:"
            read GITHUB_EMAIL
        fi
    else
        echo "Skipping Git user details setup..."
    fi
fi

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

if ask_for_confirmation "Do you want to configure Git global settings? (recommended)"; then
    # Configure Git globally
    git config --global user.name "$FULL_NAME"
    git config --global user.email "$GITHUB_EMAIL"

    # Configure Git for specific directories
    git config --global includeIf.gitdir:~/dev/bitbucket/.path ~/.gitconfig-bitbucket
    echo "[user]
        email = $BITBUCKET_EMAIL" > ~/.gitconfig-bitbucket

    git config --global includeIf.gitdir:~/dev/github/.path ~/.gitconfig-github
    echo "[user]
        email = $GITHUB_EMAIL" > ~/.gitconfig-github
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

# Instructions for Dev Container extension
echo "\nTo install the Dev Container extension in Cursor:"
echo "1. Download the extension from:"
echo "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode-remote/vsextensions/remote-containers/0.397.0/vspackage"
echo "2. Open Cursor"
echo "3. Press Cmd+Shift+P and type 'Install from VSIX'"
echo "4. Select the downloaded .vsix file"
echo "5. Restart Cursor when prompted"

# Final message
echo "\nSetup complete! Enjoy your new MacBook Pro."
