
# Security Policy

> Security guidelines and vulnerability reporting for Termux Bootstrap.

---

## Supported Versions

| Version | Supported |
|---------|:---------:|
| 0.1.x   | ✅ Yes |

Only the latest minor release receives security patches.  
Users are encouraged to always use the latest version.

---

## Reporting a Vulnerability

### Private Reporting Process

We take security vulnerabilities seriously. Please follow the process below.

**DO NOT** file a public GitHub issue for security vulnerabilities.  
**DO NOT** discuss the vulnerability in public forums before it is patched.

### How to Report

1. **Open a draft security advisory** on GitHub:
   - Go to https://github.com/0xSECsh/termux-bootstrap/security/advisories
   - Click "New draft security advisory"
   - Fill in the details

   *Or, if you prefer email:*

2. **Email** the project maintainers directly with the details.

### What to Include

Provide as much of the following as possible:

- **Type** of vulnerability (e.g., command injection, privilege escalation)
- **Affected versions** and components
- **Reproduction steps** or proof of concept
- **Impact assessment** — what an attacker could achieve
- **Suggested fix** if you have one
- Your **contact information** for follow-up

### Response Timeline

| Timeframe | Action |
|-----------|--------|
| 48 hours | Acknowledgment of receipt |
| 7 days | Initial assessment and mitigation plan |
| 30 days | Patch release for verified vulnerabilities |
| 90 days | Public disclosure (coordinated) |

### Disclosure Policy

We follow a coordinated disclosure process:

1. Vulnerability reported privately
2. Maintainers assess and develop a fix
3. Fix is prepared, tested, and a patch release is cut
4. Advisory is published on GitHub with CVE assignment (if applicable)
5. Public disclosure 30 days after patch release

---

## Security Practices

### Framework Security

- **No hardcoded secrets** — The framework does not contain API keys, tokens, or passwords
- **No network services** — The framework does not run as a service or listen on ports
- **No privilege escalation** — The framework runs with user-level permissions only
- **No telemetry** — The framework does not collect or transmit usage data
- **No eval on user input** — CLI arguments are parsed, never evaluated

### Installation Security

- **Package verification** — All packages are installed through official Termux repositories via `pkg`
- **No curl-to-bash** — The framework is cloned or downloaded as a tarball, not piped to a shell
- **Dry-run preview** — Users can preview changes with `--dry-run` before applying them
- **Rollback support** — Failed installations can be rolled back automatically

### Code Security

- **ShellCheck clean** — All code is linted with ShellCheck to detect vulnerabilities
- **Input validation** — All CLI arguments are validated before processing
- **No eval** — The framework does not use `eval` on untrusted input
- **No source injection** — Module/profile loading is restricted to the `packages/` directory

---

## Dependency Security

### Distribution Channels

| Channel | Verification |
|---------|-------------|
| Official Termux repos (`pkg`) | Maintained by Termux community |
| PyPI (`pip`) | Package signatures where available |
| npm registry | Package integrity checks |
| crates.io (`cargo`) | Registry integrity |
| GitHub releases | Release checksums published |

### CI/CD Pipeline

The CI pipeline runs on GitHub Actions and includes:
- ShellCheck static analysis
- shfmt formatting verification
- Shell syntax validation (`bash -n`)
- Full BATS test suite (428 tests)
- Coverage reporting via kcov

All CI artifacts are ephemeral and destroyed after pipeline completion.

---

## Supply Chain Security

### Verifying Releases

```bash
# Verify git tag signature (once signing is configured)
git tag -v <tag>

# Verify release checksums
sha256sum termux-bootstrap-*.tar.gz
```

### Release Artifacts

Each GitHub release includes:
- Source tarball: `termux-bootstrap-<version>.tar.gz`
- SHA256 checksums: `checksums.txt`

---

## Known Security Considerations

| Consideration | Description | Mitigation |
|---------------|-------------|------------|
| Termux sandbox | Android environment has different security properties | Run `doctor` to verify environment |
| Package trust | Modules install third-party tools | All tools listed in [MODULES.md](MODULES.md) |
| Tool legality | Security tools (nmap, metasploit) have legal restrictions | User is responsible for compliance |
| Network access | Downloads require internet | All downloads occur over HTTPS |
| Storage access | Installation writes to user home directory | No system-level writes occur |

---

## Secure Development

### Code Review

All code changes are reviewed before merging:
1. **Automated**: ShellCheck, shfmt, test suite
2. **Manual**: At least one maintainer reviews every diff
3. **Security-sensitive**: Additional review by project leads

### Sensitive Areas

The following files require extra scrutiny:

| File | Reason |
|------|--------|
| `lib/common.sh` | Framework loader — controls initialization |
| `lib/core/environment.sh` | Runtime behavior — creates directories, sets vars |
| `lib/system/packages.sh` | Package management — executes install commands |
| `modules/installer_engine.sh` | Rollback logic — undo operations on failure |
| `.github/workflows/*.yml` | CI/CD — executes in privileged context |

### Secrets Management

- **No secrets in code** — API keys, tokens, passwords must never be committed
- **Environment variables** — Use environment variables for sensitive runtime configuration
- **`.gitignore`** — Ensure sensitive files are excluded from version control
