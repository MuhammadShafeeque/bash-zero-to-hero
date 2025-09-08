# Chapter 5: Conditional Statements

## Understanding Conditionals

Conditional statements allow your scripts to make decisions based on different conditions. Bash provides several ways to test conditions and execute different code paths.

## Basic If Statements

### Simple If Statement

```bash
#!/usr/bin/env bash
# Basic if statement

age=18

if [[ $age -ge 18 ]]; then
    echo "You are an adult"
fi

# One-liner version
[[ $age -ge 18 ]] && echo "You are an adult"
```

### If-Else Statement

```bash
#!/usr/bin/env bash
# If-else statement

read -p "Enter your age: " age

if [[ $age -ge 18 ]]; then
    echo "You are an adult"
else
    echo "You are a minor"
fi
```

### If-Elif-Else Statement

```bash
#!/usr/bin/env bash
# Multiple conditions

read -p "Enter your score (0-100): " score

if [[ $score -ge 90 ]]; then
    echo "Grade: A"
elif [[ $score -ge 80 ]]; then
    echo "Grade: B"
elif [[ $score -ge 70 ]]; then
    echo "Grade: C"
elif [[ $score -ge 60 ]]; then
    echo "Grade: D"
else
    echo "Grade: F"
fi
```

## Test Conditions

### Numeric Comparisons

```bash
#!/usr/bin/env bash
# Numeric comparison operators

num1=10
num2=20

# Equality and inequality
if [[ $num1 -eq $num2 ]]; then echo "Equal"; fi
if [[ $num1 -ne $num2 ]]; then echo "Not equal"; fi

# Magnitude comparisons  
if [[ $num1 -lt $num2 ]]; then echo "$num1 is less than $num2"; fi
if [[ $num1 -le $num2 ]]; then echo "$num1 is less than or equal to $num2"; fi
if [[ $num1 -gt $num2 ]]; then echo "$num1 is greater than $num2"; fi
if [[ $num1 -ge $num2 ]]; then echo "$num1 is greater than or equal to $num2"; fi

# Alternative arithmetic comparison
if (( num1 < num2 )); then
    echo "Arithmetic: $num1 < $num2"
fi

if (( num1 + 10 == num2 )); then
    echo "Arithmetic expression: num1 + 10 equals num2"
fi
```

### String Comparisons

```bash
#!/usr/bin/env bash
# String comparison operators

str1="hello"
str2="world"
str3="hello"

# String equality
if [[ "$str1" == "$str3" ]]; then
    echo "Strings are equal"
fi

# String inequality
if [[ "$str1" != "$str2" ]]; then
    echo "Strings are different"
fi

# Lexicographic comparison
if [[ "$str1" < "$str2" ]]; then
    echo "$str1 comes before $str2 alphabetically"
fi

# String length and emptiness
if [[ -z "$str1" ]]; then
    echo "String is empty"
else
    echo "String is not empty"
fi

if [[ -n "$str1" ]]; then
    echo "String is not empty"
fi

# Pattern matching
if [[ "$str1" == h* ]]; then
    echo "String starts with 'h'"
fi

if [[ "$str1" == *llo ]]; then
    echo "String ends with 'llo'"
fi

if [[ "$str1" == *ell* ]]; then
    echo "String contains 'ell'"
fi
```

### File and Directory Tests

```bash
#!/usr/bin/env bash
# File and directory tests

filename="test.txt"
directory="mydir"

# File existence and type
if [[ -e "$filename" ]]; then
    echo "File exists"
fi

if [[ -f "$filename" ]]; then
    echo "Is a regular file"
fi

if [[ -d "$directory" ]]; then
    echo "Is a directory"
fi

if [[ -L "$filename" ]]; then
    echo "Is a symbolic link"
fi

# File permissions
if [[ -r "$filename" ]]; then
    echo "File is readable"
fi

if [[ -w "$filename" ]]; then
    echo "File is writable"
fi

if [[ -x "$filename" ]]; then
    echo "File is executable"
fi

# File properties
if [[ -s "$filename" ]]; then
    echo "File is not empty"
fi

if [[ "$file1" -nt "$file2" ]]; then
    echo "file1 is newer than file2"
fi

if [[ "$file1" -ot "$file2" ]]; then
    echo "file1 is older than file2"
fi
```

## Logical Operators

### AND and OR Operations

```bash
#!/usr/bin/env bash
# Logical operators

age=25
has_license=true

# AND operator (&&)
if [[ $age -ge 18 && "$has_license" == "true" ]]; then
    echo "Can drive"
fi

# OR operator (||)
if [[ $age -lt 18 || "$has_license" != "true" ]]; then
    echo "Cannot drive"
fi

# NOT operator (!)
if [[ ! -f "nonexistent.txt" ]]; then
    echo "File does not exist"
fi

# Complex conditions
if [[ ( $age -ge 18 && $age -le 65 ) && "$has_license" == "true" ]]; then
    echo "Can drive and is of working age"
fi
```

### Multiple Test Conditions

```bash
#!/usr/bin/env bash
# Multiple conditions with different operators

read -p "Enter username: " username
read -p "Enter age: " age
read -p "Enter country: " country

# Complex validation
if [[ -n "$username" ]] && \
   [[ $age -ge 18 ]] && \
   [[ $age -le 120 ]] && \
   [[ "$country" =~ ^[A-Za-z]+$ ]]; then
    echo "Valid user registration"
else
    echo "Invalid registration data"
fi

# Using parentheses for grouping
if [[ ( "$country" == "US" || "$country" == "Canada" ) && $age -ge 21 ]]; then
    echo "Can purchase alcohol in North America"
fi
```

## Regular Expression Matching

### Pattern Matching with =~

```bash
#!/usr/bin/env bash
# Regular expression matching

read -p "Enter email address: " email

# Email validation
if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo "Valid email address"
else
    echo "Invalid email address"
fi

# Phone number validation
read -p "Enter phone number: " phone
if [[ "$phone" =~ ^[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]; then
    echo "Valid phone format (XXX-XXX-XXXX)"
else
    echo "Invalid phone format"
fi

# IP address validation
read -p "Enter IP address: " ip
if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Valid IP format"
else
    echo "Invalid IP format"
fi

# Extract parts using regex groups
text="The price is $25.99"
if [[ "$text" =~ \$([0-9]+)\.([0-9]{2}) ]]; then
    dollars="${BASH_REMATCH[1]}"
    cents="${BASH_REMATCH[2]}"
    echo "Dollars: $dollars, Cents: $cents"
fi
```

## Advanced Conditional Techniques

### Nested Conditions

```bash
#!/usr/bin/env bash
# Nested conditions

read -p "Enter temperature in Celsius: " temp
read -p "Is it raining? (y/n): " rain

if [[ $temp -gt 20 ]]; then
    if [[ "$rain" == "y" ]]; then
        echo "It's warm but rainy - bring an umbrella"
    else
        echo "Perfect weather for outdoor activities"
    fi
else
    if [[ "$rain" == "y" ]]; then
        echo "Cold and rainy - stay inside"
    else
        echo "Cold but dry - wear a jacket"
    fi
fi
```

### Using Functions with Conditionals

```bash
#!/usr/bin/env bash
# Functions with conditionals

is_valid_email() {
    local email="$1"
    [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

is_strong_password() {
    local password="$1"
    local length=${#password}
    
    # Check length
    [[ $length -ge 8 ]] || return 1
    
    # Check for uppercase
    [[ "$password" =~ [A-Z] ]] || return 1
    
    # Check for lowercase  
    [[ "$password" =~ [a-z] ]] || return 1
    
    # Check for digit
    [[ "$password" =~ [0-9] ]] || return 1
    
    # Check for special character
    [[ "$password" =~ [^A-Za-z0-9] ]] || return 1
    
    return 0
}

file_backup_needed() {
    local file="$1"
    local backup="${file}.bak"
    
    # File exists and (no backup or file is newer)
    [[ -f "$file" ]] && [[ ! -f "$backup" || "$file" -nt "$backup" ]]
}

# Usage examples
read -p "Enter email: " email
if is_valid_email "$email"; then
    echo "Email is valid"
else
    echo "Email is invalid"
fi

read -s -p "Enter password: " password
echo
if is_strong_password "$password"; then
    echo "Strong password"
else
    echo "Password is too weak"
fi

if file_backup_needed "important.txt"; then
    echo "Backup needed for important.txt"
fi
```

## Exit Codes and Error Handling

### Understanding Exit Codes

```bash
#!/usr/bin/env bash
# Exit codes and error handling

# Check command success
if ls /nonexistent 2>/dev/null; then
    echo "Directory exists"
else
    echo "Directory does not exist"
fi

# Using exit codes directly
ls /etc >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "Command succeeded"
else
    echo "Command failed"
fi

# Multiple commands with error checking
if command1 && command2 && command3; then
    echo "All commands succeeded"
else
    echo "At least one command failed"
fi
```

### Custom Exit Codes

```bash
#!/usr/bin/env bash
# Custom exit codes

validate_user_input() {
    local username="$1"
    local age="$2"
    
    # Check if username is provided
    if [[ -z "$username" ]]; then
        echo "Error: Username is required"
        return 1
    fi
    
    # Check username format
    if [[ ! "$username" =~ ^[a-zA-Z][a-zA-Z0-9_]{2,19}$ ]]; then
        echo "Error: Invalid username format"
        return 2
    fi
    
    # Check age
    if [[ ! "$age" =~ ^[0-9]+$ ]] || [[ $age -lt 1 || $age -gt 120 ]]; then
        echo "Error: Invalid age"
        return 3
    fi
    
    return 0
}

# Usage with error handling
read -p "Username: " username
read -p "Age: " age

if validate_user_input "$username" "$age"; then
    echo "User input is valid"
else
    exit_code=$?
    case $exit_code in
        1) echo "Missing username" ;;
        2) echo "Username format error" ;;
        3) echo "Age validation error" ;;
        *) echo "Unknown error" ;;
    esac
    exit $exit_code
fi
```

## Practical Examples

### Example 1: System Health Check

```bash
#!/usr/bin/env bash
# System health check script

check_disk_space() {
    local threshold=90
    local usage
    
    echo "Checking disk space..."
    
    while read -r filesystem blocks used available percent mountpoint; do
        # Skip header line and special filesystems
        [[ "$filesystem" == "Filesystem" ]] && continue
        [[ "$filesystem" =~ ^/dev/ ]] || continue
        
        # Extract percentage (remove % sign)
        usage=${percent%\%}
        
        if [[ $usage -gt $threshold ]]; then
            echo "WARNING: $mountpoint is ${usage}% full"
        else
            echo "OK: $mountpoint is ${usage}% full"
        fi
    done < <(df -h)
}

check_memory() {
    echo "Checking memory usage..."
    
    if command -v free >/dev/null 2>&1; then
        # Linux
        local mem_info=$(free | grep "Mem:")
        local total=$(echo $mem_info | awk '{print $2}')
        local used=$(echo $mem_info | awk '{print $3}')
        local usage=$((used * 100 / total))
        
        if [[ $usage -gt 80 ]]; then
            echo "WARNING: Memory usage is ${usage}%"
        else
            echo "OK: Memory usage is ${usage}%"
        fi
    else
        echo "Memory check not available on this system"
    fi
}

check_services() {
    local services=("ssh" "cron")
    
    echo "Checking critical services..."
    
    for service in "${services[@]}"; do
        if pgrep "$service" >/dev/null 2>&1; then
            echo "OK: $service is running"
        else
            echo "WARNING: $service is not running"
        fi
    done
}

# Main health check
echo "=== SYSTEM HEALTH CHECK ==="
echo "Timestamp: $(date)"
echo

check_disk_space
echo
check_memory
echo
check_services

echo
echo "Health check completed"
```

### Example 2: File Organizer

```bash
#!/usr/bin/env bash
# File organizer script

organize_files() {
    local source_dir="${1:-.}"
    local organize_by="${2:-extension}"
    
    if [[ ! -d "$source_dir" ]]; then
        echo "Error: Directory '$source_dir' does not exist"
        return 1
    fi
    
    echo "Organizing files in '$source_dir' by $organize_by..."
    
    while IFS= read -r -d '' file; do
        [[ -f "$file" ]] || continue
        
        local filename=$(basename "$file")
        local target_dir
        
        case "$organize_by" in
            "extension")
                local ext="${filename##*.}"
                [[ "$ext" == "$filename" ]] && ext="no_extension"
                target_dir="$source_dir/${ext}_files"
                ;;
            "date")
                local file_date
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    file_date=$(stat -f "%Sm" -t "%Y-%m" "$file")
                else
                    file_date=$(stat -c "%y" "$file" | cut -d' ' -f1 | cut -d'-' -f1,2)
                fi
                target_dir="$source_dir/$file_date"
                ;;
            "size")
                local size
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    size=$(stat -f "%z" "$file")
                else
                    size=$(stat -c "%s" "$file")
                fi
                
                if [[ $size -lt 1024 ]]; then
                    target_dir="$source_dir/small_files"
                elif [[ $size -lt 1048576 ]]; then
                    target_dir="$source_dir/medium_files"
                else
                    target_dir="$source_dir/large_files"
                fi
                ;;
            *)
                echo "Error: Unknown organization method '$organize_by'"
                return 1
                ;;
        esac
        
        # Create target directory if it doesn't exist
        if [[ ! -d "$target_dir" ]]; then
            mkdir -p "$target_dir"
            echo "Created directory: $target_dir"
        fi
        
        # Move file if not already in target directory
        local current_dir=$(dirname "$file")
        if [[ "$current_dir" != "$target_dir" ]]; then
            mv "$file" "$target_dir/"
            echo "Moved: $filename -> $target_dir/"
        fi
        
    done < <(find "$source_dir" -maxdepth 1 -type f -print0)
    
    echo "File organization completed"
}

# Script usage
if [[ $# -eq 0 ]]; then
    echo "File Organizer"
    echo "=============="
    echo "Usage: $0 [directory] [method]"
    echo "Methods: extension, date, size"
    echo
    read -p "Enter directory to organize [current]: " dir
    read -p "Organization method [extension]: " method
    
    dir=${dir:-.}
    method=${method:-extension}
    
    organize_files "$dir" "$method"
else
    organize_files "$1" "${2:-extension}"
fi
```

### Example 3: Backup Validator

```bash
#!/usr/bin/env bash
# Backup validation script

validate_backup() {
    local source="$1"
    local backup="$2"
    local errors=0
    
    echo "Validating backup: $source -> $backup"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        echo "ERROR: Source '$source' does not exist"
        return 1
    fi
    
    # Check if backup exists
    if [[ ! -e "$backup" ]]; then
        echo "ERROR: Backup '$backup' does not exist"
        return 1
    fi
    
    # If source is a file
    if [[ -f "$source" ]]; then
        if [[ ! -f "$backup" ]]; then
            echo "ERROR: Backup should be a file but is not"
            ((errors++))
        else
            # Compare file sizes
            local source_size=$(stat -c%s "$source" 2>/dev/null || stat -f%z "$source")
            local backup_size=$(stat -c%s "$backup" 2>/dev/null || stat -f%z "$backup")
            
            if [[ $source_size -ne $backup_size ]]; then
                echo "ERROR: File sizes differ (source: $source_size, backup: $backup_size)"
                ((errors++))
            fi
            
            # Compare checksums
            local source_md5=$(md5sum "$source" 2>/dev/null | cut -d' ' -f1 || md5 -q "$source")
            local backup_md5=$(md5sum "$backup" 2>/dev/null | cut -d' ' -f1 || md5 -q "$backup")
            
            if [[ "$source_md5" != "$backup_md5" ]]; then
                echo "ERROR: File contents differ (MD5 mismatch)"
                ((errors++))
            fi
        fi
    fi
    
    # If source is a directory
    if [[ -d "$source" ]]; then
        if [[ ! -d "$backup" ]]; then
            echo "ERROR: Backup should be a directory but is not"
            ((errors++))
        else
            # Count files in each directory
            local source_count=$(find "$source" -type f | wc -l)
            local backup_count=$(find "$backup" -type f | wc -l)
            
            if [[ $source_count -ne $backup_count ]]; then
                echo "ERROR: File counts differ (source: $source_count, backup: $backup_count)"
                ((errors++))
            fi
            
            # Check each file in source
            while IFS= read -r -d '' file; do
                local relative_path="${file#$source/}"
                local backup_file="$backup/$relative_path"
                
                if [[ ! -f "$backup_file" ]]; then
                    echo "ERROR: Missing file in backup: $relative_path"
                    ((errors++))
                fi
            done < <(find "$source" -type f -print0)
        fi
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo "SUCCESS: Backup validation passed"
        return 0
    else
        echo "FAILED: Backup validation failed with $errors errors"
        return 1
    fi
}

# Interactive mode
if [[ $# -eq 0 ]]; then
    echo "Backup Validator"
    echo "================"
    
    read -p "Enter source path: " source
    read -p "Enter backup path: " backup
    
    if [[ -z "$source" || -z "$backup" ]]; then
        echo "Error: Both source and backup paths are required"
        exit 1
    fi
    
    validate_backup "$source" "$backup"
else
    validate_backup "$1" "$2"
fi
```

## Practice Exercises

### Exercise 1: Grade Calculator

Create a script that:
1. Reads student scores for multiple subjects
2. Calculates average
3. Assigns letter grade based on average
4. Determines if student passes or fails

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash

calculate_grade() {
    local total=0
    local count=0
    local scores=("$@")
    
    # Calculate total and count
    for score in "${scores[@]}"; do
        total=$((total + score))
        ((count++))
    done
    
    # Calculate average
    local average=$((total / count))
    
    # Determine letter grade
    local letter_grade
    if [[ $average -ge 90 ]]; then
        letter_grade="A"
    elif [[ $average -ge 80 ]]; then
        letter_grade="B"
    elif [[ $average -ge 70 ]]; then
        letter_grade="C"
    elif [[ $average -ge 60 ]]; then
        letter_grade="D"
    else
        letter_grade="F"
    fi
    
    # Determine pass/fail
    local status
    if [[ $average -ge 60 ]]; then
        status="PASS"
    else
        status="FAIL"
    fi
    
    echo "Average: $average"
    echo "Grade: $letter_grade"
    echo "Status: $status"
}

echo "Grade Calculator"
echo "================"

read -p "Enter student name: " name
read -p "Enter number of subjects: " num_subjects

scores=()
for ((i=1; i<=num_subjects; i++)); do
    while true; do
        read -p "Enter score for subject $i (0-100): " score
        if [[ "$score" =~ ^[0-9]+$ ]] && [[ $score -ge 0 && $score -le 100 ]]; then
            scores+=($score)
            break
        else
            echo "Please enter a valid score (0-100)"
        fi
    done
done

echo
echo "Results for $name:"
echo "=================="
echo "Scores: ${scores[*]}"
calculate_grade "${scores[@]}"
```
</details>

### Exercise 2: System Security Check

Write a script that checks:
1. If important system files exist and have correct permissions
2. If there are any suspicious processes running
3. If network connections are secure
4. Generate a security report

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash

check_system_files() {
    local critical_files=("/etc/passwd" "/etc/shadow" "/etc/hosts")
    local issues=0
    
    echo "Checking critical system files..."
    
    for file in "${critical_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "CRITICAL: $file is missing!"
            ((issues++))
        else
            local perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Mp%Lp" "$file")
            case "$file" in
                "/etc/shadow")
                    if [[ "$perms" != "640" && "$perms" != "600" ]]; then
                        echo "WARNING: $file has incorrect permissions: $perms"
                        ((issues++))
                    fi
                    ;;
                "/etc/passwd")
                    if [[ "$perms" != "644" ]]; then
                        echo "WARNING: $file has incorrect permissions: $perms"
                        ((issues++))
                    fi
                    ;;
            esac
        fi
    done
    
    return $issues
}

check_processes() {
    local suspicious_processes=("nc" "netcat" "nmap")
    local issues=0
    
    echo "Checking for suspicious processes..."
    
    for process in "${suspicious_processes[@]}"; do
        if pgrep "$process" >/dev/null 2>&1; then
            echo "WARNING: Suspicious process detected: $process"
            ((issues++))
        fi
    done
    
    return $issues
}

check_network() {
    local issues=0
    
    echo "Checking network connections..."
    
    # Check for listening ports
    if command -v netstat >/dev/null 2>&1; then
        local open_ports=$(netstat -tuln 2>/dev/null | grep LISTEN | wc -l)
        if [[ $open_ports -gt 10 ]]; then
            echo "WARNING: Many open ports detected ($open_ports)"
            ((issues++))
        fi
    fi
    
    return $issues
}

# Main security check
echo "=== SYSTEM SECURITY CHECK ==="
echo "Timestamp: $(date)"
echo

total_issues=0

check_system_files
total_issues=$((total_issues + $?))

echo
check_processes  
total_issues=$((total_issues + $?))

echo
check_network
total_issues=$((total_issues + $?))

echo
echo "=== SECURITY REPORT ==="
if [[ $total_issues -eq 0 ]]; then
    echo "STATUS: SECURE - No issues detected"
else
    echo "STATUS: ISSUES FOUND - $total_issues security issues detected"
fi
echo "Report completed at $(date)"
```
</details>

## Key Takeaways

1. Use `[[ ]]` for most test conditions (preferred over `[ ]`)
2. Always quote string variables in comparisons
3. Use appropriate comparison operators for different data types
4. Combine conditions with logical operators (&&, ||, !)
5. Regular expressions provide powerful pattern matching
6. Exit codes help with error handling and script flow control
7. Nested conditions should be used carefully for readability

## Next Steps

Continue to [Chapter 6: Loops](../06-loops/README.md) to learn about repetitive operations and iteration in bash scripts.

## Quick Reference

```bash
# Numeric comparisons
[[ $a -eq $b ]]    # equal
[[ $a -ne $b ]]    # not equal
[[ $a -lt $b ]]    # less than
[[ $a -le $b ]]    # less than or equal
[[ $a -gt $b ]]    # greater than
[[ $a -ge $b ]]    # greater than or equal

# String comparisons
[[ "$a" == "$b" ]] # equal
[[ "$a" != "$b" ]] # not equal
[[ "$a" < "$b" ]]  # lexicographically less
[[ -z "$a" ]]      # empty string
[[ -n "$a" ]]      # non-empty string

# File tests
[[ -f file ]]      # regular file
[[ -d dir ]]       # directory
[[ -e path ]]      # exists
[[ -r file ]]      # readable
[[ -w file ]]      # writable
[[ -x file ]]      # executable

# Logical operators
[[ cond1 && cond2 ]]  # AND
[[ cond1 || cond2 ]]  # OR
[[ ! condition ]]     # NOT

# Pattern matching
[[ "$string" == pattern ]]
[[ "$string" =~ regex ]]
```
