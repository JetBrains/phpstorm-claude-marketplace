---
name: php-project-guide
description: >-
  Foundational PHP project knowledge for AI agents. Use when working on a PHP
  project, setting up a PHP development environment, understanding PHP project
  structure, following PHP coding standards, running PHP tests, using Composer,
  or when guidance on PHP-specific tools and workflows in PhpStorm is needed.
---

# PHP Project Guide

Foundational knowledge for working effectively on any PHP project in PhpStorm. Provides project detection, coding standards, testing patterns, framework guidance, and MCP tool usage.

## Quick Start: First Interaction with a PHP Project

Run these steps when encountering a new PHP project for the first time.

### 1. Detect PHP environment

```
get_php_project_config()
```

Returns the configured PHP language level, interpreter details (name, path, local/remote), and runtime information (exact PHP version, loaded extensions, php.ini path, debuggers). Use this to understand the PHP environment before generating code.

### 2. Identify dependencies and framework

```
get_composer_dependencies()
```

This returns all installed packages with exact versions from `composer.lock`. Use it to determine:
- **Framework**: `laravel/framework`, `symfony/framework-bundle`, or neither
- **Test framework**: `phpunit/phpunit`, `pestphp/pest`, `codeception/codeception`
- **Static analysis**: `phpstan/phpstan`, `vimeo/psalm`
- **Code style**: `friendsofphp/php-cs-fixer`, `squizlabs/php_codesniffer`

Use the optional `nameFilter` glob parameter to search for specific packages (e.g., `nameFilter: "laravel/*"`).

### 3. Route to framework-specific guidance

| Dependency | Project Type | Reference |
|------------|-------------|-----------|
| `laravel/framework` | Laravel | See `references/framework-laravel.md` |
| `symfony/framework-bundle` | Symfony | See `references/framework-symfony.md` |
| Neither | Generic PHP | See `references/php-standards.md` |

## PhpStorm MCP Tools Quick Reference

### Code Analysis

| Tool | When to Use |
|------|-------------|
| `get_inspections` | After edits, for code review, to find problems with available quick fixes |
| `apply_quick_fix` | To resolve inspection problems automatically |
| `get_file_problems` | Quick error/warning check on any file type (no quick fixes returned) |
| `build_project` | Trigger project build and get compilation errors |

### Code Search

| Tool | When to Use |
|------|-------------|
| `search_structural` | To find code patterns semantically using SSR (requires `fileType: "PHP"`) |
| `get_structural_patterns` | To discover predefined PHP search patterns by category |
| `search_text` | Fast text substring search across project files |
| `search_regex` | Regex search across project files with match coordinates |
| `search_symbol` | Semantic symbol lookup (classes, methods, fields) |
| `search_file` | Find files by glob pattern |
| `find_files_by_name_keyword` | Fast file search by name substring (uses indexes) |
| `find_files_by_glob` | Find files matching glob pattern recursively |

### Code Intelligence

| Tool | When to Use |
|------|-------------|
| `get_symbol_info` | Get Quick Documentation for a symbol at a specific position |
| `rename_refactoring` | Safely rename a symbol across the entire project |
| `get_php_project_config` | Get PHP language level, interpreter, extensions, runtime info |
| `get_composer_dependencies` | Understand project dependencies, framework, and versions |

### File Operations

| Tool | When to Use |
|------|-------------|
| `read_file` | Read file with advanced modes (slice, lines, offsets, indentation) |
| `get_file_text_by_path` | Read full file text by project-relative path |
| `replace_text_in_file` | Targeted find-and-replace in files |
| `create_new_file` | Create new files with content |
| `reformat_file` | Apply IDE code formatting rules |

### Execution

| Tool | When to Use |
|------|-------------|
| `get_run_configurations` | List available run/test configurations |
| `execute_run_configuration` | Run a specific configuration and get results |
| `execute_terminal_command` | Run shell commands in IDE terminal |

See `references/mcp-tools-reference.md` for detailed parameters and usage patterns.

## Documentation Lookup

When you need documentation beyond what these references provide:

- **Context7 MCP**: Use `resolve-library-id` then `query-docs` for any PHP framework or library — returns up-to-date docs and code examples
- **PHP official docs**: https://www.php.net/manual
- **PhpStorm help**: https://www.jetbrains.com/help/phpstorm/
- **phpstorm-stubs**: https://github.com/JetBrains/phpstorm-stubs — PHP built-in function signatures and type info

## Reference Documents

| Reference | Content |
|-----------|---------|
| `references/project-detection.md` | composer.json anatomy, PSR-4 autoloading, directory layouts |
| `references/php-standards.md` | PER/PSR coding standards, PHP version features, anti-patterns |
| `references/testing-guide.md` | PHPUnit, Pest, running tests, common mistakes |
| `references/framework-laravel.md` | Laravel directory structure, Eloquent, artisan, routes |
| `references/framework-symfony.md` | Symfony directory structure, Doctrine, console, services |
| `references/static-analysis.md` | PHPStan, Psalm, PHP CS Fixer, PHP CodeSniffer |
| `references/composer-guide.md` | Composer commands, version constraints, autoloading |
| `references/mcp-tools-reference.md` | Detailed PhpStorm MCP tool parameters and workflows |