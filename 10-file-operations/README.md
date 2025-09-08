# Chapter 10: File Operations and I/O

Mastering file operations is crucial for effective bash scripting. This chapter covers comprehensive file handling, advanced I/O techniques, and real-world file processing scenarios.

## What You'll Learn

- File creation, reading, and writing
- Advanced I/O redirection and pipes
- File processing techniques
- Stream editing and text manipulation
- File system operations
- Performance optimization for file operations

## Basic File Operations

### File Creation and Writing

```bash
#!/usr/bin/env bash

# Create files with different methods
create_files_demo() {
    echo "=== File Creation Methods ==="
    
    # Method 1: Using echo with redirection
    echo "Hello, World!" > simple.txt
    echo "This is line 2" >> simple.txt
    
    # Method 2: Using printf for formatted output
    printf "Name: %s\nAge: %d\nScore: %.2f\n" "John" 25 87.5 > formatted.txt
    
    # Method 3: Using cat with here document
    cat > config.txt << 'EOF'
# Configuration file
database_host=localhost
database_port=5432
debug_mode=true
log_level=INFO
EOF
    
    # Method 4: Using tee (write and display)
    echo "This goes to file and stdout" | tee output.txt
    
    # Method 5: Creating temporary files
    temp_file=$(mktemp)
    echo "Temporary content" > "$temp_file"
    echo "Created temporary file: $temp_file"
    
    # Method 6: Creating files with specific permissions
    (umask 077; echo "Secure content" > secure.txt)
    
    echo "Files created:"
    ls -la *.txt "$temp_file"
    
    # Clean up
    rm -f simple.txt formatted.txt config.txt output.txt secure.txt "$temp_file"
}

create_files_demo
```

### File Reading Techniques

```bash
#!/usr/bin/env bash

# Create sample file for reading examples
cat > sample_data.txt << 'EOF'
Name,Age,City,Salary
John Doe,30,New York,75000
Jane Smith,25,Los Angeles,68000
Bob Johnson,35,Chicago,82000
Alice Brown,28,Houston,71000
Charlie Wilson,32,Phoenix,77000
EOF

echo "=== File Reading Methods ==="

# Method 1: Read entire file into variable
echo "Method 1: Read entire file"
content=$(cat sample_data.txt)
echo "Content length: ${#content} characters"

# Method 2: Read line by line
echo -e "\nMethod 2: Line by line processing"
line_count=0
while IFS= read -r line; do
    ((line_count++))
    echo "Line $line_count: $line"
done < sample_data.txt

# Method 3: Read with field separator
echo -e "\nMethod 3: CSV parsing"
while IFS=',' read -r name age city salary; do
    if [[ "$name" != "Name" ]]; then  # Skip header
        printf "Employee: %-15s Age: %2s City: %-12s Salary: $%s\n" \
               "$name" "$age" "$city" "$salary"
    fi
done < sample_data.txt

# Method 4: Read into array
echo -e "\nMethod 4: Read into array"
mapfile -t lines < sample_data.txt
echo "Total lines read: ${#lines[@]}"
echo "Header: ${lines[0]}"
echo "First employee: ${lines[1]}"

# Method 5: Read specific lines
echo -e "\nMethod 5: Read specific lines"
header=$(head -n 1 sample_data.txt)
last_employee=$(tail -n 1 sample_data.txt)
echo "Header: $header"
echo "Last employee: $last_employee"

# Method 6: Read with timeout
echo -e "\nMethod 6: Read with timeout (from stdin)"
echo "Enter something (5 second timeout):"
if read -t 5 -r user_input; then
    echo "You entered: $user_input"
else
    echo "Timeout reached or no input"
fi

rm -f sample_data.txt
```

## Advanced I/O Redirection

### Redirection and Pipes

```bash
#!/usr/bin/env bash

# Advanced I/O redirection examples
io_redirection_demo() {
    echo "=== Advanced I/O Redirection ==="
    
    # Create test data
    echo -e "apple\nbanana\ncherry\napricot\nblueberry" > fruits.txt
    echo -e "Error: File not found" >&2  # To stderr
    
    # Redirect both stdout and stderr to different files
    {
        echo "This goes to stdout"
        echo "This is an error" >&2
    } > output.log 2> error.log
    
    echo "Output file contains:"
    cat output.log
    echo "Error file contains:"
    cat error.log
    
    # Redirect both stdout and stderr to same file
    {
        echo "Success message"
        echo "Error message" >&2
    } &> combined.log
    
    echo -e "\nCombined log contains:"
    cat combined.log
    
    # Append to files
    echo "Additional output" >> output.log
    echo "Additional error" 2>> error.log
    
    # Here strings and here documents
    cat << 'EOF' > here_doc.txt
This is a here document.
It can contain multiple lines.
Variables are expanded: $HOME
EOF
    
    # Here string
    grep "apple" <<< "apple banana cherry"
    
    # Process substitution
    echo -e "\nFiles with 'a' in name:"
    ls -la <(echo "fruits.txt"; echo "sample.txt"; echo "data.txt") 2>/dev/null || echo "No matching files"
    
    # Pipe to multiple commands
    echo -e "\nFruit statistics:"
    cat fruits.txt | {
        echo "Total fruits: $(wc -l)"
        echo "Fruits with 'a': $(grep -c 'a')"
        echo "Longest fruit name: $(awk '{print length($0) " " $0}' | sort -nr | head -1 | cut -d' ' -f2-)"
    }
    
    # Named pipes (FIFOs)
    if command -v mkfifo >/dev/null 2>&1; then
        mkfifo mypipe
        
        # Background process writing to pipe
        {
            for i in {1..5}; do
                echo "Message $i"
                sleep 1
            done
        } > mypipe &
        
        # Read from pipe
        echo -e "\nReading from named pipe:"
        while read -r line; do
            echo "Received: $line"
        done < mypipe
        
        rm -f mypipe
    fi
    
    # Clean up
    rm -f fruits.txt output.log error.log combined.log here_doc.txt
}

io_redirection_demo
```

### File Descriptors and Advanced Techniques

```bash
#!/usr/bin/env bash

# Working with file descriptors
file_descriptor_demo() {
    echo "=== File Descriptor Management ==="
    
    # Open file descriptor for reading
    exec 3< /etc/passwd
    
    # Read from file descriptor
    echo "First line from /etc/passwd:"
    read -r line <&3
    echo "$line"
    
    # Close file descriptor
    exec 3<&-
    
    # Open file descriptor for writing
    exec 4> temp_output.txt
    
    # Write to file descriptor
    echo "This goes to file descriptor 4" >&4
    echo "Another line" >&4
    
    # Close file descriptor
    exec 4>&-
    
    echo "Content written via file descriptor:"
    cat temp_output.txt
    
    # Swap stdout and stderr
    echo -e "\nSwapping stdout and stderr:"
    {
        echo "This should go to stderr"
        echo "This should go to stdout" >&2
    } 3>&1 1>&2 2>&3 3>&-
    
    # Logging function using file descriptors
    setup_logging() {
        local log_file="$1"
        exec 5> "$log_file"  # Log file descriptor
    }
    
    log_message() {
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&5
    }
    
    setup_logging "app.log"
    log_message "Application started"
    log_message "Processing data"
    log_message "Application finished"
    exec 5>&-  # Close log file descriptor
    
    echo -e "\nLog file contents:"
    cat app.log
    
    # Clean up
    rm -f temp_output.txt app.log
}

file_descriptor_demo
```

## File Processing Techniques

### Text Processing and Filtering

```bash
#!/usr/bin/env bash

# Create sample log file for processing
create_sample_log() {
    cat > web_server.log << 'EOF'
2024-01-15 08:30:15 [INFO] Server started on port 8080
2024-01-15 08:30:16 [INFO] Database connection established
2024-01-15 08:32:45 [WARN] High memory usage detected: 85%
2024-01-15 08:35:12 [ERROR] Failed to connect to external API
2024-01-15 08:35:13 [ERROR] Request timeout: /api/users
2024-01-15 08:40:22 [INFO] Cache cleared successfully
2024-01-15 08:42:18 [WARN] Slow query detected: 2.5s
2024-01-15 08:45:33 [INFO] User authentication successful
2024-01-15 08:47:19 [ERROR] Database connection lost
2024-01-15 08:47:20 [INFO] Attempting database reconnection
2024-01-15 08:47:25 [INFO] Database connection restored
EOF
}

# Comprehensive log analysis
analyze_log_file() {
    local log_file="$1"
    
    echo "=== Log File Analysis ==="
    echo "Analyzing: $log_file"
    echo "File size: $(du -h "$log_file" | cut -f1)"
    echo "Total lines: $(wc -l < "$log_file")"
    
    echo -e "\n=== Log Level Distribution ==="
    grep -oE '\[(INFO|WARN|ERROR)\]' "$log_file" | sort | uniq -c | \
    while read count level; do
        printf "%-8s %s\n" "$level" "$count"
    done
    
    echo -e "\n=== Error Messages ==="
    grep "\[ERROR\]" "$log_file" | sed 's/.*\[ERROR\] //' | \
    while IFS= read -r error; do
        echo "• $error"
    done
    
    echo -e "\n=== Hourly Activity ==="
    awk '{print substr($2, 1, 2)}' "$log_file" | sort | uniq -c | \
    while read count hour; do
        printf "%s:00 - %s events\n" "$hour" "$count"
    done
    
    echo -e "\n=== Performance Issues ==="
    grep -E "(timeout|slow|high.*usage)" "$log_file" -i | \
    while IFS= read -r line; do
        echo "⚠️  $line"
    done
    
    echo -e "\n=== Recent Activity (Last 5 entries) ==="
    tail -5 "$log_file" | nl
}

# Advanced text processing functions
process_csv_data() {
    local csv_file="$1"
    
    echo "=== CSV Data Processing ==="
    
    # Create sample CSV
    cat > "$csv_file" << 'EOF'
Product,Category,Price,Stock,Supplier
Laptop,Electronics,899.99,45,TechCorp
Mouse,Electronics,29.99,120,TechCorp
Desk,Furniture,199.99,25,FurnishInc
Chair,Furniture,149.99,30,FurnishInc
Monitor,Electronics,299.99,60,TechCorp
Keyboard,Electronics,79.99,85,TechCorp
Bookshelf,Furniture,89.99,15,FurnishInc
EOF
    
    echo "Processing CSV file: $csv_file"
    
    # Extract headers
    header=$(head -n 1 "$csv_file")
    echo "Headers: $header"
    
    # Calculate statistics
    echo -e "\n=== Statistics ==="
    
    # Total products
    echo "Total products: $(($(wc -l < "$csv_file") - 1))"
    
    # Average price
    avg_price=$(awk -F',' 'NR>1 {sum+=$3; count++} END {print sum/count}' "$csv_file")
    printf "Average price: $%.2f\n" "$avg_price"
    
    # Products by category
    echo -e "\n=== Products by Category ==="
    awk -F',' 'NR>1 {print $2}' "$csv_file" | sort | uniq -c | \
    while read count category; do
        printf "%-15s %s products\n" "$category" "$count"
    done
    
    # Expensive products (>$100)
    echo -e "\n=== Expensive Products (>$100) ==="
    awk -F',' 'NR>1 && $3>100 {printf "%-15s $%.2f\n", $1, $3}' "$csv_file"
    
    # Low stock alerts (<30)
    echo -e "\n=== Low Stock Alerts (<30) ==="
    awk -F',' 'NR>1 && $4<30 {printf "⚠️  %-15s Stock: %s\n", $1, $4}' "$csv_file"
    
    # Generate summary report
    {
        echo "# Product Inventory Report"
        echo "Generated: $(date)"
        echo
        echo "## Summary"
        echo "- Total Products: $(($(wc -l < "$csv_file") - 1))"
        printf "- Average Price: $%.2f\n" "$avg_price"
        echo
        echo "## Categories"
        awk -F',' 'NR>1 {print $2}' "$csv_file" | sort | uniq -c | \
        while read count category; do
            echo "- $category: $count products"
        done
    } > inventory_report.md
    
    echo -e "\nReport generated: inventory_report.md"
}

# File transformation utilities
transform_files() {
    echo "=== File Transformation Utilities ==="
    
    # Create test data
    cat > data.txt << 'EOF'
John Smith,30,Engineer
Jane Doe,25,Designer
Bob Johnson,35,Manager
Alice Brown,28,Developer
EOF
    
    # Transform CSV to fixed-width format
    echo "Original CSV data:"
    cat data.txt
    
    echo -e "\nTransformed to fixed-width:"
    while IFS=',' read -r name age job; do
        printf "%-15s %3s %-12s\n" "$name" "$age" "$job"
    done < data.txt > fixed_width.txt
    
    cat fixed_width.txt
    
    # Convert to JSON-like format
    echo -e "\nConverted to JSON-like format:"
    {
        echo "["
        first=true
        while IFS=',' read -r name age job; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            printf '  {"name": "%s", "age": %s, "job": "%s"}' "$name" "$age" "$job"
        done < data.txt
        echo
        echo "]"
    } > data.json
    
    cat data.json
    
    # Create backup with timestamp
    backup_file="data_backup_$(date +%Y%m%d_%H%M%S).txt"
    cp data.txt "$backup_file"
    echo -e "\nBackup created: $backup_file"
    
    # Clean up
    rm -f data.txt fixed_width.txt data.json "$backup_file"
}

# Run demonstrations
create_sample_log
analyze_log_file "web_server.log"

echo -e "\n" && echo "="*50
process_csv_data "inventory.csv"

echo -e "\n" && echo "="*50
transform_files

# Clean up
rm -f web_server.log inventory.csv inventory_report.md
```

## File System Operations

### Directory Management and File Organization

```bash
#!/usr/bin/env bash

# File system operations and organization
file_system_operations() {
    echo "=== File System Operations ==="
    
    # Create directory structure
    create_directory_structure() {
        local base_dir="$1"
        
        echo "Creating directory structure in: $base_dir"
        
        # Create nested directories
        mkdir -p "$base_dir"/{docs/{user,admin,api},src/{frontend,backend,shared},tests/{unit,integration},config/{dev,prod,staging}}
        
        # Create sample files
        echo "# User Documentation" > "$base_dir/docs/user/README.md"
        echo "# Admin Documentation" > "$base_dir/docs/admin/README.md"
        echo "# API Documentation" > "$base_dir/docs/api/README.md"
        
        echo "console.log('Frontend');" > "$base_dir/src/frontend/app.js"
        echo "print('Backend')" > "$base_dir/src/backend/main.py"
        echo "// Shared utilities" > "$base_dir/src/shared/utils.js"
        
        echo "// Unit tests" > "$base_dir/tests/unit/test.js"
        echo "// Integration tests" > "$base_dir/tests/integration/test.js"
        
        echo "development_config=true" > "$base_dir/config/dev/app.conf"
        echo "production_config=true" > "$base_dir/config/prod/app.conf"
        echo "staging_config=true" > "$base_dir/config/staging/app.conf"
        
        echo "Directory structure created!"
    }
    
    # Analyze directory structure
    analyze_directory() {
        local dir="$1"
        
        echo "=== Directory Analysis: $dir ==="
        
        # Directory statistics
        echo "Total files: $(find "$dir" -type f | wc -l)"
        echo "Total directories: $(find "$dir" -type d | wc -l)"
        echo "Total size: $(du -sh "$dir" | cut -f1)"
        
        # File types
        echo -e "\n=== File Types ==="
        find "$dir" -type f -name "*.*" | \
        sed 's/.*\.//' | sort | uniq -c | sort -nr | \
        while read count ext; do
            printf "%-10s %s files\n" ".$ext" "$count"
        done
        
        # Large files (>1KB for this demo)
        echo -e "\n=== Files by Size ==="
        find "$dir" -type f -exec ls -la {} \; | \
        awk '{print $5 " " $9}' | sort -nr | head -5 | \
        while read size file; do
            printf "%8s bytes %s\n" "$size" "$file"
        done
        
        # Directory tree
        echo -e "\n=== Directory Tree ==="
        find "$dir" -type d | sort | sed "s|$dir|.|" | \
        while read path; do
            level=$(echo "$path" | grep -o "/" | wc -l)
            indent=$(printf "%*s" $((level * 2)) "")
            basename_path=$(basename "$path")
            echo "$indent$basename_path/"
        done
    }
    
    # File operations utilities
    file_operations() {
        local work_dir="$1"
        
        echo "=== File Operations in: $work_dir ==="
        
        # Find and organize files by type
        echo "Organizing files by type..."
        
        # Create organization directories
        mkdir -p "$work_dir/organized"/{documents,scripts,configs,other}
        
        # Organize files
        find "$work_dir" -type f -not -path "$work_dir/organized/*" | \
        while read file; do
            case "$file" in
                *.md|*.txt|*.doc|*.pdf) 
                    cp "$file" "$work_dir/organized/documents/"
                    ;;
                *.js|*.py|*.sh|*.pl)
                    cp "$file" "$work_dir/organized/scripts/"
                    ;;
                *.conf|*.cfg|*.ini|*.json)
                    cp "$file" "$work_dir/organized/configs/"
                    ;;
                *)
                    cp "$file" "$work_dir/organized/other/"
                    ;;
            esac
        done
        
        echo "Files organized! Structure:"
        find "$work_dir/organized" -type f | \
        while read file; do
            echo "  $(basename "$(dirname "$file")")/$(basename "$file")"
        done
        
        # Create archive
        echo -e "\nCreating archive..."
        tar -czf "$work_dir/backup_$(date +%Y%m%d).tar.gz" -C "$work_dir" organized
        echo "Archive created: backup_$(date +%Y%m%d).tar.gz"
        
        # File permissions audit
        echo -e "\n=== File Permissions Audit ==="
        find "$work_dir" -type f | \
        while read file; do
            perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%OLp" "$file" 2>/dev/null)
            if [[ "$perms" =~ ^[0-9]+$ ]]; then
                case "$perms" in
                    777|666) echo "⚠️  World writable: $file ($perms)" ;;
                    *) echo "✓ $file ($perms)" ;;
                esac
            fi
        done | head -10
    }
    
    # Run file system operations
    test_dir="fs_test"
    create_directory_structure "$test_dir"
    analyze_directory "$test_dir"
    file_operations "$test_dir"
    
    # Clean up
    echo -e "\nCleaning up..."
    rm -rf "$test_dir"
}

file_system_operations
```

## Performance Optimization

### Efficient File Processing

```bash
#!/usr/bin/env bash

# Performance optimization techniques for file operations
performance_optimization() {
    echo "=== File Processing Performance Optimization ==="
    
    # Create large test file
    create_large_file() {
        local file="$1"
        local lines="$2"
        
        echo "Creating test file with $lines lines..."
        
        # Generate test data efficiently
        {
            for ((i=1; i<=lines; i++)); do
                printf "Line %06d: This is sample data with timestamp %s\n" \
                       "$i" "$(date +%s)"
            done
        } > "$file"
    }
    
    # Performance comparison of different processing methods
    compare_processing_methods() {
        local file="$1"
        
        echo "=== Processing Method Comparison ==="
        
        # Method 1: Line by line with while loop
        echo "Method 1: While loop (line by line)"
        time {
            count=0
            while IFS= read -r line; do
                ((count++))
            done < "$file"
            echo "Processed $count lines"
        }
        
        # Method 2: Using wc (much faster)
        echo -e "\nMethod 2: Using wc command"
        time {
            count=$(wc -l < "$file")
            echo "Processed $count lines"
        }
        
        # Method 3: Using awk for processing
        echo -e "\nMethod 3: Using awk"
        time {
            awk 'END {print "Processed " NR " lines"}' "$file"
        }
        
        # Method 4: Batch processing
        echo -e "\nMethod 4: Batch processing (every 1000 lines)"
        time {
            count=0
            while IFS= read -r line; do
                ((count++))
                if ((count % 1000 == 0)); then
                    echo "Processed $count lines..." >/dev/null
                fi
            done < "$file"
            echo "Total processed: $count lines"
        }
    }
    
    # Memory-efficient file processing
    memory_efficient_processing() {
        local file="$1"
        
        echo "=== Memory-Efficient Processing ==="
        
        # Process file in chunks
        process_in_chunks() {
            local chunk_size=100
            local line_count=0
            local chunk_num=1
            
            while IFS= read -r line; do
                # Process line here
                ((line_count++))
                
                if ((line_count % chunk_size == 0)); then
                    echo "Processed chunk $chunk_num ($chunk_size lines)"
                    ((chunk_num++))
                fi
            done < "$file"
            
            echo "Total lines processed: $line_count"
        }
        
        echo "Processing file in chunks of 100 lines:"
        time process_in_chunks
        
        # Stream processing with limited memory
        stream_process() {
            # Only keep last N lines in memory
            local max_lines=10
            local -a buffer=()
            local line_count=0
            
            while IFS= read -r line; do
                buffer+=("$line")
                ((line_count++))
                
                # Keep only last max_lines in buffer
                if [[ ${#buffer[@]} -gt $max_lines ]]; then
                    buffer=("${buffer[@]:1}")
                fi
                
                # Process current window
                if ((line_count % 50 == 0)); then
                    echo "Buffer size: ${#buffer[@]}, Total processed: $line_count"
                fi
            done < "$file"
        }
        
        echo -e "\nStream processing with limited buffer:"
        time stream_process
    }
    
    # Parallel processing example
    parallel_processing() {
        local file="$1"
        
        echo "=== Parallel Processing ==="
        
        # Split file for parallel processing
        total_lines=$(wc -l < "$file")
        lines_per_chunk=$((total_lines / 4))  # 4 parallel processes
        
        echo "Splitting $total_lines lines into 4 chunks of ~$lines_per_chunk lines each"
        
        # Create temporary directory for chunks
        temp_dir=$(mktemp -d)
        
        # Split file
        split -l "$lines_per_chunk" "$file" "$temp_dir/chunk_"
        
        # Process chunks in parallel
        process_chunk() {
            local chunk_file="$1"
            local chunk_name=$(basename "$chunk_file")
            
            local count=0
            while IFS= read -r line; do
                ((count++))
                # Simulate processing work
                [[ "$line" =~ Line.*[0-9]+ ]] >/dev/null
            done < "$chunk_file"
            
            echo "$chunk_name: $count lines processed"
        }
        
        echo "Processing chunks in parallel:"
        time {
            for chunk in "$temp_dir"/chunk_*; do
                process_chunk "$chunk" &
            done
            wait  # Wait for all background processes
        }
        
        # Clean up
        rm -rf "$temp_dir"
    }
    
    # Run performance tests
    test_file="performance_test.txt"
    
    create_large_file "$test_file" 5000
    
    echo "File created: $(du -h "$test_file" | cut -f1)"
    
    compare_processing_methods "$test_file"
    echo -e "\n" && echo "="*50
    memory_efficient_processing "$test_file"
    echo -e "\n" && echo "="*50
    parallel_processing "$test_file"
    
    # Clean up
    rm -f "$test_file"
}

performance_optimization
```

## Practical Examples

### Log Rotation System

```bash
#!/usr/bin/env bash

# Comprehensive log rotation system
log_rotation_system() {
    echo "=== Log Rotation System ==="
    
    # Configuration
    readonly LOG_DIR="logs"
    readonly MAX_SIZE=$((1024 * 1024))  # 1MB
    readonly MAX_FILES=5
    readonly COMPRESS=true
    
    # Create log directory
    mkdir -p "$LOG_DIR"
    
    # Simulate log generation
    generate_logs() {
        local log_file="$LOG_DIR/application.log"
        
        echo "Generating sample logs..."
        
        for ((i=1; i<=100; i++)); do
            {
                echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] Application event $i"
                echo "[$(date +'%Y-%m-%d %H:%M:%S')] [DEBUG] Processing request $i"
                if ((i % 10 == 0)); then
                    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WARN] High load detected at event $i"
                fi
                if ((i % 25 == 0)); then
                    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] Error occurred at event $i"
                fi
            } >> "$log_file"
        done
        
        echo "Generated $(wc -l < "$log_file") log entries"
        echo "Log file size: $(du -h "$log_file" | cut -f1)"
    }
    
    # Rotate logs function
    rotate_logs() {
        local log_file="$1"
        local max_files="$2"
        local compress="$3"
        
        if [[ ! -f "$log_file" ]]; then
            echo "Log file not found: $log_file"
            return 1
        fi
        
        local base_name=$(basename "$log_file" .log)
        local log_dir=$(dirname "$log_file")
        
        echo "Rotating logs for: $log_file"
        
        # Rotate existing numbered logs
        for ((i=max_files-1; i>=1; i--)); do
            local old_file="$log_dir/${base_name}.${i}"
            local new_file="$log_dir/${base_name}.$((i+1))"
            
            if [[ "$compress" == "true" ]]; then
                old_file="${old_file}.gz"
                new_file="${new_file}.gz"
            fi
            
            if [[ -f "$old_file" ]]; then
                if ((i == max_files-1)); then
                    echo "Removing oldest log: $old_file"
                    rm -f "$old_file"
                else
                    echo "Moving $old_file -> $new_file"
                    mv "$old_file" "$new_file"
                fi
            fi
        done
        
        # Move current log to .1
        local rotated_file="$log_dir/${base_name}.1"
        echo "Moving current log: $log_file -> $rotated_file"
        mv "$log_file" "$rotated_file"
        
        # Compress if enabled
        if [[ "$compress" == "true" ]]; then
            echo "Compressing: $rotated_file"
            gzip "$rotated_file"
        fi
        
        # Create new empty log file
        touch "$log_file"
        echo "Created new log file: $log_file"
    }
    
    # Check if rotation is needed
    check_rotation_needed() {
        local log_file="$1"
        local max_size="$2"
        
        if [[ ! -f "$log_file" ]]; then
            return 1
        fi
        
        local file_size
        file_size=$(stat -c%s "$log_file" 2>/dev/null || stat -f%z "$log_file" 2>/dev/null)
        
        if [[ $file_size -gt $max_size ]]; then
            echo "Log rotation needed: $file_size bytes > $max_size bytes"
            return 0
        else
            echo "Log rotation not needed: $file_size bytes <= $max_size bytes"
            return 1
        fi
    }
    
    # Log cleanup function
    cleanup_old_logs() {
        local log_dir="$1"
        local days_to_keep="$2"
        
        echo "Cleaning up logs older than $days_to_keep days in: $log_dir"
        
        find "$log_dir" -name "*.log*" -mtime +$days_to_keep -type f | \
        while read old_log; do
            echo "Removing old log: $old_log"
            rm -f "$old_log"
        done
    }
    
    # Run log rotation system
    generate_logs
    
    echo -e "\n=== Checking Rotation Status ==="
    log_file="$LOG_DIR/application.log"
    
    if check_rotation_needed "$log_file" "$MAX_SIZE"; then
        rotate_logs "$log_file" "$MAX_FILES" "$COMPRESS"
    fi
    
    echo -e "\n=== Final Log Directory ==="
    ls -la "$LOG_DIR"
    
    echo -e "\n=== Log File Sizes ==="
    du -h "$LOG_DIR"/*
    
    # Simulate cleanup
    echo -e "\n=== Cleanup Simulation ==="
    cleanup_old_logs "$LOG_DIR" 30
    
    # Clean up
    rm -rf "$LOG_DIR"
}

log_rotation_system
```

## Exercises

### Exercise 1: File Synchronization Tool

Create a file synchronization tool that compares two directories and identifies differences:

```bash
#!/usr/bin/env bash

# File synchronization tool
# Compare two directories and show differences

sync_directories() {
    local source_dir="$1"
    local target_dir="$2"
    
    # TODO: Implement the following features:
    # 1. Compare file contents using checksums
    # 2. Identify new, modified, and deleted files
    # 3. Generate sync report
    # 4. Optionally perform synchronization
    
    echo "Function not implemented yet"
    echo "Source: $source_dir"
    echo "Target: $target_dir"
}

# Test your implementation
# sync_directories "source" "target"
```

### Exercise 2: Data Processing Pipeline

Create a data processing pipeline that:
- Reads CSV files
- Validates data
- Transforms data
- Generates reports
- Handles errors gracefully

```bash
#!/usr/bin/env bash

# Data processing pipeline
process_data_pipeline() {
    local input_file="$1"
    local output_dir="$2"
    
    # TODO: Implement data processing pipeline
    echo "Pipeline not implemented yet"
}
```

## Summary

In this chapter, you mastered:

- ✅ File creation, reading, and writing techniques
- ✅ Advanced I/O redirection and file descriptors
- ✅ Text processing and data transformation
- ✅ File system operations and organization
- ✅ Performance optimization for large files
- ✅ Real-world applications: log analysis and rotation

File operations are fundamental to bash scripting. These techniques enable you to build powerful data processing and system administration tools.

**Next Steps:**
- Practice with the exercises
- Apply these techniques to real log files
- Experiment with performance optimization
- Move on to Chapter 11: Text Processing and Regular Expressions

**Key Takeaways:**
- Always handle file errors gracefully
- Use appropriate methods for file size (line-by-line vs. bulk processing)
- Consider memory usage with large files
- Implement proper cleanup and error handling
- Use compression and rotation for log management
