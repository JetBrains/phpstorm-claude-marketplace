---
name: php-code-review
description: Review PHP code using PhpStorm inspections. Use when editing PHP files, reviewing code quality, fixing PHP issues, or when asked about PHP best practices.
---

# PHP Code Review Skill

Use PhpStorm's inspection engine to ensure PHP code quality. This skill provides access to the same inspections shown in the IDE editor.

## When to Use

- After editing PHP files (`.php`, `.phtml`)
- When user asks to review PHP code quality
- When fixing PHP-related issues
- When asked about PHP best practices for this codebase

## Workflow

### 1. Run Inspections

Call `get_inspections` to analyze a PHP file:

```
get_inspections(
  filePath: "path/to/file.php",
  minSeverity: "WEAK_WARNING"  # or ERROR, WARNING, INFORMATION
)
```

Returns problems with:
- **severity**: ERROR > WARNING > WEAK_WARNING > INFORMATION
- **line/column**: Exact location (1-based)
- **description**: What's wrong
- **quickFixes**: Available automated fixes (name + description)

### 2. Evaluate Results

- **ERROR**: Must fix - code may not work correctly
- **WARNING**: Should fix - potential bugs or bad practices
- **WEAK_WARNING**: Consider fixing - style or minor issues
- **INFORMATION**: Optional - suggestions for improvement

### 3. Apply Fixes

For issues with quick fixes, use `apply_quick_fix`:

```
apply_quick_fix(
  filePath: "path/to/file.php",
  line: 42,
  column: 10,
  quickFixName: "Safe delete '$unusedVar'"
)
```

**Note**: The `quickFixName` must match exactly what was returned by `get_inspections`. The tool re-runs highlighting at the specified location to find and apply the matching fix.

For issues without quick fixes, edit the file manually.

### 4. Verify

Re-run inspections to confirm issues are resolved.
