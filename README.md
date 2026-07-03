
<p align="center">
  <img src="assets/banner.png" alt="Termux Bootstrap" width="600">
</p>

<p align="center">
  <strong>A professional bootstrap framework for building a complete Termux environment</strong>
  <br>
  Cybersecurity · Development · OSINT · AI · Mobile Research
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/bash-5.0%2B-4EAA25?logo=gnubash&logoColor=white" alt="Bash 5.0+"></a>
  <a href="#"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
  <a href="#"><img src="https://img.shields.io/badge/platform-termux-green?logo=android&logoColor=white" alt="Platform: Termux"></a>
  <a href="#"><img src="https://img.shields.io/badge/tests-428%20passing-brightgreen" alt="Tests: 428 passing"></a>
  <a href="#"><img src="https://img.shields.io/badge/lint-shellcheck-brightgreen" alt="ShellCheck"></a>
  <a href="#"><img src="https://img.shields.io/badge/style-shfmt-blue" alt="shfmt"></a>
</p>

---

## Overview

Termux Bootstrap automates the installation and configuration of a reproducible, modular Termux environment. Instead of manually installing dozens of packages every time you set up a new device, this project recreates your entire environment with a single command.

Built on a professional-grade Bash framework with dependency resolution, rollback support, structured logging, and comprehensive test coverage (428 tests, zero failures).

---

## Features

- **One-Command Installation** — Single command to install any profile
- **Modular Architecture** — 17 composable modules across 5 categories
- **13 Pre-Built Profiles** — Developer, Pentester, OSINT, AI, and more
- **Dependency Resolution** — Automatic module dependency ordering with cycle detection
- **Rollback Support** — Safe installation with automatic rollback on failure
- **Dry-Run Mode** — Preview changes before applying them
- **Structured Logging** — Timestamped, leveled logs with caller context
- **Comprehensive Config Management** — Merge, validate, and manage dotfiles
- **System Diagnostics** — Built-in doctor command for troubleshooting
- **Cache System** — TTL-based caching for downloads and metadata
- **428 Passing Tests** — BATS-based test suite with regression coverage

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/0xSECsh/termux-bootstrap.git
cd termux-bootstrap

# Run diagnostics
./bootstrap.sh doctor

# Install a profile (e.g., development)
./bootstrap.sh install --profile developer

# Or use the CLI interactively
./bootstrap.sh help
```

---

## Profiles

| Profile | Description | Included Modules |
|---------|-------------|-----------------|
| `minimal` | Essential base packages | core/base |
| `dev` | Base + editors | core/base, core/editors |
| `full` | Core + shell enhancements | core/base, core/shell |
| `developer` | Full development stack | core/* + development/* |
| `pentester` | Penetration testing toolkit | core/* + cybersecurity/pentest, recon, wireless, threat-hunting |
| `osint` | OSINT investigation tools | core/* + cybersecurity/osint, recon |
| `reverse` | Reverse engineering | core/* + cybersecurity/reverse, mobile |
| `ai` | AI and ML environment | core/*, development/python, ai/ai |
| `dry` | Dry-run validation | core/base |

---

## CLI Commands

| Command | Description |
|---------|-------------|
| `help [command]` | Show help for any command |
| `version` | Display version and build info |
| `doctor` | Run system diagnostics |
| `install` | Install profiles or modules |
| `update` | Update packages or framework |
| `module` | Manage modules (list, install, remove, info) |
| `profile` | Manage profiles (list, install, remove, info) |
| `config` | Manage configuration (show, list, edit, validate, merge) |
| `list` | List profiles, modules, or installed items |

---

## Project Structure

```
termux-bootstrap/
├── bootstrap.sh              # Entry point — CLI dispatcher
├── commands/                 # CLI command handlers
├── lib/                      # Framework libraries
│   ├── core/                 #   Core: constants, environment, errors, CLI, dispatcher
│   ├── system/               #   System: packages, validation, capabilities
│   ├── terminal/             #   Terminal: colors, logging, progress, UI, spinner
│   └── utils/                #   Utilities: filesystem, download, cache, hash, string
├── modules/                  # Orchestration: loaders, registries, config_engine, installer_engine
├── packages/                 # Domain modules organized by category
│   ├── core/                 #   Base system modules
│   ├── development/          #   Language runtimes and tooling
│   ├── cybersecurity/        #   Security tools
│   ├── ai/                   #   AI/ML packages
│   └── profiles/             #   Profile definitions
├── tests/                    # BATS test suite (428 tests)
├── configs/                  # Shipped dotfiles
├── scripts/                  # Standalone utility scripts
├── tools/                    # Release and validation tooling
└── docs/                     # Documentation
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture and design decisions |
| [INSTALL.md](INSTALL.md) | Detailed installation guide |
| [USAGE.md](USAGE.md) | Usage and workflows |
| [MODULES.md](MODULES.md) | Module reference |
| [PROFILES.md](PROFILES.md) | Profile reference |
| [CONFIGURATION.md](CONFIGURATION.md) | Configuration system reference |
| [CLI.md](CLI.md) | CLI command reference |
| [TESTING.md](TESTING.md) | Testing guide |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Development guide |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines |
| [SECURITY.md](SECURITY.md) | Security policy |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [FAQ.md](FAQ.md) | Frequently asked questions |
| [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) | Release engineering playbook |
| [AGENTS.md](AGENTS.md) | Development conventions (AI-assisted) |
| [SUPPORT.md](SUPPORT.md) | Support and community resources |
| [ROADMAP.md](ROADMAP.md) | Future plans |

---

## Requirements

- **Termux** (Android) or a Linux environment with Bash 5.0+
- `git`, `curl`, or `wget` for installation
- Approximately 100 MB of storage for base profile (varies by profile)

---

## License

MIT License — see [LICENSE.md](LICENSE.md)

---

<p align="center">
  Built with ♥ by <a href="https://github.com/0xSECsh">0xSEC</a>
</p>
