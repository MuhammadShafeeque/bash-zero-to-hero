# Chapter 6: Loops

Loops allow you to execute code repeatedly, making your scripts more efficient and powerful. Bash provides several types of loops for different scenarios.

## For Loops

### Basic For Loop with List

```bash
#!/usr/bin/env bash
# Basic for loop

# Loop through a list of items
for fruit in apple banana orange grape; do
    echo "I like $fruit"
done

# Loop through command output
for file in *.txt; do
    echo "Processing file: $file"
done

# Loop through array
fruits=("apple" "banana" "orange")
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done
```

### C-style For Loop

```bash
#!/usr/bin/env bash
# C-style for loop

# Basic counting loop
for ((i=1; i<=10; i++)); do
    echo "Count: $i"
done

# Loop with custom increment
for ((i=0; i<=20; i+=2)); do
    echo "Even number: $i"
done

# Countdown loop
for ((i=10; i>=1; i--)); do
    echo "Countdown: $i"
    sleep 1
done
echo "Blast off!"

# Multiple variables
for ((i=1, j=10; i<=5; i++, j--)); do
    echo "i=$i, j=$j"
done
```

### For Loop with Ranges

```bash
#!/usr/bin/env bash
# For loops with ranges

# Using brace expansion for ranges
for i in {1..10}; do
    echo "Number: $i"
done

# Range with step
for i in {0..20..2}; do
    echo "Even: $i"
done

# Character ranges
for letter in {a..z}; do
    echo "Letter: $letter"
done

# Reverse range
for i in {10..1}; do
    echo "Countdown: $i"
done
```

## While Loops

### Basic While Loop

```bash
#!/usr/bin/env bash
# Basic while loop

counter=1
while [[ $counter -le 5 ]]; do
    echo "Counter: $counter"
    ((counter++))
done

# Reading user input
while true; do
    read -p "Enter 'quit' to exit: " input
    if [[ "$input" == "quit" ]]; then
        break
    fi
    echo "You entered: $input"
done
```

### Reading Files with While

```bash
#!/usr/bin/env bash
# Reading files with while loops

# Read line by line
while IFS= read -r line; do
    echo "Line: $line"
done < "input.txt"

# Process CSV data
while IFS=',' read -r name age city; do
    echo "Name: $name, Age: $age, City: $city"
done < "data.csv"

# Read with line numbers
line_num=1
while IFS= read -r line; do
    printf "%3d: %s\n" "$line_num" "$line"
    ((line_num++))
done < "file.txt"

# Skip empty lines
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "Non-empty line: $line"
done < "file.txt"
```

### While Loop with Conditions

```bash
#!/usr/bin/env bash
# While loops with various conditions

# Loop until file exists
while [[ ! -f "important.txt" ]]; do
    echo "Waiting for important.txt to be created..."
    sleep 2
done
echo "File found!"

# Monitor disk usage
while true; do
    usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $usage -gt 90 ]]; then
        echo "WARNING: Disk usage is ${usage}%"
        break
    fi
    echo "Disk usage: ${usage}%"
    sleep 10
done

# Process monitoring
process_name="httpd"
while pgrep "$process_name" >/dev/null; do
    echo "$process_name is running"
    sleep 5
done
echo "$process_name has stopped"
```

## Until Loops

### Basic Until Loop

```bash
#!/usr/bin/env bash
# Until loops (opposite of while)

counter=1
until [[ $counter -gt 5 ]]; do
    echo "Counter: $counter"
    ((counter++))
done

# Wait until file is created
until [[ -f "ready.txt" ]]; do
    echo "Waiting for ready.txt..."
    sleep 1
done
echo "File is ready!"

# Wait until service is available
until curl -s http://localhost:8080 >/dev/null; do
    echo "Waiting for service to start..."
    sleep 2
done
echo "Service is available!"
```

## Loop Control

### Break and Continue

```bash
#!/usr/bin/env bash
# Loop control with break and continue

# Using break to exit loop
for i in {1..10}; do
    if [[ $i -eq 6 ]]; then
        echo "Breaking at $i"
        break
    fi
    echo "Number: $i"
done

# Using continue to skip iterations
for i in {1..10}; do
    if [[ $((i % 2)) -eq 0 ]]; then
        continue  # Skip even numbers
    fi
    echo "Odd number: $i"
done

# Multiple nested loops with labeled break
outer_loop:
for i in {1..3}; do
    for j in {1..3}; do
        if [[ $i -eq 2 && $j -eq 2 ]]; then
            echo "Breaking outer loop at i=$i, j=$j"
            break 2  # Break out of both loops
        fi
        echo "i=$i, j=$j"
    done
done
```

### Infinite Loops

```bash
#!/usr/bin/env bash
# Infinite loops

# Infinite while loop
while true; do
    echo "This will run forever (press Ctrl+C to stop)"
    sleep 1
done

# Infinite for loop
for (( ; ; )); do
    echo "Another infinite loop"
    sleep 1
done

# Infinite until loop (rarely used)
until false; do
    echo "Until false is also infinite"
    sleep 1
done
```

## Nested Loops

### Basic Nested Loops

```bash
#!/usr/bin/env bash
# Nested loops

# Multiplication table
echo "Multiplication Table:"
for i in {1..5}; do
    for j in {1..5}; do
        result=$((i * j))
        printf "%3d " "$result"
    done
    echo  # New line after each row
done

# File processing in multiple directories
directories=("dir1" "dir2" "dir3")
for dir in "${directories[@]}"; do
    echo "Processing directory: $dir"
    if [[ -d "$dir" ]]; then
        for file in "$dir"/*; do
            if [[ -f "$file" ]]; then
                echo "  File: $(basename "$file")"
            fi
        done
    fi
done
```

### Advanced Nested Loops

```bash
#!/usr/bin/env bash
# Advanced nested loop patterns

# Matrix operations
declare -a matrix=(
    "1 2 3"
    "4 5 6" 
    "7 8 9"
)

echo "Matrix:"
row=0
for row_data in "${matrix[@]}"; do
    col=0
    for value in $row_data; do
        printf "%3d " "$value"
        ((col++))
    done
    echo
    ((row++))
done

# Processing multiple file types in multiple directories
directories=("src" "docs" "tests")
extensions=("txt" "md" "sh")

for dir in "${directories[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "Checking directory: $dir"
        for ext in "${extensions[@]}"; do
            echo "  Looking for .$ext files:"
            for file in "$dir"/*."$ext"; do
                if [[ -f "$file" ]]; then
                    echo "    Found: $(basename "$file")"
                fi
            done
        done
    fi
done
```

## Loop Applications

### File Processing

```bash
#!/usr/bin/env bash
# File processing with loops

# Batch rename files
for file in *.txt; do
    if [[ -f "$file" ]]; then
        new_name="backup_${file}"
        mv "$file" "$new_name"
        echo "Renamed: $file -> $new_name"
    fi
done

# Convert images (example)
for image in *.jpg; do
    if [[ -f "$image" ]]; then
        basename="${image%.jpg}"
        # convert "$image" "${basename}_small.jpg"  # ImageMagick command
        echo "Would convert: $image"
    fi
done

# Calculate directory sizes
for dir in */; do
    if [[ -d "$dir" ]]; then
        size=$(du -sh "$dir" | cut -f1)
        echo "Directory $dir: $size"
    fi
done
```

### System Administration

```bash
#!/usr/bin/env bash
# System administration loops

# Check service status
services=("ssh" "nginx" "mysql" "cron")
for service in "${services[@]}"; do
    if systemctl is-active "$service" >/dev/null 2>&1; then
        echo "✓ $service is running"
    else
        echo "✗ $service is not running"
    fi
done

# Monitor log files
log_files=("/var/log/syslog" "/var/log/auth.log" "/var/log/apache2/error.log")
for log_file in "${log_files[@]}"; do
    if [[ -f "$log_file" ]]; then
        echo "Checking $log_file for errors..."
        error_count=$(grep -i "error" "$log_file" | wc -l)
        echo "  Found $error_count errors"
    fi
done

# Backup multiple directories
backup_dirs=("$HOME/Documents" "$HOME/Pictures" "/etc")
backup_dest="/backup/$(date +%Y%m%d)"

mkdir -p "$backup_dest"
for dir in "${backup_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "Backing up $dir..."
        tar -czf "$backup_dest/$(basename "$dir").tar.gz" "$dir"
        echo "  Backup completed: $(basename "$dir").tar.gz"
    fi
done
```

### Data Processing

```bash
#!/usr/bin/env bash
# Data processing with loops

# Process CSV file
echo "Processing sales data..."
total_sales=0
while IFS=',' read -r date product quantity price; do
    # Skip header line
    [[ "$date" == "Date" ]] && continue
    
    # Calculate line total
    line_total=$(echo "$quantity * $price" | bc)
    total_sales=$(echo "$total_sales + $line_total" | bc)
    
    echo "Date: $date, Product: $product, Total: \$${line_total}"
done < "sales.csv"

echo "Total Sales: \$${total_sales}"

# Generate reports
months=("Jan" "Feb" "Mar" "Apr" "May" "Jun")
for month in "${months[@]}"; do
    echo "Generating report for $month..."
    
    # Create monthly report
    report_file="report_${month}.txt"
    {
        echo "Monthly Report - $month"
        echo "======================="
        echo "Generated: $(date)"
        echo "Data processed: $(date)"
    } > "$report_file"
    
    echo "Report saved: $report_file"
done
```

## Advanced Loop Techniques

### Parallel Processing

```bash
#!/usr/bin/env bash
# Parallel processing with loops

# Process files in parallel
files=(*.txt)
max_jobs=4
current_jobs=0

for file in "${files[@]}"; do
    # Start background process
    {
        echo "Processing $file..."
        # Simulate processing time
        sleep 2
        echo "Completed $file"
    } &
    
    ((current_jobs++))
    
    # Limit concurrent jobs
    if [[ $current_jobs -ge $max_jobs ]]; then
        wait  # Wait for all background jobs to complete
        current_jobs=0
    fi
done

# Wait for remaining jobs
wait
echo "All files processed"
```

### Loop with Functions

```bash
#!/usr/bin/env bash
# Using functions in loops

process_file() {
    local file="$1"
    local line_count=$(wc -l < "$file")
    local word_count=$(wc -w < "$file")
    
    echo "File: $file"
    echo "  Lines: $line_count"
    echo "  Words: $word_count"
    echo "  Size: $(stat -c%s "$file" 2>/dev/null || stat -f%z "$file") bytes"
    echo
}

validate_email() {
    local email="$1"
    if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Process all text files
echo "File Analysis Report"
echo "===================="
for file in *.txt; do
    [[ -f "$file" ]] && process_file "$file"
done

# Validate email list
email_list=("user@example.com" "invalid-email" "test@domain.org")
echo "Email Validation:"
echo "=================="
for email in "${email_list[@]}"; do
    if validate_email "$email"; then
        echo "✓ Valid: $email"
    else
        echo "✗ Invalid: $email"
    fi
done
```

## Practical Examples

### Example 1: Log Analyzer

```bash
#!/usr/bin/env bash
# Log analyzer script

analyze_log() {
    local log_file="$1"
    local start_date="${2:-yesterday}"
    
    if [[ ! -f "$log_file" ]]; then
        echo "Error: Log file '$log_file' not found"
        return 1
    fi
    
    echo "Analyzing log: $log_file"
    echo "========================="
    
    # Count different log levels
    declare -A log_levels
    while IFS= read -r line; do
        if [[ "$line" =~ \[(ERROR|WARN|INFO|DEBUG)\] ]]; then
            level="${BASH_REMATCH[1]}"
            ((log_levels[$level]++))
        fi
    done < "$log_file"
    
    echo "Log Level Summary:"
    for level in "${!log_levels[@]}"; do
        printf "  %-8s: %d\n" "$level" "${log_levels[$level]}"
    done
    
    # Find most frequent IP addresses
    echo
    echo "Top IP Addresses:"
    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$log_file" | \
        sort | uniq -c | sort -nr | head -5 | \
        while read count ip; do
            printf "  %-15s: %d requests\n" "$ip" "$count"
        done
    
    # Find errors
    echo
    echo "Recent Errors:"
    grep -i "error" "$log_file" | tail -5 | \
        while IFS= read -r error_line; do
            echo "  $error_line"
        done
}

# Analyze multiple log files
log_files=("/var/log/apache2/access.log" "/var/log/syslog" "app.log")
for log_file in "${log_files[@]}"; do
    analyze_log "$log_file"
    echo
done
```

### Example 2: System Resource Monitor

```bash
#!/usr/bin/env bash
# System resource monitor

monitor_resources() {
    local duration="${1:-60}"  # Monitor for 60 seconds by default
    local interval="${2:-5}"   # Check every 5 seconds
    local iterations=$((duration / interval))
    
    echo "Monitoring system resources for ${duration} seconds..."
    echo "======================================================="
    
    # Create monitoring log
    log_file="resource_monitor_$(date +%Y%m%d_%H%M%S).log"
    
    for ((i=1; i<=iterations; i++)); do
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Get CPU usage
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' 2>/dev/null || echo "N/A")
        
        # Get memory usage
        if command -v free >/dev/null 2>&1; then
            mem_info=$(free | grep "Mem:")
            total_mem=$(echo $mem_info | awk '{print $2}')
            used_mem=$(echo $mem_info | awk '{print $3}')
            mem_usage=$((used_mem * 100 / total_mem))
        else
            mem_usage="N/A"
        fi
        
        # Get disk usage
        disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        
        # Get load average
        load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
        
        # Display current stats
        printf "[%s] CPU: %s%%, MEM: %s%%, DISK: %s%%, LOAD: %s\n" \
               "$timestamp" "$cpu_usage" "$mem_usage" "$disk_usage" "$load_avg"
        
        # Log to file
        printf "%s,%s,%s,%s,%s\n" \
               "$timestamp" "$cpu_usage" "$mem_usage" "$disk_usage" "$load_avg" >> "$log_file"
        
        # Check for alerts
        if [[ "$mem_usage" != "N/A" && $mem_usage -gt 80 ]]; then
            echo "  ALERT: High memory usage ($mem_usage%)"
        fi
        
        if [[ $disk_usage -gt 90 ]]; then
            echo "  ALERT: High disk usage ($disk_usage%)"
        fi
        
        sleep "$interval"
    done
    
    echo
    echo "Monitoring completed. Log saved to: $log_file"
}

# Usage
monitor_resources 120 10  # Monitor for 2 minutes, check every 10 seconds
```

### Example 3: Backup System

```bash
#!/usr/bin/env bash
# Intelligent backup system

perform_backup() {
    local source_dirs=("$@")
    local backup_base="/backup/$(hostname)"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$backup_base/$timestamp"
    
    echo "Starting backup process..."
    echo "========================="
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Initialize backup log
    local log_file="$backup_dir/backup.log"
    echo "Backup started at $(date)" > "$log_file"
    
    local total_size=0
    local total_files=0
    local failed_dirs=()
    
    for source_dir in "${source_dirs[@]}"; do
        if [[ ! -d "$source_dir" ]]; then
            echo "Warning: Directory '$source_dir' does not exist, skipping..."
            echo "WARNING: Directory '$source_dir' not found" >> "$log_file"
            failed_dirs+=("$source_dir")
            continue
        fi
        
        echo "Backing up: $source_dir"
        
        # Calculate source size
        local dir_size=$(du -s "$source_dir" | awk '{print $1}')
        local file_count=$(find "$source_dir" -type f | wc -l)
        
        # Create archive
        local archive_name="$(basename "$source_dir").tar.gz"
        local archive_path="$backup_dir/$archive_name"
        
        if tar -czf "$archive_path" -C "$(dirname "$source_dir")" "$(basename "$source_dir")" 2>>"$log_file"; then
            local archive_size=$(stat -c%s "$archive_path" 2>/dev/null || stat -f%z "$archive_path")
            archive_size=$((archive_size / 1024))  # Convert to KB
            
            echo "  ✓ Success: $archive_name"
            echo "  Files: $file_count, Size: ${dir_size}KB -> ${archive_size}KB"
            
            total_size=$((total_size + archive_size))
            total_files=$((total_files + file_count))
            
            echo "SUCCESS: $source_dir -> $archive_name (${archive_size}KB)" >> "$log_file"
        else
            echo "  ✗ Failed: $source_dir"
            failed_dirs+=("$source_dir")
            echo "FAILED: $source_dir backup failed" >> "$log_file"
        fi
    done
    
    # Backup summary
    echo
    echo "Backup Summary:"
    echo "==============="
    echo "Total files backed up: $total_files"
    echo "Total backup size: ${total_size}KB"
    echo "Backup location: $backup_dir"
    
    if [[ ${#failed_dirs[@]} -gt 0 ]]; then
        echo "Failed backups: ${failed_dirs[*]}"
    fi
    
    echo "Backup completed at $(date)" >> "$log_file"
    
    # Cleanup old backups (keep last 7 days)
    find "$backup_base" -type d -name "20*_*" -mtime +7 -exec rm -rf {} \; 2>/dev/null
    
    echo "Backup process completed!"
}

# Configuration
backup_sources=(
    "$HOME/Documents"
    "$HOME/Pictures"
    "/etc"
    "$HOME/scripts"
)

# Perform backup
perform_backup "${backup_sources[@]}"
```

## Practice Exercises

### Exercise 1: File Statistics Generator

Create a script that processes all files in a directory and generates statistics:
- Total number of files by extension
- Total size by file type
- Largest and smallest files
- Average file size

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash

generate_file_stats() {
    local target_dir="${1:-.}"
    
    if [[ ! -d "$target_dir" ]]; then
        echo "Error: Directory '$target_dir' does not exist"
        return 1
    fi
    
    declare -A ext_count ext_size
    local total_files=0 total_size=0
    local largest_file largest_size=0
    local smallest_file smallest_size=999999999999
    
    echo "Analyzing files in: $target_dir"
    echo "================================"
    
    while IFS= read -r -d '' file; do
        [[ -f "$file" ]] || continue
        
        local filename=$(basename "$file")
        local ext="${filename##*.}"
        [[ "$ext" == "$filename" ]] && ext="no_extension"
        
        local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
        
        # Update counters
        ((ext_count[$ext]++))
        ext_size[$ext]=$((${ext_size[$ext]:-0} + size))
        ((total_files++))
        total_size=$((total_size + size))
        
        # Track largest file
        if [[ $size -gt $largest_size ]]; then
            largest_size=$size
            largest_file="$file"
        fi
        
        # Track smallest file
        if [[ $size -lt $smallest_size ]]; then
            smallest_size=$size
            smallest_file="$file"
        fi
        
    done < <(find "$target_dir" -type f -print0)
    
    # Display results
    echo "File Type Statistics:"
    echo "===================="
    printf "%-15s %10s %15s\n" "Extension" "Count" "Total Size"
    echo "----------------------------------------"
    
    for ext in "${!ext_count[@]}"; do
        printf "%-15s %10d %15d\n" "$ext" "${ext_count[$ext]}" "${ext_size[$ext]}"
    done
    
    echo
    echo "Summary:"
    echo "========"
    echo "Total files: $total_files"
    echo "Total size: $total_size bytes"
    [[ $total_files -gt 0 ]] && echo "Average size: $((total_size / total_files)) bytes"
    echo "Largest file: $(basename "$largest_file") ($largest_size bytes)"
    echo "Smallest file: $(basename "$smallest_file") ($smallest_size bytes)"
}

generate_file_stats "$1"
```
</details>

### Exercise 2: Network Port Scanner

Write a script that scans common ports on a given host:
- Tests connectivity to multiple ports
- Reports open/closed status
- Measures response time
- Generates a summary report

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash

scan_ports() {
    local host="$1"
    local ports=(22 23 25 53 80 110 143 443 993 995)
    local timeout=3
    
    if [[ -z "$host" ]]; then
        echo "Usage: scan_ports <hostname_or_ip>"
        return 1
    fi
    
    echo "Scanning ports on: $host"
    echo "========================"
    
    local open_ports=() closed_ports=()
    
    for port in "${ports[@]}"; do
        echo -n "Testing port $port... "
        
        local start_time=$(date +%s%N)
        
        if timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
            local end_time=$(date +%s%N)
            local response_time=$(( (end_time - start_time) / 1000000 ))
            echo "OPEN (${response_time}ms)"
            open_ports+=($port)
        else
            echo "CLOSED"
            closed_ports+=($port)
        fi
    done
    
    echo
    echo "Scan Results:"
    echo "============="
    echo "Open ports: ${open_ports[*]:-none}"
    echo "Closed ports: ${closed_ports[*]:-none}"
    echo "Total open: ${#open_ports[@]}"
    echo "Total closed: ${#closed_ports[@]}"
}

scan_ports "$1"
```
</details>

## Key Takeaways

1. Choose the right loop type for your needs
2. Use C-style loops for numeric iterations
3. Use for loops for lists and arrays
4. Use while loops for condition-based repetition
5. Always handle loop control (break/continue) properly
6. Consider performance with large datasets
7. Use functions within loops for better organization
8. Be careful with infinite loops - always have an exit condition

## Next Steps

Continue to [Chapter 7: Case Statements](../07-case-statements/README.md) to learn about multi-way branching and pattern matching.

## Quick Reference

```bash
# For loops
for item in list; do commands; done
for file in *.txt; do commands; done
for ((i=1; i<=10; i++)); do commands; done
for i in {1..10}; do commands; done

# While loops
while condition; do commands; done
while IFS= read -r line; do commands; done < file

# Until loops
until condition; do commands; done

# Loop control
break         # Exit loop
continue      # Skip to next iteration
break 2       # Break out of nested loops

# Reading files
while IFS= read -r line; do
    echo "$line"
done < file.txt
```
