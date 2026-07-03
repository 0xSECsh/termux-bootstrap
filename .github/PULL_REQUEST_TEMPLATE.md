
## Description

<!-- Describe the changes in this pull request. -->
<!-- Include the motivation, context, and any related issues. -->

Fixes #(issue)

## Type of Change

<!-- Mark the relevant option(s) with an 'x'. -->

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would break existing functionality)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)
- [ ] Test addition or update
- [ ] CI/CD change
- [ ] Dependency update

## Scope

<!-- What area does this change affect? -->

- [ ] Core library (`lib/`)
- [ ] Module definition (`packages/`)
- [ ] Profile definition (`packages/profiles/`)
- [ ] CLI command (`commands/`)
- [ ] Configuration engine (`modules/config_engine.sh`)
- [ ] Installer engine (`modules/installer_engine.sh`)
- [ ] Documentation
- [ ] Tests
- [ ] CI/CD

## Testing

<!-- Describe how you tested these changes. -->

- [ ] All existing tests pass: `./tests/run_tests.sh`
- [ ] Added new tests for the change
- [ ] ShellCheck clean: `find . -name '*.sh' -exec shellcheck -x -s bash {} +`
- [ ] shfmt formatted: `find . -name '*.sh' -exec shfmt -d -i 8 -ci {} +`
- [ ] No new ShellCheck warnings

## Checklist

<!-- Confirm each item before requesting review. -->

- [ ] My code follows the project's [coding standards](DEVELOPMENT.md#code-standards)
- [ ] I have updated the documentation accordingly
- [ ] My changes generate no new warnings or errors
- [ ] I have added comments to clarify complex logic
- [ ] I have reviewed my own code before requesting review

## Additional Context

<!-- Add any other context, screenshots, or benchmark results. -->
