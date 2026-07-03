# Usage Guide

> How to use Termux Bootstrap effectively — workflows, profiles, modules, and tips.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Working with Profiles](#working-with-profiles)
- [Managing Modules](#managing-modules)
- [Configuration Management](#configuration-management)
- [System Diagnostics](#system-diagnostics)
- [Update Management](#update-management)
- [Advanced Usage](#advanced-usage)
- [Workflows](#workflows)

---

## Getting Started

### Entry Point

All operations begin with `bootstrap.sh`:

```bash
./bootstrap.sh <command> [options]
```

### First Steps

```bash
# 1. Verify the environment is ready
./bootstrap.sh doctor

# 2. See what's available
./bootstrap.sh help

# 3. List available profiles
./bootstrap.sh list profiles

# 4. List available modules
./bootstrap.sh list modules

# 5. Preview an installation (dry-run)
./bootstrap.sh install --profile minimal --dry-run

# 6. Install your first profile
./bootstrap.sh install --profile minimal
```

### Understanding Output

```
[2026-07-03 10:30:45] [INFO]  [dispatcher.sh:42] Starting installation
[2026-07-03 10:30:46] [ OK ]  [installer_engine.sh:85] Module core/base installed
[2026-07-03 10:30:47] [WARN]  [packages.sh:120] Package already installed: git
[2026-07-03 10:30:48] [FAIL]  [packages.sh:45] Failed to install: python
```

| Prefix | Level | Meaning |
|--------|-------|---------|
| `[INFO]` | Blue | Informational message |
| `[ OK ]` | Green | Operation succeeded |
| `[WARN]` | Yellow | Non-critical issue |
| `[FAIL]` | Red | Error occurred |

---

## Working with Profiles

### List Available Profiles

```bash
# List all profiles with descriptions
./bootstrap.sh list profiles

# Verbose listing
./bootstrap.sh list profiles --verbose
```

### Install a Profile

```bash
# Install with dependency resolution
./bootstrap.sh install --profile developer

# Preview without installing
./bootstrap.sh install --profile developer --dry-run

# Install multiple profiles (if supported)
./bootstrap.sh install --profile developer --profile ai
```

### Profile Information

```bash
# Show profile metadata
./bootstrap.sh profile info developer

# List modules included in a profile
./bootstrap.sh profile list developer
```

### Remove a Profile

```bash
# Uninstall profile (removes associated packages)
./bootstrap.sh profile remove developer
```

---

## Managing Modules

### List Modules

```bash
# List all modules
./bootstrap.sh list modules

# Filter by category
./bootstrap.sh list modules --category cybersecurity

# Verbose output
./bootstrap.sh list modules --verbose
```

### Install Individual Modules

```bash
# Install a specific module
./bootstrap.sh install --module development/rust

# Install without dependencies
./bootstrap.sh install --module cybersecurity/pentest --no-deps

# Preview
./bootstrap.sh install --module development/rust --dry-run
```

### Module Information

```bash
# Show module metadata, dependencies, and packages
./bootstrap.sh module info development/rust
```

### Module States

| State | Meaning |
|-------|---------|
| Discovered | Module file exists in packages/ |
| Sourced | Module file has been loaded by the loader |
| Loaded | Module's install function has been registered |
| Installed | Module's install function has been executed |

---

## Configuration Management

### List Configurations

```bash
# List all managed configurations
./bootstrap.sh config list

# Show current config content
./bootstrap.sh config show git
```

### Validate Configurations

```bash
# Validate a single config
./bootstrap.sh config validate git

# Validate all configurations
./bootstrap.sh config validate --all
```

### Merge Configurations

```bash
# Merge a config from shipped defaults
./bootstrap.sh config merge git

# Overwrite (replace) existing config
./bootstrap.sh config merge git --overwrite

# Merge all configs
./bootstrap.sh config merge --all
```

### Config Status

```bash
# Check if a config is current
./bootstrap.sh config validate
```

Output:

| Status | Meaning |
|--------|---------|
| `not_installed` | No user config file found |
| `up_to_date` | User config matches shipped default |
| `modified` | User config differs from default |
| `missing` | Source template is absent |

---

## System Diagnostics

### Basic Diagnostics

```bash
./bootstrap.sh doctor
```

Checks:
- Termux environment
- Internet connectivity
- Required commands availability
- Storage setup
- Bash version

### Verbose Diagnostics

```bash
./bootstrap.sh doctor --verbose
```

Additional checks:
- Architecture detection
- Memory and storage info
- Shell configuration
- Capability registry state

### Reading the Report

The doctor command provides:
- **PASS/FAIL** for each check
- Suggestions for fixing failures
- Summary of environment capabilities

---

## Update Management

### Update Packages

```bash
# Update all installed packages
./bootstrap.sh update packages
```

### Update Framework

```bash
# Pull latest framework changes
./bootstrap.sh update framework

# This updates:
# - lib/ libraries
# - modules/ orchestration
# - commands/ CLI handlers
# - packages/ module definitions
```

### Update All

```bash
# Update repositories + packages + framework
./bootstrap.sh update all
```

### Update Repositories Only

```bash
# Refresh package repository metadata
./bootstrap.sh update repos
```

---

## Advanced Usage

### Dry-Run Mode

Preview installation without making changes:

```bash
./bootstrap.sh install --profile developer --dry-run
```

Dry-run shows:
- Which modules would be installed
- Which packages would be installed
- Dependency resolution order
- Configuration files that would be merged

### Verbose Mode

```bash
# Enable verbose output for a command
./bootstrap.sh doctor --verbose

# Enable debug-level logging
export LOG_LEVEL=DEBUG
./bootstrap.sh install --profile minimal
```

### Custom Log Level

```bash
# Set log level before running
export LOG_LEVEL=DEBUG
./bootstrap.sh module list

# Levels: DEBUG, INFO (default), WARNING, ERROR
```

### Batch Installation

```bash
# Install multiple modules at once
./bootstrap.sh install --module development/rust --module development/golang
```

---

## Workflows

### New Device Setup

```bash
# 1. Install Termux from F-Droid
# 2. Grant storage permission
termux-setup-storage

# 3. Install git and clone
pkg install git -y
git clone https://github.com/0xSECsh/termux-bootstrap.git
cd termux-bootstrap

# 4. Verify
./bootstrap.sh doctor

# 5. Install your profile
./bootstrap.sh install --profile developer

# 6. Apply configurations
./bootstrap.sh config merge --all

# 7. Restart shell
exec zsh
```

### Security Researcher Setup

```bash
# Install pentester profile
./bootstrap.sh install --profile pentester

# Add OSINT tools
./bootstrap.sh install --module cybersecurity/osint

# Add AI tools
./bootstrap.sh install --profile ai
```

### Developer Environment Setup

```bash
# Install full developer stack
./bootstrap.sh install --profile developer

# Verify installations
./bootstrap.sh doctor --verbose
```

### Minimal Setup (Limited Storage)

```bash
# Install only essentials
./bootstrap.sh install --profile minimal

# Add modules incrementally as needed
./bootstrap.sh install --module development/python
./bootstrap.sh install --module development/nodejs
```
