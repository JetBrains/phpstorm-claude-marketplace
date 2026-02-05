# Static Analysis Tools

## PHPStan

### Detection

Config files: `phpstan.neon`, `phpstan.neon.dist`, or `phpstan.neon.local`
Package: `phpstan/phpstan` in `require-dev`

### Levels

PHPStan uses levels 0-9, each adding more checks:

| Level | What It Checks |
|-------|----------------|
| 0 | Basic checks: unknown classes, functions, methods |
| 1 | Possibly undefined variables, unknown magic methods |
| 2 | Unknown methods on all expressions (not just `$this`), validate PHPDocs |
| 3 | Return types, types assigned to properties |
| 4 | Dead code, unreachable branches |
| 5 | Argument types passed to methods |
| 6 | Missing typehints |
| 7 | Union type handling |
| 8 | Nullable types, method calls on nullable |
| 9 | Mixed type usage (strictest) |

### Running

```bash
./vendor/bin/phpstan analyse              # Analyse with config defaults
./vendor/bin/phpstan analyse src/          # Analyse specific directory
./vendor/bin/phpstan analyse --level=6    # Override level
```

### Baseline

Legacy projects use a baseline file to ignore existing errors:

```neon
includes:
    - phpstan-baseline.neon
```

The baseline captures existing errors so new code is held to a higher standard. Regenerate with `./vendor/bin/phpstan --generate-baseline`.

### Framework Extensions

| Package | Framework |
|---------|-----------|
| `larastan/larastan` | Laravel (model types, collection methods, facades) |
| `phpstan/phpstan-symfony` | Symfony (container types, form types) |
| `phpstan/phpstan-doctrine` | Doctrine (entity types, repository methods) |
| `phpstan/phpstan-phpunit` | PHPUnit (assertion types) |

## Psalm

### Detection

Config file: `psalm.xml` or `psalm.xml.dist`
Package: `vimeo/psalm` in `require-dev`

### Error Levels

Psalm uses levels 1-8 (1 = strictest, 8 = most permissive — **opposite to PHPStan**).

### Running

```bash
./vendor/bin/psalm                # Analyse with config defaults
./vendor/bin/psalm src/           # Analyse specific directory
./vendor/bin/psalm --show-info    # Include informational issues
```

### Baseline

Similar to PHPStan: `./vendor/bin/psalm --set-baseline=psalm-baseline.xml`

## PHP CS Fixer

### Detection

Config files: `.php-cs-fixer.php`, `.php-cs-fixer.dist.php`
Package: `friendsofphp/php-cs-fixer` in `require-dev`

### Running

```bash
./vendor/bin/php-cs-fixer fix              # Fix all files
./vendor/bin/php-cs-fixer fix src/         # Fix specific directory
./vendor/bin/php-cs-fixer fix --dry-run    # Preview changes without applying
./vendor/bin/php-cs-fixer fix --diff       # Show diff of changes
```

## PHP CodeSniffer

### Detection

Config files: `phpcs.xml`, `phpcs.xml.dist`, `.phpcs.xml`
Package: `squizlabs/php_codesniffer` in `require-dev`

### Running

```bash
./vendor/bin/phpcs              # Check code style
./vendor/bin/phpcbf             # Auto-fix code style issues
./vendor/bin/phpcs src/         # Check specific directory
```

## Laravel Pint

### Detection

Config file: `pint.json`
Package: `laravel/pint` in `require-dev` (included by default in Laravel projects)

### Running

```bash
./vendor/bin/pint              # Fix all files
./vendor/bin/pint --test       # Preview changes without applying
```

## Relationship to PhpStorm Inspections

PhpStorm's built-in inspections and external static analysis tools may report **different issues** for the same code. They are complementary:

- **PhpStorm inspections** (`get_inspections`): Real-time, IDE-integrated, includes quick fixes
- **PHPStan/Psalm**: Deeper type analysis, framework-specific rules, CI/CD integration

When both are available, use PhpStorm inspections for quick feedback during editing and external tools for comprehensive analysis.

## External References

- PHPStan: https://phpstan.org/user-guide/getting-started
- Psalm: https://psalm.dev/docs/
- PHP CS Fixer: https://cs.symfony.com/
- PHP CodeSniffer: https://github.com/PHPCSStandards/PHP_CodeSniffer