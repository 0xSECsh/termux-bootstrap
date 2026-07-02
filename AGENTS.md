# AGENTS.md

# Termux Bootstrap Development Guidelines

You are working on the Termux Bootstrap project.

This project aims to become a professional Bash framework for bootstrapping, configuring, and maintaining Termux environments.

Your goal is to produce production-quality code.

---

## General Principles

- Prefer readability over cleverness.
- Keep functions small.
- Keep modules independent.
- Favor composition over duplication.
- Every function must have a single responsibility.
- Reuse existing libraries whenever possible.
- Never duplicate logic.

---

## Architecture

Always preserve the current architecture.

Core

- core/
- system/
- terminal/
- utils/

Modules

- core
- development
- cybersecurity
- ai

Profiles

- developer
- pentester
- osint
- reverse
- ai
- full

---

## Coding Standards

- Bash 5+
- ShellCheck clean
- shfmt formatted
- Prefer printf over echo
- Quote every variable unless intentional
- Use local variables whenever possible
- Prefer [[ ]] over [ ]
- Avoid unnecessary subshells
- Avoid global mutable state
- Prefer reusable helper functions
- Do not execute code during library sourcing

---

## Library Rules

Libraries must:

- Define functions only.
- Never perform initialization automatically.
- Never create files automatically.
- Never install packages automatically.
- Never modify user configuration automatically.

Initialization must occur exclusively through:

framework_initialize()

---

## Error Handling

Never use:

exit 1

directly inside modules.

Instead use the framework error library.

Examples:

die
panic
assert_file
assert_directory
assert_command
assert_capability

---

## Logging

Always use the logging library.

Never print operational messages directly.

Use:

log_info
log_success
log_warning
log_error
log_debug

---

## Package Management

Never call pkg directly outside packages.sh.

Never call:

pkg
pip
cargo
go
npm

directly from modules.

Always use framework wrappers.

---

## UI

Never print menus directly.

Use:

ui_header
ui_menu
ui_confirm
ui_box
ui_summary

---

## Documentation

Every file must contain:

- Header
- Description
- Sections
- Comments

Every public function should be documented.

---

## Development Workflow

Before modifying code:

1. Read the affected files.
2. Understand dependencies.
3. Explain the implementation plan.
4. Implement the changes.
5. Validate consistency.
6. Explain the final result.

Never modify code you do not understand.

Always preserve backward compatibility unless explicitly instructed otherwise.

When in doubt, ask before making architectural changes.
