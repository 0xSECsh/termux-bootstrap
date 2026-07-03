# Frequently Asked Questions

> Common questions about Termux Bootstrap.

---

## General

### What is Termux Bootstrap?

Termux Bootstrap is a professional Bash framework for automating the setup and configuration of Termux on Android. It provides modular, reproducible environments through pre-defined profiles and individual module installation.

### Why would I use this instead of setting up Termux manually?

If you set up Termux on multiple devices, or reinstall frequently, Termux Bootstrap saves hours of repetitive configuration. A single command recreates your entire environment, including packages, dotfiles, and tool configurations.

### Does this work on non-Android systems?

The framework is designed for Termux on Android. Some system detection and package management functions are Termux-specific. However, the library architecture is platform-aware and degrades gracefully on non-Termux systems.

### Is this only for security/penetration testing?

No. While the project includes cybersecurity profiles, it also provides profiles for development, AI/ML, and general use. You can install only what you need.

---

## Installation

### Do I need root access?

No. Termux Bootstrap runs entirely within Termux's sandboxed environment. No root access is required.

### How much storage do I need?

The minimal profile requires approximately 100 MB. Full profiles (developer, pentester) can require 1-2 GB depending on included packages.

### Can I install this without git?

Yes. Download the latest release archive from GitHub and extract it:

```bash
curl -LO https://github.com/0xSECsh/termux-bootstrap/releases/latest/download/termux-bootstrap.tar.gz
tar xzf termux-bootstrap.tar.gz
```

### Does it work on Termux from Google Play?

The F-Droid version of Termux is recommended. The Google Play version is outdated and may have compatibility issues.

---

## Usage

### What's the difference between a profile and a module?

A **module** installs a specific capability (e.g., `development/rust` installs the Rust toolchain). A **profile** composes multiple modules for a use case (e.g., the `developer` profile installs Python, Rust, Go, Node.js, and more).

### Can I install multiple profiles?

Yes. Installing multiple profiles is safe — the module loader deduplicates modules shared between profiles.

### How do I see what a profile will install before running it?

```bash
./bootstrap.sh install --profile developer --dry-run
```

### How do I uninstall something?

```bash
# Remove a specific profile
./bootstrap.sh profile remove developer

# Full uninstall (once implemented)
./uninstall.sh
```

### How do I update?

```bash
# Update everything
./bootstrap.sh update all

# Update just the framework
./bootstrap.sh update framework
```

---

## Modules

### How do I add a new module?

Create a file in `packages/<category>/<name>.sh` with an `install_<category>_<name>()` function. The module registry automatically discovers it. See [MODULES.md](MODULES.md#creating-modules) for details.

### How do I find what packages a module installs?

```bash
./bootstrap.sh module info <module-name>
```

Or check the documentation in [MODULES.md](MODULES.md#package-manifest).

### Can I create a module that installs Python packages?

Yes. Use the `pip_install` wrapper instead of calling `pip` directly:

```bash
install_development_my_tools() {
    pip_install "numpy" "pandas" "scipy"
}
```

### Can modules depend on other modules?

Yes. Use `require_module "other/module"` within your install function:

```bash
install_development_my_module() {
    require_module "development/python"
    # ... rest of installation
}
```

---

## Configuration

### Where are configuration files stored?

Framework configuration: `~/.config/termux-bootstrap/`
Managed dotfiles: `~/.zshrc`, `~/.gitconfig`, `~/.tmux.conf`
Logs: `~/.local/share/termux-bootstrap/logs/`

### How do I change the log level?

```bash
export LOG_LEVEL=DEBUG
./bootstrap.sh install --profile developer
```

### Can I customize which dotfiles get installed?

Yes. Use the config command to selectively merge configurations:

```bash
# Only merge git config
./bootstrap.sh config merge git

# Preview what would be merged
./bootstrap.sh config list
```

---

## Troubleshooting

### The doctor command shows failures

```bash
# Run with verbose output for details
./bootstrap.sh doctor --verbose
```

Common issues:
- **Termux not detected** — You must run inside Termux
- **No internet** — Check your connection and try again
- **Storage not accessible** — Run `termux-setup-storage`

### Installation fails halfway through

```bash
# Check the error log
cat ~/.local/share/termux-bootstrap/logs/error.log

# Check the main log
cat ~/.local/share/termux-bootstrap/logs/install.log

# If rollback is enabled, packages should be cleaned up automatically
```

### "Command not found" after installation

Restart your shell session:

```bash
exec zsh   # or exec bash
```

### The framework loads slowly

First load is slower because directories are created and libraries are sourced. Subsequent loads are faster due to guard variables. If it's consistently slow, run:

```bash
./bootstrap.sh doctor --verbose
```

---

## Development

### How do I run the tests?

```bash
./tests/run_tests.sh
```

### How do I add a test?

Create a `.bats` file in the appropriate `tests/` subdirectory. See [TESTING.md](TESTING.md#writing-tests) for examples.

### How do I contribute?

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contribution guide.

### What coding standards do you follow?

ShellCheck compliance, shfmt formatting (8-space indent, `-ci` style), Bash 5.0+ syntax. See [DEVELOPMENT.md](DEVELOPMENT.md#code-standards).

---

## Security

### Is it safe to run?

Yes. The framework:
- Uses official Termux repositories for package installation
- Does not require root access
- Does not collect telemetry
- Is ShellCheck clean
- Supports dry-run preview before installation

### Does this contain malware?

No. Review the source code — it's all open-source Bash. Security tools installed by profiles (nmap, metasploit, etc.) are legitimate open-source tools with legal uses.

### Should I run this on my primary device?

That depends on your profile choice. The minimal and dev profiles are safe for daily use. The pentester profile installs network tools that may trigger antivirus or network monitoring.

---

## Support

### Where can I get help?

- **GitHub Issues** — Bug reports and feature requests
- **Documentation** — Start with the relevant `.md` file
- **Source code** — All code is readable Bash

### I found a bug. What do I do?

Open a GitHub issue with:
1. Termux version
2. Android version
3. Exact commands that caused the issue
4. Log output from `~/.local/share/termux-bootstrap/logs/`

### How do I request a feature?

Open a GitHub issue with the "feature request" label. Include your use case and proposed solution.
