# Chapter 9: Arrays and Data Structures

Arrays are one of the most powerful features in bash for handling collections of data. This chapter covers array creation, manipulation, and advanced techniques.

## What You'll Learn

- Array basics and types
- Array operations and manipulation
- Associative arrays (hash tables)
- Multi-dimensional array simulation
- Real-world array applications

## Array Fundamentals

### Creating Arrays

```bash
#!/usr/bin/env bash

# Method 1: Direct assignment
fruits=("apple" "banana" "cherry" "date")

# Method 2: Individual assignments
colors[0]="red"
colors[1]="green"
colors[2]="blue"

# Method 3: Using declare
declare -a numbers=(1 2 3 4 5)

# Method 4: From command output
files=($(ls *.txt))

# Method 5: Reading from file
mapfile -t lines < input.txt
# or
readarray -t lines < input.txt

echo "Fruits: ${fruits[@]}"
echo "Colors: ${colors[@]}"
echo "Numbers: ${numbers[@]}"
echo "Files: ${files[@]}"
echo "Lines from file: ${lines[@]}"
```

### Array Properties

```bash
#!/usr/bin/env bash

animals=("cat" "dog" "elephant" "fish" "giraffe")

# Array length
echo "Number of animals: ${#animals[@]}"

# Individual element length
echo "Length of first animal name: ${#animals[0]}"

# Array indices
echo "Array indices: ${!animals[@]}"

# Check if element exists
if [[ -n "${animals[2]:-}" ]]; then
    echo "Third animal exists: ${animals[2]}"
fi

# Array slice (subset)
echo "Animals 1-3: ${animals[@]:1:3}"

# All elements starting from index 2
echo "From index 2: ${animals[@]:2}"
```

## Array Operations

### Adding and Removing Elements

```bash
#!/usr/bin/env bash

# Initialize array
programming_languages=("bash" "python" "javascript")

echo "Initial: ${programming_languages[@]}"

# Add element to end
programming_languages+=("go")
echo "After adding go: ${programming_languages[@]}"

# Add multiple elements
programming_languages+=("rust" "c++")
echo "After adding rust and c++: ${programming_languages[@]}"

# Insert at beginning (recreate array)
programming_languages=("assembly" "${programming_languages[@]}")
echo "After inserting assembly at start: ${programming_languages[@]}"

# Insert at specific position
insert_at_position() {
    local -n arr_ref=$1
    local position=$2
    local new_element=$3
    
    arr_ref=("${arr_ref[@]:0:position}" "$new_element" "${arr_ref[@]:position}")
}

insert_at_position programming_languages 2 "java"
echo "After inserting java at position 2: ${programming_languages[@]}"

# Remove element by index
remove_by_index() {
    local -n arr_ref=$1
    local index=$2
    
    arr_ref=("${arr_ref[@]:0:index}" "${arr_ref[@]:index+1}")
}

remove_by_index programming_languages 1
echo "After removing element at index 1: ${programming_languages[@]}"

# Remove element by value
remove_by_value() {
    local -n arr_ref=$1
    local value=$2
    local new_array=()
    
    for element in "${arr_ref[@]}"; do
        if [[ "$element" != "$value" ]]; then
            new_array+=("$element")
        fi
    done
    
    arr_ref=("${new_array[@]}")
}

remove_by_value programming_languages "javascript"
echo "After removing javascript: ${programming_languages[@]}"
```

### Array Iteration

```bash
#!/usr/bin/env bash

servers=("web1.example.com" "web2.example.com" "db1.example.com" "cache1.example.com")

echo "=== Iteration Methods ==="

# Method 1: For loop with elements
echo "Method 1 - Direct iteration:"
for server in "${servers[@]}"; do
    echo "  Checking server: $server"
done

# Method 2: For loop with indices
echo -e "\nMethod 2 - Index-based iteration:"
for i in "${!servers[@]}"; do
    echo "  Server $((i+1)): ${servers[i]}"
done

# Method 3: C-style for loop
echo -e "\nMethod 3 - C-style loop:"
for ((i=0; i<${#servers[@]}; i++)); do
    echo "  Position $i: ${servers[i]}"
done

# Method 4: While loop with counter
echo -e "\nMethod 4 - While loop:"
i=0
while [[ $i -lt ${#servers[@]} ]]; do
    echo "  Entry $i: ${servers[i]}"
    ((i++))
done
```

## Associative Arrays

### Creating and Using Hash Tables

```bash
#!/usr/bin/env bash

# Declare associative array
declare -A user_info

# Add key-value pairs
user_info["name"]="John Doe"
user_info["email"]="john@example.com"
user_info["age"]="30"
user_info["department"]="Engineering"
user_info["location"]="San Francisco"

echo "=== User Information ==="
echo "Name: ${user_info[name]}"
echo "Email: ${user_info[email]}"
echo "Age: ${user_info[age]}"
echo "Department: ${user_info[department]}"
echo "Location: ${user_info[location]}"

# Check if key exists
if [[ -n "${user_info[phone]:-}" ]]; then
    echo "Phone: ${user_info[phone]}"
else
    echo "Phone: Not provided"
fi

# Iterate over keys
echo -e "\n=== All Keys ==="
for key in "${!user_info[@]}"; do
    echo "$key"
done

# Iterate over key-value pairs
echo -e "\n=== All Key-Value Pairs ==="
for key in "${!user_info[@]}"; do
    echo "$key: ${user_info[$key]}"
done

# Remove a key
unset user_info[age]
echo -e "\n=== After removing age ==="
for key in "${!user_info[@]}"; do
    echo "$key: ${user_info[$key]}"
done
```

### Configuration Management with Associative Arrays

```bash
#!/usr/bin/env bash

# Application configuration
declare -A config

# Load default configuration
load_default_config() {
    config["app_name"]="MyApp"
    config["version"]="1.0.0"
    config["debug"]="false"
    config["log_level"]="INFO"
    config["database_host"]="localhost"
    config["database_port"]="5432"
    config["cache_enabled"]="true"
    config["max_connections"]="100"
}

# Load configuration from file
load_config_file() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        echo "Config file not found: $config_file"
        return 1
    fi
    
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove quotes from value
        value="${value%\"}"
        value="${value#\"}"
        
        config["$key"]="$value"
    done < "$config_file"
}

# Get configuration value with default
get_config() {
    local key="$1"
    local default="${2:-}"
    
    echo "${config[$key]:-$default}"
}

# Set configuration value
set_config() {
    local key="$1"
    local value="$2"
    
    config["$key"]="$value"
}

# Validate configuration
validate_config() {
    local errors=0
    
    # Required settings
    local required=("app_name" "database_host" "database_port")
    for key in "${required[@]}"; do
        if [[ -z "${config[$key]:-}" ]]; then
            echo "Error: Required configuration missing: $key"
            ((errors++))
        fi
    done
    
    # Validate numeric values
    if [[ -n "${config[database_port]:-}" ]] && ! [[ "${config[database_port]}" =~ ^[0-9]+$ ]]; then
        echo "Error: database_port must be numeric"
        ((errors++))
    fi
    
    # Validate boolean values
    local booleans=("debug" "cache_enabled")
    for key in "${booleans[@]}"; do
        if [[ -n "${config[$key]:-}" ]] && [[ ! "${config[$key]}" =~ ^(true|false)$ ]]; then
            echo "Error: $key must be 'true' or 'false'"
            ((errors++))
        fi
    done
    
    return $errors
}

# Display configuration
show_config() {
    echo "=== Application Configuration ==="
    for key in $(printf '%s\n' "${!config[@]}" | sort); do
        echo "$key: ${config[$key]}"
    done
}

# Usage example
load_default_config

# Create sample config file
cat > app.conf << 'EOF'
# Application Configuration
app_name="MyAwesomeApp"
version="2.1.0"
debug="true"
log_level="DEBUG"
database_host="db.example.com"
database_port="3306"
# This is a comment
max_connections="200"
EOF

echo "Loading configuration from file..."
load_config_file "app.conf"

echo -e "\nValidating configuration..."
if validate_config; then
    echo "Configuration is valid!"
else
    echo "Configuration has errors!"
fi

show_config

# Clean up
rm -f app.conf
```

## Advanced Array Techniques

### Multi-dimensional Array Simulation

```bash
#!/usr/bin/env bash

# Simulate 2D array using associative array
declare -A matrix

# Set matrix dimensions
ROWS=3
COLS=4

# Initialize matrix
init_matrix() {
    local rows=$1
    local cols=$2
    local value=${3:-0}
    
    for ((i=0; i<rows; i++)); do
        for ((j=0; j<cols; j++)); do
            matrix["$i,$j"]="$value"
        done
    done
}

# Set matrix value
set_matrix() {
    local row=$1
    local col=$2
    local value=$3
    
    matrix["$row,$col"]="$value"
}

# Get matrix value
get_matrix() {
    local row=$1
    local col=$2
    
    echo "${matrix["$row,$col"]:-0}"
}

# Print matrix
print_matrix() {
    local rows=$1
    local cols=$2
    
    for ((i=0; i<rows; i++)); do
        for ((j=0; j<cols; j++)); do
            printf "%3s " "${matrix["$i,$j"]:-0}"
        done
        echo
    done
}

# Matrix operations
multiply_matrix_by_scalar() {
    local rows=$1
    local cols=$2
    local scalar=$3
    
    for ((i=0; i<rows; i++)); do
        for ((j=0; j<cols; j++)); do
            local current="${matrix["$i,$j"]:-0}"
            matrix["$i,$j"]=$((current * scalar))
        done
    done
}

# Usage example
echo "Initializing 3x4 matrix with zeros:"
init_matrix $ROWS $COLS 0
print_matrix $ROWS $COLS

echo -e "\nSetting some values:"
set_matrix 0 0 1
set_matrix 0 1 2
set_matrix 1 1 5
set_matrix 2 3 9
print_matrix $ROWS $COLS

echo -e "\nMultiplying by 3:"
multiply_matrix_by_scalar $ROWS $COLS 3
print_matrix $ROWS $COLS
```

### Array Sorting and Searching

```bash
#!/usr/bin/env bash

# Bubble sort implementation
bubble_sort() {
    local -n arr_ref=$1
    local n=${#arr_ref[@]}
    
    for ((i=0; i<n-1; i++)); do
        for ((j=0; j<n-i-1; j++)); do
            if [[ ${arr_ref[j]} > ${arr_ref[j+1]} ]]; then
                # Swap elements
                local temp=${arr_ref[j]}
                arr_ref[j]=${arr_ref[j+1]}
                arr_ref[j+1]=$temp
            fi
        done
    done
}

# Binary search (array must be sorted)
binary_search() {
    local -n arr_ref=$1
    local target=$2
    local left=0
    local right=$((${#arr_ref[@]} - 1))
    
    while [[ $left -le $right ]]; do
        local mid=$(( (left + right) / 2 ))
        
        if [[ ${arr_ref[mid]} -eq $target ]]; then
            echo $mid
            return 0
        elif [[ ${arr_ref[mid]} -lt $target ]]; then
            left=$((mid + 1))
        else
            right=$((mid - 1))
        fi
    done
    
    echo -1  # Not found
}

# Linear search
linear_search() {
    local -n arr_ref=$1
    local target=$2
    
    for i in "${!arr_ref[@]}"; do
        if [[ ${arr_ref[i]} == "$target" ]]; then
            echo $i
            return 0
        fi
    done
    
    echo -1  # Not found
}

# Find unique elements
find_unique() {
    local -n arr_ref=$1
    local -A seen
    local unique=()
    
    for element in "${arr_ref[@]}"; do
        if [[ -z "${seen[$element]:-}" ]]; then
            seen[$element]=1
            unique+=("$element")
        fi
    done
    
    arr_ref=("${unique[@]}")
}

# Usage examples
echo "=== Sorting Example ==="
numbers=(64 34 25 12 22 11 90)
echo "Original: ${numbers[@]}"

bubble_sort numbers
echo "Sorted: ${numbers[@]}"

echo -e "\n=== Search Examples ==="
target=22
index=$(binary_search numbers $target)
if [[ $index -ne -1 ]]; then
    echo "Binary search: Found $target at index $index"
else
    echo "Binary search: $target not found"
fi

mixed_array=("apple" "banana" "cherry" "apple" "banana")
echo -e "\nOriginal array: ${mixed_array[@]}"
find_unique mixed_array
echo "Unique elements: ${mixed_array[@]}"
```

## Practical Examples

### Log File Analysis

```bash
#!/usr/bin/env bash

# Analyze log files using arrays
analyze_logs() {
    local log_file="$1"
    
    if [[ ! -f "$log_file" ]]; then
        echo "Log file not found: $log_file"
        return 1
    fi
    
    # Arrays to store analysis data
    declare -A ip_counts
    declare -A status_counts
    declare -A hour_counts
    local -a error_lines=()
    
    # Read log file line by line
    while IFS= read -r line; do
        # Parse common log format: IP - - [timestamp] "method path protocol" status size
        if [[ $line =~ ^([0-9.]+).*\[([^]]+)\].*\"[^\"]*\"[[:space:]]+([0-9]+) ]]; then
            local ip="${BASH_REMATCH[1]}"
            local timestamp="${BASH_REMATCH[2]}"
            local status="${BASH_REMATCH[3]}"
            
            # Extract hour from timestamp
            local hour
            if [[ $timestamp =~ ([0-9]{2}):([0-9]{2}):([0-9]{2}) ]]; then
                hour="${BASH_REMATCH[1]}"
            fi
            
            # Count occurrences
            ((ip_counts[$ip]++))
            ((status_counts[$status]++))
            ((hour_counts[$hour]++))
            
            # Collect error lines
            if [[ $status -ge 400 ]]; then
                error_lines+=("$line")
            fi
        fi
    done < "$log_file"
    
    # Display results
    echo "=== Log Analysis Results ==="
    echo "Total lines processed: $(wc -l < "$log_file")"
    echo "Unique IP addresses: ${#ip_counts[@]}"
    echo "Error responses: ${#error_lines[@]}"
    
    echo -e "\n=== Top 5 IP Addresses ==="
    for ip in "${!ip_counts[@]}"; do
        echo "${ip_counts[$ip]} $ip"
    done | sort -rn | head -5
    
    echo -e "\n=== Status Code Distribution ==="
    for status in $(printf '%s\n' "${!status_counts[@]}" | sort); do
        echo "$status: ${status_counts[$status]}"
    done
    
    echo -e "\n=== Hourly Traffic Distribution ==="
    for hour in $(printf '%s\n' "${!hour_counts[@]}" | sort); do
        printf "%s:00 %s\n" "$hour" "${hour_counts[$hour]}"
    done
}

# Create sample log file for testing
create_sample_log() {
    cat > sample.log << 'EOF'
192.168.1.100 - - [01/Jan/2024:10:15:30 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - - [01/Jan/2024:10:16:45 +0000] "GET /about.html HTTP/1.1" 200 5678
192.168.1.100 - - [01/Jan/2024:10:17:22 +0000] "GET /missing.html HTTP/1.1" 404 890
10.0.0.50 - - [01/Jan/2024:11:20:15 +0000] "POST /api/data HTTP/1.1" 500 234
192.168.1.102 - - [01/Jan/2024:11:25:33 +0000] "GET /products.html HTTP/1.1" 200 3456
192.168.1.100 - - [01/Jan/2024:12:30:45 +0000] "GET /contact.html HTTP/1.1" 200 2345
EOF
}

# Run analysis
echo "Creating sample log file..."
create_sample_log

echo "Analyzing logs..."
analyze_logs "sample.log"

# Clean up
rm -f sample.log
```

### File Organization System

```bash
#!/usr/bin/env bash

# Organize files by extension using arrays
organize_files() {
    local source_dir="$1"
    local target_dir="$2"
    
    if [[ ! -d "$source_dir" ]]; then
        echo "Source directory not found: $source_dir"
        return 1
    fi
    
    mkdir -p "$target_dir"
    
    declare -A extension_counts
    declare -A file_sizes
    local organized_files=()
    local skipped_files=()
    
    # Find all files
    while IFS= read -r -d '' file; do
        local basename
        basename=$(basename "$file")
        
        # Skip hidden files and directories
        if [[ "$basename" == .* ]] || [[ -d "$file" ]]; then
            skipped_files+=("$file")
            continue
        fi
        
        # Get file extension
        local extension="${basename##*.}"
        if [[ "$basename" == "$extension" ]]; then
            extension="no_extension"
        fi
        
        # Create target directory for extension
        local ext_dir="$target_dir/$extension"
        mkdir -p "$ext_dir"
        
        # Move file
        if mv "$file" "$ext_dir/"; then
            organized_files+=("$file")
            ((extension_counts[$extension]++))
            
            # Get file size
            local size
            size=$(stat -f%z "$ext_dir/$basename" 2>/dev/null || stat -c%s "$ext_dir/$basename" 2>/dev/null || echo 0)
            file_sizes[$extension]=$((${file_sizes[$extension]:-0} + size))
        else
            skipped_files+=("$file")
        fi
        
    done < <(find "$source_dir" -type f -print0)
    
    # Display results
    echo "=== File Organization Results ==="
    echo "Files organized: ${#organized_files[@]}"
    echo "Files skipped: ${#skipped_files[@]}"
    
    echo -e "\n=== Files by Extension ==="
    for ext in $(printf '%s\n' "${!extension_counts[@]}" | sort); do
        local count=${extension_counts[$ext]}
        local size=${file_sizes[$ext]:-0}
        local size_mb=$((size / 1024 / 1024))
        printf "%-15s %3d files (%d MB)\n" "$ext" "$count" "$size_mb"
    done
    
    if [[ ${#skipped_files[@]} -gt 0 ]]; then
        echo -e "\n=== Skipped Files ==="
        printf '%s\n' "${skipped_files[@]}" | head -10
        if [[ ${#skipped_files[@]} -gt 10 ]]; then
            echo "... and $((${#skipped_files[@]} - 10)) more"
        fi
    fi
}

# Create test files for demonstration
create_test_files() {
    local test_dir="test_files"
    mkdir -p "$test_dir"
    
    # Create various file types
    echo "Sample document" > "$test_dir/document.txt"
    echo "print('Hello World')" > "$test_dir/script.py"
    echo "console.log('Hello');" > "$test_dir/app.js"
    echo "body { color: red; }" > "$test_dir/style.css"
    echo '{"name": "test"}' > "$test_dir/data.json"
    echo "No extension file" > "$test_dir/README"
    
    echo "Created test files in $test_dir/"
    ls -la "$test_dir/"
}

# Example usage
echo "Creating test files..."
create_test_files

echo -e "\nOrganizing files..."
organize_files "test_files" "organized_files"

echo -e "\nFinal structure:"
find organized_files -type f | sort

# Clean up
rm -rf test_files organized_files
```

## Exercises

### Exercise 1: Student Grade Manager

Create a script that manages student grades using arrays:

```bash
#!/usr/bin/env bash

# Implement the following functions:
# 1. add_student(name, grade) - Add student and grade
# 2. remove_student(name) - Remove student
# 3. update_grade(name, new_grade) - Update student's grade
# 4. calculate_average() - Calculate class average
# 5. find_top_students(n) - Find top N students
# 6. generate_report() - Generate grade report

# Your solution here:
declare -A student_grades

add_student() {
    # TODO: Implement this function
    echo "Function not implemented"
}

# Test your implementation
# add_student "Alice" 95
# add_student "Bob" 87
# add_student "Charlie" 92
# generate_report
```

### Exercise 2: File Backup Manager

Create a backup system that uses arrays to track:
- Files to backup
- Backup timestamps
- File checksums
- Backup destinations

```bash
#!/usr/bin/env bash

# Implement backup tracking system
# Use arrays to store backup metadata
# Include integrity checking

# Your solution here
```

## Summary

In this chapter, you learned:

- ✅ Array creation and initialization methods
- ✅ Array operations (add, remove, search, sort)
- ✅ Associative arrays for key-value storage
- ✅ Multi-dimensional array simulation
- ✅ Real-world applications: log analysis and file organization
- ✅ Performance considerations for large datasets

Arrays are essential for handling collections of data in bash scripts. They enable you to build sophisticated data processing and management tools.

**Next Steps:**
- Practice with the exercises
- Experiment with different array operations
- Apply arrays to your own scripting challenges
- Move on to Chapter 10: File Operations and I/O

**Key Takeaways:**
- Always quote array expansions: `"${array[@]}"`
- Use associative arrays for key-value relationships
- Consider performance implications with large arrays
- Combine arrays with functions for powerful data processing
