# PhpStorm Claude Plugin

A Claude Code plugin that integrates PhpStorm with Claude Code

## Features

### Context-Aware Skills

**PHP Code Review**
Review PHP code using PhpStorm inspections for code quality and best practices.

**PHP Project Guide**
Foundational PHP project knowledge - setup, structure, standards, and tooling.

**Upgrade PHP**
PHP upgrade assistant - fix deprecations and scan for compatibility issues.

### Automatic Inspection Feedback
- Hook triggers after code edit
- Runs PhpStorm inspections automatically
- Feeds results to Claude

## Prerequisites

- PhpStorm with MCP server enabled
- Claude Code CLI
- `curl` and `jq` installed
- PHP project

## Installation

1. Add the marketplace to Claude Code:
```bash
claude plugin marketplace add jetbrains/phpstorm-claude-marketplace
```

2. Install the plugin:
```bash
claude plugin install phpstorm-plugin@phpstorm-marketplace
```

3. Ensure PhpStorm MCP server is installed.

## Contributing

Contributions welcome! Please follow existing patterns for hooks and skills, and test with real projects.

For information on creating hooks and skills, see the [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference).