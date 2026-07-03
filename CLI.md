# CLI Reference

> Complete command-line reference for Termux Bootstrap.

---

## Table of Contents

- [Usage](#usage)
- [Global Options](#global-options)
- [Commands](#commands)
  - [help](#help)
  - [version](#version)
  - [doctor](#doctor)
  - [install](#install)
  - [update](#update)
  - [module](#module)
  - [profile](#profile)
  - [config](#config)
  - [list](#list)

---

## Usage

```bash
./bootstrap.sh <command> [options] [arguments]
```

Commands are discovered from `commands/<name>.sh` and dispatched by `lib/core/dispatcher.sh`.

---

## Global Options

Legacy options (supported for backward compatibility):

| Flag | Alternative | Purpose |
|------|-------------|---------|
| `--help` | `help` | Show help |
| `--version` | `version` | Show version |
| `--about` | `version --about` | Show project info |
| `--doctor` | `doctor` | Run diagnostics |
| `--profile <name>` | `install --profile <name>` | Install profile |
| `--module <name>` | `install --module <name>` | Install module |
| `--all` | `install --all` | Install all |
| `--list` | `list profiles` | List profiles |
| `--verbose` | `doctor --verbose` | Verbose output |
| `--debug` | (set `LOG_LEVEL=DEBUG`) | Debug output |

---

## help

Show help information for commands.

```bash
./bootstrap.sh help [command]
```

### Arguments

| Argument | Description |
|----------|-------------|
| *(none)* | Show general help with all commands |
| `<command>` | Show detailed help for a specific command |

### Options

| Flag | Description |
|------|-------------|
| `-a`, `--all` | Show detailed help for all commands |
| `-h`, `--help` | Show help for the help command itself |

### Examples

```bash
# General help
./bootstrap.sh help

# Command-specific help
./bootstrap.sh help install

# All command details
./bootstrap.sh help --all
```

### Output

General help lists all commands with descriptions. Command-specific help shows flags, arguments, and examples.

---

## version

Display version information, project details, and build info.

```bash
./bootstrap.sh version [options]
```

### Options

| Flag | Description |
|------|-------------|
| `-a`, `--about` | Show project info (author, repository, description) |
| `-b`, `--build` | Show build information (architecture, OS, kernel, shell) |
| `-h`, `--help` | Show help for version command |

### Examples

```bash
# Simple version
./bootstrap.sh version
# Output: Termux Bootstrap 0.1.0

# Project info
./bootstrap.sh version --about

# Full build info
./bootstrap.sh version --build
```

### Build Info

The `--build` flag displays:

- Architecture (aarch64, arm, x86_64)
- Operating system (Android/Linux)
- Kernel version
- Shell (bash version)
- Termux version (if applicable)

---

## doctor

Run system diagnostics and environment checks.

```bash
./bootstrap.sh doctor [options]
```

### Options

| Flag | Description |
|------|-------------|
| `-v`, `--verbose` | Show detailed diagnostic information |
| `-h`, `--help` | Show help for doctor command |

### Checks Performed

| Check | Description | Verbose Only |
|-------|-------------|:------------:|
| Termux environment | Verifies running in Termux | |
| Internet connectivity | Tests connection to 1.1.1.1 | |
| Required commands | Checks git, curl, bash versions | |
| Storage setup | Verifies Termux storage access | |
| Capability registry | Tests has() for common capabilities | ✓ |
| Architecture | Reports CPU architecture | ✓ |
| Memory | Reports available memory | ✓ |
| Storage | Reports available disk space | ✓ |
| Shell config | Checks shell version | ✓ |

### Examples

```bash
# Standard diagnostics
./bootstrap.sh doctor

# Detailed report
./bootstrap.sh doctor --verbose
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All checks passed |
| `1` | One or more checks failed |

---

## install

Install profiles or modules.

```bash
./bootstrap.sh install [options]
```

### Options

| Flag | Description |
|------|-------------|
| `-p`, `--profile <name>` | Install a profile |
| `-m`, `--module <name>` | Install a module |
| `-a`, `--all` | Install all available modules |
| `-h`, `--help` | Show help for install command |

### Adding `--dry-run`

Append `--dry-run` to any install command to preview changes without applying them.

### Examples

```bash
# Install a profile
./bootstrap.sh install --profile developer

# Install a module
./bootstrap.sh install --module development/rust

# Install multiple modules
./bootstrap.sh install --module development/rust --module development/golang

# Preview installation
./bootstrap.sh install --profile pentester --dry-run

# Install all modules
./bootstrap.sh install --all
```

### Module Path Format

Modules use the format `<category>/<name>`:

- `development/rust`
- `cybersecurity/pentest`
- `ai/ai`
- `core/base`

---

## update

Update packages, framework, or everything.

```bash
./bootstrap.sh update <subcommand> [options]
```

### Subcommands

| Subcommand | Description |
|------------|-------------|
| `all` | Update repositories, packages, and framework |
| `repos` | Update package repository metadata |
| `packages` | Upgrade all installed packages |
| `framework` | Pull latest framework code from git |

### Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help for update command |

### Examples

```bash
# Update everything
./bootstrap.sh update all

# Update only packages
./bootstrap.sh update packages

# Update framework
./bootstrap.sh update framework

# Update repositories
./bootstrap.sh update repos
```

---

## module

Manage modules — list, install, remove, and inspect.

```bash
./bootstrap.sh module <subcommand> [options]
```

### Subcommands

| Subcommand | Description |
|------------|-------------|
| `list` | List available or installed modules |
| `install` | Install a specific module |
| `remove` | Remove a module |
| `info` | Show detailed module information |

### Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help for module command |

### Examples

```bash
# List all modules
./bootstrap.sh module list

# Install a module
./bootstrap.sh module install cybersecurity/pentest

# Show module info
./bootstrap.sh module info development/rust

# Remove a module
./bootstrap.sh module remove development/nodejs
```

---

## profile

Manage profiles — list, install, remove, and inspect.

```bash
./bootstrap.sh profile <subcommand> [options]
```

### Subcommands

| Subcommand | Description |
|------------|-------------|
| `list` | List available profiles |
| `install` | Install a profile |
| `remove` | Remove a profile |
| `info` | Show detailed profile information |

### Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help for profile command |

### Examples

```bash
# List all profiles
./bootstrap.sh profile list

# Show profile info
./bootstrap.sh profile info developer

# Install a profile
./bootstrap.sh profile install pentester

# Remove a profile
./bootstrap.sh profile remove ai
```

---

## config

Manage configurations — show, list, edit, validate, and merge.

```bash
./bootstrap.sh config <subcommand> [options]
```

### Subcommands

| Subcommand | Description |
|------------|-------------|
| `show <app>` | Display config file content |
| `list` | List all managed configurations |
| `edit <app>` | Open config in editor |
| `reset <app>` | Reset config to defaults |
| `validate [app]` | Validate config file(s) |
| `merge <app>` | Merge shipped config into user config |

### Options

| Flag | Description |
|------|-------------|
| `--overwrite` | Overwrite existing config during merge |
| `--all` | Apply to all configurations |
| `-h`, `--help` | Show help for config command |

### Managed Applications

| App Key | Description | Path |
|---------|-------------|------|
| `git` | Git configuration | `~/.gitconfig` |
| `zsh` | ZSH shell config | `~/.zshrc` |
| `tmux` | TMUX terminal config | `~/.tmux.conf` |
| `micro` | Micro editor config | `~/.config/micro/` |
| `nvim` | Neovim editor config | `~/.config/nvim/` |
| `fastfetch` | Fastfetch system info | `~/.config/fastfetch/` |

### Examples

```bash
# List all configs
./bootstrap.sh config list

# Show git config
./bootstrap.sh config show git

# Validate all configs
./bootstrap.sh config validate --all

# Merge git config (preserve customizations)
./bootstrap.sh config merge git

# Overwrite git config
./bootstrap.sh config merge git --overwrite

# Merge all configs
./bootstrap.sh config merge --all

# Edit git config
./bootstrap.sh config edit git
```

### Config Status

After `config validate`, each config shows:

| Status | Meaning |
|--------|---------|
| `not_installed` | No user config exists |
| `up_to_date` | User config matches shipped default |
| `modified` | User config has been customized |
| `missing` | Source template is missing |

---

## list

List profiles, modules, or installed items.

```bash
./bootstrap.sh list <target> [options]
```

### Targets

| Target | Description |
|--------|-------------|
| `profiles` | List all available profiles |
| `modules` | List all available modules |
| `installed` | List installed profiles/modules |

### Options

| Flag | Description |
|------|-------------|
| `-c`, `--category <name>` | Filter by category (modules only) |
| `-v`, `--verbose` | Show detailed information |
| `-h`, `--help` | Show help for list command |

### Examples

```bash
# List all profiles
./bootstrap.sh list profiles

# List all modules (verbose)
./bootstrap.sh list modules --verbose

# Filter modules by category
./bootstrap.sh list modules --category cybersecurity

# List installed items
./bootstrap.sh list installed
```
