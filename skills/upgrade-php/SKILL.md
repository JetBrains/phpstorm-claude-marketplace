---
name: upgrade-php
description: "PHP Upgrade Assistant. Use when upgrading PHP version, fixing deprecations for a target PHP version, or scanning for PHP compatibility issues."
---

# PHP Upgrade Assistant

Helps upgrade a PHP project to a target PHP version by scanning for deprecations,
reporting issues, applying automated fixes after confirmation, and verifying the result.

## Activation and exit

- **Enter** when the user asks to:
  - Upgrade to a specific PHP version (e.g., "upgrade to PHP 8.4")
  - Fix PHP deprecations or compatibility issues
  - Scan for PHP version-related problems
- **Exit** when all identified issues are resolved/triaged, or the user cancels.

## Phase 1: Pre-check

### 1. Confirm target version

Ask the user for the **target PHP version** if not already stated.

### 2. Detect current PHP configuration

```
get_php_project_config()
```

This returns the configured PHP language level, interpreter details (name, path, local/remote),
and runtime information (exact version, loaded extensions, debuggers). Use it to determine the
current PHP version the project is targeting.

### 3. Check Composer project

```
get_composer_dependencies()
```

If no packages are returned, warn: *"No composer.json found. Proceeding with code-only scan."*

### 4. Confirm PHP version constraint

```
get_file_text_by_path(pathInProject: "composer.json")
```

Look for `"require": { "php": "..." }` and `config.platform.php`.
Report to the user: **Current: PHP >=X.Y → Target: PHP Z.W**

## Phase 2: Discovery (Scan)

Scan the project to build a complete issue inventory. **Do not fix anything yet.**

### Step 1: Find PHP files

```
find_files_by_glob(globPattern: "**/*.php")
```

Exclude `vendor/` from scanning. For large projects (>200 files), scan `src/`, `app/` first, then `tests/` separately.

### Step 2: Run deprecation inspections on each file

```
get_inspections(
  filePath: "<relative-path>",
  minSeverity: "WEAK_WARNING"
)
```

Common deprecation-related problems will have descriptions mentioning:
- Deprecated function/method usage
- PHP version-specific language level issues
- Deprecated string interpolation syntax (`${}`)
- Deprecated partially-supported callables
- Deprecated `implode()` argument order
- Deprecated serializable usage
- Deprecated cast expressions

### Step 3: Supplementary structural search (optional)

For patterns inspections may miss, use structural search:

```
# Dynamic properties (deprecated in PHP 8.2)
search_structural(
  pattern: "$obj$->$prop$ = $val$",
  fileType: "PHP",
  maxResults: 50
)
```

**Pattern syntax**: Use `$name$` for template variables (e.g., `$a$->$b$()` matches any method
call on any object). Use `$a${2,5}` for count constraints, `$a$+` for one-or-more, `$a$*` for
zero-or-more.

### Step 4: Build and present inventory

Categorize all discovered issues:

| Priority | Category                            | Count | Auto-fixable |
|----------|-------------------------------------|-------|--------------|
| **P0**   | Errors (breaking in target version) | N     | Y/N          |
| **P1**   | Deprecations (removed in target)    | N     | Y/N          |
| **P2**   | Deprecations (warned in target)     | N     | Y/N          |

Present this table to the user. **Wait for explicit confirmation before proceeding to fixes.**

## Phase 3: Fix

Apply fixes only after user confirmation. Process in priority order: P0 → P1 → P2.

### Auto-fixes (quick fix available)

For each problem where `quickFixes` is non-empty:

```
apply_quick_fix(
  filePath: "<path>",
  line: <line>,
  column: <column>,
  quickFixName: "<quickFixes[0].name>"
)
```

**Strategy:**

1. Process one file at a time — apply all fixes for that file before moving on.
2. After all fixes in a file, re-scan it to verify fixes took effect:
   ```
   get_inspections(filePath: "<path>", minSeverity: "WEAK_WARNING")
   ```
3. If re-scan shows new issues, attempt to fix (max 3 iterations per file).

### Manual fixes (no quick fix available)

When `quickFixes` is empty:

1. Read the problem `description` — it usually names the replacement.
2. Read the file context with `get_file_text_by_path`.
3. Apply the fix with `replace_text_in_file`.

Common manual fix patterns:

| Deprecation                         | Before                       | After                         |
|-------------------------------------|------------------------------|-------------------------------|
| Implicitly nullable params (8.4)    | `function f(Type $p = null)` | `function f(?Type $p = null)` |
| `${}` interpolation (8.2)           | `"Hello ${name}"`            | `"Hello {$name}"`             |
| Partially-supported callables (8.2) | `$c = "self::method"`        | `$c = self::method(...)`      |

If no replacement is documented, add a `// TODO: PHP <target> - <description>` comment
and include in the "Remaining" report.

### Update composer.json

After code fixes, update the PHP version constraint:

```
replace_text_in_file(
  pathInProject: "composer.json",
  oldText: "\"php\": \">=8.1\"",
  newText: "\"php\": \">=8.4\""
)
```

**Do NOT run `composer update` automatically.** Advise the user to run it manually.

## Phase 4: Verify

### 1. Re-scan modified files

Re-run `get_inspections` on all modified files with `minSeverity: "WEAK_WARNING"`.
Confirm zero remaining deprecation issues.

### 2. Suggest test run

Check for available test configurations:

```
get_run_configurations()
```

Suggest the user run their test suite. Do not execute tests automatically unless
the user explicitly asks.

### 3. Final report

```
PHP Upgrade Summary: X.Y → Z.W
────────────────────────────────
Files scanned:    N
Issues found:     M
Auto-fixed:       A
Manually fixed:   B
Remaining:        C (needs manual review)
composer.json:    Updated / Not updated

Next steps:
1. Run `composer update` to validate dependency compatibility
2. Run your test suite
3. Review files listed under "Remaining"
```

## Edge cases

| Case                           | Handling                                                      |
|--------------------------------|---------------------------------------------------------------|
| **No quick fix available**     | Apply manual fix or add TODO comment                          |
| **Breaking changes (P0)**      | Fix these first — code will fail at runtime                   |
| **Inspection timeout**         | Re-run with longer `timeout` or narrow to subdirectory        |
| **Large project (>500 files)** | Scan in batches of 50; offer to scope to specific directories |
| **Multiple composer.json**     | Ask user which sub-project to upgrade                         |
