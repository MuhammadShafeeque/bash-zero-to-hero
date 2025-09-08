# Chapter 4: Input and Output Operations

## Standard Input, Output, and Error

### Understanding File Descriptors

```bash
# Standard streams
# 0 = stdin (standard input)
# 1 = stdout (standard output)  
# 2 = stderr (standard error)

# Explicit redirection
echo "Normal output" >&1
echo "Error message" >&2
```

## Reading Input

### Basic Input Reading

```bash
#!/usr/bin/env bash
# Basic input methods

# Simple read
echo -n "Enter your name: "
read name
echo "Hello, $name!"

# Read with prompt
read -p "Enter your age: " age

# Read with timeout
if read -t 5 -p "Enter something (5 sec timeout): " input; then
    echo "You entered: $input"
else
    echo "Timeout! No input received."
fi

# Silent input (for passwords)
read -s -p "Enter password: " password
echo  # New line after silent input
echo "Password has ${#password} characters"
```

### Advanced Input Options

```bash
#!/usr/bin/env bash
# Advanced input reading

# Read single character
echo -n "Press any key to continue..."
read -n 1 -s key
echo "You pressed: $key"

# Read multiple variables
read -p "Enter first and last name: " first_name last_name
echo "First: $first_name, Last: $last_name"

# Read into array
echo "Enter multiple words:"
read -a word_array
echo "You entered ${#word_array[@]} words: ${word_array[*]}"

# Custom delimiter
echo "Enter values separated by commas:"
IFS=',' read -a values
echo "Values: ${values[*]}"

# Read from variable
data="apple,banana,orange"
IFS=',' read -a fruits <<< "$data"
echo "Fruits: ${fruits[*]}"
```

### Reading from Files

```bash
#!/usr/bin/env bash
# Reading from files

# Read line by line
while IFS= read -r line; do
    echo "Processing: $line"
done < "input.txt"

# Read with line numbers
line_num=1
while IFS= read -r line; do
    printf "%3d: %s\n" "$line_num" "$line"
    ((line_num++))
done < "input.txt"

# Read entire file into variable
file_content=$(cat "input.txt")
echo "File content: $file_content"

# Read file into array (preserving empty lines)
mapfile -t lines < "input.txt"
echo "File has ${#lines[@]} lines"

# Process CSV file
while IFS=',' read -r name age city; do
    echo "Name: $name, Age: $age, City: $city"
done < "data.csv"
```

## Output and Formatting

### Echo vs Printf

```bash
#!/usr/bin/env bash
# Output comparison

# Echo - simple and fast
echo "Simple text"
echo -e "With\tescapes\nand newlines"
echo -n "No newline at end"

# Printf - more control
printf "Formatted: %s %d %.2f\n" "text" 42 3.14159
printf "Padded: |%10s|%-10s|\n" "right" "left"
printf "Numbers: %05d %x %o\n" 42 42 42

# Formatting examples
printf "%-20s %10s %8s\n" "Name" "Age" "Score"
printf "%-20s %10d %8.1f\n" "Alice" 25 95.5
printf "%-20s %10d %8.1f\n" "Bob" 30 87.2
```

### Here Documents and Here Strings

```bash
#!/usr/bin/env bash
# Here documents

# Basic here document
cat << EOF
This is a multi-line
here document that can
contain variables: $USER
and command substitution: $(date)
EOF

# Quoted here document (no expansion)
cat << 'EOF'
This here document
will not expand $USER
or $(date)
EOF

# Indented here document
if true; then
    cat <<- 'EOF'
	This is indented
	Leading tabs are removed
	EOF
fi

# Here document to variable
message=$(cat << EOF
Welcome $USER!
Today is $(date +%A)
Your home directory is $HOME
EOF
)

echo "$message"

# Here string
grep "pattern" <<< "search this pattern text"

# Here string with variable
text="Hello World"
wc -w <<< "$text"
```

## Redirection

### Output Redirection

```bash
#!/usr/bin/env bash
# Output redirection examples

# Redirect stdout to file
echo "Hello World" > output.txt

# Append to file
echo "Second line" >> output.txt

# Redirect stderr to file
ls nonexistent 2> error.log

# Redirect both stdout and stderr
ls /etc /nonexistent > all_output.txt 2>&1

# Redirect to different files
ls /etc /nonexistent > success.log 2> error.log

# Redirect to null (discard output)
noisy_command > /dev/null 2>&1

# Redirect stderr to stdout
command 2>&1

# Redirect stdout to stderr
echo "Error message" >&2
```

### Input Redirection

```bash
#!/usr/bin/env bash
# Input redirection

# Read from file
sort < unsorted.txt

# Here document as input
sort << EOF
banana
apple
cherry
EOF

# Read from file descriptor
exec 3< input.txt
while read -r line <&3; do
    echo "Line: $line"
done
exec 3<&-  # Close file descriptor
```

### Advanced Redirection

```bash
#!/usr/bin/env bash
# Advanced redirection techniques

# Tee - write to file and stdout
echo "Important message" | tee important.log

# Multiple outputs
echo "Data" | tee file1.txt file2.txt file3.txt

# Process substitution
diff <(ls dir1) <(ls dir2)

# Command substitution with multiple lines
users=$(cat << 'EOF' | sort
alice
bob
charlie
admin
EOF
)

echo "Sorted users: $users"

# Named pipes (FIFOs)
mkfifo mypipe
echo "Hello" > mypipe &
read message < mypipe
echo "Received: $message"
rm mypipe
```

## File Operations

### Creating and Writing Files

```bash
#!/usr/bin/env bash
# File creation and writing

# Create empty file
touch newfile.txt

# Write to file (overwrite)
echo "First line" > myfile.txt

# Append to file
echo "Second line" >> myfile.txt

# Write multiple lines
cat > multiline.txt << EOF
Line 1
Line 2
Line 3
EOF

# Write array to file
fruits=("apple" "banana" "orange")
printf "%s\n" "${fruits[@]}" > fruits.txt

# Write formatted data
printf "%-10s %5s\n" "Name" "Age" > people.txt
printf "%-10s %5d\n" "Alice" 25 >> people.txt
printf "%-10s %5d\n" "Bob" 30 >> people.txt
```

### Reading and Processing Files

```bash
#!/usr/bin/env bash
# File reading and processing

# Count lines, words, characters
echo "File statistics for input.txt:"
wc input.txt

# Display file with line numbers
nl input.txt

# Show first/last lines
head -5 input.txt    # First 5 lines
tail -5 input.txt    # Last 5 lines
tail -f log.txt      # Follow file (like live monitoring)

# Search in files
grep "pattern" file.txt
grep -n "pattern" file.txt     # Show line numbers
grep -i "pattern" file.txt     # Case insensitive
grep -r "pattern" directory/   # Recursive search

# Process file line by line with modifications
while IFS= read -r line; do
    # Convert to uppercase and add line number
    echo "${line^^}" | nl
done < input.txt > processed.txt
```

## Interactive Menus and Forms

### Simple Menu System

```bash
#!/usr/bin/env bash
# Interactive menu system

show_menu() {
    clear
    echo "================================="
    echo "        MAIN MENU"
    echo "================================="
    echo "1. Display system information"
    echo "2. List files in current directory"
    echo "3. Show disk usage"
    echo "4. Show running processes"
    echo "5. Exit"
    echo "================================="
}

while true; do
    show_menu
    read -p "Enter your choice [1-5]: " choice
    
    case $choice in
        1)
            echo "System Information:"
            uname -a
            ;;
        2)
            echo "Files in current directory:"
            ls -la
            ;;
        3)
            echo "Disk Usage:"
            df -h
            ;;
        4)
            echo "Running Processes:"
            ps aux | head -10
            ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option! Please choose 1-5."
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
done
```

### Data Entry Form

```bash
#!/usr/bin/env bash
# Data entry form

collect_user_data() {
    echo "======== USER REGISTRATION ========"
    
    # Personal information
    while [[ -z "$full_name" ]]; do
        read -p "Full Name (required): " full_name
        [[ -z "$full_name" ]] && echo "Name cannot be empty!"
    done
    
    while [[ -z "$email" ]]; do
        read -p "Email (required): " email
        if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            echo "Invalid email format!"
            email=""
        fi
    done
    
    while [[ -z "$age" ]]; do
        read -p "Age: " age
        if ! [[ "$age" =~ ^[0-9]+$ ]] || [[ $age -lt 1 || $age -gt 120 ]]; then
            echo "Please enter a valid age (1-120)!"
            age=""
        fi
    done
    
    # Optional fields
    read -p "Phone (optional): " phone
    read -p "City (optional): " city
    
    # Confirmation
    echo
    echo "======== CONFIRMATION ========"
    echo "Name: $full_name"
    echo "Email: $email"
    echo "Age: $age"
    [[ -n "$phone" ]] && echo "Phone: $phone"
    [[ -n "$city" ]] && echo "City: $city"
    echo
    
    read -p "Is this information correct? (y/n): " confirm
    case $confirm in
        [Yy]|[Yy][Ee][Ss])
            save_user_data
            ;;
        *)
            echo "Registration cancelled."
            ;;
    esac
}

save_user_data() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Save to CSV file
    echo "$timestamp,$full_name,$email,$age,$phone,$city" >> users.csv
    
    echo "User data saved successfully!"
}

# Create CSV header if file doesn't exist
[[ ! -f users.csv ]] && echo "Timestamp,Name,Email,Age,Phone,City" > users.csv

collect_user_data
```

## Logging and Output Management

### Logging System

```bash
#!/usr/bin/env bash
# Logging system

# Configuration
LOG_FILE="/tmp/app.log"
LOG_LEVEL="INFO"

# Log levels
declare -A LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [WARN]=2
    [ERROR]=3
    [FATAL]=4
)

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Check if we should log this level
    if [[ ${LOG_LEVELS[$level]} -ge ${LOG_LEVELS[$LOG_LEVEL]} ]]; then
        echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
    fi
}

# Convenience functions
log_debug() { log "DEBUG" "$@"; }
log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_fatal() { log "FATAL" "$@"; exit 1; }

# Usage examples
log_info "Application starting"
log_debug "Debug information"
log_warn "This is a warning"
log_error "An error occurred"

# Rotate log files
rotate_logs() {
    local max_size=1048576  # 1MB
    
    if [[ -f "$LOG_FILE" && $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null) -gt $max_size ]]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        touch "$LOG_FILE"
        log_info "Log file rotated"
    fi
}
```

## Progress Indicators

### Progress Bar

```bash
#!/usr/bin/env bash
# Progress bar implementation

show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    # Build progress bar
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    
    # Display progress
    printf "\r[%s] %d%% (%d/%d)" "$bar" "$percentage" "$current" "$total"
    
    # New line when complete
    [[ $current -eq $total ]] && echo
}

# Example usage
echo "Processing files..."
total_files=100

for ((i=1; i<=total_files; i++)); do
    # Simulate work
    sleep 0.1
    show_progress $i $total_files
done

echo "Complete!"
```

### Spinner

```bash
#!/usr/bin/env bash
# Spinner implementation

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    
    printf "    \b\b\b\b"
}

# Example usage
echo -n "Processing"
sleep 5 &  # Background process
spinner $!
echo "Done!"
```

## Practice Exercises

### Exercise 1: File Processor

Create a script that:
1. Reads a list of files from user input
2. For each file, displays size, modification date, and first 5 lines
3. Logs all operations to a log file

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash

LOG_FILE="file_processor.log"

log_operation() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

process_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found!"
        log_operation "ERROR: File '$file' not found"
        return 1
    fi
    
    echo "Processing: $file"
    echo "=================="
    
    # File information
    local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    local mod_date=$(stat -f%Sm "$file" 2>/dev/null || stat -c%y "$file" 2>/dev/null)
    
    echo "Size: $size bytes"
    echo "Modified: $mod_date"
    echo "First 5 lines:"
    echo "-------------"
    head -5 "$file"
    echo
    
    log_operation "Processed file: $file (size: $size bytes)"
}

echo "File Processor"
echo "=============="
echo "Enter file names (one per line, empty line to finish):"

while true; do
    read -r filename
    [[ -z "$filename" ]] && break
    process_file "$filename"
done

echo "Processing complete. Check $LOG_FILE for details."
```
</details>

### Exercise 2: Configuration Manager

Write a script that:
1. Reads configuration from a file or creates default values
2. Allows user to modify settings interactively
3. Saves configuration back to file
4. Validates input values

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash

CONFIG_FILE="app.conf"

# Default configuration
declare -A config=(
    [server_host]="localhost"
    [server_port]="8080"
    [debug_mode]="false"
    [max_connections]="100"
    [timeout]="30"
)

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        echo "Loading configuration from $CONFIG_FILE"
        while IFS='=' read -r key value; do
            [[ $key =~ ^#.*$ || -z $key ]] && continue
            config[$key]="$value"
        done < "$CONFIG_FILE"
    fi
}

save_config() {
    echo "# Application Configuration" > "$CONFIG_FILE"
    echo "# Generated on $(date)" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
    
    for key in "${!config[@]}"; do
        echo "$key=${config[$key]}" >> "$CONFIG_FILE"
    done
    
    echo "Configuration saved to $CONFIG_FILE"
}

validate_input() {
    local key="$1"
    local value="$2"
    
    case "$key" in
        server_port|max_connections|timeout)
            if ! [[ "$value" =~ ^[0-9]+$ ]] || [[ $value -lt 1 ]]; then
                echo "Error: $key must be a positive number"
                return 1
            fi
            ;;
        debug_mode)
            if [[ "$value" != "true" && "$value" != "false" ]]; then
                echo "Error: debug_mode must be 'true' or 'false'"
                return 1
            fi
            ;;
    esac
    
    return 0
}

configure_interactively() {
    echo "Current Configuration:"
    echo "====================="
    
    for key in "${!config[@]}"; do
        printf "%-15s: %s\n" "$key" "${config[$key]}"
    done
    
    echo
    echo "Modify settings (press Enter to keep current value):"
    
    for key in "${!config[@]}"; do
        while true; do
            read -p "$key [${config[$key]}]: " new_value
            
            if [[ -z "$new_value" ]]; then
                break
            fi
            
            if validate_input "$key" "$new_value"; then
                config[$key]="$new_value"
                break
            fi
        done
    done
}

# Main execution
load_config
configure_interactively
save_config
```
</details>

## Key Takeaways

1. Use appropriate input methods for different scenarios
2. Always validate user input
3. Use here documents for multi-line text
4. Master redirection for flexible I/O control
5. Implement proper logging for debugging
6. Create user-friendly interfaces with menus and progress indicators
7. Handle errors gracefully

## Next Steps

Continue to [Chapter 5: Conditional Statements](../05-conditionals/README.md) to learn about decision-making in bash scripts.

## Quick Reference

```bash
# Input
read -p "Prompt: " var
read -s -p "Password: " pass
read -t 5 -p "Timeout: " input

# Output redirection
command > file          # stdout to file
command >> file         # append stdout
command 2> file         # stderr to file
command &> file         # both to file
command | tee file      # stdout to file and terminal

# Here documents
cat << EOF
Multi-line text
Variables: $USER
EOF

# File testing
[[ -f file ]]           # file exists
[[ -d dir ]]            # directory exists
[[ -r file ]]           # readable
[[ -w file ]]           # writable
[[ -x file ]]           # executable
```
