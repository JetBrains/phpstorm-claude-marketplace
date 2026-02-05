# Laravel Framework Guide

## Directory Structure Quick Reference

| Directory | Purpose |
|-----------|---------|
| `app/Models/` | Eloquent model classes (singular naming: `User`, `Post`) |
| `app/Http/Controllers/` | Route controllers |
| `app/Http/Middleware/` | HTTP middleware |
| `app/Http/Requests/` | Form request validation classes |
| `app/Providers/` | Service providers |
| `app/Services/` | Business logic (convention, not enforced) |
| `config/` | Configuration files (e.g., `config/database.php`) |
| `database/factories/` | Model factories for testing |
| `database/migrations/` | Database schema migrations |
| `database/seeders/` | Database seeders |
| `resources/views/` | Blade templates (`.blade.php`) |
| `routes/web.php` | Web routes (session, CSRF) |
| `routes/api.php` | API routes (stateless, token auth) |
| `tests/Feature/` | Feature/integration tests |
| `tests/Unit/` | Unit tests |
| `storage/` | Logs, cache, file uploads |

## Key Concepts

### Eloquent Models

- Located in `app/Models/` by convention
- Class name is **singular** (`User`), table name is **plural** (`users`) by default
- **`$fillable`**: Whitelist of mass-assignable attributes
- **`$guarded`**: Blacklist of non-mass-assignable attributes
- **`$casts`**: Attribute type casting (e.g., `'email_verified_at' => 'datetime'`)

**Before writing any Eloquent code**, verify the actual schema by reading migration files or using `php artisan model:show`.

### Migrations

Located in `database/migrations/`. File names include timestamps for ordering:
```
2024_01_15_000000_create_users_table.php
```

Read migration files to understand the actual database schema when `php artisan model:show` is not available.

### Routes

| File | Middleware | Use Case |
|------|-----------|----------|
| `routes/web.php` | `web` (session, CSRF, cookies) | Browser-facing pages |
| `routes/api.php` | `api` (stateless, rate limiting) | API endpoints |
| `routes/console.php` | None | Artisan command definitions |

**Route model binding**: `Route::get('/users/{user}', ...)` automatically resolves `{user}` to a `User` model instance.

### Controllers

- Located in `app/Http/Controllers/`
- **Resource controllers** provide CRUD methods: `index`, `create`, `store`, `show`, `edit`, `update`, `destroy`
- **Invocable controllers** have a single `__invoke()` method

### Form Requests

- Located in `app/Http/Requests/`
- Encapsulate validation rules and authorization logic
- Method `rules()` returns validation rules array
- Method `authorize()` returns boolean for authorization

### Blade Templates

- Located in `resources/views/`
- Use `.blade.php` extension
- Directives: `@if`, `@foreach`, `@extends`, `@section`, `@yield`, `@include`, `@component`
- Echo: `{{ $variable }}` (escaped), `{!! $html !!}` (raw)

### Service Container and Dependency Injection

- Laravel auto-resolves constructor dependencies via the service container
- Prefer **constructor injection** over facades for testability
- **Facades** (e.g., `Cache::get()`) are static proxies to container-resolved instances
- Service providers in `app/Providers/` register bindings

## Essential Artisan Commands

| Command | Purpose |
|---------|---------|
| `php artisan model:show Model` | Inspect model schema, relationships, attributes |
| `php artisan route:list` | List all registered routes |
| `php artisan make:model Name -mfc` | Generate model + migration + factory + controller |
| `php artisan make:controller Name` | Generate controller |
| `php artisan make:request Name` | Generate form request |
| `php artisan make:test Name` | Generate test (Feature by default) |
| `php artisan make:test Name --unit` | Generate unit test |
| `php artisan migrate` | Run pending migrations |
| `php artisan migrate:rollback` | Roll back last migration batch |
| `php artisan test` | Run test suite |
| `php artisan tinker` | Interactive REPL with app context |
| `php artisan config:clear` | Clear configuration cache |
| `php artisan cache:clear` | Clear application cache |

## Structural Search Patterns for Laravel

Use `search_structural` with `fileType: "PHP"` to find common Laravel patterns.
Pattern variables use `$name$` syntax:

| Pattern | What It Finds |
|---------|---------------|
| `$model$::where($args$)` | Eloquent query builders |
| `Route::get($args$)` | GET route definitions |
| `Route::post($args$)` | POST route definitions |
| `$model$::factory()` | Factory usage |
| `$var$->hasMany($args$)` | HasMany relationships |
| `$var$->belongsTo($args$)` | BelongsTo relationships |

## Environment Configuration

- `.env` — local environment variables (gitignored, **never commit**)
- `.env.example` — template with placeholder values (committed)
- Access via `env('KEY')` (only in config files) or `config('app.key')` (everywhere else)

## External References

- Laravel docs: https://laravel.com/docs/
- Larastan (PHPStan for Laravel): https://github.com/larastan/larastan
- Laravel Pint (code style): https://laravel.com/docs/pint