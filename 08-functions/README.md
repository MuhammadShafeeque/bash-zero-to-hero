# Chapter 8: Functions

Functions are reusable blocks of code that make your scripts more organized, maintainable, and efficient. They allow you to break complex tasks into smaller, manageable pieces.

## Basic Function Syntax

### Simple Function Declaration

```bash
#!/usr/bin/env bash
# Basic function examples

# Method 1: function keyword
function greet() {
    echo "Hello, World!"
}

# Method 2: without function keyword (preferred)
say_goodbye() {
    echo "Goodbye!"
}

# Method 3: one-liner
hello() { echo "Hello from one-liner!"; }

# Calling functions
greet
say_goodbye
hello
```

### Functions with Parameters

```bash
#!/usr/bin/env bash
# Functions with parameters

greet_user() {
    local name="$1"
    local time="$2"
    
    echo "Good $time, $name!"
}

calculate_sum() {
    local num1="$1"
    local num2="$2"
    local sum=$((num1 + num2))
    
    echo "Sum of $num1 and $num2 is: $sum"
}

# Function with default parameters
greet_with_default() {
    local name="${1:-Guest}"
    local greeting="${2:-Hello}"
    
    echo "$greeting, $name!"
}

# Usage examples
greet_user "Alice" "morning"
calculate_sum 15 25
greet_with_default
greet_with_default "Bob"
greet_with_default "Charlie" "Hi"
```

## Function Parameters and Variables

### Working with Parameters

```bash
#!/usr/bin/env bash
# Parameter handling in functions

show_parameters() {
    echo "Function name: $0"
    echo "First parameter: $1"
    echo "Second parameter: $2"
    echo "All parameters: $@"
    echo "Number of parameters: $#"
    echo "Process ID: $$"
}

process_all_params() {
    echo "Processing all parameters:"
    local count=1
    
    for param in "$@"; do
        echo "  Parameter $count: $param"
        ((count++))
    done
}

# Variable arguments
sum_numbers() {
    local total=0
    
    for number in "$@"; do
        total=$((total + number))
    done
    
    echo "Sum of all numbers: $total"
}

# Usage
show_parameters "arg1" "arg2" "arg3"
process_all_params "apple" "banana" "cherry"
sum_numbers 1 2 3 4 5
```

### Local vs Global Variables

```bash
#!/usr/bin/env bash
# Variable scope in functions

global_var="I'm global"

demonstrate_scope() {
    local local_var="I'm local"
    global_var="Modified global"  # Modifies global variable
    local global_var="Local override"  # Creates local variable
    
    echo "Inside function:"
    echo "  Local variable: $local_var"
    echo "  Global variable (local): $global_var"
}

echo "Before function call:"
echo "  Global variable: $global_var"

demonstrate_scope

echo "After function call:"
echo "  Global variable: $global_var"
# echo "  Local variable: $local_var"  # This would cause an error
```

## Return Values

### Using Return Codes

```bash
#!/usr/bin/env bash
# Function return codes

is_even() {
    local number="$1"
    
    if [[ $((number % 2)) -eq 0 ]]; then
        return 0  # True (even)
    else
        return 1  # False (odd)
    fi
}

check_file_exists() {
    local filename="$1"
    
    if [[ -f "$filename" ]]; then
        return 0  # File exists
    else
        return 1  # File doesn't exist
    fi
}

validate_email() {
    local email="$1"
    
    if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0  # Valid email
    else
        return 1  # Invalid email
    fi
}

# Usage with return codes
number=42
if is_even "$number"; then
    echo "$number is even"
else
    echo "$number is odd"
fi

if check_file_exists "/etc/passwd"; then
    echo "Password file exists"
fi

email="user@example.com"
if validate_email "$email"; then
    echo "Valid email address"
else
    echo "Invalid email address"
fi
```

### Returning Values via Echo

```bash
#!/usr/bin/env bash
# Returning values via echo

get_file_size() {
    local filename="$1"
    
    if [[ -f "$filename" ]]; then
        stat -c%s "$filename" 2>/dev/null || stat -f%z "$filename"
    else
        echo "0"
    fi
}

get_current_time() {
    date '+%Y-%m-%d %H:%M:%S'
}

calculate_factorial() {
    local n="$1"
    local result=1
    
    for ((i=1; i<=n; i++)); do
        result=$((result * i))
    done
    
    echo "$result"
}

format_bytes() {
    local bytes="$1"
    
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$((bytes / 1024))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}

# Usage
file_size=$(get_file_size "/etc/passwd")
echo "Password file size: $(format_bytes "$file_size")"

current_time=$(get_current_time)
echo "Current time: $current_time"

factorial=$(calculate_factorial 5)
echo "5! = $factorial"
```

## Advanced Function Techniques

### Functions with Named Parameters

```bash
#!/usr/bin/env bash
# Named parameters using associative arrays

create_user() {
    # Parse named parameters
    local username="" email="" full_name="" role="user"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --username)
                username="$2"
                shift 2
                ;;
            --email)
                email="$2"
                shift 2
                ;;
            --name)
                full_name="$2"
                shift 2
                ;;
            --role)
                role="$2"
                shift 2
                ;;
            *)
                echo "Unknown parameter: $1"
                return 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$username" || -z "$email" ]]; then
        echo "Error: Username and email are required"
        return 1
    fi
    
    # Create user
    echo "Creating user:"
    echo "  Username: $username"
    echo "  Email: $email"
    echo "  Full Name: ${full_name:-Not provided}"
    echo "  Role: $role"
}

# Usage
create_user --username "johndoe" --email "john@example.com" --name "John Doe" --role "admin"
```

### Recursive Functions

```bash
#!/usr/bin/env bash
# Recursive functions

factorial_recursive() {
    local n="$1"
    
    if [[ $n -le 1 ]]; then
        echo 1
    else
        local prev=$(factorial_recursive $((n - 1)))
        echo $((n * prev))
    fi
}

fibonacci() {
    local n="$1"
    
    if [[ $n -le 1 ]]; then
        echo "$n"
    else
        local a=$(fibonacci $((n - 1)))
        local b=$(fibonacci $((n - 2)))
        echo $((a + b))
    fi
}

find_files_recursive() {
    local dir="$1"
    local pattern="$2"
    local depth="${3:-0}"
    
    # Prevent infinite recursion
    if [[ $depth -gt 10 ]]; then
        return
    fi
    
    for item in "$dir"/*; do
        if [[ -f "$item" && "$item" == *"$pattern"* ]]; then
            echo "Found: $item"
        elif [[ -d "$item" ]]; then
            find_files_recursive "$item" "$pattern" $((depth + 1))
        fi
    done
}

# Usage
echo "5! = $(factorial_recursive 5)"
echo "Fibonacci 10 = $(fibonacci 10)"
find_files_recursive "/home/user" ".txt"
```

### Function Libraries

```bash
#!/usr/bin/env bash
# Function library example

# Math utilities
math_add() { echo $(($1 + $2)); }
math_subtract() { echo $(($1 - $2)); }
math_multiply() { echo $(($1 * $2)); }
math_divide() { 
    [[ $2 -eq 0 ]] && { echo "Error: Division by zero"; return 1; }
    echo "scale=2; $1 / $2" | bc
}

# String utilities
string_length() { echo "${#1}"; }
string_upper() { echo "${1^^}"; }
string_lower() { echo "${1,,}"; }
string_reverse() {
    local str="$1"
    local reversed=""
    for ((i=${#str}-1; i>=0; i--)); do
        reversed+="${str:$i:1}"
    done
    echo "$reversed"
}

# Date utilities
date_format() {
    local format="${1:-%Y-%m-%d %H:%M:%S}"
    date +"$format"
}

date_add_days() {
    local days="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        date -v+"${days}d" '+%Y-%m-%d'
    else
        date -d "+${days} days" '+%Y-%m-%d'
    fi
}

# File utilities
file_backup() {
    local file="$1"
    local backup="${file}.bak.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "$file" ]]; then
        cp "$file" "$backup"
        echo "Backup created: $backup"
    else
        echo "Error: File '$file' not found"
        return 1
    fi
}

file_size_human() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
        format_bytes "$size"
    else
        echo "File not found"
    fi
}

# Usage examples
echo "Math: $(math_add 15 25)"
echo "String: $(string_reverse "Hello World")"
echo "Date: $(date_add_days 7)"
file_backup "important.txt"
```

## Error Handling in Functions

### Robust Error Handling

```bash
#!/usr/bin/env bash
# Error handling in functions

# Set error handling
set -euo pipefail

log_error() {
    echo "[ERROR] $*" >&2
}

log_info() {
    echo "[INFO] $*"
}

validate_input() {
    local input="$1"
    local type="$2"
    
    case "$type" in
        "number")
            if ! [[ "$input" =~ ^[0-9]+$ ]]; then
                log_error "Invalid number: '$input'"
                return 1
            fi
            ;;
        "email")
            if ! [[ "$input" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
                log_error "Invalid email: '$input'"
                return 1
            fi
            ;;
        "file")
            if [[ ! -f "$input" ]]; then
                log_error "File not found: '$input'"
                return 1
            fi
            ;;
        *)
            log_error "Unknown validation type: '$type'"
            return 1
            ;;
    esac
    
    return 0
}

safe_divide() {
    local dividend="$1"
    local divisor="$2"
    
    # Validate inputs
    validate_input "$dividend" "number" || return 1
    validate_input "$divisor" "number" || return 1
    
    # Check for division by zero
    if [[ $divisor -eq 0 ]]; then
        log_error "Division by zero"
        return 1
    fi
    
    echo $((dividend / divisor))
}

process_file_safe() {
    local filename="$1"
    
    # Validate file exists
    validate_input "$filename" "file" || return 1
    
    # Process file
    log_info "Processing file: $filename"
    
    local line_count
    line_count=$(wc -l < "$filename") || {
        log_error "Failed to count lines in $filename"
        return 1
    }
    
    log_info "File has $line_count lines"
    return 0
}

# Usage with error handling
if safe_divide 10 2; then
    log_info "Division successful"
else
    log_error "Division failed"
fi

process_file_safe "/etc/passwd" || log_error "File processing failed"
```

## Function Best Practices

### Well-Structured Functions

```bash
#!/usr/bin/env bash
# Best practices for function design

# Function template with documentation
backup_database() {
    # Purpose: Create a backup of the specified database
    # Parameters:
    #   $1 - database name (required)
    #   $2 - backup directory (optional, default: /backup)
    # Returns:
    #   0 - success
    #   1 - invalid parameters
    #   2 - backup failed
    # Example:
    #   backup_database "myapp" "/custom/backup/path"
    
    local db_name="$1"
    local backup_dir="${2:-/backup}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    # Validate parameters
    if [[ -z "$db_name" ]]; then
        echo "Error: Database name is required" >&2
        return 1
    fi
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "Error: Backup directory '$backup_dir' does not exist" >&2
        return 1
    fi
    
    # Create backup
    local backup_file="$backup_dir/${db_name}_${timestamp}.sql"
    
    echo "Starting backup of database '$db_name'..."
    
    if mysqldump "$db_name" > "$backup_file" 2>/dev/null; then
        echo "Backup completed: $backup_file"
        return 0
    else
        echo "Error: Backup failed" >&2
        return 2
    fi
}

# Function with configuration
deploy_application() {
    # Configuration variables
    local app_name="$1"
    local version="$2"
    local environment="${3:-staging}"
    
    # Configuration based on environment
    case "$environment" in
        "production")
            local deploy_path="/var/www/production"
            local config_file="prod.conf"
            local restart_services=("nginx" "php-fpm")
            ;;
        "staging")
            local deploy_path="/var/www/staging"
            local config_file="staging.conf"
            local restart_services=("nginx-staging")
            ;;
        *)
            echo "Error: Unknown environment '$environment'" >&2
            return 1
            ;;
    esac
    
    echo "Deploying $app_name v$version to $environment..."
    
    # Deployment steps
    local steps=(
        "create_backup"
        "stop_services"
        "deploy_code"
        "update_config"
        "run_migrations"
        "start_services"
        "verify_deployment"
    )
    
    for step in "${steps[@]}"; do
        echo "Executing step: $step"
        # Call individual step functions
        if ! "${step}" "$app_name" "$version" "$environment"; then
            echo "Error: Step '$step' failed" >&2
            return 1
        fi
    done
    
    echo "Deployment completed successfully!"
}

# Utility function for retries
retry_command() {
    local max_attempts="$1"
    local delay="$2"
    shift 2
    local command=("$@")
    
    local attempt=1
    while [[ $attempt -le $max_attempts ]]; do
        echo "Attempt $attempt of $max_attempts: ${command[*]}"
        
        if "${command[@]}"; then
            echo "Command succeeded on attempt $attempt"
            return 0
        else
            echo "Command failed on attempt $attempt"
            if [[ $attempt -lt $max_attempts ]]; then
                echo "Waiting $delay seconds before retry..."
                sleep "$delay"
            fi
        fi
        
        ((attempt++))
    done
    
    echo "Command failed after $max_attempts attempts"
    return 1
}

# Usage examples
# backup_database "myapp_db" "/backups"
# deploy_application "myapp" "1.2.3" "production"
# retry_command 3 5 curl -f http://api.example.com/health
```

## Practical Examples

### Example 1: System Monitoring Functions

```bash
#!/usr/bin/env bash
# System monitoring function library

get_cpu_usage() {
    # Linux
    if command -v top >/dev/null 2>&1; then
        top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//'
    # macOS
    elif command -v iostat >/dev/null 2>&1; then
        iostat -c 1 | tail -1 | awk '{print 100-$6}'
    else
        echo "N/A"
    fi
}

get_memory_usage() {
    if command -v free >/dev/null 2>&1; then
        free | grep "Mem:" | awk '{printf "%.1f", $3*100/$2}'
    elif command -v vm_stat >/dev/null 2>&1; then
        # macOS memory calculation
        local total=$(sysctl -n hw.memsize)
        local used=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
        echo "scale=1; $used * 4096 * 100 / $total" | bc
    else
        echo "N/A"
    fi
}

get_disk_usage() {
    local path="${1:-/}"
    df -h "$path" | awk 'NR==2 {print $5}' | sed 's/%//'
}

check_service_status() {
    local service="$1"
    
    if systemctl is-active "$service" >/dev/null 2>&1; then
        echo "running"
    elif pgrep "$service" >/dev/null 2>&1; then
        echo "running"
    else
        echo "stopped"
    fi
}

generate_system_report() {
    local output_file="${1:-system_report_$(date +%Y%m%d_%H%M%S).txt}"
    
    {
        echo "System Report - $(date)"
        echo "========================"
        echo
        echo "System Information:"
        echo "  Hostname: $(hostname)"
        echo "  Uptime: $(uptime | awk -F, '{print $1}' | sed 's/.*up //')"
        echo "  Load Average: $(uptime | awk -F'load average:' '{print $2}')"
        echo
        echo "Resource Usage:"
        echo "  CPU: $(get_cpu_usage)%"
        echo "  Memory: $(get_memory_usage)%"
        echo "  Disk (/): $(get_disk_usage)%"
        echo
        echo "Service Status:"
        local services=("ssh" "cron" "nginx")
        for service in "${services[@]}"; do
            echo "  $service: $(check_service_status "$service")"
        done
        echo
        echo "Network Connections:"
        netstat -tuln 2>/dev/null | grep LISTEN | wc -l | awk '{print "  Listening ports: " $1}'
    } > "$output_file"
    
    echo "System report saved to: $output_file"
}

# Usage
generate_system_report
```

### Example 2: File Management Functions

```bash
#!/usr/bin/env bash
# File management function library

create_directory_structure() {
    local base_dir="$1"
    local structure=("docs" "src" "tests" "config" "logs")
    
    if [[ -z "$base_dir" ]]; then
        echo "Error: Base directory name required" >&2
        return 1
    fi
    
    echo "Creating directory structure for: $base_dir"
    
    mkdir -p "$base_dir"
    cd "$base_dir" || return 1
    
    for dir in "${structure[@]}"; do
        mkdir -p "$dir"
        echo "Created: $dir/"
    done
    
    # Create initial files
    touch README.md
    touch .gitignore
    echo "# $base_dir" > README.md
    
    echo "Directory structure created successfully!"
}

organize_downloads() {
    local downloads_dir="${1:-$HOME/Downloads}"
    local organize_dir="$downloads_dir/organized"
    
    if [[ ! -d "$downloads_dir" ]]; then
        echo "Error: Downloads directory not found: $downloads_dir" >&2
        return 1
    fi
    
    mkdir -p "$organize_dir"/{documents,images,videos,audio,archives,other}
    
    echo "Organizing files in: $downloads_dir"
    
    local moved_count=0
    
    for file in "$downloads_dir"/*; do
        [[ -f "$file" ]] || continue
        
        local filename=$(basename "$file")
        local extension="${filename##*.}"
        local target_dir="other"
        
        case "${extension,,}" in
            pdf|doc|docx|txt|rtf|odt)
                target_dir="documents"
                ;;
            jpg|jpeg|png|gif|bmp|svg)
                target_dir="images"
                ;;
            mp4|avi|mkv|mov|wmv)
                target_dir="videos"
                ;;
            mp3|wav|flac|aac)
                target_dir="audio"
                ;;
            zip|tar|gz|rar|7z)
                target_dir="archives"
                ;;
        esac
        
        mv "$file" "$organize_dir/$target_dir/"
        echo "Moved: $filename -> $target_dir/"
        ((moved_count++))
    done
    
    echo "Organization complete! Moved $moved_count files."
}

find_duplicate_files() {
    local search_dir="${1:-.}"
    local min_size="${2:-1024}"  # Minimum file size in bytes
    
    echo "Finding duplicate files in: $search_dir"
    echo "Minimum file size: $min_size bytes"
    echo
    
    # Create temporary file for checksums
    local temp_file=$(mktemp)
    
    # Calculate checksums for files larger than minimum size
    find "$search_dir" -type f -size +"${min_size}c" -exec md5sum {} \; 2>/dev/null | \
        sort > "$temp_file"
    
    # Find duplicates
    local duplicates=$(awk '{print $1}' "$temp_file" | uniq -d)
    
    if [[ -n "$duplicates" ]]; then
        echo "Duplicate files found:"
        echo "====================="
        
        for checksum in $duplicates; do
            echo "Files with checksum $checksum:"
            grep "^$checksum" "$temp_file" | awk '{print "  " $2}'
            echo
        done
    else
        echo "No duplicate files found."
    fi
    
    rm "$temp_file"
}

# Usage examples
# create_directory_structure "my_project"
# organize_downloads
# find_duplicate_files "/home/user/Documents" 10240
```

## Practice Exercises

### Exercise 1: Configuration Manager

Create a set of functions to manage application configuration:
- Load configuration from file
- Set/get configuration values
- Validate configuration
- Save configuration to file

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash

# Global configuration array
declare -A config

load_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        echo "Warning: Config file '$config_file' not found, using defaults"
        return 1
    fi
    
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^#.*$ || -z $key ]] && continue
        
        # Remove quotes from value
        value="${value%\"}"
        value="${value#\"}"
        
        config[$key]="$value"
    done < "$config_file"
    
    echo "Configuration loaded from: $config_file"
}

get_config() {
    local key="$1"
    local default="$2"
    
    echo "${config[$key]:-$default}"
}

set_config() {
    local key="$1"
    local value="$2"
    
    config[$key]="$value"
    echo "Set $key = $value"
}

validate_config() {
    local errors=0
    
    # Required keys
    local required_keys=("app_name" "version" "port")
    
    for key in "${required_keys[@]}"; do
        if [[ -z "${config[$key]}" ]]; then
            echo "Error: Required key '$key' is missing"
            ((errors++))
        fi
    done
    
    # Validate port number
    local port="${config[port]}"
    if [[ -n "$port" && ! "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: Port must be a number"
        ((errors++))
    fi
    
    return $errors
}

save_config() {
    local config_file="$1"
    
    {
        echo "# Configuration file"
        echo "# Generated on $(date)"
        echo
        
        for key in "${!config[@]}"; do
            echo "$key=\"${config[$key]}\""
        done
    } > "$config_file"
    
    echo "Configuration saved to: $config_file"
}

show_config() {
    echo "Current Configuration:"
    echo "====================="
    
    for key in "${!config[@]}"; do
        printf "%-15s: %s\n" "$key" "${config[$key]}"
    done
}

# Example usage
load_config "app.conf"
set_config "app_name" "MyApp"
set_config "version" "1.0"
set_config "port" "8080"
show_config
validate_config && echo "Configuration is valid"
save_config "app.conf"
```
</details>

### Exercise 2: Log Processing Library

Create functions for processing and analyzing log files:
- Parse different log formats
- Filter by date range
- Count error levels
- Generate summaries

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash

parse_apache_log() {
    local log_file="$1"
    local date_filter="$2"
    
    awk -v date="$date_filter" '
    {
        # Extract IP, date, method, URL, status, size
        match($0, /^([^ ]+) .* \[([^\]]+)\] "([^ ]+) ([^ ]+) [^"]*" ([0-9]+) ([0-9-]+)/, arr)
        ip = arr[1]
        datetime = arr[2]
        method = arr[3]
        url = arr[4]
        status = arr[5]
        size = arr[6]
        
        if (date == "" || datetime ~ date) {
            print ip "|" datetime "|" method "|" url "|" status "|" size
        }
    }' "$log_file"
}

count_status_codes() {
    local log_data="$1"
    
    echo "$log_data" | awk -F'|' '
    {
        status_codes[$5]++
    }
    END {
        print "Status Code Summary:"
        print "==================="
        for (code in status_codes) {
            printf "%-10s: %d\n", code, status_codes[code]
        }
    }'
}

find_top_ips() {
    local log_data="$1"
    local count="${2:-10}"
    
    echo "$log_data" | awk -F'|' '{print $1}' | \
        sort | uniq -c | sort -nr | head -"$count" | \
        awk '{printf "%-15s: %d requests\n", $2, $1}'
}

analyze_log_file() {
    local log_file="$1"
    local date_filter="$2"
    
    if [[ ! -f "$log_file" ]]; then
        echo "Error: Log file '$log_file' not found"
        return 1
    fi
    
    echo "Analyzing log file: $log_file"
    [[ -n "$date_filter" ]] && echo "Date filter: $date_filter"
    echo "================================="
    
    local log_data=$(parse_apache_log "$log_file" "$date_filter")
    
    echo "Top IP Addresses:"
    find_top_ips "$log_data" 5
    echo
    
    count_status_codes "$log_data"
}

# Example usage
# analyze_log_file "/var/log/apache2/access.log" "01/Jan/2024"
```
</details>

## Key Takeaways

1. Use functions to organize and reuse code
2. Always use local variables in functions
3. Validate function parameters
4. Use meaningful function names
5. Document complex functions
6. Handle errors gracefully
7. Use return codes for success/failure status
8. Consider using function libraries for common tasks

## Next Steps

Continue to [Chapter 21: Project 1 - System Monitor](../21-project-system-monitor/README.md) to apply your function knowledge in a real-world project.

## Quick Reference

```bash
# Function declaration
function_name() {
    local var="$1"
    echo "Result"
    return 0
}

# With parameters
func() {
    local param1="$1"
    local param2="${2:-default}"
    # function body
}

# Call function
result=$(function_name "arg1")
function_name "arg1" "arg2"

# Check return code
if function_name; then
    echo "Success"
fi
```
