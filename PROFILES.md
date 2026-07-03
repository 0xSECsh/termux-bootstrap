# Profiles Reference

> Complete reference for all Termux Bootstrap profiles, their composition, and usage.

---

## Table of Contents

- [What are Profiles?](#what-are-profiles)
- [Profile Comparison](#profile-comparison)
- [Profile Details](#profile-details)
- [Creating Profiles](#creating-profiles)
- [Customizing Profiles](#customizing-profiles)

---

## What are Profiles?

Profiles are curated compositions of modules designed for specific use cases. They provide:

- **One-command setup** — Install a complete environment with a single command
- **Curated selections** — Hand-picked modules that work well together
- **Dependency management** — Automatic resolution of module requirements
- **Consistency** — Reproducible environments across devices

Each profile lives in `packages/profiles/<name>.sh` and exports an `install_profile_<name>()` function.

### Profile vs Module

| Aspect | Profile | Module |
|--------|---------|--------|
| **Purpose** | Composes modules for a use case | Installs a specific capability |
| **File** | `packages/profiles/<name>.sh` | `packages/<cat>/<name>.sh` |
| **Install command** | `install --profile <name>` | `install --module <path>` |
| **Dependencies** | Declares which modules to load | Declares module-to-module deps |
| **Can install packages** | No (delegates to modules) | Yes |

---

## Profile Comparison

```
                    ┌─────────┬────────┬────────┬──────────┬────────┬──────┐
                    │ Minimal │  Dev   │  Full  │ Developer│Pentester│ OSINT│
├────────────────────┼─────────┼────────┼────────┼──────────┼────────┼──────┤
│ Core Base         │    ✓    │   ✓    │   ✓    │    ✓     │   ✓    │  ✓   │
│ Core Editors      │         │   ✓    │        │    ✓     │   ✓    │  ✓   │
│ Core Shell        │         │        │   ✓    │    ✓     │   ✓    │  ✓   │
│ Core Utils        │         │        │        │    ✓     │   ✓    │  ✓   │
│ Dev Python        │         │        │        │    ✓     │        │      │
│ Dev Node.js       │         │        │        │    ✓     │        │      │
│ Dev Go            │         │        │        │    ✓     │        │      │
│ Dev Rust          │         │        │        │    ✓     │        │      │
│ Dev Containers    │         │        │        │    ✓     │        │      │
│ Cyber Pentest     │         │        │        │          │   ✓    │      │
│ Cyber Recon       │         │        │        │          │   ✓    │  ✓   │
│ Cyber OSINT       │         │        │        │          │        │  ✓   │
│ Cyber Wireless    │         │        │        │          │   ✓    │      │
│ Cyber Threat Hunt │         │        │        │          │   ✓    │      │
│ Cyber Reverse     │         │        │        │          │        │      │
│ Cyber Mobile      │         │        │        │          │        │      │
│ AI                │         │        │        │          │        │      │
└────────────────────┴─────────┴────────┴────────┴──────────┴────────┴──────┘
```

---

## Profile Details

### Minimal

**Purpose:** Essential packages for a basic Termux environment.

```bash
./bootstrap.sh install --profile minimal
```

**Modules:**
- `core/base` — Foundational packages

**When to use:**
- Limited storage space
- Fresh devices where you want to build up incrementally
- Containerized or minimal environments

---

### Dev

**Purpose:** Base system plus text editors for light development.

```bash
./bootstrap.sh install --profile dev
```

**Modules:**
- `core/base` — Foundational packages
- `core/editors` — Text editors

**When to use:**
- Quick configuration editing
- Writing scripts and documentation
- When you need editors without a full dev stack

---

### Full

**Purpose:** Core system with shell enhancements.

```bash
./bootstrap.sh install --profile full
```

**Modules:**
- `core/base` — Foundational packages
- `core/shell` — Shell configuration and enhancements

**When to use:**
- General-purpose Termux usage
- When you want a polished shell experience
- As a base for adding modules manually later

---

### Developer

**Purpose:** Complete development environment.

```bash
./bootstrap.sh install --profile developer
```

**Modules:**

| Module | Provides |
|--------|----------|
| `core/base` | System essentials |
| `core/editors` | Text editors (Vim, Nano, Micro) |
| `core/shell` | Shell enhancements (ZSH, plugins) |
| `core/utils` | General utilities |
| `development/python` | Python 3 + pip |
| `development/nodejs` | Node.js + npm |
| `development/golang` | Go compiler |
| `development/rust` | Rust + Cargo |
| `development/containers` | Docker + Podman |

**When to use:**
- Software development across multiple languages
- Building and testing open-source projects
- DevOps and infrastructure work

---

### Pentester

**Purpose:** Comprehensive penetration testing toolkit.

```bash
./bootstrap.sh install --profile pentester
```

**Modules:**

| Module | Provides |
|--------|----------|
| `core/base` | System essentials |
| `core/editors` | Text editors |
| `core/shell` | Shell enhancements |
| `core/utils` | General utilities |
| `cybersecurity/pentest` | nmap, metasploit, hydra, sqlmap, john, hashcat |
| `cybersecurity/recon` | subfinder, httpx, nuclei, naabu, amass |
| `cybersecurity/wireless` | aircrack-ng, reaver, wifite, bettercap |
| `cybersecurity/threat-hunting` | yara, volatility3, capa |

**When to use:**
- Security assessments and penetration testing
- CTF competitions
- Network security research

**Disk space:** Large (Metasploit and wordlists require significant storage)

---

### OSINT

**Purpose:** Open-source intelligence gathering toolkit.

```bash
./bootstrap.sh install --profile osint
```

**Modules:**

| Module | Provides |
|--------|----------|
| `core/base` | System essentials |
| `core/editors` | Text editors |
| `core/shell` | Shell enhancements |
| `core/utils` | General utilities |
| `cybersecurity/osint` | recon-ng, sherlock, holehe, maigret, photon |
| `cybersecurity/recon` | subfinder, httpx, nuclei, naabu, amass |

**When to use:**
- Intelligence gathering and analysis
- Social media investigation
- Domain and subdomain enumeration
- Email and username reconnaissance

**Note:** OSINT tools may require API keys for full functionality.

---

### Reverse

**Purpose:** Reverse engineering and binary analysis environment.

```bash
./bootstrap.sh install --profile reverse
```

**Modules:**

| Module | Provides |
|--------|----------|
| `core/base` | System essentials |
| `core/editors` | Text editors |
| `core/shell` | Shell enhancements |
| `core/utils` | General utilities |
| `cybersecurity/reverse` | radare2, gdb, strace, ltrace |
| `cybersecurity/mobile` | apktool, jadx, dex2jar |

**When to use:**
- Binary reverse engineering
- Mobile application analysis (APK decompilation)
- Debugging and low-level analysis
- Malware analysis (static)

---

### AI

**Purpose:** AI and machine learning environment.

```bash
./bootstrap.sh install --profile ai
```

**Modules:**

| Module | Provides |
|--------|----------|
| `core/base` | System essentials |
| `core/editors` | Text editors |
| `core/shell` | Shell enhancements |
| `core/utils` | General utilities |
| `development/python` | Python 3 + pip |
| `ai/ai` | NumPy, OpenBLAS, CLBlast |

**When to use:**
- Machine learning experimentation
- Data analysis and visualization
- AI/LLM tooling
- Running inference on device

**Note:** GPU acceleration (via CLBlast) depends on device OpenCL support.

---

### Additional Profiles

| Profile | Command | Modules |
|---------|---------|---------|
| **dry** | `install --profile dry` | core/base (dry-run validation) |
| **test** | `install --profile test` | core/base (testing) |
| **base** | (stub) | Not implemented |
| **mobile** | (stub) | Not implemented |
| **researcher** | (stub) | Not implemented |

---

## Creating Profiles

### Step 1: Create the Profile File

```bash
touch packages/profiles/my-profile.sh
```

### Step 2: Define the Install Function

```bash
# packages/profiles/my-profile.sh
# Description: My custom profile

install_profile_my_profile() {
    load_module "core/base"
    load_module "development/python"
    load_module "cybersecurity/osint"
    
    log_success "My profile installed successfully"
}
```

### Step 3: Verify Discovery

```bash
./bootstrap.sh list profiles
```

Your profile should appear in the list.

### Step 4: Test Installation

```bash
# Preview first
./bootstrap.sh install --profile my-profile --dry-run

# Install
./bootstrap.sh install --profile my-profile
```

---

## Customizing Profiles

### Combining Profiles

You can install multiple profiles:

```bash
./bootstrap.sh install --profile developer
./bootstrap.sh install --profile osint
```

The module loader deduplicates — modules shared between profiles are only loaded once.

### Adding Modules to an Existing Profile

```bash
# Install a module not in your profile
./bootstrap.sh install --module cybersecurity/pentest
```

### Creating a Custom Profile

For a truly custom setup, create your own profile file as shown above. This approach:

- Gives you full control over module selection
- Creates a reproducible configuration
- Can be committed to your fork

### Module Installation Options

```bash
# Custom profile with specific module options
install_profile_my_custom() {
    load_module "core/base"
    load_module "development/rust"
    
    # Additional setup after module installation
    log_info "Running custom post-install setup..."
    mkdir -p ~/tools
    log_success "Custom profile ready"
}
```
