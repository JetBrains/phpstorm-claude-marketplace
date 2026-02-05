# PHP Coding Standards and Language Features

## Coding Standards

### PER Coding Style (Current Standard)

The latest PHP coding standard, superseding PSR-12.

- **Reference**: https://www.php-fig.org/per/coding-style/
- 4-space indentation (no tabs)
- 120-character soft line length limit
- Unix LF line endings
- Opening brace on the same line for control structures, next line for classes/methods
- One `use` import per line, grouped by type (classes, functions, constants)
- `declare(strict_types=1)` as the first statement after `<?php`

### PSR-12 Extended Coding Style

Still widely used in existing projects.

- **Reference**: https://www.php-fig.org/psr/psr-12/
- Largely compatible with PER; PER adds clarifications and updates

### PSR-4 Autoloading

- **Reference**: https://www.php-fig.org/psr/psr-4/
- See `references/project-detection.md` for detailed mapping rules

### All PSR Standards

- **Reference**: https://www.php-fig.org/psr/

## PHP Version Detection

Read the `require.php` field in `composer.json`:

```json
"require": {
  "php": ">=8.2"
}
```

Also check `config.platform.php` which may override the effective version for dependency resolution.

**Rule**: Never use language features newer than the project's minimum PHP version.

## Modern PHP Features by Version

Check the project's PHP version before using any of these features.

### PHP 8.0

- **Named arguments**: `htmlspecialchars(string: $s, double_encode: false)`
- **Match expression**: `match($status) { 'active' => 1, default => 0 }`
- **Constructor promotion**: `public function __construct(private string $name) {}`
- **Union types**: `function foo(int|string $value): void`
- **Nullsafe operator**: `$user?->getAddress()?->getCity()`
- **`str_contains()`**, **`str_starts_with()`**, **`str_ends_with()`**

### PHP 8.1

- **Enums**: `enum Status: string { case Active = 'active'; }`
- **Readonly properties**: `public readonly string $name`
- **Fibers**: low-level concurrency primitive
- **Intersection types**: `function foo(Countable&Iterator $value): void`
- **`never` return type**: for functions that always throw or exit
- **First-class callable syntax**: `$fn = strlen(...)`

### PHP 8.2

- **Readonly classes**: `readonly class Point { ... }`
- **DNF types**: `(A&B)|null`
- **`true`, `false`, `null` as standalone types**
- **Constants in traits**
- **Deprecated**: dynamic properties (use `#[AllowDynamicProperties]` to opt in)

### PHP 8.3

- **Typed class constants**: `const string NAME = 'value';`
- **`json_validate()` function**
- **`#[Override]` attribute**: verify method actually overrides parent
- **Dynamic class constant fetch**: `$class::{$constName}`

### PHP 8.4

- **Property hooks**: `public string $name { get => ...; set => ...; }`
- **Asymmetric visibility**: `public private(set) string $name`
- **`new` without wrapping parentheses**: `new MyClass()->method()` (previously required `(new MyClass())->method()`)
- **`array_find()`**, **`array_any()`**, **`array_all()`** functions

## Anti-Patterns to Avoid

| Anti-Pattern | Why | Alternative |
|-------------|-----|-------------|
| `@` error suppression | Hides bugs silently | Proper error handling or null checks |
| `eval()` | Security risk, hard to debug | Use proper language constructs |
| Missing `declare(strict_types=1)` | Allows silent type coercion | Add to every PHP file |
| Untyped arrays for structured data | Hard to understand, error-prone | DTOs or value objects |
| `global` keyword | Hidden dependencies | Dependency injection |
| `extract()` | Creates variables from nowhere | Access array keys directly |
| Suppressing exceptions with empty `catch` | Hides failures | Log or rethrow |

## External References

- PHP-FIG standards: https://www.php-fig.org/psr/
- PHP version lifecycle: https://www.php.net/supported-versions.php
- PHP RFC process: https://wiki.php.net/rfc