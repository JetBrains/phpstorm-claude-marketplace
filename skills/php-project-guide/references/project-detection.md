# Project Detection and Structure

How to understand the structure of any PHP project by reading its configuration files.

## composer.json Anatomy

The `composer.json` file is the single source of truth for a PHP project's structure.

### Key Sections

| Section | Purpose |
|---------|---------|
| `require` | Production dependencies (including `php` version constraint) |
| `require-dev` | Development dependencies (test frameworks, static analysis) |
| `autoload` | PSR-4 namespace-to-directory mapping for production code |
| `autoload-dev` | PSR-4 mapping for test code |
| `scripts` | Custom commands (e.g., `test`, `lint`, `analyse`) |
| `config.platform.php` | Override PHP version for dependency resolution |

### Example

```json
{
  "require": {
    "php": ">=8.2",
    "laravel/framework": "^11.0"
  },
  "require-dev": {
    "phpunit/phpunit": "^11.0",
    "phpstan/phpstan": "^2.0"
  },
  "autoload": {
    "psr-4": {
      "App\\": "app/",
      "Database\\": "database/"
    }
  },
  "autoload-dev": {
    "psr-4": {
      "Tests\\": "tests/"
    }
  },
  "scripts": {
    "test": "phpunit",
    "analyse": "phpstan analyse"
  }
}
```

## PSR-4 Autoloading

PSR-4 maps namespace prefixes to base directories. Understanding this mapping is critical for placing files in the correct location.

### How It Works

Given `"App\\": "app/"`:
- Class `App\Models\User` → file `app/Models/User.php`
- Class `App\Http\Controllers\Api\UserController` → file `app/Http/Controllers/Api/UserController.php`

**Rules:**
1. The namespace prefix (`App\`) is replaced by the base directory (`app/`)
2. Each remaining namespace separator becomes a directory separator
3. The class name becomes the file name with `.php` extension
4. **Case matters** — `App\Models\User` must be in `app/Models/User.php`, not `app/models/user.php`

### Resolving FQCN to File Path

To find the file for a fully qualified class name (FQCN):

1. Read `autoload.psr-4` from `composer.json`
2. Find the longest matching namespace prefix
3. Replace the prefix with the corresponding directory
4. Convert remaining `\` to `/` and append `.php`

Example with mapping `"App\\": "app/"`:
- `App\Services\Payment\StripeGateway` → `app/Services/Payment/StripeGateway.php`

### Common Mistake

Do not confuse the namespace with the directory. The mapping is **not** always 1:1 with the folder name:
- `"Domain\\": "src/Domain/"` means `Domain\Order\Order` → `src/Domain/Order/Order.php` (not `Domain/Order/Order.php`)

## Common Directory Layouts

### Laravel

```
project-root/
├── app/
│   ├── Console/            # Artisan commands
│   ├── Events/             # Event classes
│   ├── Exceptions/         # Exception handlers
│   ├── Http/
│   │   ├── Controllers/    # Route controllers
│   │   ├── Middleware/      # HTTP middleware
│   │   └── Requests/       # Form request validation
│   ├── Jobs/               # Queue jobs
│   ├── Listeners/          # Event listeners
│   ├── Mail/               # Mailables
│   ├── Models/             # Eloquent models
│   ├── Notifications/      # Notifications
│   ├── Policies/           # Authorization policies
│   ├── Providers/          # Service providers
│   └── Services/           # Business logic (convention)
├── bootstrap/              # Framework bootstrapping
├── config/                 # Configuration files
├── database/
│   ├── factories/          # Model factories for testing
│   ├── migrations/         # Database migrations
│   └── seeders/            # Database seeders
├── public/                 # Web server document root
├── resources/
│   ├── css/                # Stylesheets
│   ├── js/                 # JavaScript
│   └── views/              # Blade templates
├── routes/
│   ├── api.php             # API routes
│   ├── console.php         # Console routes
│   └── web.php             # Web routes
├── storage/                # Logs, cache, uploads
├── tests/
│   ├── Feature/            # Feature/integration tests
│   └── Unit/               # Unit tests
├── .env.example            # Environment template
├── artisan                 # CLI entry point
├── composer.json
└── phpunit.xml(.dist)
```

### Symfony

```
project-root/
├── bin/
│   └── console             # CLI entry point
├── config/
│   ├── packages/           # Bundle configuration
│   ├── routes/             # Routing configuration
│   ├── bundles.php         # Registered bundles
│   ├── routes.yaml         # Main route config
│   └── services.yaml       # Service container config
├── migrations/             # Doctrine migrations
├── public/
│   └── index.php           # Web entry point
├── src/
│   ├── Command/            # Console commands
│   ├── Controller/         # Route controllers
│   ├── Entity/             # Doctrine entities
│   ├── EventSubscriber/    # Event subscribers
│   ├── Form/               # Form types
│   ├── Repository/         # Doctrine repositories
│   ├── Security/           # Authentication/authorization
│   └── Service/            # Business logic
├── templates/              # Twig templates
├── tests/                  # Test files
├── translations/           # Translation files
├── var/                    # Cache, logs (gitignored)
├── vendor/                 # Dependencies (gitignored)
├── .env                    # Environment variables
├── composer.json
└── phpunit.xml.dist
```

### Generic PHP (No Framework)

```
project-root/
├── src/                    # Application source code
├── tests/                  # Test files
├── public/                 # Web document root (if applicable)
├── vendor/                 # Dependencies (gitignored)
├── composer.json
└── phpunit.xml(.dist)
```

## Config Files and Their Meaning

| File | Indicates |
|------|-----------|
| `phpunit.xml` or `phpunit.xml.dist` | PHPUnit test configuration |
| `phpstan.neon` or `phpstan.neon.dist` | PHPStan static analysis config |
| `psalm.xml` | Psalm static analysis config |
| `.php-cs-fixer.php` or `.php-cs-fixer.dist.php` | PHP CS Fixer code style config |
| `phpcs.xml` or `phpcs.xml.dist` | PHP CodeSniffer code style config |
| `.env` | Environment variables — **never commit this file** |
| `.env.example` | Template for environment variables — safe to commit |
| `rector.php` | Rector automated refactoring config |
| `pint.json` | Laravel Pint code style config |

## Monorepo Detection

In monorepo setups, `get_composer_dependencies` includes packages from all `composer.json` sub-projects. If you find packages from different frameworks or conflicting versions, the project is likely a monorepo. Each `composer.json` represents a sub-project with its own dependencies and autoloading.

When working in a monorepo:
1. Identify which sub-project the target file belongs to
2. Use that sub-project's `composer.json` for autoloading resolution
3. Be aware that sub-projects may have different PHP version requirements