# Architecture Review: Termux Bootstrap Framework

---

## Directory Structure

**Current:**
```
lib/
  core/         # cli, constants, environment, errors, version
  system/       # capabilities, packages, system, validation
  terminal/     # colors, logging, progress, spinner, terminal, ui
  utils/        # archive, cache, download, filesystem, hash, json, random, retry, string, time
packages/
  core/         # base, editors, shell, utils
  development/  # containers, golang, nodejs, python, rust
  cybersecurity/# mobile, osint, pentest, recon, reverse, threat-hunting, wireless
  ai/           # ai
  profiles/     # ai, base, developer, full, mobile, osint, pentester, researcher, reverse
```

**Assessment:** Clean separation of framework vs. domain logic. Four-layer lib structure is logical. Profile/category organization in packages scales well.

**Recommendation:** Move `packages/core` → `packages/foundation` to avoid confusion with `lib/core`. Add `packages/integrations/` for third-party tooling.

---

## Module Boundaries

**Current:** Modules are single `.sh` files with `install_<category>_<module>()` function.

**Assessment:** Boundaries are clear but implicit. No formal module manifest (dependencies, version, description).

**Recommendation:** Add metadata header:
```bash
# MODULE_META: name=python category=development version=1.0.0 deps=base provides=python3
```

---

## Dependency Graph

**Current:**
- `lib/common.sh` loads ALL libraries in fixed hardcoded order
- Profiles call `load_module category module` dynamically
- Modules can call `load_module` (transitive deps)

**Issues:**
- No declared dependencies → load order fragile
- Circular dependency possible (A loads B, B loads A)
- No dependency resolution / topological sort

**Recommendation:** Implement declarative dependencies + topological loader. Replace hardcoded load order in `common.sh` with dependency graph.

---

## Coupling

**High Coupling:**
- All modules depend on global `load_module` function
- 42 exported variables from `constants.sh` create implicit coupling
- `lib/common.sh` is God object (loads everything)

**Low Coupling:**
- Modules don't import each other directly
- Profiles compose modules via `load_module`

**Recommendation:**
- Remove global exports; pass config via context object
- Split `common.sh` → `bootstrap.sh` (entry) + `registry.sh` (module system)
- Modules receive dependencies as parameters, not globals

---

## Cohesion

**High Cohesion:**
- `lib/terminal/*` — all UI/terminal concerns
- `lib/system/*` — all system interrogation
- `lib/utils/*` — pure helpers
- Profiles — single-purpose compositions

**Low Cohesion:**
- `lib/core/` mixes CLI, version, environment, errors, constants
- `packages/core/` mixes base, editors, shell, utils (grab bag)

**Recommendation:**
- Split `lib/core/` → `lib/cli/`, `lib/runtime/`, `lib/meta/`
- Rename `packages/core/` → `packages/foundation/` with subcategories

---

## Framework Layering

**Current Layers:**
```
Layer 0: bootstrap.sh (entry)
Layer 1: lib/common.sh (loader)
Layer 2: lib/core/* + lib/terminal/* + lib/system/* + lib/utils/* (framework)
Layer 3: packages/*/modules (domain logic)
Layer 4: packages/profiles/* (compositions)
```

**Assessment:** Clean 4-layer architecture. Layer 2 is too broad (20+ files).

**Recommendation:** Formalize layer contracts. Layer 2 should be <10 stable interfaces. Hide implementation behind facades.

---

## Future Scalability

**Strengths:**
- Profile composition model scales horizontally
- Category-based organization supports new domains
- Module loader supports lazy loading

**Risks:**
- Global namespace pollution (no function prefix)
- Hardcoded load order in `common.sh`
- No versioning for modules/profiles
- No plugin isolation

**Recommendation:**
- Adopt `tb_` namespace prefix immediately
- Add semantic versioning to modules
- Design plugin API before 1.0

---

## Plugin Support

**Current:** None. All code in-repo.

**Gap:** No mechanism for external modules, no plugin manifest, no sandboxing.

**Recommendation:** Design plugin interface:
```
~/.config/termux-bootstrap/plugins/
  my-plugin/
    plugin.toml      # metadata, deps, entry
    lib/             # optional framework extensions
    modules/         # domain modules
    profiles/        # profile contributions
```
Framework discovers and loads plugins at startup.

---

## Profile System

**Current:** Profiles are shell scripts calling `load_module` sequentially.

**Limitations:**
- No conditional modules (platform-specific)
- No module variants (minimal/full)
- No profile inheritance/extension
- No conflict detection

**Recommendation:** Move to declarative profile spec:
```yaml
# profiles/developer.yaml
extends: base
modules:
  - core:base
  - core:editors
  - development:python {variant: full}
  - development:nodejs {version: 20}
conditions:
  - if: has_docker
    then: development:containers
```

---

## Module System

**Current:** Convention-based (`install_<cat>_<mod>` function).

**Gaps:**
- No module discovery API
- No version constraints
- No health checks
- No rollback/uninstall
- No dry-run mode

**Recommendation:** Formalize module contract:
```bash
module_meta()        # → JSON: name, version, deps, provides
module_install()     # → install
module_verify()      # → health check
module_uninstall()   # → cleanup
module_dry_run()     # → preview changes
```

---

## Versioning

**Current:** Single `PROJECT_VERSION="0.1.0"` in `constants.sh`. No module/profile versioning.

**Recommendation:**
- Framework: SemVer (core libraries)
- Modules: Independent SemVer in metadata
- Profiles: Lockfile with resolved versions
- Compatibility matrix: framework ↔ module versions

---

## Summary Recommendations

| Priority | Action |
|----------|--------|
| **P0** | Add `tb_` namespace prefix to all public functions |
| **P0** | Remove 42 global exports from `constants.sh` |
| **P1** | Replace hardcoded load order with dependency graph |
| **P1** | Split `lib/common.sh` God object |
| **P1** | Resolve `lib/core/cli.sh` + `version.sh` duplicate functions |
| **P2** | Add module metadata (deps, version, description) |
| **P2** | Declarative profile specification (YAML/TOML) |
| **P2** | Design plugin API + discovery mechanism |
| **P3** | Module versioning + compatibility matrix |
| **P3** | Profile inheritance + conditional modules |
| **P3** | Module uninstall/verify/dry-run contracts |