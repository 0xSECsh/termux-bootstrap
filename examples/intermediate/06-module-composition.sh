#!/usr/bin/env bash
# ==============================================================================
# Example: Module Composition and Insights
# Level:    Intermediate
# Usage:    bash examples/intermediate/06-module-composition.sh
# ==============================================================================
# Demonstrates how modules compose, their dependency graphs, and how to
# introspect them:
#   1. List modules with categories
#   2. Show module dependency trees
#   3. Demonstrate dependency resolution ordering
#   4. Show how profiles compose modules
#   5. Test idempotency of module loading
#
# Key concepts: module_registry discovery, dependency graphs,
# topological sort, module_loader guards.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck disable=SC1091
source "${PROJECT_ROOT}/lib/common.sh"
framework_initialize

ui_header "Module Composition and Dependency Analysis"
echo ""

# ---- Step 1: Module Inventory ----
log_info "Step 1: Complete module inventory"
echo ""

declare -A CATEGORY_LABELS=(
        [core]="Core System"
        [development]="Development"
        [cybersecurity]="Cybersecurity"
        [ai]="AI / ML"
)

for cat_dir in "${PROJECT_ROOT}"/packages/*/; do
        cat_name="$(basename "${cat_dir}")"
        [[ "$cat_name" == "profiles" ]] && continue

        echo "  [${CATEGORY_LABELS[${cat_name}]:-${cat_name}}]"

        for mod_file in "${cat_dir}"*.sh; do
                [[ -f "$mod_file" ]] || continue
                mod_name="$(basename "${mod_file}" .sh)"
                install_fn="install_${cat_name}_${mod_name}"
                echo "    ├─ ${mod_name}"

                # Extract description from file header
                desc="$(grep -m1 '^# Description' "$mod_file" 2>/dev/null | sed 's/^# Description[: ]*//')"
                [[ -n "$desc" ]] && echo "    │  └─ ${desc}"

                # Check if install function exists
                if grep -q "^${install_fn}()" "$mod_file" 2>/dev/null; then
                        : # function defined
                fi
        done
        echo ""
done

# ---- Step 2: Dependency Trees ----
log_info "Step 2: Dependency trees"
echo ""

show_dep_tree() {
        local module_path="$1"
        local indent="${2:-  }"

        if declare -F module_deps &>/dev/null; then
                local deps
                deps="$(module_deps "$module_path" 2>/dev/null || true)"
                if [[ -n "$deps" ]]; then
                        while IFS= read -r dep; do
                                echo "${indent}├─ ${dep}"
                                show_dep_tree "$dep" "${indent}   "
                        done <<<"$deps"
                fi
        fi
}

for module in "development/nodejs" "cybersecurity/pentest" "ai/ai"; do
        echo "  Module: ${module}"
        show_dep_tree "$module" "  "
        echo "  → Resolved order:"
        if declare -F resolve_module_deps &>/dev/null; then
                order="$(resolve_module_deps "$module" 2>/dev/null || true)"
                if [[ -n "$order" ]]; then
                        count=1
                        while IFS= read -r m; do
                                echo "     ${count}. ${m}"
                                count=$((count + 1))
                        done <<<"$order"
                fi
        else
                echo "     (dependency resolver not loaded)"
        fi
        echo ""
done

# ---- Step 3: Profile Composition ----
log_info "Step 3: How profiles compose modules"
echo ""

echo "  A profile is a curated composition of modules:"
echo ""

if declare -F profile_modules &>/dev/null; then
        for profile in developer pentester osint; do
                echo "  Profile: ${profile}"
                mods="$(profile_modules "$profile" 2>/dev/null || true)"
                if [[ -n "$mods" ]]; then
                        count=1
                        while IFS= read -r m; do
                                echo "    ${count}. ${m}"
                                count=$((count + 1))
                        done <<<"$mods"
                fi
                echo ""
        done
else
        cat <<'COMPOSE_EOF'
    developer profile:
      1. core/base           (foundation)
      2. core/editors        (vim, nano, micro)
      3. core/shell          (zsh, plugins)
      4. core/utils          (general utilities)
      5. development/python  (python, pip)
      6. development/nodejs  (node, npm)      → depends on python
      7. development/golang  (go compiler)
      8. development/rust    (rustc, cargo)
      9. development/containers (docker, podman)

    pentester profile:
      1. core/base
      2. core/editors
      3. core/shell
      4. core/utils
      5. cybersecurity/pentest       (nmap, metasploit, ...)
      6. cybersecurity/recon         (subfinder, nuclei, ...)
      7. cybersecurity/wireless      (aircrack-ng, bettercap)
      8. cybersecurity/threat-hunting (yara, volatility3)

    osint profile:
      1. core/base
      2. core/editors
      3. core/shell
      4. core/utils
      5. cybersecurity/osint         (recon-ng, sherlock, ...)
      6. cybersecurity/recon         (subfinder, httpx, ...)

COMPOSE_EOF
fi

# ---- Step 4: Deduplication ----
log_info "Step 4: Idempotency and deduplication"
echo ""

cat <<'DEDUP_EOF'
  The module_loader uses guard variables to track module state:

    LOADED_MODULES["development/python"]=sourced   → file sourced
    LOADED_MODULES["development/python"]=loaded    → install fn registered
    LOADED_MODULES["development/python"]=ran       → install fn executed

  If two profiles share a module:

    Profile A loads core/base  → sourced, loaded, ran
    Profile B loads core/base  → skipped (already ran)

  This means installing 'developer' then 'pentester' is safe —
  they share core/* modules which won't be re-installed.

DEDUP_EOF

# ---- Step 5: Shared Module Analysis ----
log_info "Step 5: Shared modules between profiles"
echo ""

echo "  Modules shared by ALL profiles: core/base"
echo ""
echo "  Modules shared by developer + pentester:"
echo "    core/base, core/editors, core/shell, core/utils"
echo ""
echo "  Modules unique to developer:"
echo "    development/python, development/nodejs, development/golang,"
echo "    development/rust, development/containers"
echo ""
echo "  Modules unique to pentester:"
echo "    cybersecurity/pentest, cybersecurity/recon,"
echo "    cybersecurity/wireless, cybersecurity/threat-hunting"
echo ""

log_success "Module composition analysis complete"
