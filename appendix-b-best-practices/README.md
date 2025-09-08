# Appendix B: Best Practices

This appendix outlines the best practices for writing robust, maintainable, and secure bash scripts.

## Script Structure and Organization

### 1. Script Header Template

Always start your scripts with a comprehensive header:

```bash
#!/usr/bin/env bash
#
# Script Name: backup_manager.sh
# Description: Automated backup management system
# Author: John Doe <john@example.com>
# Version: 2.1.0
# Date: 2024-01-15
# License: MIT
#
# Usage: ./backup_manager.sh [options] source destination
#
# Dependencies:
#   - rsync
#   - tar
#   - gzip
#
# Exit Codes:
#   0 - Success
#   1 - General error
#   2 - Invalid arguments
#   3 - Missing dependencies
#
# Examples:
#   ./backup_manager.sh --full /home/user /backup
#   ./backup_manager.sh --incremental --compress /data /backup
#

set -euo pipefail  # Exit on error, undefined variables, pipe failures
```

### 2. Script Organization

Structure your scripts logically:

```bash
#!/usr/bin/env bash

# ============================================================================
# CONFIGURATION AND CONSTANTS
# ============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly VERSION="1.0.0"
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"

# Default configuration
readonly DEFAULT_CONFIG_FILE="/etc/${SCRIPT_NAME%.sh}.conf"

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $*" | tee -a "$LOG_FILE" >&2
}

# ============================================================================
# MAIN FUNCTIONS
# ============================================================================

validate_dependencies() {
    local deps=("rsync" "tar" "gzip")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log_error "Required dependency '$dep' not found"
            exit 3
        fi
    done
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    validate_dependencies
    # Main script logic here
}

# Only execute main if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Error Handling and Safety

### 3. Use Strict Mode

Always use strict mode at the beginning of scripts:

```bash
#!/usr/bin/env bash

# Strict mode
set -euo pipefail

# Optional: Enable debug mode during development
# set -x

# Explanation:
# -e: Exit immediately if a command exits with non-zero status
# -u: Exit when using undefined variables
# -o pipefail: Fail on pipe command failures
```

### 4. Robust Error Handling

```bash
# Error handling function
handle_error() {
    local line_number="$1"
    local command="$2"
    local exit_code="$3"
    
    log_error "Error on line $line_number: Command '$command' failed with exit code $exit_code"
    cleanup
    exit "$exit_code"
}

# Set error trap
trap 'handle_error ${LINENO} "$BASH_COMMAND" $?' ERR

# Cleanup function
cleanup() {
    log_info "Performing cleanup..."
    # Remove temporary files
    [[ -n "${TEMP_DIR:-}" ]] && rm -rf "$TEMP_DIR"
    # Kill background processes
    [[ -n "${BACKGROUND_PID:-}" ]] && kill "$BACKGROUND_PID" 2>/dev/null || true
}

# Exit trap
trap cleanup EXIT
```

### 5. Input Validation

Always validate input parameters:

```bash
validate_input() {
    local email="$1"
    local age="$2"
    local file="$3"
    
    # Email validation
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_error "Invalid email format: $email"
        return 1
    fi
    
    # Age validation
    if [[ ! "$age" =~ ^[0-9]+$ ]] || [[ $age -lt 1 || $age -gt 120 ]]; then
        log_error "Invalid age: $age (must be 1-120)"
        return 1
    fi
    
    # File validation
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi
    
    if [[ ! -r "$file" ]]; then
        log_error "File not readable: $file"
        return 1
    fi
    
    return 0
}

# Usage
if ! validate_input "$email" "$age" "$file"; then
    show_usage
    exit 2
fi
```

## Variable and Function Best Practices

### 6. Variable Naming and Declaration

```bash
# Use meaningful variable names
user_home_directory="/home/user"
database_connection_string="mysql://user:pass@host/db"
backup_retention_days=30

# Use constants for unchanging values
readonly MAX_RETRIES=3
readonly CONFIG_FILE="/etc/myapp.conf"
readonly LOG_LEVEL="INFO"

# Use local variables in functions
process_user_data() {
    local username="$1"
    local email="$2"
    local temp_file
    
    temp_file=$(mktemp)
    # Process data
    rm "$temp_file"
}

# Use uppercase for environment variables
export DATABASE_URL="postgresql://localhost/myapp"
export LOG_LEVEL="DEBUG"

# Use arrays for lists
valid_extensions=("txt" "log" "conf")
backup_directories=("/home" "/etc" "/var/log")
```

### 7. Function Design

```bash
# Functions should do one thing well
calculate_file_checksum() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi
    
    md5sum "$file" | awk '{print $1}'
}

# Use descriptive function names
is_valid_ip_address() {
    local ip="$1"
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
}

# Document complex functions
backup_database() {
    # Purpose: Create a compressed backup of the specified database
    # Arguments:
    #   $1 - database name (required)
    #   $2 - backup directory (optional, default: /backup)
    # Returns:
    #   0 - success
    #   1 - database not found
    #   2 - backup failed
    # Side effects:
    #   Creates backup file in specified directory
    #   Logs backup operation
    
    local db_name="$1"
    local backup_dir="${2:-/backup}"
    
    # Implementation here...
}
```

## Quoting and Expansion

### 8. Proper Quoting

```bash
# Always quote variables to handle spaces and special characters
filename="my file with spaces.txt"
echo "Processing file: $filename"
cp "$filename" "$backup_dir/"

# Use arrays for command arguments
rsync_options=(-av --delete --exclude='*.tmp')
rsync "${rsync_options[@]}" "$source/" "$destination/"

# Quote command substitution
current_time="$(date +'%Y-%m-%d %H:%M:%S')"
user_list="$(getent passwd | cut -d: -f1)"

# Use double quotes for variable expansion
echo "Welcome, $username! Today is $(date +%A)"

# Use single quotes for literal strings
awk_script='BEGIN { FS=":" } { print $1 }'
sed_command='s/old/new/g'
```

### 9. Parameter Expansion

```bash
# Use parameter expansion for string manipulation
filename="document.pdf.backup"

# Get file extension
extension="${filename##*.}"

# Get filename without extension
basename="${filename%.*}"

# Get directory from path
path="/home/user/documents/file.txt"
directory="${path%/*}"

# Default values
config_file="${CONFIG_FILE:-/etc/default.conf}"
log_level="${LOG_LEVEL:-INFO}"
timeout="${TIMEOUT:-30}"

# Required parameters
database_url="${DATABASE_URL:?Database URL is required}"
```

## Performance and Efficiency

### 10. Efficient Scripting

```bash
# Use built-in commands when possible
# Good
if [[ -f "$file" ]]; then
    echo "File exists"
fi

# Avoid external commands for simple tasks
# Bad
if [ "$(ls -A "$directory" 2>/dev/null)" ]; then
    echo "Directory not empty"
fi

# Good
if [[ -n "$(ls -A "$directory" 2>/dev/null)" ]]; then
    echo "Directory not empty"
fi

# Use command substitution efficiently
# Good - single command
file_count=$(ls | wc -l)

# Better - avoid pipe when possible
files=(*)
file_count=${#files[@]}

# Process files in batches
process_files_batch() {
    local files=("$@")
    local batch_size=10
    
    for ((i=0; i<${#files[@]}; i+=batch_size)); do
        local batch=("${files[@]:i:batch_size}")
        for file in "${batch[@]}"; do
            process_file "$file" &
        done
        wait  # Wait for batch to complete
    done
}
```

### 11. Memory Management

```bash
# Use temporary files appropriately
create_temp_file() {
    local temp_file
    temp_file=$(mktemp) || {
        log_error "Failed to create temporary file"
        return 1
    }
    
    # Ensure cleanup
    trap "rm -f '$temp_file'" RETURN
    
    echo "$temp_file"
}

# Process large files line by line
process_large_file() {
    local file="$1"
    local line_count=0
    
    while IFS= read -r line; do
        process_line "$line"
        ((line_count++))
        
        # Progress indicator for large files
        if ((line_count % 1000 == 0)); then
            log_info "Processed $line_count lines"
        fi
    done < "$file"
}

# Limit resource usage
ulimit -n 1024    # Limit open files
ulimit -v 1048576 # Limit virtual memory (1GB)
```

## Security Best Practices

### 12. Secure Scripting

```bash
# Set secure permissions
umask 077  # Owner read/write only for new files

# Avoid hardcoded secrets
# Bad
password="secret123"

# Good
read -s -p "Enter password: " password
echo

# Or use environment variables
password="${DATABASE_PASSWORD:?Password required}"

# Sanitize input
sanitize_input() {
    local input="$1"
    # Remove potentially dangerous characters
    echo "$input" | sed 's/[^a-zA-Z0-9._-]//g'
}

# Use absolute paths for security
readonly SAFE_PATH="/usr/local/bin:/usr/bin:/bin"
export PATH="$SAFE_PATH"

# Validate file paths
validate_path() {
    local path="$1"
    local allowed_base="/safe/directory"
    
    # Resolve path and check if it's under allowed base
    local resolved_path
    resolved_path=$(realpath "$path" 2>/dev/null) || return 1
    
    [[ "$resolved_path" == "$allowed_base"* ]]
}
```

### 13. Logging and Auditing

```bash
# Comprehensive logging
setup_logging() {
    readonly LOG_DIR="/var/log/myapp"
    readonly LOG_FILE="$LOG_DIR/$(date +%Y%m%d).log"
    readonly ERROR_LOG="$LOG_DIR/error.log"
    readonly AUDIT_LOG="$LOG_DIR/audit.log"
    
    mkdir -p "$LOG_DIR"
    
    # Redirect all output to log file
    exec 1> >(tee -a "$LOG_FILE")
    exec 2> >(tee -a "$ERROR_LOG" >&2)
}

# Audit function calls
audit_log() {
    local action="$1"
    shift
    local details="$*"
    
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [AUDIT] User: $(whoami) PID: $$ Action: $action Details: $details" >> "$AUDIT_LOG"
}

# Usage
audit_log "FILE_DELETE" "Deleted file: $filename"
audit_log "USER_LOGIN" "User logged in from: $REMOTE_ADDR"
```

## Code Style and Formatting

### 14. Consistent Code Style

```bash
# Use consistent indentation (2 or 4 spaces)
if [[ condition ]]; then
    if [[ another_condition ]]; then
        do_something
    fi
fi

# Align related code
readonly CONFIG_FILE="/etc/myapp.conf"
readonly LOG_FILE="/var/log/myapp.log"
readonly PID_FILE="/var/run/myapp.pid"

# Break long lines appropriately
very_long_command \
    --option1 value1 \
    --option2 value2 \
    --option3 value3

# Group related functions
# ============================================================================
# FILE OPERATIONS
# ============================================================================

create_file() { ... }
delete_file() { ... }
backup_file() { ... }

# ============================================================================
# USER MANAGEMENT
# ============================================================================

create_user() { ... }
delete_user() { ... }
```

### 15. Documentation and Comments

```bash
# Document purpose, not implementation
# Good: Explains why
# Calculate checksums to verify file integrity
for file in "${critical_files[@]}"; do
    calculate_checksum "$file"
done

# Bad: Explains what (obvious from code)
# Loop through files and calculate checksum
for file in "${critical_files[@]}"; do
    calculate_checksum "$file"
done

# Document complex logic
# Use binary search to find the insertion point
# This reduces complexity from O(n) to O(log n)
find_insertion_point() {
    local -a sorted_array=("$@")
    local target="$1"
    # Implementation...
}

# Document assumptions and limitations
# NOTE: This function assumes input files are UTF-8 encoded
# LIMITATION: Maximum file size supported is 2GB
# DEPENDENCY: Requires GNU awk (gawk)
process_text_file() {
    local file="$1"
    # Implementation...
}
```

## Testing and Debugging

### 16. Testing Best Practices

```bash
# Include self-tests
run_self_tests() {
    log_info "Running self-tests..."
    
    # Test critical functions
    test_function "validate_email" "user@example.com" 0
    test_function "validate_email" "invalid-email" 1
    test_function "calculate_checksum" "/etc/passwd" 0
    
    log_info "All self-tests passed"
}

test_function() {
    local func_name="$1"
    local input="$2"
    local expected_exit_code="$3"
    
    if $func_name "$input"; then
        actual_exit_code=0
    else
        actual_exit_code=$?
    fi
    
    if [[ $actual_exit_code -eq $expected_exit_code ]]; then
        log_info "✓ $func_name('$input') passed"
    else
        log_error "✗ $func_name('$input') failed: expected $expected_exit_code, got $actual_exit_code"
        return 1
    fi
}

# Add debug mode
if [[ "${DEBUG:-}" == "true" ]]; then
    set -x  # Enable command tracing
    log_info "Debug mode enabled"
fi
```

### 17. Debugging Techniques

```bash
# Debug function
debug() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Trace function entry/exit
trace_function() {
    local func_name="$1"
    shift
    local args="$*"
    
    debug "Entering $func_name with args: $args"
    "$func_name" "$@"
    local exit_code=$?
    debug "Exiting $func_name with code: $exit_code"
    
    return $exit_code
}

# Add checkpoints
checkpoint() {
    local message="$1"
    debug "CHECKPOINT: $message"
    debug "Variables: VAR1=$VAR1, VAR2=$VAR2"
    debug "Working directory: $(pwd)"
}

# Conditional debugging
if [[ "${BASH_SUBSHELL}" -gt 0 ]]; then
    debug "Running in subshell level: $BASH_SUBSHELL"
fi
```

## Deployment and Maintenance

### 18. Production Readiness

```bash
# Version information
show_version() {
    cat << EOF
$SCRIPT_NAME version $VERSION
Build date: $(date +'%Y-%m-%d')
Bash version: $BASH_VERSION
Platform: $(uname -s)
EOF
}

# Health check
health_check() {
    local exit_code=0
    
    # Check dependencies
    for cmd in rsync tar gzip; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Missing dependency: $cmd"
            exit_code=1
        fi
    done
    
    # Check file permissions
    if [[ ! -w "$LOG_DIR" ]]; then
        log_error "Log directory not writable: $LOG_DIR"
        exit_code=1
    fi
    
    # Check disk space
    local available_space
    available_space=$(df "$LOG_DIR" | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1048576 ]]; then  # 1GB in KB
        log_error "Insufficient disk space: ${available_space}KB available"
        exit_code=1
    fi
    
    return $exit_code
}

# Configuration validation
validate_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "Configuration file not found: $config_file"
        return 1
    fi
    
    if [[ ! -r "$config_file" ]]; then
        log_error "Configuration file not readable: $config_file"
        return 1
    fi
    
    # Validate configuration syntax
    if ! bash -n "$config_file"; then
        log_error "Configuration file has syntax errors: $config_file"
        return 1
    fi
    
    return 0
}
```

## Summary Checklist

✅ **Script Structure**
- [ ] Proper shebang line
- [ ] Comprehensive header with metadata
- [ ] Logical organization with clear sections
- [ ] Consistent indentation and formatting

✅ **Safety and Error Handling**
- [ ] Strict mode enabled (`set -euo pipefail`)
- [ ] Error traps implemented
- [ ] Input validation for all parameters
- [ ] Proper cleanup on exit

✅ **Variables and Functions**
- [ ] Meaningful variable names
- [ ] Local variables in functions
- [ ] Constants properly declared
- [ ] Proper quoting throughout

✅ **Security**
- [ ] No hardcoded secrets
- [ ] Input sanitization
- [ ] Secure file permissions
- [ ] Path validation

✅ **Performance**
- [ ] Efficient algorithms
- [ ] Resource usage limits
- [ ] Appropriate use of external commands
- [ ] Memory management

✅ **Documentation**
- [ ] Clear comments explaining why, not what
- [ ] Function documentation
- [ ] Usage examples
- [ ] Dependencies listed

✅ **Testing and Debugging**
- [ ] Self-tests included
- [ ] Debug mode available
- [ ] Logging implemented
- [ ] Health checks

Following these best practices will help you write bash scripts that are robust, maintainable, secure, and professional-grade!
