# mac-dev-autoconfig

## Overview
This script automates the setup of a new **MacBook Pro** for developers, installing essential applications, setting up SSH keys, and configuring Git for **GitHub** and **Bitbucket**.

## Features
- **Interactive Setup**: Users can confirm each step before proceeding.
- **Essential Installations**:
  - Installs **Homebrew** and **Git** if not present.
  - Installs key development applications like **Slack, Arc, Sublime Text, Cursor AI, DBeaver, Sourcetree, Hey, Postman, Docker Desktop, Todoist, AVG, Zoom, and Core Tunnel**.
- **SSH Key Management**:
  - Generates SSH keys for **Bitbucket** and **GitHub** (if they don’t exist).
  - Configures SSH settings for seamless Git operations.
- **Git Configuration**:
  - Creates a `~/dev` directory with `bitbucket` and `github` subdirectories.
  - Ensures Git commands use the correct identity for each directory.
- **Step-by-Step Instructions**: Guides users in adding SSH keys to **GitHub** and **Bitbucket**.

## Installation (For a Brand-New MacBook)
If Git is not installed, follow these steps:

1. Open **Terminal** (Press `Cmd + Space`, type **Terminal**, and hit **Enter**).
2. Download the script manually:
   ```bash
   curl -O https://raw.githubusercontent.com/reicolina/mac-dev-autoconfig/main/macbook_setup.sh
   ```

3. Make the script executable:
   ```bash
   chmod +x macbook_setup.sh
   ```

4. Run the script:
   ```bash
   ./macbook_setup.sh
   ```

## Usage
- Follow the **interactive prompts** to customize your setup.
- When SSH keys are generated, **copy and paste** the public keys into **GitHub** and **Bitbucket** as instructed.

## Adding SSH Keys
Once the setup is complete, follow these steps to add your SSH keys:

### GitHub
1. Copy your GitHub SSH key:
   ```bash
   cat ~/.ssh/id_rsa_github.pub
   ```
2. Go to [GitHub SSH Keys Settings](https://github.com/settings/keys).
3. Click **New SSH Key**, paste the copied key, and save.

### Bitbucket
1. Copy your Bitbucket SSH key:
   ```bash
   cat ~/.ssh/id_rsa_bitbucket.pub
   ```
2. Go to [Bitbucket SSH Keys Settings](https://bitbucket.org/account/settings/).
3. Click **SSH Keys**, paste the copied key, and save.

## Contribution
Feel free to submit pull requests or issues to enhance this script.

## License
This project is licensed under the **MIT License**.

