# Chapter 3: Variables and Data Types

## Variable Declaration and Assignment

### Basic Variable Assignment

```bash
# Simple assignment (no spaces around =)
name="John Doe"
age=25
is_student=true

# Using variables
echo "Name: $name"
echo "Age: $age"
echo "Student: $is_student"
```

### Variable Naming Rules

```bash
# Valid variable names
user_name="Alice"
USER_NAME="Bob"
userName="Charlie"
_private_var="secret"
var123="mixed"

# Invalid variable names (will cause errors)
# 123var="invalid"     # Cannot start with number
# user-name="invalid"  # Cannot contain hyphens
# user name="invalid"  # Cannot contain spaces
```

### Reading Variables

```bash
username="developer"

# Method 1: Using $
echo $username

# Method 2: Using ${} (recommended)
echo ${username}

# Method 3: For concatenation
echo "Hello ${username}!"
echo "User: ${username}_admin"
```

## Variable Scope

### Global Variables

```bash
#!/usr/bin/env bash

# Global variable
GLOBAL_VAR="I'm global"

function show_global() {
    echo "Inside function: $GLOBAL_VAR"
}

echo "Outside function: $GLOBAL_VAR"
show_global
```

### Local Variables

```bash
#!/usr/bin/env bash

GLOBAL_VAR="Global value"

function demo_local() {
    local LOCAL_VAR="Local value"
    local GLOBAL_VAR="Local override"
    
    echo "Local variable: $LOCAL_VAR"
    echo "Overridden global: $GLOBAL_VAR"
}

demo_local
echo "Global variable: $GLOBAL_VAR"  # Still original value
# echo "$LOCAL_VAR"  # This would cause an error
```

## Special Variables

### Positional Parameters

```bash
#!/usr/bin/env bash
# Script: positional_demo.sh

echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "Third argument: $3"

echo "All arguments: $@"
echo "All arguments (single string): $*"
echo "Number of arguments: $#"
echo "Process ID: $$"
echo "Exit status of last command: $?"
```

### Built-in Variables

```bash
# Process and environment variables
echo "Process ID: $$"
echo "Parent Process ID: $PPID"
echo "User ID: $UID"
echo "Home directory: $HOME"
echo "Current working directory: $PWD"
echo "Previous working directory: $OLDPWD"
echo "Path: $PATH"
echo "Shell: $SHELL"
echo "Random number: $RANDOM"
echo "Current line number: $LINENO"
```

## Data Types

### Strings

```bash
# String assignment
first_name="John"
last_name='Doe'
full_name="$first_name $last_name"

# String length
echo "Length of name: ${#full_name}"

# String manipulation
text="Hello World"
echo "Original: $text"
echo "Uppercase: ${text^^}"        # Bash 4+
echo "Lowercase: ${text,,}"        # Bash 4+
echo "First char upper: ${text^}"  # Bash 4+
echo "First char lower: ${text,}"  # Bash 4+
```

### String Operations

```bash
string="Hello World Programming"

# Substring extraction
echo "Characters 0-5: ${string:0:5}"     # "Hello"
echo "Characters 6 onwards: ${string:6}" # "World Programming"
echo "Last 11 characters: ${string: -11}" # "Programming"

# String replacement
echo "Replace first 'o': ${string/o/O}"    # "HellO World Programming"
echo "Replace all 'o': ${string//o/O}"     # "HellO WOrld PrOgramming"
echo "Remove 'World ': ${string/World /}"  # "Hello Programming"

# String length and checking
echo "Length: ${#string}"
echo "Is empty: ${string:+false}"
echo "Default if empty: ${string:-'default'}"
```

### Numbers (Integers)

```bash
# Integer arithmetic with $(())
num1=10
num2=5

echo "Addition: $((num1 + num2))"
echo "Subtraction: $((num1 - num2))"
echo "Multiplication: $((num1 * num2))"
echo "Division: $((num1 / num2))"
echo "Modulo: $((num1 % num2))"
echo "Power: $((num1 ** 2))"

# Increment/Decrement
counter=0
echo "Initial: $counter"
((counter++))
echo "After increment: $counter"
((counter += 5))
echo "After adding 5: $counter"
```

### Floating Point Numbers

```bash
# Bash doesn't support floating point natively
# Use bc or awk for floating point arithmetic

# Using bc
result=$(echo "scale=2; 10.5 + 3.7" | bc)
echo "10.5 + 3.7 = $result"

# Using awk
result=$(awk "BEGIN {printf \"%.2f\", 10.5 + 3.7}")
echo "Using awk: $result"

# Function for floating point arithmetic
calculate() {
    echo "scale=4; $*" | bc -l
}

echo "Square root of 2: $(calculate "sqrt(2)")"
echo "Pi: $(calculate "4*a(1)")"  # arctan(1) * 4 = pi
```

## Arrays

### Indexed Arrays

```bash
# Array declaration
fruits=("apple" "banana" "orange")

# Alternative declarations
colors[0]="red"
colors[1]="green"
colors[2]="blue"

# Adding elements
fruits+=("grape")
fruits[10]="mango"  # Sparse array

# Accessing elements
echo "First fruit: ${fruits[0]}"
echo "All fruits: ${fruits[@]}"
echo "All fruits (quoted): ${fruits[*]}"
echo "Number of fruits: ${#fruits[@]}"
echo "Indices: ${!fruits[@]}"

# Iterating arrays
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done

# Array slicing
echo "First 3 fruits: ${fruits[@]:0:3}"
echo "From index 1: ${fruits[@]:1}"
```

### Associative Arrays (Bash 4+)

```bash
# Declare associative array
declare -A student_grades

# Assign values
student_grades[Alice]=95
student_grades[Bob]=87
student_grades[Charlie]=92

# Alternative assignment
declare -A countries=(
    [USA]="Washington"
    [UK]="London"
    [France]="Paris"
    [Japan]="Tokyo"
)

# Access values
echo "Alice's grade: ${student_grades[Alice]}"
echo "Capital of France: ${countries[France]}"

# Get all keys and values
echo "Students: ${!student_grades[@]}"
echo "Grades: ${student_grades[@]}"

# Iterate associative array
for student in "${!student_grades[@]}"; do
    echo "$student: ${student_grades[$student]}"
done
```

## Variable Manipulation

### Parameter Expansion

```bash
filename="document.txt.bak"

# Get file extension
echo "Extension: ${filename##*.}"        # "bak"

# Get filename without extension
echo "Name: ${filename%.*}"              # "document.txt"

# Get base filename
echo "Base: ${filename%%.*}"             # "document"

# Get directory (if path)
path="/home/user/documents/file.txt"
echo "Directory: ${path%/*}"             # "/home/user/documents"
echo "Filename: ${path##*/}"             # "file.txt"
```

### Default Values and Error Handling

```bash
# Set default values
username=${USER:-"unknown"}
config_file=${CONFIG_FILE:-"/etc/default.conf"}

# Required variables (exit if not set)
database_url=${DATABASE_URL:?"Database URL is required"}

# Set variable if not already set
: ${LOG_LEVEL:="INFO"}
: ${DEBUG:=false}

echo "Username: $username"
echo "Config: $config_file"
echo "Log level: $LOG_LEVEL"
echo "Debug: $DEBUG"
```

## Input and Output

### Reading User Input

```bash
# Basic input
echo -n "Enter your name: "
read name
echo "Hello, $name!"

# Read with prompt
read -p "Enter your age: " age
echo "You are $age years old"

# Silent input (passwords)
read -s -p "Enter password: " password
echo
echo "Password entered (length: ${#password})"

# Read multiple values
read -p "Enter first and last name: " first last
echo "First: $first, Last: $last"

# Read into array
read -a words -p "Enter some words: "
echo "You entered ${#words[@]} words: ${words[*]}"
```

### Reading from Files

```bash
# Read line by line
while IFS= read -r line; do
    echo "Line: $line"
done < "filename.txt"

# Read entire file into variable
file_content=$(cat "filename.txt")

# Read file into array
mapfile -t lines < "filename.txt"
# or
readarray -t lines < "filename.txt"

echo "File has ${#lines[@]} lines"
```

## Practical Examples

### Example 1: User Information Collector

```bash
#!/usr/bin/env bash
# File: user_info_collector.sh

# Collect user information
read -p "Enter your full name: " full_name
read -p "Enter your age: " age
read -p "Enter your email: " email
read -s -p "Create a password: " password
echo

# Validate and process
if [[ -z "$full_name" || -z "$email" ]]; then
    echo "Name and email are required!"
    exit 1
fi

# Split name
IFS=' ' read -r first_name last_name <<< "$full_name"

# Create user ID
user_id="${first_name,,}_${last_name,,}"  # lowercase
user_id="${user_id// /_}"  # replace spaces with underscores

# Display summary
cat << EOF

User Registration Summary
========================
Name: $full_name
First: $first_name
Last: $last_name
Age: $age
Email: $email
User ID: $user_id
Password Length: ${#password} characters
========================
EOF
```

### Example 2: System Configuration Script

```bash
#!/usr/bin/env bash
# File: config_manager.sh

# Default configuration
declare -A config=(
    [app_name]="MyApp"
    [version]="1.0"
    [debug]="false"
    [port]="8080"
    [database_host]="localhost"
)

# Load configuration from file if exists
CONFIG_FILE="${CONFIG_FILE:-config.conf}"

if [[ -f "$CONFIG_FILE" ]]; then
    echo "Loading configuration from $CONFIG_FILE"
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^#.*$ || -z $key ]] && continue
        config[$key]="$value"
    done < "$CONFIG_FILE"
fi

# Display current configuration
echo "Current Configuration:"
echo "====================="
for key in "${!config[@]}"; do
    printf "%-15s: %s\n" "$key" "${config[$key]}"
done

# Allow user to modify configuration
echo
echo "Modify configuration (press Enter to keep current value):"
for key in "${!config[@]}"; do
    read -p "$key [${config[$key]}]: " new_value
    [[ -n "$new_value" ]] && config[$key]="$new_value"
done

# Save configuration
echo
echo "Saving configuration to $CONFIG_FILE..."
{
    echo "# Configuration file"
    echo "# Generated on $(date)"
    for key in "${!config[@]}"; do
        echo "$key=${config[$key]}"
    done
} > "$CONFIG_FILE"

echo "Configuration saved!"
```

### Example 3: Calculator Script

```bash
#!/usr/bin/env bash
# File: calculator.sh

calculate() {
    local operation="$1"
    local num1="$2"
    local num2="$3"
    local result
    
    case "$operation" in
        "add"|"+")
            result=$((num1 + num2))
            ;;
        "sub"|"-")
            result=$((num1 - num2))
            ;;
        "mul"|"*")
            result=$((num1 * num2))
            ;;
        "div"|"/")
            if [[ $num2 -eq 0 ]]; then
                echo "Error: Division by zero!"
                return 1
            fi
            result=$(echo "scale=2; $num1 / $num2" | bc)
            ;;
        "pow"|"**")
            result=$((num1 ** num2))
            ;;
        *)
            echo "Unknown operation: $operation"
            return 1
            ;;
    esac
    
    echo "$result"
}

# Interactive calculator
echo "Simple Calculator"
echo "================="
echo "Operations: add, sub, mul, div, pow"
echo "Type 'quit' to exit"
echo

while true; do
    read -p "Enter operation: " operation
    [[ "$operation" == "quit" ]] && break
    
    read -p "Enter first number: " num1
    read -p "Enter second number: " num2
    
    # Validate numbers
    if ! [[ "$num1" =~ ^-?[0-9]+\.?[0-9]*$ ]] || ! [[ "$num2" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
        echo "Please enter valid numbers!"
        continue
    fi
    
    result=$(calculate "$operation" "$num1" "$num2")
    if [[ $? -eq 0 ]]; then
        echo "Result: $num1 $operation $num2 = $result"
    fi
    echo
done

echo "Goodbye!"
```

## Practice Exercises

### Exercise 1: Variable Manipulation

Create a script that:
1. Takes a full file path as input
2. Extracts and displays the directory, filename, and extension
3. Creates a backup filename with timestamp

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash

read -p "Enter file path: " filepath

# Extract components
directory="${filepath%/*}"
filename="${filepath##*/}"
basename="${filename%.*}"
extension="${filename##*.}"

# Create backup name
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_name="${basename}_backup_${timestamp}.${extension}"

echo "Directory: $directory"
echo "Filename: $filename"
echo "Base name: $basename"
echo "Extension: $extension"
echo "Backup name: $backup_name"
```
</details>

### Exercise 2: Array Processing

Write a script that:
1. Reads a list of numbers from user
2. Stores them in an array
3. Calculates sum, average, min, and max

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash

read -p "Enter numbers separated by spaces: " -a numbers

if [[ ${#numbers[@]} -eq 0 ]]; then
    echo "No numbers entered!"
    exit 1
fi

sum=0
min=${numbers[0]}
max=${numbers[0]}

for num in "${numbers[@]}"; do
    sum=$((sum + num))
    [[ $num -lt $min ]] && min=$num
    [[ $num -gt $max ]] && max=$num
done

average=$(echo "scale=2; $sum / ${#numbers[@]}" | bc)

echo "Numbers: ${numbers[*]}"
echo "Count: ${#numbers[@]}"
echo "Sum: $sum"
echo "Average: $average"
echo "Min: $min"
echo "Max: $max"
```
</details>

## Key Takeaways

1. Use `${variable}` syntax for clarity and safety
2. Always quote variables to handle spaces: `"$variable"`
3. Use `local` for function variables
4. Arrays are powerful for storing lists of data
5. Parameter expansion provides many string manipulation features
6. Always validate user input
7. Use appropriate data types for your needs

## Next Steps

Continue to [Chapter 4: Input and Output](../04-input-output/README.md) to learn advanced I/O operations and redirection.

## Quick Reference

```bash
# Variable assignment
var="value"

# Variable usage
echo "${var}"

# Arrays
arr=("a" "b" "c")
echo "${arr[@]}"     # all elements
echo "${#arr[@]}"    # length
echo "${!arr[@]}"    # indices

# String manipulation
${var#pattern}       # remove shortest match from beginning
${var##pattern}      # remove longest match from beginning
${var%pattern}       # remove shortest match from end
${var%%pattern}      # remove longest match from end
${var/old/new}       # replace first match
${var//old/new}      # replace all matches
```
