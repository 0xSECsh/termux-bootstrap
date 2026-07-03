# Configuration Reference

> Complete reference for the Termux Bootstrap configuration system, environment variables, and dotfile management.

---

## Table of Contents

- [Overview](#overview)
- [Environment Variables](#environment-variables)
- [Framework Directory Structure](#framework-directory-structure)
- [Configuration Engine](#configuration-engine)
- [Managed Configurations](#managed-configurations)
- [Config File States](#config-file-states)
- [Merge Modes](#merge-modes)
- [Custom Configuration](#custom-configuration)
- [User Configuration](#user-configuration)

---

## Overview

Termux Bootstrap has a two-tier configuration system:

1. **Environment Variables** — Control framework behavior at runtime
2. **Managed Configurations** — Dotfiles and app configs managed by the configuration engine

---

## Environment Variables

### Framework Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LOG_LEVEL` | `INFO` | Logging verbosity: `DEBUG`, `INFO`, `WARNING`, `ERROR` |
| `FORCE_COLOR` | (unset) | Force color output even in non-TTY (`1` to enable) |
| `NO_COLOR` | (unset) | Disable color output (`1` to disable) |

### Runtime Directories

These are determined at initialization by `lib/core/constants.sh`:

| Variable | Default Path | Purpose |
|----------|-------------|---------|
| `HOME_DIR` | `$HOME` | User home directory |
| `CONFIG_DIR` | `$HOME/.config/termux-bootstrap` | Framework configuration |
| `CONFIGS_DIR` | `<project>/configs/` | Shipped default configurations |
| `CACHE_DIR` | `$HOME/.cache/termux-bootstrap` | Cached data |
| `DATA_DIR` | `$HOME/.local/share/termux-bootstrap` | Persistent data |
| `LOG_DIR` | `$DATA_DIR/logs` | Log files |
| `BACKUP_DIR` | `$DATA_DIR/backup` | Backup storage |
| `TEMP_DIR` | `/tmp/termux-bootstrap.$$` | Temporary files |

### Log Files

| Variable | Path | Contents |
|----------|------|----------|
| `LOG_FILE` | `$LOG_DIR/install.log` | All log entries |
| `ERROR_LOG` | `$LOG_DIR/error.log` | Errors only |

### Package Managers

| Variable | Default | Purpose |
|----------|---------|---------|
| `PKG_MANAGER` | `pkg` | System package manager |
| `PIP_MANAGER` | `pip` | Python package manager |
| `NPM_MANAGER` | `npm` | Node.js package manager |
| `CARGO_MANAGER` | `cargo` | Rust package manager |
| `GO_MANAGER` | `go` | Go package manager |

### Exit Codes

| Variable | Value | Meaning |
|----------|-------|---------|
| `EXIT_SUCCESS` | `0` | Success |
| `EXIT_FAILURE` | `1` | General failure |
| `EXIT_INVALID_ARGUMENT` | `2` | Invalid CLI argument |
| `EXIT_DEPENDENCY_ERROR` | `3` | Missing dependency |
| `EXIT_NETWORK_ERROR` | `4` | Network failure |
| `EXIT_PERMISSION_ERROR` | `5` | Permission denied |
| `EXIT_INTERRUPTED` | `130` | User interrupt (SIGINT) |

### Defaults

| Variable | Default | Purpose |
|----------|---------|---------|
| `DEFAULT_TIMEOUT` | `30` | Default timeout in seconds |
| `DEFAULT_RETRIES` | `3` | Default retry count |
| `DEFAULT_LOG_LEVEL` | `INFO` | Default logging level |
| `DEFAULT_EDITOR` | `micro` | Default text editor |
| `DEFAULT_SHELL` | `zsh` | Default shell |

### Boolean Constants

| Variable | Value | Meaning |
|----------|-------|---------|
| `TRUE` | `0` | Success / true |
| `FALSE` | `1` | Failure / false |

### Architecture

| Variable | Value | Meaning |
|----------|-------|---------|
| `ARCH_ARM64` | `aarch64` | ARM 64-bit |
| `ARCH_ARM` | `arm` | ARM 32-bit |
| `ARCH_X86_64` | `x86_64` | Intel/AMD 64-bit |

---

## Framework Directory Structure

```
$HOME/
├── .config/
│   └── termux-bootstrap/        # Framework configuration
│       └── user.yaml             # User configuration overrides
│
├── .cache/
│   └── termux-bootstrap/        # Cached data
│       └── <module>/            # Per-module caches
│
└── .local/
    └── share/
        └── termux-bootstrap/
            ├── logs/
            │   ├── install.log   # Main log file
            │   └── error.log     # Error log file
            └── backup/           # Configuration backups
```

---

## Configuration Engine

The configuration engine (`modules/config_engine.sh`) manages application dotfiles through a unified registry.

### Config Path Map

The engine maps application names to filesystem paths:

| App Key | Resolved Path |
|---------|---------------|
| `zsh` | `~/.zshrc` |
| `git` | `~/.gitconfig` |
| `tmux` | `~/.tmux.conf` |
| `nvim` | `~/.config/nvim/<file>` |
| `micro` | `~/.config/micro/<file>` |
| `fastfetch` | `~/.config/fastfetch/<file>` |

### Engine Functions

| Function | Purpose |
|----------|---------|
| `config_resolve_path()` | Resolve app key to filesystem path |
| `config_exists()` | Check if config exists in registry |
| `config_list()` | List all managed configs |
| `config_count()` | Count managed configs |
| `config_read()` | Read config file content |
| `config_read_key()` | Read specific key (INI-style, supports sections) |
| `config_write()` | Write content to config path |
| `config_write_key()` | Write or update a key=value pair |
| `config_validate()` | Validate a single config |
| `config_validate_all()` | Validate all configs |
| `config_merge()` | Merge source into user config |
| `config_merge_all()` | Merge all configs |
| `config_status()` | Get config status |
| `config_info()` | Get full config metadata |

---

## Managed Configurations

### Git Configuration

**Shipped file:** `configs/git/.gitconfig`
**User path:** `~/.gitconfig`

Default settings:

```ini
[user]
    email = your-email@example.com
    name = your-username
[core]
    editor = micro
    pager = less
[init]
    defaultBranch = main
[push]
    default = current
[pull]
    rebase = true
```

### TMUX Configuration

**Shipped file:** `configs/tmux/.tmux.conf`
**User path:** `~/.tmux.conf`

Default settings:

```
set -g prefix C-a
set -g mouse on
set -g history-limit 5000
set -g default-terminal screen-256color
```

### ZSH Configuration

**Shipped file:** `configs/zsh/.zshrc`
**User path:** `~/.zshrc`

Default settings:

```zsh
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history
setopt share_history
```

---

## Config File States

The engine tracks each config file through four states:

```
not_installed ──┬──> up_to_date
                │
                └──> missing ──> (if source restored)
```

| State | CLI Output | Meaning | Action Needed |
|-------|------------|---------|---------------|
| `not_installed` | 🔴 Not installed | No user config exists | Run `config merge` |
| `up_to_date` | 🟢 Up to date | User config matches source | None |
| `modified` | 🟡 Modified | User config differs | Run `config merge --overwrite` to reset |
| `missing` | ⚫ Missing | Source template is missing | Check source template exists |

---

## Merge Modes

### Normal Merge

```bash
./bootstrap.sh config merge git
```

- Adds lines from source that don't exist in the user config
- Preserves existing customizations
- Safe for already-configured environments

### Overwrite Merge

```bash
./bootstrap.sh config merge git --overwrite
```

- Replaces the user config entirely with the source
- Useful for resetting to defaults
- Creates a backup of the previous config

---

## Custom Configuration

### User Config File

Create `~/.config/termux-bootstrap/user.yaml` to override framework settings:

```yaml
# user.yaml — Framework configuration overrides
log_level: DEBUG
default_editor: nvim
default_shell: zsh
```

### Setting Environment Variables

```bash
# Per-session configuration
export LOG_LEVEL=DEBUG
./bootstrap.sh install --profile developer

# Persistent configuration (add to ~/.zshrc or ~/.bashrc)
echo 'export DEFAULT_EDITOR="nvim"' >> ~/.zshrc
```

### Configuring Modules

Modules read configuration from the environment. For example:

```bash
# Customize Python module behavior
export PYTHON_PACKAGES="numpy pandas scipy"
./bootstrap.sh install --module development/python
```

---

## Runtime State Variables

These internal variables track framework state:

| Variable | Guard For | Set By |
|----------|-----------|--------|
| `TERMUX_BOOTSTRAP_COMMON_LOADED` | Double-loading `common.sh` | `common.sh` |
| `ENVIRONMENT_INITIALIZED` | Reinitializing environment | `environment.sh` |
| `TERMINAL_INITIALIZED` | Reinitializing terminal | `terminal.sh` |
| `ERROR_HANDLERS_REGISTERED` | Double-registering signal handlers | `errors.sh` |
| `TEMP_CLEANUP_TRAP_SET` | Double-setting cleanup trap | `temp.sh` |
| `LOADED_LIBRARIES` | Tracking loaded library files | `common.sh` |
| `_INSTALLER_ROLLBACK_STACK` | Installation rollback | `installer_engine.sh` |
| `_CONFIG_PATH_MAP` | Config path resolution | `config_engine.sh` |

These are internal and should not be modified directly.
