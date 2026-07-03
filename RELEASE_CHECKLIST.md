# Release Checklist

> Pre-flight checks and procedures for publishing a Termux Bootstrap release.

---

## Before the Release

- [ ] All CI checks pass on `main` (lint, test, coverage)
- [ ] `CHANGELOG.md` is up to date and formatted per [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
- [ ] `VERSION` file at project root contains the target version
- [ ] Version is consistent across all source files (`./tools/validate-version.sh`)
- [ ] Build verification passes (`./tools/verify-build.sh`)
- [ ] No open issues or PRs that should block the release
- [ ] All new features have test coverage
- [ ] Documentation is updated (README, CLI reference, profile docs)
- [ ] `SECURITY.md` vulnerability disclosure policy is current

---

## Creating the Release

### 1. Update the VERSION file

```bash
echo "1.0.0" > VERSION
git add VERSION
git commit -m "chore(release): bump to 1.0.0"
```

### 2. Update CHANGELOG

Move items from `[Unreleased]` to the new version section:

```bash
./tools/gen-changelog.sh --write
```

Review and edit the generated changelog, then commit:

```bash
git add CHANGELOG.md
git commit -m "docs(changelog): update for v1.0.0"
```

### 3. Validate

```bash
./tools/validate-version.sh
./tools/verify-build.sh
```

### 4. Tag and push

```bash
git tag -a v1.0.0 -m "v1.0.0"
git push origin main --tags
```

Pushing the tag triggers the [Release workflow](.github/workflows/release.yml), which runs:

1. **Validation** — CI pipeline (lint, test, coverage)
2. **Version check** — `tools/validate-version.sh` against the tag
3. **Build verification** — `tools/verify-build.sh`
4. **Changelog generation** — `tools/gen-changelog.sh --verify`
5. **Release notes** — `tools/gen-release-notes.sh`
6. **Packaging** — archive + checksums + GitHub Release

---

## After the Release

- [ ] GitHub Release is published with correct notes
- [ ] Release archive is downloadable and passes checksum verification
- [ ] Announce on project communication channels
- [ ] Update any downstream references (package managers, install scripts)

---

## Versioning Policy

This project follows [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html):

| Component | When to bump |
|-----------|-------------|
| MAJOR | Breaking API or behavioral changes |
| MINOR | New features (backward compatible) |
| PATCH | Bug fixes, performance improvements |

Pre-release versions use the format `MAJOR.MINOR.PATCH-rc.N`:

```bash
echo "1.0.0-rc.1" > VERSION
```

---

## Emergency Hotfix

```bash
git checkout -b hotfix/v1.0.1 main
# apply fix
echo "1.0.1" > VERSION
git add VERSION && git commit -m "chore(release): bump to 1.0.1"
./tools/validate-version.sh
./tools/verify-build.sh
git tag -a v1.0.1 -m "v1.0.1"
git push origin hotfix/v1.0.1 --tags
# merge to main after release
```

---

## References

- [Release workflow](.github/workflows/release.yml)
- [CHANGELOG.md](CHANGELOG.md)
- [VERSION](VERSION)
- [tools/](tools/)
- [CONTRIBUTING.md](CONTRIBUTING.md)
