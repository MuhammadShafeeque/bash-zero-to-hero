# Appendix C: Troubleshooting Guide

This appendix provides solutions to common bash scripting problems and debugging techniques.

## Common Error Messages and Solutions

### 1. Permission Denied Errors

**Error:** `bash: ./script.sh: Permission denied`

**Cause:** Script doesn't have execute permissions.

**Solutions:**
```bash
# Add execute permission
chmod +x script.sh

# Or run with bash explicitly
bash script.sh

# Check current permissions
ls -l script.sh
```

**Error:** `mkdir: cannot create directory '/var/log/myapp': Permission denied`

**Cause:** Insufficient permissions to create directory.

**Solutions:**
```bash
# Run with sudo (if appropriate)
sudo mkdir -p /var/log/myapp

# Use a directory you have access to
LOG_DIR="$HOME/logs/myapp"
mkdir -p "$LOG_DIR"

# Check and modify permissions
sudo chown "$USER" /var/log/myapp
```

### 2. Variable and Command Errors

**Error:** `bash: command not found`

**Cause:** Command is not in PATH or doesn't exist.

**Solutions:**
```bash
# Check if command exists
command -v missing_command

# Check PATH
echo "$PATH"

# Use full path
/usr/local/bin/mycommand

# Install missing package (Ubuntu/Debian)
sudo apt-get install package-name

# Install missing package (CentOS/RHEL)
sudo yum install package-name
```

**Error:** `bash: VAR: unbound variable`

**Cause:** Using undefined variable with `set -u`.

**Solutions:**
```bash
# Check if variable is set before using
if [[ -n "${VAR:-}" ]]; then
    echo "VAR is set to: $VAR"
fi

# Provide default value
VAR="${VAR:-default_value}"

# Set variable before use
VAR="some_value"
echo "$VAR"
```

### 3. Syntax Errors

**Error:** `bash: syntax error near unexpected token`

**Common causes and solutions:**

```bash
# Missing quotes
# Bad
if [ $var = some value ]; then

# Good
if [[ "$var" == "some value" ]]; then

# Missing spaces around brackets
# Bad
if[$var -eq 1]; then

# Good
if [[ $var -eq 1 ]]; then

# Mismatched quotes
# Bad
echo "This is a string with 'mixed quotes"

# Good
echo "This is a string with 'mixed quotes'"

# Missing semicolon or newline before then/do
# Bad
if [[ condition ]] then

# Good
if [[ condition ]]; then
# or
if [[ condition ]]
then
```

### 4. File and Directory Issues

**Error:** `No such file or directory`

**Debugging steps:**
```bash
# Check if file exists
if [[ -f "$filename" ]]; then
    echo "File exists"
else
    echo "File does not exist: $filename"
fi

# Check directory exists
if [[ -d "$directory" ]]; then
    echo "Directory exists"
else
    echo "Directory does not exist: $directory"
fi

# List directory contents
ls -la "$(dirname "$filename")"

# Show current working directory
pwd

# Show absolute path
realpath "$filename"
```

**Error:** `Is a directory` when expecting a file

**Solution:**
```bash
# Check if it's a file (not directory)
if [[ -f "$path" ]]; then
    echo "It's a file"
elif [[ -d "$path" ]]; then
    echo "It's a directory"
else
    echo "Path doesn't exist"
fi
```

## Debugging Techniques

### 5. Shell Debugging Options

```bash
# Enable debugging at script start
#!/usr/bin/env bash
set -x  # Print commands before executing

# Enable debugging for specific sections
set -x
complex_function_call
set +x

# Show variable assignments and expansions
set -v

# Combination for maximum debugging
set -xv

# Debug mode with conditional output
DEBUG=${DEBUG:-false}
if [[ "$DEBUG" == "true" ]]; then
    set -x
fi
```

### 6. Adding Debug Output

```bash
# Debug function
debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo "[DEBUG $(date +'%H:%M:%S')] $*" >&2
    fi
}

# Usage examples
debug "Starting function with args: $*"
debug "Variable value: VAR=$VAR"
debug "Current directory: $(pwd)"

# Trace function entry/exit
trace() {
    local func_name="$1"
    shift
    
    debug "→ Entering $func_name($*)"
    "$func_name" "$@"
    local exit_code=$?
    debug "← Exiting $func_name (exit code: $exit_code)"
    
    return $exit_code
}
```

### 7. Variable Inspection

```bash
# Show all variables
debug_variables() {
    echo "=== Variable Dump ==="
    echo "Script: $0"
    echo "Args: $*"
    echo "Arg count: $#"
    echo "PID: $$"
    echo "Working dir: $(pwd)"
    echo "User: $(whoami)"
    echo "PATH: $PATH"
    echo "===================="
}

# Show specific variables
debug_vars() {
    local vars=("$@")
    for var in "${vars[@]}"; do
        echo "$var = ${!var:-<unset>}"
    done
}

# Usage
debug_vars USER HOME PWD
```

## Common Scripting Pitfalls

### 8. Quoting Issues

```bash
# Problem: Unquoted variables with spaces
file="my document.txt"
cp $file /backup/  # Fails! Tries to copy "my" and "document.txt"

# Solution: Always quote variables
cp "$file" /backup/

# Problem: Command substitution not quoted
files=$(find . -name "*.txt")
for file in $files; do  # Breaks on filenames with spaces
    echo "$file"
done

# Solution: Use arrays or quote properly
while IFS= read -r -d '' file; do
    echo "$file"
done < <(find . -name "*.txt" -print0)

# Or use array
files=()
while IFS= read -r -d '' file; do
    files+=("$file")
done < <(find . -name "*.txt" -print0)
```

### 9. Array and Loop Issues

```bash
# Problem: Wrong array syntax
arr=(one two three)
echo $arr        # Only prints first element
echo ${arr}      # Only prints first element

# Solution: Proper array access
echo "${arr[0]}"   # First element
echo "${arr[@]}"   # All elements
echo "${#arr[@]}"  # Array length

# Problem: Wrong loop variable scope
for i in {1..5}; do
    result=$(some_command)
done
echo "$result"  # Only has last iteration value

# Solution: Accumulate results
results=()
for i in {1..5}; do
    result=$(some_command)
    results+=("$result")
done
```

### 10. Subprocess and Pipeline Issues

```bash
# Problem: Exit code lost in pipeline
grep "pattern" file.txt | wc -l
echo $?  # Shows exit code of 'wc', not 'grep'

# Solution: Check PIPESTATUS
grep "pattern" file.txt | wc -l
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    echo "grep failed"
fi

# Problem: Variables in subshells
counter=0
cat file.txt | while read line; do
    ((counter++))
done
echo "$counter"  # Still 0! Loop ran in subshell

# Solution: Use process substitution
counter=0
while read line; do
    ((counter++))
done < file.txt
echo "$counter"  # Correct count
```

## Performance Troubleshooting

### 11. Slow Script Diagnosis

```bash
# Time script execution
time ./my_script.sh

# Time specific functions
time_function() {
    local func_name="$1"
    shift
    
    local start_time=$(date +%s.%N)
    "$func_name" "$@"
    local exit_code=$?
    local end_time=$(date +%s.%N)
    
    local duration=$(echo "$end_time - $start_time" | bc)
    echo "Function $func_name took ${duration}s" >&2
    
    return $exit_code
}

# Profile script with timestamps
profile() {
    echo "[$(date +'%H:%M:%S.%3N')] $*" >&2
}

# Usage
profile "Starting data processing"
process_data
profile "Data processing complete"
```

### 12. Memory Usage Issues

```bash
# Monitor memory usage
monitor_memory() {
    local pid=$1
    while kill -0 "$pid" 2>/dev/null; do
        ps -o pid,vsz,rss,comm "$pid"
        sleep 1
    done
}

# Check for memory leaks in loops
process_files() {
    local files=("$@")
    
    for file in "${files[@]}"; do
        # Process file
        process_single_file "$file"
        
        # Clear large variables
        unset large_array
        
        # Monitor memory every 100 files
        if (( (i++ % 100) == 0 )); then
            echo "Memory usage: $(ps -o rss= $$) KB"
        fi
    done
}
```

## Error Recovery Strategies

### 13. Retry Logic

```bash
# Retry function with exponential backoff
retry() {
    local max_attempts=$1
    local delay=$2
    local command=("${@:3}")
    
    local attempt=1
    while [[ $attempt -le $max_attempts ]]; do
        if "${command[@]}"; then
            return 0
        fi
        
        echo "Attempt $attempt failed. Retrying in ${delay}s..." >&2
        sleep "$delay"
        
        ((attempt++))
        delay=$((delay * 2))  # Exponential backoff
    done
    
    echo "All $max_attempts attempts failed" >&2
    return 1
}

# Usage
retry 3 1 curl -f "https://api.example.com/data"
```

### 14. Graceful Degradation

```bash
# Fallback strategies
safe_command() {
    local primary_cmd=("$@")
    
    # Try primary command
    if "${primary_cmd[@]}"; then
        return 0
    fi
    
    # Fallback strategies
    case "${primary_cmd[0]}" in
        curl)
            echo "curl failed, trying wget..." >&2
            wget -O - "${primary_cmd[2]}"
            ;;
        git)
            echo "git failed, using fallback method..." >&2
            # Alternative implementation
            ;;
        *)
            echo "No fallback available for ${primary_cmd[0]}" >&2
            return 1
            ;;
    esac
}
```

## Testing and Validation

### 15. Unit Testing for Bash

```bash
# Simple test framework
test_count=0
pass_count=0

assert_equals() {
    local expected="$1"
    local actual="$2"
    local description="$3"
    
    ((test_count++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✓ $description"
        ((pass_count++))
    else
        echo "✗ $description"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
    fi
}

assert_success() {
    local command=("$@")
    
    ((test_count++))
    
    if "${command[@]}"; then
        echo "✓ Command succeeded: ${command[*]}"
        ((pass_count++))
    else
        echo "✗ Command failed: ${command[*]}"
    fi
}

# Run tests
run_tests() {
    echo "Running tests..."
    
    # Test examples
    assert_equals "hello" "$(echo hello)" "echo command"
    assert_success test -f "/etc/passwd"
    
    echo
    echo "Tests: $test_count, Passed: $pass_count, Failed: $((test_count - pass_count))"
    
    if [[ $pass_count -eq $test_count ]]; then
        echo "All tests passed!"
        return 0
    else
        echo "Some tests failed!"
        return 1
    fi
}
```

### 16. Validation Scripts

```bash
# Pre-deployment validation
validate_environment() {
    local errors=0
    
    echo "Validating environment..."
    
    # Check required commands
    local required_commands=(git curl rsync)
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "✗ Missing required command: $cmd"
            ((errors++))
        else
            echo "✓ Found command: $cmd"
        fi
    done
    
    # Check required directories
    local required_dirs=("/tmp" "/var/log")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo "✗ Missing required directory: $dir"
            ((errors++))
        elif [[ ! -w "$dir" ]]; then
            echo "✗ Directory not writable: $dir"
            ((errors++))
        else
            echo "✓ Directory accessible: $dir"
        fi
    done
    
    # Check environment variables
    local required_vars=(HOME USER PATH)
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            echo "✗ Missing environment variable: $var"
            ((errors++))
        else
            echo "✓ Environment variable set: $var"
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        echo "✓ Environment validation passed"
        return 0
    else
        echo "✗ Environment validation failed ($errors errors)"
        return 1
    fi
}
```

## Quick Reference for Common Issues

### Command Quick Fixes

| Issue | Quick Fix |
|-------|-----------|
| Permission denied | `chmod +x script.sh` |
| Command not found | `which command` or `type command` |
| Unbound variable | Use `${VAR:-default}` |
| Syntax error | Check quotes, spaces, semicolons |
| File not found | Check path with `ls -la` |
| Wrong exit code | Check `$?` immediately after command |
| Loop variable lost | Avoid pipes, use process substitution |
| Array issues | Use `"${array[@]}"` for all elements |
| Slow performance | Add `time` and profiling |
| Memory leaks | Unset large variables, monitor RSS |

### Debugging Checklist

1. **Enable strict mode**: `set -euo pipefail`
2. **Add debug output**: Use `set -x` or debug functions
3. **Check file permissions**: `ls -la`
4. **Verify paths**: Use absolute paths when possible
5. **Test small parts**: Isolate problematic sections
6. **Check environment**: Validate required tools/variables
7. **Use shellcheck**: Static analysis tool for bash
8. **Test with different inputs**: Edge cases and empty values
9. **Monitor resources**: CPU, memory, disk usage
10. **Add logging**: Comprehensive error and audit logs

Remember: Good debugging practices and preventive coding are worth more than fixing bugs later!
