# Composer Dependency Management

## Core Files

| File | Purpose | Commit? |
|------|---------|---------|
| `composer.json` | Declares dependencies and version constraints | Yes |
| `composer.lock` | Locks exact versions for reproducible installs | Yes (for applications), No (for libraries) |
| `vendor/` | Installed packages | No (gitignored) |

## Common Commands

| Command | Purpose |
|---------|---------|
| `composer install` | Install exact versions from `composer.lock` |
| `composer update` | Update dependencies to newest versions matching constraints, regenerates `composer.lock` |
| `composer require package/name` | Add a production dependency |
| `composer require --dev package/name` | Add a development dependency |
| `composer remove package/name` | Remove a dependency |
| `composer dump-autoload` | Regenerate autoloader (needed after adding files to `classmap`) |
| `composer dump-autoload --optimize` | Optimize autoloader for production |
| `composer audit` | Check dependencies for known security vulnerabilities |
| `composer outdated` | List packages with newer versions available |
| `composer show package/name` | Show details about a specific package |

### install vs update

- **`composer install`**: Reads `composer.lock` and installs those exact versions. Use in CI/CD and deployment. If no lock file exists, behaves like `update`.
- **`composer update`**: Resolves constraints in `composer.json`, finds newest matching versions, updates `composer.lock`. Use during development when you want newer versions.

## Version Constraints

| Syntax | Meaning | Example |
|--------|---------|---------|
| `^1.2` | `>=1.2.0 <2.0.0` (next major) | Most common — allows minor and patch updates |
| `~1.2` | `>=1.2.0 <2.0.0` (last digit goes up) | `~1.2.3` = `>=1.2.3 <1.3.0` (more restrictive) |
| `>=1.2` | `>=1.2.0` (no upper bound) | Dangerous — may break on major updates |
| `1.2.*` | `>=1.2.0 <1.3.0` | Wildcard on patch version only |
| `1.2.3` | Exact version | Avoid unless necessary |

**Recommendation**: Use `^` (caret) for most dependencies. It follows semantic versioning and allows safe updates.

## Autoloading

### When dump-autoload Is Needed

- After adding a new PSR-4 root in `composer.json`
- After adding files to `classmap` or `files` autoload sections
- After manually placing files outside PSR-4 conventions
- **Not needed** after creating new classes within existing PSR-4 namespaces (the autoloader resolves these dynamically)

### Autoload Types

| Type | Use Case |
|------|----------|
| `psr-4` | Standard namespace-to-directory mapping (most common) |
| `psr-0` | Legacy namespace mapping (deprecated, avoid in new projects) |
| `classmap` | Scan directories and build a class-to-file map |
| `files` | Always load these files (for helper functions) |

## Using get_composer_dependencies

The `get_composer_dependencies` MCP tool returns all Composer packages installed in the project with their exact versions. It reads from already-indexed `composer.lock` data — no disk I/O or network calls. In monorepo setups, packages from all `composer.json` sub-projects are included.

Use the optional `nameFilter` glob parameter to search for specific packages:
- `nameFilter: "laravel/*"` — find all Laravel packages
- `nameFilter: "*phpunit*"` — find PHPUnit-related packages
- `nameFilter: "symfony/console"` — find a specific package

Use this to:
- Detect which framework is installed
- Check if a specific library is available before suggesting its use
- Verify package versions for compatibility

## Security

Run `composer audit` to check for known vulnerabilities in dependencies. This checks against the PHP Security Advisories Database.

## Monorepo Considerations

In monorepo setups, `get_composer_dependencies` includes packages from all `composer.json` sub-projects:
- Each sub-project has its own dependency tree
- Sub-projects may have different PHP version requirements
- Use the `composer.json` closest to the file being edited

## External References

- Composer docs: https://getcomposer.org/doc/
- Packagist (package registry): https://packagist.org/
- Version constraints: https://getcomposer.org/doc/articles/versions.md
- Composer security advisories: https://github.com/FriendsOfPHP/security-advisories