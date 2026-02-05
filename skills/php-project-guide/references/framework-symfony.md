# Symfony Framework Guide

## Directory Structure Quick Reference

| Directory | Purpose |
|-----------|---------|
| `src/` | Application source code (controllers, entities, services) |
| `src/Controller/` | Route controllers |
| `src/Entity/` | Doctrine ORM entities |
| `src/Repository/` | Doctrine repositories |
| `src/Command/` | Console commands |
| `src/Form/` | Form types |
| `src/EventSubscriber/` | Event subscribers |
| `src/Security/` | Authentication and authorization |
| `config/` | Application configuration |
| `config/packages/` | Bundle-specific configuration |
| `config/routes/` | Routing definitions |
| `config/services.yaml` | Service container configuration |
| `migrations/` | Doctrine database migrations |
| `templates/` | Twig templates |
| `tests/` | Test files |
| `translations/` | Translation files |
| `public/` | Web server document root |
| `var/` | Cache and logs (gitignored) |

## Key Concepts

### Service Container and Autowiring

Symfony's core is its dependency injection container.

- **Autowiring**: Services are automatically resolved by type-hinting constructor parameters
- **`config/services.yaml`**: Configures service registration and argument binding
- Services in `src/` are auto-registered by default
- **Tags**: Mark services for specific purposes (e.g., `kernel.event_subscriber`)

### Configuration

Symfony supports YAML, PHP, and XML configuration:

- `config/packages/` — per-bundle settings (e.g., `doctrine.yaml`, `security.yaml`)
- `config/services.yaml` — service definitions and parameters
- `config/routes.yaml` — route imports (or use PHP attributes on controllers)
- `config/bundles.php` — registered bundles

### Doctrine ORM

Symfony's default database layer.

**Entities** (`src/Entity/`):
- Annotated PHP classes mapped to database tables
- Use `#[ORM\Entity]`, `#[ORM\Column]`, `#[ORM\Id]` attributes
- Naming: entity `User` maps to table `user` by default

**Repositories** (`src/Repository/`):
- Custom query methods extending `ServiceEntityRepository`
- Injected via autowiring: type-hint `UserRepository` in constructors

**Migrations** (`migrations/`):
- Generated with `php bin/console make:migration`
- Applied with `php bin/console doctrine:migrations:migrate`

### Routing

Two main styles:

**PHP Attributes (preferred)**:
```php
#[Route('/users/{id}', name: 'user_show', methods: ['GET'])]
public function show(User $user): Response { ... }
```

**YAML** (`config/routes.yaml`):
```yaml
user_show:
    path: /users/{id}
    controller: App\Controller\UserController::show
    methods: [GET]
```

### Twig Templates

- Located in `templates/`
- Extension: `.html.twig`
- Syntax: `{{ variable }}` for output, `{% block %}` for structure, `{# comment #}`
- Inheritance: `{% extends 'base.html.twig' %}` with `{% block content %}...{% endblock %}`

### Console Commands

- Located in `src/Command/`
- Extend `Symfony\Component\Console\Command\Command`
- Auto-registered via service container

### Forms and Validation

- Form types in `src/Form/` define field structure
- Validation uses `#[Assert\*]` attributes on entity properties
- Built-in constraints: `NotBlank`, `Email`, `Length`, `Valid`, `UniqueEntity`

## Essential CLI Commands

| Command | Purpose |
|---------|---------|
| `php bin/console debug:router` | List all routes |
| `php bin/console debug:container` | List all services |
| `php bin/console debug:config BundleName` | Show bundle configuration |
| `php bin/console doctrine:schema:validate` | Validate entity mapping vs database |
| `php bin/console doctrine:migrations:migrate` | Run pending migrations |
| `php bin/console make:controller Name` | Generate controller |
| `php bin/console make:entity Name` | Generate Doctrine entity |
| `php bin/console make:form Name` | Generate form type |
| `php bin/console make:migration` | Generate migration from entity changes |
| `php bin/console make:command Name` | Generate console command |
| `php bin/console cache:clear` | Clear application cache |

## Testing in Symfony

| Test Type | Base Class | Use Case |
|-----------|-----------|----------|
| Unit | `PHPUnit\Framework\TestCase` | Pure logic, no container |
| Integration | `KernelTestCase` | Tests needing services |
| Functional | `WebTestCase` | HTTP request/response testing |

```php
// Functional test example
class UserControllerTest extends WebTestCase
{
    public function test_user_page_loads(): void
    {
        $client = static::createClient();
        $client->request('GET', '/users');
        $this->assertResponseIsSuccessful();
    }
}
```

## External References

- Symfony docs: https://symfony.com/doc/current/index.html
- Doctrine ORM: https://www.doctrine-project.org/projects/orm.html
- Twig docs: https://twig.symfony.com/doc/
- Symfony best practices: https://symfony.com/doc/current/best_practices.html