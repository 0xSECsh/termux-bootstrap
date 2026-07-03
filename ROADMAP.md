# Roadmap

> Future development plans for Termux Bootstrap.

---

## Overview

Termux Bootstrap is in its early stages (v0.1.0). The roadmap below outlines the major milestones planned for future releases. Priorities may shift based on community feedback and contributor availability.

---

## Legend

| Icon | Meaning |
|:----:|---------|
| ✅ | Completed |
| 🚧 | In progress |
| 📋 | Planned |
| 💡 | Proposed |

---

## Phase 1: Foundation (v0.1.0) ✅

### Core Framework

- ✅ Framework initialization pipeline
- ✅ Library loader with double-load guards
- ✅ CLI dispatcher with extensible commands
- ✅ Environment setup (directories, logs, variables)
- ✅ Error handling framework (die, panic, assertions)
- ✅ Structured logging with levels and file output
- ✅ System diagnostics (doctor command)
- ✅ Terminal utilities and UI components

### Module System

- ✅ Dynamic module discovery from `packages/`
- ✅ Module loading with dependency resolution
- ✅ Cycle detection in dependency graphs
- ✅ State tracking (discovered, sourced, loaded, ran)

### Profile System

- ✅ Dynamic profile discovery from `packages/profiles/`
- ✅ Profile loading with deduplication

### Configuration Engine

- ✅ Config path resolution (6 managed apps)
- ✅ Config read/write/merge/validate
- ✅ Config status tracking (4 states)
- ✅ Merge modes (smart merge, overwrite)

### Installer Engine

- ✅ Dry-run mode for preview
- ✅ Rollback stack on failure
- ✅ Package tracking and deduplication
- ✅ Progress bar integration

### Testing

- ✅ BATS test suite (428 tests)
- ✅ Test helpers: assertions, fixtures, mocks
- ✅ Test isolation framework

### CI/CD

- ✅ GitHub Actions: push, PR, nightly, release workflows

### Documentation

- ✅ 16 documentation files (README through LICENSE)

---

## Phase 2: Stability & Coverage (v0.2.0) 🚧

- 📋 **Increase test coverage** to 70%+ line coverage (currently ~40%)
- 📋 **Complete stub modules** — Implement core/base, core/editors, core/shell, core/utils, development/python, development/nodejs with real package lists
- 📋 **Complete stub profiles** — Implement base, mobile, researcher profiles
- 📋 **Add module/stub tests** for `module_dependencies.sh` and `module_runner.sh`
- 📋 **Cross-bash-version testing** — Test against Bash 4.4, 5.0, 5.1, 5.2 in CI
- 📋 **Performance benchmarks** — Track framework initialization time, module loading time
- 📋 **Shell completion** — Add tab completion for bootstrap.sh commands

---

## Phase 3: Features (v0.3.0)

- 📋 **Backup & restore** — Implement `scripts/backup.sh` and `scripts/restore.sh` with full backup/restore of profiles, configs, and packages
- 📋 **Update system** — Complete `scripts/update.sh` with git-based framework updates
- 📋 **Uninstall system** — Complete `uninstall.sh` with profile/package removal
- 📋 **Environment validation** — Pre-installation validation of disk space, dependencies, network
- 📋 **Offline mode** — Support installation from cached packages
- 📋 **Progress reporting** — Detailed installation reports with timing

---

## Phase 4: Profiles & Modules (v0.4.0)

- 💡 **New profiles:**
  - Cloud — Cloud CLI tools (aws-cli, gcloud, azure-cli)
  - ML — Machine learning profile with TensorFlow, PyTorch
  - CTF — Competition-focused tools
  - Homework — Academic tools and utilities
- 💡 **New modules:**
  - `development/database` — SQLite, PostgreSQL client, MySQL client
  - `development/docker` — Docker-specific tooling (docker-compose, docker-buildx)
  - `cybersecurity/forensics` — Digital forensics tools
  - `cybersecurity/stego` — Steganography tools
  - `ai/llm` — Local LLM tools (llama.cpp, ollama)

---

## Phase 5: Polish (v0.5.0)

- 💡 **Interactive TUI** — Full terminal UI with menus and wizards
- 💡 **Web UI** — Basic web interface for remote management
- 💡 **Plugin system** — Third-party module registry
- 💡 **Visual identity** — Logo, banner art, consistent styling
- 💡 **Localization** — Multi-language support for logs and UI

---

## Phase 6: Ecosystem (v1.0.0)

- 💡 **Package registry** — Community module submission
- 💡 **One-liner install** — `bash -c "$(curl -fsSL ...)"`
- 💡 **Multi-device sync** — Sync profiles across devices
- 💡 **Configuration as code** — Declarative environment definition files
- 💡 **Rollback management** — Timeline-based rollback with snapshots
- 💡 **Dependency audit** — Automated dependency tree analysis

---

## How to Influence the Roadmap

1. **Open an issue** — Suggest features with clear use cases
2. **Submit a PR** — Implement roadmap items yourself
3. **Comment on issues** — Upvote features you want to see
4. **Join discussions** — Provide feedback on design proposals

The roadmap is a living document and will evolve based on:

- Community feedback
- Contributor availability
- Technical feasibility
- Project maintainer direction
