# Installation Guide

> Prerequisites, installation methods, and upgrade procedures for Termux Bootstrap.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
- [Post-Installation](#post-installation)
- [Upgrade](#upgrade)
- [Uninstall](#uninstall)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required

- **Termux** from [F-Droid](https://f-droid.org/packages/com.termux/) (recommended) or Google Play
- **Storage permission** enabled: `termux-setup-storage`
- **Internet connection** for package downloads
- **Bash 5.0+** (default in modern Termux)

### Recommended

- Git: `pkg install git`
- Storage access: `termux-setup-storage`
- At least 500 MB free space (varies by profile)

### Verify Your Environment

```bash
# Check Termux version
termux-info | head -5

# Check Bash version
bash --version

# Check storage setup
ls ~/storage
```

---

## Installation Methods

### Method 1: Git Clone (Recommended)

```bash
# Update package lists
pkg update && pkg upgrade -y

# Install git if not present
pkg install git -y

# Clone the repository
git clone https://github.com/0xSECsh/termux-bootstrap.git

# Enter the directory
cd termux-bootstrap

# Run system diagnostics
./bootstrap.sh doctor

# Install your desired profile
./bootstrap.sh install --profile developer
```

### Method 2: Download Archive

```bash
# Download the latest release
curl -LO https://github.com/0xSECsh/termux-bootstrap/releases/latest/download/termux-bootstrap.tar.gz

# Extract
tar xzf termux-bootstrap.tar.gz

# Enter the directory
cd termux-bootstrap

# Verify and install
./bootstrap.sh doctor
./bootstrap.sh install --profile minimal
```

### Method 3: Quick Install (Future)

```bash
# One-liner (once available)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/0xSECsh/termux-bootstrap/main/install.sh)"
```

---

## Post-Installation

After installing a profile, you can:

### Verify Installation

```bash
# Run doctor to verify everything
./bootstrap.sh doctor --verbose

# List installed modules
./bootstrap.sh list installed

# Check configuration status
./bootstrap.sh config validate
```

### Apply Dotfiles

```bash
# Merge all configuration files
./bootstrap.sh config merge --all

# Check configuration status
./bootstrap.sh config list
```

### Configure Your Environment

```bash
# Set default shell (if ZSH was installed)
chsh -s zsh

# Restart shell for changes to take effect
exec zsh
```

---

## Upgrade

### Upgrade the Framework

```bash
# Update the framework code
./bootstrap.sh update framework

# Or manually via git
git pull origin main

# Re-run doctor after update
./bootstrap.sh doctor
```

### Upgrade Packages

```bash
# Upgrade all installed packages
./bootstrap.sh update packages

# Upgrade everything
./bootstrap.sh update all
```

### Upgrade Repositories

```bash
# Update package repository lists
./bootstrap.sh update repos
```

---

## Uninstall

### Remove a Profile

```bash
# Uninstall a specific profile
./bootstrap.sh profile remove developer
```

### Complete Uninstall

```bash
# Run the uninstaller (once implemented)
./uninstall.sh

# Or manually:
# 1. Remove framework directory
rm -rf ~/termux-bootstrap

# 2. Remove framework data
rm -rf ~/.local/share/termux-bootstrap
rm -rf ~/.config/termux-bootstrap
rm -rf ~/.cache/termux-bootstrap

# 3. Remove installed packages (selectively)
# List what was installed:
cat ~/.local/share/termux-bootstrap/logs/install.log | grep "Installing"
```

---

## Troubleshooting

### Doctor Reports Issues

```bash
# Run verbose diagnostics
./bootstrap.sh doctor --verbose

# Check specific capability
./bootstrap.sh doctor | grep capability
```

### Installation Fails

```bash
# Try dry-run first to preview
./bootstrap.sh install --profile developer --dry-run

# Check the error log
cat ~/.local/share/termux-bootstrap/logs/error.log

# Check the main log
cat ~/.local/share/termux-bootstrap/logs/install.log
```

### Common Issues

**Issue:** "Permission denied" errors
**Solution:** Run `termux-setup-storage` and ensure storage permission is granted.

**Issue:** "Command not found" after installation
**Solution:** Restart your shell session: `exec bash` or `exec zsh`

**Issue:** Package installation fails
**Solution:** 
```bash
pkg update -y
pkg upgrade -y
# Then retry
```
