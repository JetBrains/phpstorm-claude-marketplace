# PhpStorm MCP Tools Reference

Detailed usage guide for MCP tools provided by the PhpStorm JetBrains IDE plugin.

## get_inspections

Analyze a file using the IDE's inspections. Returns problems with severity, description, location, and available quick fixes.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `filePath` | string | (required) | Path to file, relative to project root |
| `minSeverity` | string | `"WEAK_WARNING"` | Minimum severity: `ERROR`, `WARNING`, `WEAK_WARNING`, `INFORMATION` |
| `timeout` | int | (IDE default) | Timeout in milliseconds |

### Severity Levels

| Severity | Typical Issues |
|----------|----------------|
| `ERROR` | Syntax errors, unresolved symbols, type mismatches |
| `WARNING` | Potential bugs, missing overrides |
| `WEAK_WARNING` | Code style, best practices, missing type hints |
| `INFORMATION` | Suggestions, hints |

**Note**: Most PHP inspections report at `WEAK_WARNING` level. Use `WEAK_WARNING` as the default to capture most issues. Use `ERROR` when you only want critical problems.

### Response Format

Each problem includes:
- `severity`: `ERROR`, `WARNING`, `WEAK_WARNING`, or `INFORMATION`
- `line`, `column`: 1-based location
- `description`: Human-readable problem description
- `quickFixes`: Array of available automated fixes (each with `name`)

### Difference from get_file_problems

| Feature | `get_inspections` | `get_file_problems` |
|---------|-------------------|---------------------|
| Quick fixes | Included with name | Not included |
| Filtering | By minimum severity | By `errorsOnly` flag |
| Use when | Need quick fixes or fine-grained severity control | Quick error check on any file type |

## apply_quick_fix

Apply an automated fix for a specific inspection problem.

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filePath` | string | Path to file, relative to project root |
| `line` | int | 1-based line number from inspection result |
| `column` | int | 1-based column number from inspection result |
| `quickFixName` | string | Exact name from the `quickFixes` array |

### Workflow

1. **Always run `get_inspections` first** — you need the exact `line`, `column`, and `quickFixName` values
2. **Match `quickFixName` exactly** — use the name string as returned by inspections
3. **Re-run inspections after applying** — verify the fix took effect and didn't introduce new issues

### Example

```
# Step 1: Find problems
get_inspections(filePath: "app/Services/UserService.php", minSeverity: "WARNING")
# Returns: line=15, column=9,
#          quickFixes=[{name: "Safe delete '$temp'"}]

# Step 2: Apply fix
apply_quick_fix(
  filePath: "app/Services/UserService.php",
  line: 15, column: 9,
  quickFixName: "Safe delete '$temp'"
)

# Step 3: Verify
get_inspections(filePath: "app/Services/UserService.php", minSeverity: "WARNING")
```

## search_structural

Search for code patterns using Structural Search and Replace (SSR). Unlike text/regex search, SSR understands code structure semantically.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pattern` | string | (required) | SSR pattern to search for |
| `fileType` | string | (required) | Language: `"PHP"`, `"Java"`, `"Kotlin"`, `"Python"` |
| `directoryToSearch` | string | (project root) | Directory scope, relative to project root |
| `constraints` | object | (none) | Variable constraints (see below) |
| `maxResults` | int | 100 | Maximum number of results to return |
| `timeout` | int | (IDE default) | Timeout in milliseconds |

### Pattern Syntax

Use `$name$` for template variables that match any expression:

| Pattern | Matches |
|---------|---------|
| `$a$->$b$()` | Any method call on any object |
| `$a$->$b$` | Any property access on any object |
| `new $Class$()` | Any object instantiation |
| `class $a$ extends $b$ {}` | Any class that extends another |
| `$a$::$b$()` | Any static method call |
| `$a$ = $b$` | Any assignment |

**Count modifiers** (in pattern):
- `$a${2,5}` — matches 2 to 5 occurrences
- `$a$+` — one or more occurrences
- `$a$*` — zero or more occurrences

### Constraints

Constraints refine what template variables can match. Use the variable name **without** dollar signs as the key:

```json
{
  "a": {
    "regex": "User.*",
    "exprType": "App\\Models\\User"
  },
  "b": {
    "minCount": 1,
    "maxCount": 5
  }
}
```

| Constraint | Purpose |
|------------|---------|
| `regex` | Variable text must match this regex |
| `invertRegex` | Invert the regex match |
| `exprType` | Expression must be of this PHP type |
| `invertExprType` | Invert the expression type match |
| `minCount` | Minimum number of occurrences |
| `maxCount` | Maximum number of occurrences |
| `wholeWordsOnly` | Match whole words only |
| `withinHierarchy` | Include type hierarchy in matching |

### Practical Examples

```
# Find all Eloquent where() calls
search_structural(pattern: "$model$::where($args$)", fileType: "PHP")

# Find all class definitions extending Model
search_structural(pattern: "class $name$ extends Model {}", fileType: "PHP")

# Find all route definitions in routes directory
search_structural(
  pattern: "Route::$method$($args$)",
  fileType: "PHP",
  directoryToSearch: "routes"
)

# Find try-catch blocks with empty catch
search_structural(pattern: "try { $body$ } catch ($e$) { }", fileType: "PHP")

# Find method calls matching a regex on the method name
search_structural(
  pattern: "$a$->$b$()",
  fileType: "PHP",
  constraints: {"b": {"regex": "^get.*"}}
)
```

### Known Limitations

- Some class modifiers (e.g., `readonly`) may not be matched
- Complex nested patterns with constraints may not work as expected
- Use `get_structural_patterns` to discover reliably working patterns

## get_structural_patterns

List predefined PHP structural search patterns organized by category.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `category` | string | (all) | Filter by category: `"General"`, `"Expressions"`, `"Suspicious"` |

### Response

Returns categories of patterns with descriptions:

- **General**: Class, interface, trait definitions and structure
- **Expressions**: Assignments, method calls, field access, etc.
- **Suspicious**: Potentially problematic code patterns

Use these predefined patterns as templates — modify them for your specific search needs.

## get_composer_dependencies

Return all Composer packages installed in the project with their exact versions. Reads from already-indexed `composer.lock` data — no disk I/O or network calls.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `nameFilter` | string | (all) | Glob pattern to filter packages (e.g., `"laravel/*"`, `"*phpunit*"`, `"symfony/console"`). Case-insensitive. |

### Use Cases

| Use Case | How |
|----------|-----|
| Detect framework | Filter with `nameFilter: "laravel/*"` or check for `symfony/framework-bundle` |
| Check library availability | Search packages by name before suggesting usage |
| Verify versions | Check if a package version supports a feature |
| Find test framework | Filter with `nameFilter: "*phpunit*"` or `"*pest*"` |

### Example

```
get_composer_dependencies(nameFilter: "laravel/*")
# Returns packages matching the filter with exact versions
```

## get_php_project_config

Return the PHP project configuration as seen by PhpStorm.

### Parameters

None required.

### Response

Includes:
- **PHP language level**: The configured target PHP version (may differ from system PHP)
- **Interpreter details**: Name, path, local/remote
- **PHP runtime information**: Exact version, loaded extensions, php.ini path, debuggers

### Use Cases

- Determine the project's target PHP version before generating code
- Check if specific PHP extensions are available
- Understand if the interpreter is local or remote (Docker/SSH)

## get_symbol_info

Retrieve information about a symbol at a specific position in a file. Provides the same information as PhpStorm's Quick Documentation feature.

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filePath` | string | Path relative to project root |
| `line` | int | 1-based line number |
| `column` | int | 1-based column number |

### Response

Returns symbol information including name, signature, type, documentation, and declaration code when available.

### Use Cases

- Understand what a function/method does without reading the full source
- Check parameter types and return types
- Find where a symbol is declared
- Get PHPDoc documentation for a class or method

## rename_refactoring

Rename a symbol (variable, function, class, etc.) across the entire project. Unlike text search-and-replace, this understands code structure and updates all references safely.

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pathInProject` | string | Path to file containing the symbol, relative to project root |
| `symbolName` | string | Exact current name of the symbol |
| `newName` | string | New name for the symbol |

### Use Cases

- Rename a class, method, or variable and update all usages
- Safe refactoring that preserves code integrity
- Always preferred over manual find-and-replace for symbol renaming

## get_file_problems

Analyze a file for errors and warnings using IntelliJ's inspections. Lighter than `get_inspections` — does not return quick fixes.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `filePath` | string | (required) | Path relative to project root |
| `errorsOnly` | boolean | false | Only include errors (skip warnings) |
| `timeout` | int | (IDE default) | Timeout in milliseconds |

## Search Tools

PhpStorm provides multiple search tools optimized for different use cases:

| Tool | Best For | Key Feature |
|------|----------|-------------|
| `search_structural` | Code patterns (method calls, class definitions) | Semantic understanding of code structure |
| `search_text` | Known text substrings | Fast, with match coordinates |
| `search_regex` | Complex pattern matching | Full regex, with match coordinates |
| `search_symbol` | Finding classes, methods, fields by name | Semantic symbol lookup |
| `search_file` | Finding files by glob pattern | Glob-based file matching |
| `find_files_by_name_keyword` | Finding files by partial name | Fastest — uses IDE indexes |
| `find_files_by_glob` | Finding files by glob in subdirectories | Recursive glob matching |
| `search_in_files_by_text` | Full-project text search with context | Highlights matches with `||` markers |
| `search_in_files_by_regex` | Full-project regex search with context | Highlights matches with `||` markers |

## File Operation Tools

| Tool | Description |
|------|-------------|
| `read_file` | Read file with modes: slice, lines, line_columns, offsets, indentation |
| `get_file_text_by_path` | Read full file content by project-relative path |
| `replace_text_in_file` | Find and replace text in a file (supports regex) |
| `create_new_file` | Create a new file with optional content |
| `reformat_file` | Apply IDE code formatting rules to a file |
| `open_file_in_editor` | Open a file in the IDE editor |

## Execution Tools

| Tool | Description |
|------|-------------|
| `get_run_configurations` | List run/test configurations with command details |
| `execute_run_configuration` | Run a configuration and wait for results |
| `execute_terminal_command` | Execute shell command in IDE terminal |
| `build_project` | Trigger project build and get errors/warnings |
