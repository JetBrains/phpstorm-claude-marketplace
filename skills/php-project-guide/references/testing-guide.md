# PHP Testing Guide

## Detecting the Test Framework

Check `require-dev` in `composer.json` or use `get_composer_dependencies`:

| Package | Framework | Syntax |
|---------|-----------|--------|
| `phpunit/phpunit` | PHPUnit | `$this->assert*()` in classes extending `TestCase` |
| `pestphp/pest` | Pest | `it()` / `test()` closures with `expect()` chains |
| `codeception/codeception` | Codeception | Step-based `$I->...` syntax |
| `behat/behat` | Behat | Gherkin `.feature` files with PHP step definitions |

Most projects use **PHPUnit** or **Pest**. Pest is built on PHPUnit — any PHPUnit assertion works inside Pest tests too.

## PHPUnit Patterns

### Test Class Structure

```php
<?php

declare(strict_types=1);

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class CalculatorTest extends TestCase
{
    public function test_adds_two_numbers(): void
    {
        $calculator = new Calculator();
        $this->assertEquals(4, $calculator->add(2, 2));
    }
}
```

**Conventions:**
- File naming: `*Test.php` (e.g., `CalculatorTest.php`)
- Class naming: `*Test` extending `TestCase`
- Method naming: `test_*` prefix **or** `@test` annotation / `#[Test]` attribute
- One test class per file

### Important: Base Class Selection

| Project Type | Base Class | Why |
|-------------|-----------|-----|
| Generic PHP | `PHPUnit\Framework\TestCase` | No framework container needed |
| Laravel | `Tests\TestCase` | Boots the Laravel application container |
| Symfony | `Symfony\Bundle\FrameworkBundle\Test\KernelTestCase` or `WebTestCase` | Boots the Symfony kernel |

**Common mistake**: Using `PHPUnit\Framework\TestCase` in a Laravel feature test — this skips the app container and causes `Target class [X] does not exist` errors.

### Common Assertions

| Assertion | Purpose |
|-----------|---------|
| `assertEquals($expected, $actual)` | Equality with type coercion |
| `assertSame($expected, $actual)` | Strict equality (type + value) |
| `assertTrue($condition)` | Boolean true |
| `assertFalse($condition)` | Boolean false |
| `assertNull($value)` | Null check |
| `assertCount($expected, $array)` | Array/collection count |
| `assertInstanceOf(Class::class, $obj)` | Type check |
| `assertStringContainsString($needle, $haystack)` | Substring check |
| `assertArrayHasKey($key, $array)` | Array key existence |

### Data Providers

Supply multiple test cases to a single test method:

```php
#[DataProvider('additionProvider')]
public function test_addition(int $a, int $b, int $expected): void
{
    $this->assertEquals($expected, $a + $b);
}

public static function additionProvider(): array
{
    return [
        'positive numbers' => [1, 2, 3],
        'negative numbers' => [-1, -2, -3],
        'zero' => [0, 0, 0],
    ];
}
```

**Note**: Use `#[DataProvider]` attribute (PHP 8+) or `@dataProvider` annotation. The provider method must be `static` in PHPUnit 10+.

### Mocking

```php
$mock = $this->createMock(PaymentGateway::class);
$mock->expects($this->once())
     ->method('charge')
     ->with(100, 'USD')
     ->willReturn(true);

$service = new OrderService($mock);
$result = $service->processPayment(100, 'USD');
$this->assertTrue($result);
```

Key mocking methods:
- `createMock(Class::class)` — creates mock with all methods stubbed (returns `null`)
- `createStub(Class::class)` — like `createMock` but does not verify expectations
- `expects($this->once())` — verify call count
- `willReturn($value)` — set return value
- `willThrowException(new \Exception())` — simulate errors

## Pest Patterns

### Test Structure

```php
<?php

use App\Models\User;

it('can create a user', function () {
    $user = User::factory()->create();
    expect($user)->toBeInstanceOf(User::class);
});

test('user has a name', function () {
    $user = User::factory()->create(['name' => 'John']);
    expect($user->name)->toBe('John');
});
```

**`it()` vs `test()`**: Both are identical. Convention: `it('does something')` reads as a sentence; `test('something works')` is more descriptive.

### Expectation API

```php
expect($value)
    ->toBe('exact')           // assertSame
    ->toEqual('loose')        // assertEquals
    ->toBeTrue()              // assertTrue
    ->toBeFalse()             // assertFalse
    ->toBeNull()              // assertNull
    ->toHaveCount(3)          // assertCount
    ->toBeInstanceOf(Foo::class)
    ->toContain('substring')
    ->toBeEmpty()
    ->toBeGreaterThan(5)
    ->toMatchArray(['key' => 'value']);
```

### Lifecycle Hooks

```php
beforeEach(function () {
    $this->calculator = new Calculator();
});

afterEach(function () {
    // cleanup
});
```

### Datasets (Data Providers)

```php
it('adds numbers correctly', function (int $a, int $b, int $expected) {
    expect($a + $b)->toBe($expected);
})->with([
    [1, 2, 3],
    [-1, -2, -3],
    [0, 0, 0],
]);
```

## Running Tests

### Commands

| Runner | Command | Single file | Single test |
|--------|---------|-------------|-------------|
| PHPUnit | `./vendor/bin/phpunit` | `./vendor/bin/phpunit tests/Unit/FooTest.php` | `./vendor/bin/phpunit --filter test_method_name` |
| Pest | `./vendor/bin/pest` | `./vendor/bin/pest tests/Unit/FooTest.php` | `./vendor/bin/pest --filter "test name"` |
| Laravel | `php artisan test` | `php artisan test tests/Feature/FooTest.php` | `php artisan test --filter test_method_name` |

### Configuration

`phpunit.xml(.dist)` controls:
- Test suite directories and file patterns
- Environment variables for testing
- Code coverage settings
- Bootstrap file (typically `vendor/autoload.php`)

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Wrong `TestCase` base class | Container not booted | Use framework's `TestCase` for feature tests |
| Missing `RefreshDatabase` trait | Stale data between tests | Add `use RefreshDatabase;` for DB tests |
| Hardcoded IDs | Test depends on insertion order | Use factory-created models |
| Not using `--filter` | Running entire suite for one test | `--filter test_name` for fast feedback |
| Inventing factory states | `State [x] not found` error | Read the factory file first to check available states |
| Static provider not `static` | PHPUnit 10+ error | Add `static` keyword to data provider methods |

## External References

- PHPUnit docs: https://docs.phpunit.de/
- Pest docs: https://pestphp.com/docs/writing-tests
- PhpStorm test integration: https://www.jetbrains.com/help/phpstorm/php-test-frameworks.html