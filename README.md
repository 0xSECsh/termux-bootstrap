# Termux Bootstrap

> A professional bootstrap framework for building a complete Termux environment focused on Cybersecurity, Development, OSINT, Automation and Mobile Research.

---

## Overview

Termux Bootstrap automates the installation and configuration of a reproducible and modular Termux environment.

Instead of manually installing dozens of packages every time a new device is configured, this project allows the entire environment to be recreated with a single command.

The project is designed to be modular, allowing users to install only the profiles they need.

---

## Features

- One-command installation
- Modular architecture
- Multiple installation profiles
- Package management
- Dotfiles deployment
- Development environment
- Cybersecurity toolkit
- OSINT toolkit
- AI tooling
- Backup & restore utilities
- Easy updates

---

## Installation

```bash
git clone git@github.com:0xSECsh/termux-bootstrap.git

cd termux-bootstrap

./bootstrap.sh
```

---

## Installation Profiles

| Profile | Description |
|---------|-------------|
| Base | Essential packages and shell configuration |
| Development | Python, Go, Rust, Node.js and developer tools |
| Pentest | Offensive security tools |
| OSINT | Open Source Intelligence toolkit |
| Mobile | Android security and reverse engineering |
| Reverse | Reverse engineering environment |
| AI | AI and LLM utilities |

---

## Project Structure

```
termux-bootstrap/
├── bootstrap.sh
├── install.sh
├── uninstall.sh
├── packages/
├── configs/
├── scripts/
├── docs/
├── templates/
├── lib/
├── tests/
└── assets/
```

---

## Roadmap

### Core

- [ ] Bootstrap installer
- [ ] Package manager
- [ ] Dependency validation
- [ ] Logging system
- [ ] Error handling

### Profiles

- [ ] Base
- [ ] Development
- [ ] Pentest
- [ ] OSINT
- [ ] Mobile
- [ ] Reverse Engineering
- [ ] AI

### Configuration

- [ ] ZSH
- [ ] Git
- [ ] Fastfetch
- [ ] Micro
- [ ] Neovim
- [ ] tmux

### Automation

- [ ] Automatic updates
- [ ] Backup
- [ ] Restore
- [ ] Health check

---

## Documentation

Documentation is available inside the **docs/** directory.

- INSTALL.md
- PROFILES.md
- TOOLS.md

---

## Contributing

Contributions, suggestions and improvements are welcome.

Please open an Issue before submitting major changes.

---

## License

MIT License
