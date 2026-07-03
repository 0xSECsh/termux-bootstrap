# Changelog

> All notable changes to Termux Bootstrap are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- feat(installer): implement installation engine
- feat(config): implement configuration engine
- feat(profiles): implement profile engine
- feat(cli): implement bootstrap command dispatcher
- Initial project structure and framework architecture
- Core libraries: constants, errors, CLI, dispatcher, environment, version
- Terminal libraries: colors, logging, progress, spinner, terminal, UI
- System libraries: system info, validation, capabilities, packages
- Utility libraries: filesystem, download, archive, hash, JSON, random, retry, string, time, cache, temp
- Module system: registry, loader, dependency resolution, cycle detection
- Profile system: registry, loader, deduplication
- Configuration engine: read, write, merge, validate, status
- Installer engine: dry-run, rollback, batch install, progress tracking
- CLI commands: help, version, doctor, install, update, module, profile, config, list
- Package modules:
  - Core: base, editors, shell, utils
  - Development: python, nodejs, rust, golang, containers
  - Cybersecurity: pentest, recon, osint, reverse, wireless, threat-hunting, mobile
  - AI: ai
- Installation profiles:
  - Minimal, Dev, Full
  - Developer, Pentester, OSINT, Reverse, AI
  - Dry, Test
- BATS test suite: 428 tests across 12 categories
- Test helpers: assertions, fixtures, mocks, filesystem
- CI/CD pipeline: push, PR, nightly, release workflows
- Documentation: README, ARCHITECTURE, INSTALL, USAGE, MODULES, PROFILES, CONFIGURATION, CLI, TESTING, DEVELOPMENT, CONTRIBUTING, SECURITY, CHANGELOG, ROADMAP, FAQ, LICENSE
- Shipped dotfiles: git, tmux, zsh

### Changed
- (No previous releases to compare against)

### Fixed
- (No previous releases to compare against)

### Security
- ShellCheck compliance for all shell scripts
- No hardcoded secrets or credentials
- Input validation on all CLI arguments
- No eval on untrusted input
- Safe temp file handling with cleanup traps
