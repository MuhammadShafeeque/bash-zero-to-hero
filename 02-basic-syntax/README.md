# Chapter 2: Basic Syntax

## Script Structure

A well-structured bash script follows this pattern:

```bash
#!/usr/bin/env bash
# Script description
# Author: Your Name
# Date: YYYY-MM-DD
# Version: 1.0

# Global variables
SCRIPT_NAME="example.sh"
VERSION="1.0"

# Functions
function main() {
    # Main script logic
    echo "Script execution"
}

# Script execution
main "$@"
```

## Comments

Comments make your code readable and maintainable.

### Single Line Comments

```bash
# This is a single line comment
echo "Hello World"  # End of line comment
```

### Multi-line Comments

```bash
: '
This is a multi-line comment
It can span several lines
Very useful for documentation
'

# Alternative multi-line comment
<<'COMMENT'
Another way to create
multi-line comments
COMMENT
```

### Documentation Comments

```bash
#!/usr/bin/env bash
#
# Script Name: backup_manager.sh
# Description: Manages system backups
# Author: John Doe
# Email: john@example.com
# Date: 2024-01-15
# Version: 2.1
# Usage: ./backup_manager.sh [options]
#
# Examples:
#   ./backup_manager.sh --full
#   ./backup_manager.sh --incremental --target /backup
#
# Dependencies:
#   - rsync
#   - tar
#   - gzip
#
```

## Output and Echo

### Basic Echo

```bash
echo "Hello World"
echo 'Single quotes prevent variable expansion'
echo Hello World    # No quotes needed for simple text
```

### Echo Options

```bash
# No newline at end
echo -n "Text without newline"

# Enable interpretation of backslash escapes
echo -e "Line 1\nLine 2\tTabbed"

# Output:
# Line 1
# Line 2    Tabbed
```

### Escape Sequences

```bash
echo -e "Common escape sequences:"
echo -e "\n - \\n: New line"
echo -e "\t - \\t: Tab"
echo -e "\\ - \\\\: Backslash"
echo -e "\" - \\\": Double quote"
echo -e "\a - \\a: Alert (bell)"
echo -e "\b - \\b: Backspace"
echo -e "\r - \\r: Carriage return"
```

### Printf (More Control)

```bash
# Basic printf
printf "Hello %s\n" "World"

# Formatting numbers
printf "Integer: %d, Float: %.2f\n" 42 3.14159

# Padding and alignment
printf "|%10s|%-10s|\n" "Right" "Left"
printf "|%010d|\n" 42  # Zero-padded

# Multiple values
printf "Name: %s, Age: %d, Score: %.1f\n" "Alice" 25 95.7
```

## Command Substitution

### Using $() (Recommended)

```bash
current_date=$(date)
user_count=$(who | wc -l)
file_count=$(ls | wc -l)

echo "Today is: $current_date"
echo "Users logged in: $user_count"
echo "Files in directory: $file_count"
```

### Using Backticks (Deprecated)

```bash
# Old style - avoid using
current_date=`date`
echo "Date: $current_date"
```

### Nested Command Substitution

```bash
# Get the size of the largest file
largest_file_size=$(ls -la | awk '{print $5}' | sort -n | tail -1)

# Get the name of the current directory
current_dir=$(basename $(pwd))

# Complex example
log_message="[$(date '+%Y-%m-%d %H:%M:%S')] User $(whoami) in $(pwd)"
echo "$log_message"
```

## Here Documents (Heredoc)

### Basic Heredoc

```bash
cat << EOF
This is a here document
It can contain multiple lines
Variables are expanded: $HOME
EOF
```

### Heredoc with No Variable Expansion

```bash
cat << 'EOF'
This is a literal here document
Variables are NOT expanded: $HOME
Special characters are literal: \n \t
EOF
```

### Heredoc to Variable

```bash
message=$(cat << EOF
Welcome to our system!
Today's date: $(date)
Your home directory: $HOME
EOF
)

echo "$message"
```

### Indented Heredoc

```bash
if true; then
    cat <<- EOF
	This heredoc is indented
	The leading tabs will be removed
	But internal formatting is preserved
	EOF
fi
```

## Here Strings

```bash
# Pass string directly to command
grep "pattern" <<< "text to search pattern here"

# With variables
text="Hello World Pattern Test"
grep "Pattern" <<< "$text"

# Multiple commands
{
    echo "Line 1"
    echo "Line 2"
    echo "Line 3"
} | grep "2"
```

## Basic Script Examples

### Example 1: System Information Script

```bash
#!/usr/bin/env bash
# File: detailed_system_info.sh
# Purpose: Display comprehensive system information

# Script header
cat << 'HEADER'
=====================================
    SYSTEM INFORMATION REPORT
=====================================
HEADER

# System details
printf "%-20s: %s\n" "Hostname" "$(hostname)"
printf "%-20s: %s\n" "Username" "$(whoami)"
printf "%-20s: %s\n" "Date/Time" "$(date)"
printf "%-20s: %s\n" "Uptime" "$(uptime | awk -F, '{print $1}' | sed 's/.*up //')"
printf "%-20s: %s\n" "Bash Version" "$BASH_VERSION"
printf "%-20s: %s\n" "Working Directory" "$(pwd)"
printf "%-20s: %s\n" "Home Directory" "$HOME"

# Separator
echo "-------------------------------------"

# File system information
echo "DISK USAGE:"
df -h | head -1
df -h | grep -E '^/dev/'

echo "-------------------------------------"

# Memory information (if available)
if command -v free >/dev/null 2>&1; then
    echo "MEMORY USAGE:"
    free -h
elif command -v vm_stat >/dev/null 2>&1; then
    echo "MEMORY USAGE (macOS):"
    vm_stat | head -5
fi
```

### Example 2: File Processing Script

```bash
#!/usr/bin/env bash
# File: file_processor.sh
# Purpose: Process files in current directory

echo "File Processing Report"
echo "====================="

# Count different file types
total_files=$(ls -1 | wc -l)
directories=$(ls -la | grep '^d' | wc -l)
regular_files=$((total_files - directories))

printf "Total items: %d\n" "$total_files"
printf "Directories: %d\n" "$directories"
printf "Regular files: %d\n" "$regular_files"

echo
echo "File breakdown by extension:"
echo "----------------------------"

# Group files by extension
for file in *; do
    if [[ -f "$file" ]]; then
        extension="${file##*.}"
        if [[ "$extension" == "$file" ]]; then
            extension="no_extension"
        fi
        echo "$extension"
    fi
done | sort | uniq -c | sort -nr

echo
echo "Largest files:"
echo "--------------"
ls -lah | sort -k5 -hr | head -5
```

### Example 3: Interactive Menu Script

```bash
#!/usr/bin/env bash
# File: simple_menu.sh
# Purpose: Interactive menu demonstration

# Function to display menu
show_menu() {
    echo
    echo "====== SIMPLE MENU ======"
    echo "1. Display current date"
    echo "2. Show current directory"
    echo "3. List files"
    echo "4. Show disk usage"
    echo "5. Exit"
    echo "========================="
    echo -n "Choose an option [1-5]: "
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            echo "Current date: $(date)"
            ;;
        2)
            echo "Current directory: $(pwd)"
            ;;
        3)
            echo "Files in current directory:"
            ls -la
            ;;
        4)
            echo "Disk usage:"
            df -h
            ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose 1-5."
            ;;
    esac
    
    echo
    echo "Press Enter to continue..."
    read -r
done
```

## Best Practices for Script Structure

### 1. Use Proper Headers

```bash
#!/usr/bin/env bash
#
# Script: backup_system.sh
# Purpose: Automated system backup
# Author: Admin Team
# Version: 2.1.0
# Date: 2024-01-15
#
# Usage: ./backup_system.sh [options]
# Dependencies: rsync, tar
#
```

### 2. Set Script Options

```bash
#!/usr/bin/env bash

# Exit on any error
set -e

# Exit on undefined variable
set -u

# Exit on pipe failure
set -o pipefail

# Enable debug mode (uncomment when debugging)
# set -x
```

### 3. Use Constants

```bash
#!/usr/bin/env bash

# Constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly LOG_FILE="/var/log/${SCRIPT_NAME}.log"
readonly CONFIG_FILE="/etc/${SCRIPT_NAME}.conf"

# Version
readonly VERSION="1.0.0"
```

## Practice Exercises

### Exercise 1: Personal Information Script

Create a script that displays a formatted report with:
- Your name and favorite programming language
- Current date and time
- Your home directory
- Number of files in your home directory

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash
# Personal information script

name="Your Name"
favorite_lang="Bash"

cat << EOF
Personal Information Report
===========================
Name: $name
Favorite Language: $favorite_lang
Date: $(date)
Home Directory: $HOME
Files in Home: $(ls "$HOME" | wc -l)
===========================
EOF
```
</details>

### Exercise 2: System Stats

Write a script that shows:
- System uptime
- Current user count
- Available disk space
- Memory usage (if available)

Use printf for clean formatting.

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash
# System statistics script

printf "=== SYSTEM STATISTICS ===\n"
printf "%-15s: %s\n" "Uptime" "$(uptime | cut -d',' -f1 | sed 's/.*up //')"
printf "%-15s: %s\n" "Users Online" "$(who | wc -l)"
printf "%-15s: %s\n" "Disk Available" "$(df -h . | awk 'NR==2{print $4}')"

if command -v free >/dev/null 2>&1; then
    printf "%-15s: %s\n" "Memory Free" "$(free -h | awk 'NR==2{print $7}')"
fi

printf "========================\n"
```
</details>

## Key Takeaways

1. Always use proper script headers and comments
2. Use `$()` for command substitution, not backticks
3. Printf gives more control than echo
4. Here documents are great for multi-line text
5. Structure your scripts with functions and constants
6. Set proper error handling with `set` options

## Next Steps

Continue to [Chapter 3: Variables and Data Types](../03-variables/README.md) to learn about storing and manipulating data in bash scripts.

## Quick Reference

```bash
# Script template
#!/usr/bin/env bash
set -euo pipefail

# Header comment block
# Constants
readonly VAR="value"

# Functions
main() {
    local variable="value"
    printf "Output: %s\n" "$variable"
}

# Execute
main "$@"
```
