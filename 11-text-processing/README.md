# Chapter 11: Text Processing and Regular Expressions

Text processing is one of bash's greatest strengths. This chapter covers comprehensive text manipulation, regular expressions, and advanced pattern matching techniques.

## What You'll Learn

- Regular expression fundamentals and advanced patterns
- Text processing with sed, awk, and grep
- String manipulation techniques
- Data extraction and transformation
- Pattern matching and validation
- Real-world text processing applications

## Regular Expression Fundamentals

### Basic Regular Expression Syntax

```bash
#!/usr/bin/env bash

# Regular expression examples and explanations
regex_fundamentals() {
    echo "=== Regular Expression Fundamentals ==="
    
    # Create sample text for testing
    cat > sample_text.txt << 'EOF'
John Doe - johndoe@email.com - Phone: (555) 123-4567
Jane Smith - jane.smith@company.org - Phone: (555) 987-6543
Bob Johnson - bob123@test.net - Phone: (555) 555-5555
Alice Brown - alice.brown@university.edu - Phone: (555) 246-8135
Charlie Wilson - c.wilson@startup.io - Phone: (555) 369-2580
Invalid Email - notanemail - Phone: 555-123-4567
Another Invalid - @invalid.com - Phone: (555) abc-defg
EOF
    
    echo "Sample text file created:"
    cat sample_text.txt
    
    echo -e "\n=== Basic Pattern Matching ==="
    
    # Match literal strings
    echo "1. Literal string matching:"
    echo "   Lines containing 'John':"
    grep "John" sample_text.txt
    
    # Case-insensitive matching
    echo -e "\n2. Case-insensitive matching:"
    echo "   Lines containing 'john' (any case):"
    grep -i "john" sample_text.txt
    
    # Character classes
    echo -e "\n3. Character classes:"
    echo "   Lines with digits [0-9]:"
    grep "[0-9]" sample_text.txt
    
    echo -e "\n   Lines with uppercase letters [A-Z]:"
    grep "[A-Z]" sample_text.txt | head -2
    
    # Anchors
    echo -e "\n4. Anchors (^ for start, $ for end):"
    echo "   Lines starting with 'John':"
    grep "^John" sample_text.txt
    
    echo -e "\n   Lines ending with '5555':"
    grep "5555$" sample_text.txt
    
    # Wildcards
    echo -e "\n5. Wildcard . (any character):"
    echo "   Email patterns with any character before @:"
    grep "[a-z]\..*@" sample_text.txt
    
    # Quantifiers
    echo -e "\n6. Quantifiers:"
    echo "   Phone patterns with exactly 3 digits in parentheses:"
    grep "([0-9]\{3\})" sample_text.txt
    
    echo -e "\n   Names with repeated letters (+ for one or more):"
    grep -E "[a-zA-Z]+" sample_text.txt | head -2
    
    rm -f sample_text.txt
}

# Advanced regular expression patterns
advanced_regex() {
    echo "=== Advanced Regular Expression Patterns ==="
    
    # Create more complex sample data
    cat > complex_data.txt << 'EOF'
Date: 2024-01-15, Amount: $1,234.56, Status: COMPLETED
Date: 2024-02-20, Amount: $567.89, Status: PENDING
Date: 2024-03-10, Amount: $2,345.67, Status: FAILED
Date: 2024-04-05, Amount: $89.12, Status: COMPLETED
Date: 2024-05-12, Amount: $1,567.34, Status: PENDING
Invalid: Not a date, Amount: $abc.def, Status: UNKNOWN
IP: 192.168.1.100, Port: 8080, Protocol: HTTP
IP: 10.0.0.1, Port: 443, Protocol: HTTPS
IP: 172.16.0.50, Port: 22, Protocol: SSH
Invalid IP: 999.999.999.999, Port: 0, Protocol: NONE
URL: https://www.example.com/path/to/resource
URL: http://subdomain.test.org:8080/api/v1/users
URL: ftp://files.company.net/downloads/
Email: user@domain.com, valid@test.org, invalid@, @invalid.com
Phone: +1-555-123-4567, (555) 987-6543, 555.246.8135
EOF
    
    echo "Complex data file created."
    
    echo -e "\n=== Pattern Matching Examples ==="
    
    # Date patterns
    echo "1. Date patterns (YYYY-MM-DD):"
    grep -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" complex_data.txt
    
    # Currency patterns
    echo -e "\n2. Currency patterns (\$X,XXX.XX):"
    grep -E '\$[0-9]{1,3}(,[0-9]{3})*\.[0-9]{2}' complex_data.txt
    
    # IP address patterns
    echo -e "\n3. Valid IP address patterns:"
    grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' complex_data.txt | \
    grep -v "999.999.999.999"  # Exclude invalid IPs
    
    # Email patterns
    echo -e "\n4. Valid email patterns:"
    grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' complex_data.txt
    
    # URL patterns
    echo -e "\n5. URL patterns:"
    grep -E 'https?://[a-zA-Z0-9.-]+(/[a-zA-Z0-9./_-]*)?(:?[0-9]+)?' complex_data.txt
    
    # Phone number patterns
    echo -e "\n6. Phone number patterns:"
    grep -E '(\+?1[-.\s]?)?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}' complex_data.txt
    
    rm -f complex_data.txt
}

# Extended regular expressions
extended_regex() {
    echo "=== Extended Regular Expressions ==="
    
    cat > log_data.txt << 'EOF'
2024-01-15 08:30:15 [INFO] User login successful: john.doe@company.com
2024-01-15 08:31:22 [DEBUG] Database query executed in 0.025s
2024-01-15 08:32:45 [WARN] High memory usage: 85% (threshold: 80%)
2024-01-15 08:35:12 [ERROR] Database connection failed: Connection timeout
2024-01-15 08:35:13 [ERROR] Failed to process request: /api/users/123
2024-01-15 09:15:30 [INFO] User logout: jane.smith@company.com
2024-01-15 09:20:45 [INFO] System backup completed successfully
2024-01-15 10:05:12 [WARN] SSL certificate expires in 30 days
2024-01-15 10:10:33 [ERROR] Payment processing failed: Invalid credit card
2024-01-15 10:15:45 [DEBUG] Cache cleared: 1,234 entries removed
EOF
    
    echo "Log data created for extended regex examples."
    
    # Using grep with extended regex (-E)
    echo -e "\n1. Multiple alternatives with | (OR):"
    echo "   Lines with ERROR or WARN:"
    grep -E "(ERROR|WARN)" log_data.txt
    
    echo -e "\n2. Optional patterns with ? (zero or one):"
    echo "   Email patterns with optional subdomain:"
    grep -E '[a-zA-Z0-9._%+-]+@([a-zA-Z0-9-]+\.)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' log_data.txt
    
    echo -e "\n3. Grouping with parentheses:"
    echo "   Time patterns (HH:MM:SS):"
    grep -E '([0-9]{2}:){2}[0-9]{2}' log_data.txt | head -3
    
    echo -e "\n4. Word boundaries \\b:"
    echo "   Lines with whole word 'User' (not 'users'):"
    grep -E '\bUser\b' log_data.txt
    
    echo -e "\n5. Negative lookahead simulation:"
    echo "   Lines with percentages not equal to 100%:"
    grep -E '[0-9]+%' log_data.txt | grep -v '100%'
    
    # Using sed with regex
    echo -e "\n=== Using sed with Regular Expressions ==="
    
    echo "6. Extract timestamps:"
    sed -E 's/^([0-9-]+ [0-9:]+).*/\1/' log_data.txt | head -3
    
    echo -e "\n7. Extract log levels:"
    sed -E 's/.*\[([A-Z]+)\].*/\1/' log_data.txt | head -5
    
    echo -e "\n8. Mask email addresses:"
    sed -E 's/([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/***@\2/g' log_data.txt | head -3
    
    rm -f log_data.txt
}

# Run regex examples
regex_fundamentals
echo -e "\n" && echo "="*60
advanced_regex
echo -e "\n" && echo "="*60
extended_regex
```

## Text Processing with Core Tools

### Advanced grep Techniques

```bash
#!/usr/bin/env bash

# Advanced grep usage and techniques
advanced_grep() {
    echo "=== Advanced grep Techniques ==="
    
    # Create comprehensive test data
    create_test_data() {
        # Server log file
        cat > server.log << 'EOF'
2024-01-15 08:30:15 INFO [web] Request GET /api/users from 192.168.1.100
2024-01-15 08:30:16 INFO [web] Response 200 OK (0.025s)
2024-01-15 08:31:22 DEBUG [db] Query: SELECT * FROM users WHERE active=1
2024-01-15 08:31:23 DEBUG [db] Query executed in 0.015s
2024-01-15 08:32:45 WARN [system] High CPU usage: 85%
2024-01-15 08:35:12 ERROR [db] Connection pool exhausted
2024-01-15 08:35:13 ERROR [web] Request failed: 500 Internal Server Error
2024-01-15 08:40:22 INFO [cache] Cache hit ratio: 95%
2024-01-15 08:42:18 WARN [system] Memory usage: 78%
2024-01-15 08:45:33 INFO [auth] User login: john.doe@company.com
2024-01-15 08:47:19 ERROR [network] Connection timeout to external API
2024-01-15 08:50:15 INFO [web] Request GET /api/products from 192.168.1.101
EOF
        
        # Configuration file
        cat > config.txt << 'EOF'
# Database Configuration
db.host=localhost
db.port=5432
db.name=myapp
db.user=admin
db.password=secret123

# Web Server Configuration
web.port=8080
web.ssl.enabled=true
web.ssl.port=8443

# Cache Configuration
cache.enabled=true
cache.ttl=3600
cache.size=1024MB

# Logging Configuration
log.level=INFO
log.file=/var/log/myapp.log
log.rotation=daily
EOF
        
        # CSV data file
        cat > data.csv << 'EOF'
ID,Name,Department,Salary,Start_Date,Email
1,John Doe,Engineering,85000,2023-01-15,john.doe@company.com
2,Jane Smith,Marketing,72000,2023-02-20,jane.smith@company.com
3,Bob Johnson,Engineering,90000,2022-11-10,bob.johnson@company.com
4,Alice Brown,HR,65000,2023-03-05,alice.brown@company.com
5,Charlie Wilson,Sales,78000,2023-01-30,charlie.wilson@company.com
6,Diana Prince,Engineering,92000,2022-09-15,diana.prince@company.com
7,Edward Davis,Marketing,70000,2023-04-12,edward.davis@company.com
EOF
    }
    
    create_test_data
    
    echo "Test data created. Demonstrating advanced grep techniques:"
    
    # Basic grep with options
    echo -e "\n1. Line numbers and filenames:"
    grep -n "ERROR" server.log
    
    echo -e "\n2. Case-insensitive search with count:"
    grep -ci "info" server.log
    
    echo -e "\n3. Invert match (lines NOT containing pattern):"
    grep -v "DEBUG" server.log | head -5
    
    echo -e "\n4. Multiple files with filename display:"
    grep -H "port" config.txt data.csv
    
    # Context options
    echo -e "\n5. Show context around matches:"
    echo "   2 lines before and after ERROR:"
    grep -C 2 "ERROR" server.log
    
    echo -e "\n   3 lines after WARN:"
    grep -A 3 "WARN" server.log
    
    # Pattern files and multiple patterns
    echo -e "\n6. Multiple patterns with -E (extended regex):"
    grep -E "(ERROR|WARN)" server.log | head -3
    
    echo -e "\n7. Fixed strings (literal matching) with -F:"
    grep -F "[web]" server.log | head -2
    
    # Advanced pattern matching
    echo -e "\n8. Word boundaries:"
    echo "   Exact word 'web' (not 'web]' or '[web'):"
    grep -w "web" server.log >/dev/null && echo "Found matches" || echo "No exact word matches"
    
    echo -e "\n9. Beginning and end of line:"
    echo "   Lines starting with '2024':"
    grep "^2024" server.log | head -3
    
    echo -e "\n   Lines ending with 'company.com':"
    grep "company.com$" data.csv
    
    # Recursive searching
    echo -e "\n10. Recursive search (if directories exist):"
    mkdir -p test_dir
    cp server.log test_dir/
    echo "additional log entry" > test_dir/other.log
    grep -r "ERROR" test_dir/ 2>/dev/null || echo "No recursive matches found"
    rm -rf test_dir
    
    # Binary file handling
    echo -e "\n11. Binary file handling:"
    echo "Creating binary-like file..."
    printf "\x00\x01\x02ERROR in binary\x03\x04" > binary_file
    grep -a "ERROR" binary_file  # -a treats binary as text
    rm -f binary_file
    
    # Performance with large files
    echo -e "\n12. Only filenames with matches:"
    grep -l "Engineering" *.csv 2>/dev/null || echo "No CSV files with Engineering"
    
    echo -e "\n13. Only filenames without matches:"
    grep -L "TRACE" *.log 2>/dev/null || echo "All log files contain TRACE or no log files"
    
    # Clean up
    rm -f server.log config.txt data.csv
}

advanced_grep
```

### Powerful sed Operations

```bash
#!/usr/bin/env bash

# Advanced sed operations for text transformation
advanced_sed() {
    echo "=== Advanced sed Operations ==="
    
    # Create test data for sed operations
    cat > sed_test.txt << 'EOF'
John Doe,30,Engineer,85000
Jane Smith,25,Designer,72000
Bob Johnson,35,Manager,95000
Alice Brown,28,Developer,78000
Charlie Wilson,32,Analyst,68000
Diana Prince,29,Engineer,82000

# Comments in the file
# Data format: Name,Age,Position,Salary
# Last updated: 2024-01-15
EOF
    
    cat > config_template.txt << 'EOF'
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location /api/ {
        proxy_pass http://backend:8080;
        proxy_set_header Host $host;
    }
}
EOF
    
    echo "Test files created. Demonstrating sed operations:"
    
    echo -e "\n=== Basic Substitution ==="
    
    # Simple substitution
    echo "1. Simple substitution (first occurrence):"
    sed 's/Engineer/Software Engineer/' sed_test.txt | head -3
    
    echo -e "\n2. Global substitution (all occurrences):"
    sed 's/e/E/g' sed_test.txt | head -2
    
    echo -e "\n3. Case-insensitive substitution:"
    sed 's/ENGINEER/Software Engineer/I' sed_test.txt | head -3
    
    # Advanced substitution
    echo -e "\n=== Advanced Substitution ==="
    
    echo "4. Using different delimiters:"
    sed 's|/var/www/html|/opt/webapp|g' config_template.txt | head -5
    
    echo -e "\n5. Backreferences and capture groups:"
    echo "   Swap first and last names:"
    sed -E 's/([A-Z][a-z]+) ([A-Z][a-z]+)/\2, \1/' sed_test.txt | head -3
    
    echo -e "\n6. Multiple substitutions:"
    sed -e 's/Engineer/SWE/' -e 's/Designer/UXD/' sed_test.txt | head -3
    
    # Line addressing
    echo -e "\n=== Line Addressing ==="
    
    echo "7. Substitute only on specific lines:"
    echo "   Line 2 only:"
    sed '2s/,/, /' sed_test.txt | head -3
    
    echo -e "\n8. Range of lines:"
    echo "   Lines 2-4:"
    sed '2,4s/,/ | /g' sed_test.txt
    
    echo -e "\n9. Pattern-based addressing:"
    echo "   Lines containing 'Engineer':"
    sed '/Engineer/s/,/ - /g' sed_test.txt | head -4
    
    # Line operations
    echo -e "\n=== Line Operations ==="
    
    echo "10. Delete lines:"
    echo "    Delete comment lines:"
    sed '/^#/d' sed_test.txt | head -5
    
    echo -e "\n11. Insert lines:"
    echo "    Insert header:"
    sed '1i\
# Employee Database\
# Generated on: '$(date)'\
' sed_test.txt | head -5
    
    echo -e "\n12. Append lines:"
    echo "    Append footer:"
    sed '$a\
# End of file\
# Total employees processed
' sed_test.txt | tail -5
    
    # Advanced operations
    echo -e "\n=== Advanced Operations ==="
    
    echo "13. Print specific lines:"
    echo "    Lines 2-4 only:"
    sed -n '2,4p' sed_test.txt
    
    echo -e "\n14. Transform characters:"
    echo "    Convert to uppercase:"
    sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' sed_test.txt | head -2
    
    echo -e "\n15. Hold space operations:"
    echo "    Reverse line order (simple version):"
    sed '1!G;h;$!d' sed_test.txt | head -4
    
    # Practical examples
    echo -e "\n=== Practical Examples ==="
    
    # CSV to formatted text
    echo "16. CSV to formatted table:"
    sed -E 's/([^,]+),([^,]+),([^,]+),([^,]+)/Name: \1, Age: \2, Position: \3, Salary: $\4/' sed_test.txt | head -3
    
    # Configuration file modification
    echo -e "\n17. Configuration modification:"
    echo "    Change port from 80 to 8080:"
    sed 's/listen 80;/listen 8080;/' config_template.txt | grep listen
    
    # Log processing
    echo -e "\n18. Extract specific data:"
    echo "    Extract just names and salaries:"
    sed -E 's/([^,]+),[^,]+,[^,]+,([^,]+)/\1: $\2/' sed_test.txt | grep -v "^#"
    
    # Multiple file processing
    echo -e "\n19. In-place editing simulation:"
    echo "    Original file (first 3 lines):"
    head -3 sed_test.txt
    echo "    After modification (simulation):"
    sed 's/,/ | /g' sed_test.txt | head -3
    
    # Advanced pattern processing
    echo -e "\n20. Complex pattern replacement:"
    echo "    Format salary with commas:"
    sed -E 's/([0-9])([0-9]{3})$/\1,\2/' sed_test.txt | grep -v "^#"
    
    # Clean up
    rm -f sed_test.txt config_template.txt
}

advanced_sed
```

### AWK Programming

```bash
#!/usr/bin/env bash

# Advanced AWK programming for data processing
advanced_awk() {
    echo "=== Advanced AWK Programming ==="
    
    # Create comprehensive test data
    cat > employees.csv << 'EOF'
Name,Department,Salary,Years,Performance
John Doe,Engineering,85000,3,Excellent
Jane Smith,Marketing,72000,2,Good
Bob Johnson,Engineering,90000,5,Excellent
Alice Brown,HR,65000,1,Good
Charlie Wilson,Sales,78000,4,Average
Diana Prince,Engineering,92000,6,Excellent
Edward Davis,Marketing,70000,2,Good
Frank Miller,Sales,82000,3,Excellent
Grace Lee,HR,68000,1,Average
Henry Clark,Engineering,88000,4,Good
EOF
    
    cat > sales_data.txt << 'EOF'
2024-01-15 1250.50 Product_A North
2024-01-15 890.25 Product_B South
2024-01-15 1100.75 Product_A East
2024-01-16 750.00 Product_C West
2024-01-16 1350.25 Product_A North
2024-01-16 920.50 Product_B South
2024-01-17 1180.00 Product_C East
2024-01-17 1025.75 Product_A West
2024-01-17 865.50 Product_B North
2024-01-18 1450.25 Product_A South
EOF
    
    echo "Test data created. Demonstrating AWK features:"
    
    echo -e "\n=== Basic AWK Operations ==="
    
    # Field processing
    echo "1. Print specific fields:"
    echo "   Names and salaries:"
    awk -F',' 'NR>1 {print $1 ": $" $3}' employees.csv | head -3
    
    echo -e "\n2. Field calculations:"
    echo "   Salary after 10% raise:"
    awk -F',' 'NR>1 {printf "%-15s $%.2f\n", $1, $3*1.1}' employees.csv | head -3
    
    echo -e "\n3. Pattern matching:"
    echo "   Engineering employees only:"
    awk -F',' '$2=="Engineering" {print $1 " - " $3}' employees.csv
    
    # Variables and calculations
    echo -e "\n=== Variables and Calculations ==="
    
    echo "4. Sum and average:"
    awk -F',' '
        NR>1 { 
            sum+=$3; count++ 
        } 
        END { 
            printf "Total salary: $%.2f\n", sum
            printf "Average salary: $%.2f\n", sum/count
        }' employees.csv
    
    echo -e "\n5. Department statistics:"
    awk -F',' '
        NR>1 { 
            dept[$2]+=$3; 
            count[$2]++ 
        } 
        END {
            for (d in dept) {
                printf "%-12s Total: $%8.2f Avg: $%8.2f Count: %d\n", 
                       d, dept[d], dept[d]/count[d], count[d]
            }
        }' employees.csv
    
    # Advanced pattern processing
    echo -e "\n=== Advanced Pattern Processing ==="
    
    echo "6. Multiple conditions:"
    awk -F',' '
        NR>1 && $3>80000 && $5=="Excellent" {
            printf "Top performer: %-15s $%s\n", $1, $3
        }' employees.csv
    
    echo -e "\n7. Regular expressions:"
    awk -F',' '
        $1 ~ /^[JD]/ { 
            print "Name starts with J or D: " $1 
        }' employees.csv
    
    # String functions
    echo -e "\n=== String Functions ==="
    
    echo "8. String manipulation:"
    awk -F',' '
        NR>1 {
            name = toupper($1)
            dept = tolower($2)
            printf "%-20s %s\n", name, dept
        }' employees.csv | head -3
    
    echo -e "\n9. String extraction:"
    awk -F',' '
        NR>1 {
            first_name = substr($1, 1, index($1, " ")-1)
            printf "First name: %s\n", first_name
        }' employees.csv | head -3
    
    # Date and time processing
    echo -e "\n=== Date and Time Processing ==="
    
    echo "10. Sales by date:"
    awk '{
        date_sales[$1] += $2
    } 
    END {
        for (date in date_sales) {
            printf "%s: $%.2f\n", date, date_sales[date]
        }
    }' sales_data.txt | sort
    
    echo -e "\n11. Product analysis:"
    awk '{
        product_sales[$3] += $2
        region_sales[$4] += $2
    } 
    END {
        print "=== Product Sales ==="
        for (product in product_sales) {
            printf "%-12s $%.2f\n", product, product_sales[product]
        }
        print "\n=== Region Sales ==="
        for (region in region_sales) {
            printf "%-8s $%.2f\n", region, region_sales[region]
        }
    }' sales_data.txt
    
    # Control structures
    echo -e "\n=== Control Structures ==="
    
    echo "12. Performance categorization:"
    awk -F',' '
        NR>1 {
            if ($3 >= 85000) 
                category = "High"
            else if ($3 >= 75000) 
                category = "Medium"
            else 
                category = "Low"
            
            printf "%-15s %-8s (%s)\n", $1, category, $5
        }' employees.csv
    
    echo -e "\n13. Loop processing:"
    awk -F',' '
        BEGIN { 
            print "Performance Distribution:" 
        }
        NR>1 { 
            perf[$5]++ 
        } 
        END {
            for (p in perf) {
                printf "%-12s ", p
                for (i=1; i<=perf[p]; i++) printf "*"
                printf " (%d)\n", perf[p]
            }
        }' employees.csv
    
    # Custom functions
    echo -e "\n=== Custom Functions ==="
    
    echo "14. User-defined functions:"
    awk -F',' '
        function format_salary(amount) {
            if (amount >= 1000000)
                return sprintf("$%.1fM", amount/1000000)
            else if (amount >= 1000)
                return sprintf("$%.1fK", amount/1000)
            else
                return sprintf("$%.0f", amount)
        }
        
        NR>1 {
            printf "%-15s %s\n", $1, format_salary($3)
        }' employees.csv | head -5
    
    # Complex report generation
    echo -e "\n=== Report Generation ==="
    
    echo "15. Comprehensive employee report:"
    awk -F',' '
        BEGIN {
            print "=========================================="
            print "          EMPLOYEE REPORT"
            print "=========================================="
            printf "%-15s %-12s %-8s %-8s %-12s\n", 
                   "Name", "Department", "Salary", "Years", "Performance"
            print "------------------------------------------"
        }
        
        NR>1 {
            total_salary += $3
            total_years += $4
            count++
            
            # Performance bonus calculation
            if ($5 == "Excellent") bonus = $3 * 0.15
            else if ($5 == "Good") bonus = $3 * 0.10
            else bonus = $3 * 0.05
            
            total_bonus += bonus
            
            printf "%-15s %-12s $%-7.0f %-8s %-12s\n", $1, $2, $3, $4, $5
        }
        
        END {
            print "------------------------------------------"
            printf "Total Employees: %d\n", count
            printf "Total Salary: $%.2f\n", total_salary
            printf "Average Salary: $%.2f\n", total_salary/count
            printf "Average Years: %.1f\n", total_years/count
            printf "Total Bonuses: $%.2f\n", total_bonus
            print "=========================================="
        }' employees.csv
    
    # Clean up
    rm -f employees.csv sales_data.txt
}

advanced_awk
```

## String Manipulation and Validation

### String Processing Functions

```bash
#!/usr/bin/env bash

# Comprehensive string manipulation and validation
string_manipulation() {
    echo "=== String Manipulation and Validation ==="
    
    # String extraction and manipulation
    echo "=== String Extraction ==="
    
    sample_string="John.Doe@Company.COM"
    echo "Sample string: $sample_string"
    
    # Parameter expansion for string manipulation
    echo -e "\n1. Parameter expansion techniques:"
    
    # Remove from beginning
    echo "   Remove 'John.': ${sample_string#John.}"
    
    # Remove from end
    echo "   Remove '.COM': ${sample_string%.COM}"
    
    # Case conversion
    echo "   Lowercase: ${sample_string,,}"
    echo "   Uppercase: ${sample_string^^}"
    
    # Length
    echo "   Length: ${#sample_string}"
    
    # Substring
    echo "   Substring (5-8): ${sample_string:5:8}"
    
    # Replace
    echo "   Replace dots with underscores: ${sample_string//./_}"
    
    # Advanced string functions
    echo -e "\n=== Advanced String Functions ==="
    
    # Validation functions
    validate_email() {
        local email="$1"
        local pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        
        if [[ "$email" =~ $pattern ]]; then
            echo "✓ Valid email: $email"
            return 0
        else
            echo "✗ Invalid email: $email"
            return 1
        fi
    }
    
    validate_phone() {
        local phone="$1"
        # Remove all non-digits
        local digits_only="${phone//[^0-9]/}"
        
        if [[ ${#digits_only} -eq 10 ]]; then
            # Format as (XXX) XXX-XXXX
            local formatted="(${digits_only:0:3}) ${digits_only:3:3}-${digits_only:6:4}"
            echo "✓ Valid phone: $formatted"
            return 0
        elif [[ ${#digits_only} -eq 11 && ${digits_only:0:1} == "1" ]]; then
            # Format as +1 (XXX) XXX-XXXX
            local formatted="+1 (${digits_only:1:3}) ${digits_only:4:3}-${digits_only:7:4}"
            echo "✓ Valid phone: $formatted"
            return 0
        else
            echo "✗ Invalid phone: $phone"
            return 1
        fi
    }
    
    validate_ip() {
        local ip="$1"
        local pattern='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
        
        if [[ "$ip" =~ $pattern ]]; then
            # Check each octet
            IFS='.' read -ra octets <<< "$ip"
            for octet in "${octets[@]}"; do
                if [[ $octet -gt 255 ]]; then
                    echo "✗ Invalid IP (octet > 255): $ip"
                    return 1
                fi
            done
            echo "✓ Valid IP: $ip"
            return 0
        else
            echo "✗ Invalid IP format: $ip"
            return 1
        fi
    }
    
    # Test validation functions
    echo "2. Email validation:"
    validate_email "user@example.com"
    validate_email "invalid.email"
    validate_email "test@domain.co.uk"
    
    echo -e "\n3. Phone validation:"
    validate_phone "555-123-4567"
    validate_phone "(555) 123-4567"
    validate_phone "15551234567"
    validate_phone "123-45-6789"
    
    echo -e "\n4. IP validation:"
    validate_ip "192.168.1.1"
    validate_ip "10.0.0.1"
    validate_ip "256.1.1.1"
    validate_ip "192.168.1"
    
    # Text transformation functions
    echo -e "\n=== Text Transformation ==="
    
    # Normalize text
    normalize_text() {
        local text="$1"
        
        # Convert to lowercase, remove extra spaces, replace special chars
        text="${text,,}"                    # Lowercase
        text="${text//[^a-z0-9 ]/_}"       # Replace special chars with underscore
        text="${text//  / }"               # Replace double spaces with single
        text="${text// /_}"                # Replace spaces with underscores
        text="${text//__/_}"               # Replace double underscores with single
        
        echo "$text"
    }
    
    # Title case conversion
    title_case() {
        local text="$1"
        echo "$text" | awk '{
            for(i=1; i<=NF; i++) {
                $i = toupper(substr($i,1,1)) tolower(substr($i,2))
            }
            print
        }'
    }
    
    # Word count and statistics
    text_stats() {
        local text="$1"
        
        local char_count=${#text}
        local word_count=$(echo "$text" | wc -w)
        local line_count=$(echo "$text" | wc -l)
        
        echo "Characters: $char_count"
        echo "Words: $word_count"
        echo "Lines: $line_count"
    }
    
    echo "5. Text normalization:"
    sample_text="Hello World! This is a Test String."
    echo "Original: $sample_text"
    echo "Normalized: $(normalize_text "$sample_text")"
    
    echo -e "\n6. Title case conversion:"
    echo "Original: hello world from bash"
    echo "Title case: $(title_case "hello world from bash")"
    
    echo -e "\n7. Text statistics:"
    long_text="This is a sample text for testing.
It has multiple lines and various words.
We can count characters, words, and lines."
    echo "Sample text:"
    echo "$long_text"
    echo -e "\nStatistics:"
    text_stats "$long_text"
    
    # Data extraction from text
    echo -e "\n=== Data Extraction ==="
    
    # Extract data from structured text
    extract_data() {
        local text="User: john.doe@company.com, Phone: (555) 123-4567, ID: 12345"
        
        echo "Source text: $text"
        echo "Extracted data:"
        
        # Extract email
        if [[ $text =~ ([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}) ]]; then
            echo "  Email: ${BASH_REMATCH[1]}"
        fi
        
        # Extract phone
        if [[ $text =~ \(([0-9]{3})\)\ ([0-9]{3})-([0-9]{4}) ]]; then
            echo "  Phone: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]}"
        fi
        
        # Extract ID
        if [[ $text =~ ID:\ ([0-9]+) ]]; then
            echo "  ID: ${BASH_REMATCH[1]}"
        fi
    }
    
    echo "8. Data extraction from structured text:"
    extract_data
    
    # Password strength checker
    echo -e "\n=== Password Strength Checker ==="
    
    check_password_strength() {
        local password="$1"
        local score=0
        local feedback=()
        
        # Length check
        if [[ ${#password} -ge 8 ]]; then
            ((score += 2))
        else
            feedback+=("Password should be at least 8 characters long")
        fi
        
        # Uppercase check
        if [[ "$password" =~ [A-Z] ]]; then
            ((score += 1))
        else
            feedback+=("Add uppercase letters")
        fi
        
        # Lowercase check
        if [[ "$password" =~ [a-z] ]]; then
            ((score += 1))
        else
            feedback+=("Add lowercase letters")
        fi
        
        # Number check
        if [[ "$password" =~ [0-9] ]]; then
            ((score += 1))
        else
            feedback+=("Add numbers")
        fi
        
        # Special character check
        if [[ "$password" =~ [^a-zA-Z0-9] ]]; then
            ((score += 1))
        else
            feedback+=("Add special characters")
        fi
        
        # Determine strength
        local strength
        if [[ $score -ge 5 ]]; then
            strength="Strong"
        elif [[ $score -ge 3 ]]; then
            strength="Medium"
        else
            strength="Weak"
        fi
        
        echo "Password: $password"
        echo "Strength: $strength (Score: $score/6)"
        
        if [[ ${#feedback[@]} -gt 0 ]]; then
            echo "Suggestions:"
            printf '  • %s\n' "${feedback[@]}"
        fi
        
        echo
    }
    
    echo "9. Password strength checking:"
    check_password_strength "password"
    check_password_strength "Password123"
    check_password_strength "MyStr0ng!Pass"
}

string_manipulation
```

## Practical Applications

### Log Analysis System

```bash
#!/usr/bin/env bash

# Comprehensive log analysis system
log_analysis_system() {
    echo "=== Log Analysis System ==="
    
    # Create realistic log data
    create_realistic_logs() {
        cat > access.log << 'EOF'
192.168.1.100 - - [15/Jan/2024:08:30:15 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - - [15/Jan/2024:08:30:16 +0000] "GET /about.html HTTP/1.1" 200 2345
192.168.1.100 - - [15/Jan/2024:08:31:22 +0000] "POST /api/login HTTP/1.1" 200 567
10.0.0.50 - - [15/Jan/2024:08:32:45 +0000] "GET /admin/panel HTTP/1.1" 403 890
192.168.1.102 - - [15/Jan/2024:08:35:12 +0000] "GET /products.html HTTP/1.1" 200 3456
192.168.1.100 - - [15/Jan/2024:08:35:13 +0000] "GET /missing.html HTTP/1.1" 404 234
203.0.113.10 - - [15/Jan/2024:08:40:22 +0000] "GET /api/data HTTP/1.1" 500 456
192.168.1.103 - - [15/Jan/2024:08:42:18 +0000] "GET /contact.html HTTP/1.1" 200 1789
198.51.100.25 - - [15/Jan/2024:08:45:33 +0000] "POST /api/users HTTP/1.1" 201 678
192.168.1.100 - - [15/Jan/2024:08:47:19 +0000] "GET /dashboard.html HTTP/1.1" 200 4567
EOF
        
        cat > error.log << 'EOF'
[15/Jan/2024:08:32:45] [error] [client 10.0.0.50] access denied: /admin/panel
[15/Jan/2024:08:35:13] [error] [client 192.168.1.100] file not found: /missing.html
[15/Jan/2024:08:40:22] [error] [client 203.0.113.10] database connection failed
[15/Jan/2024:08:40:23] [warn] [client 203.0.113.10] retrying database connection
[15/Jan/2024:08:40:24] [error] [client 203.0.113.10] database still unavailable
[15/Jan/2024:08:42:00] [warn] high memory usage: 85%
[15/Jan/2024:08:45:00] [info] database connection restored
[15/Jan/2024:08:47:30] [warn] slow query detected: 2.5 seconds
EOF
    }
    
    create_realistic_logs
    
    echo "Log files created. Starting analysis..."
    
    # Basic log statistics
    analyze_basic_stats() {
        echo "=== Basic Log Statistics ==="
        
        echo "Access log entries: $(wc -l < access.log)"
        echo "Error log entries: $(wc -l < error.log)"
        echo "Log date range: $(head -1 access.log | grep -oE '\[[^]]+\]' | tr -d '[]' | cut -d: -f1)"
        
        echo -e "\nStatus code distribution:"
        awk '{print $9}' access.log | sort | uniq -c | sort -rn | \
        while read count code; do
            printf "  %-3s: %s requests\n" "$code" "$count"
        done
    }
    
    # IP analysis
    analyze_ips() {
        echo -e "\n=== IP Address Analysis ==="
        
        echo "Top IP addresses:"
        awk '{print $1}' access.log | sort | uniq -c | sort -rn | \
        while read count ip; do
            printf "  %-15s %s requests\n" "$ip" "$count"
        done
        
        echo -e "\nSuspicious activity (multiple 403/404 errors):"
        awk '$9 ~ /40[34]/ {print $1}' access.log | sort | uniq -c | \
        awk '$1 > 1 {printf "  %-15s %s failed requests\n", $2, $1}'
        
        echo -e "\nUnique IP addresses: $(awk '{print $1}' access.log | sort -u | wc -l)"
    }
    
    # Request analysis
    analyze_requests() {
        echo -e "\n=== Request Analysis ==="
        
        echo "Most requested pages:"
        awk '{match($0, /"[A-Z]+ ([^ ]+)/, arr); print arr[1]}' access.log | \
        sort | uniq -c | sort -rn | head -5 | \
        while read count page; do
            printf "  %-20s %s requests\n" "$page" "$count"
        done
        
        echo -e "\nHTTP methods:"
        awk '{match($0, /"([A-Z]+)/, arr); print arr[1]}' access.log | \
        sort | uniq -c | \
        while read count method; do
            printf "  %-6s %s requests\n" "$method" "$count"
        done
        
        echo -e "\nLarge responses (>2KB):"
        awk '$10 > 2000 {printf "  %s %s (%s bytes)\n", $1, $7, $10}' access.log
    }
    
    # Error analysis
    analyze_errors() {
        echo -e "\n=== Error Analysis ==="
        
        echo "Error levels:"
        grep -oE '\[(error|warn|info)\]' error.log | sort | uniq -c | \
        while read count level; do
            printf "  %-7s %s occurrences\n" "$level" "$count"
        done
        
        echo -e "\nClient errors (by IP):"
        grep 'client' error.log | \
        sed -E 's/.*client ([0-9.]+)\].*/\1/' | sort | uniq -c | \
        while read count ip; do
            printf "  %-15s %s errors\n" "$ip" "$count"
        done
        
        echo -e "\nError timeline:"
        grep -oE '\[[^]]+:[0-9]{2}:[0-9]{2}:[0-9]{2}\]' error.log | \
        sed -E 's/.*:([0-9]{2}):[0-9]{2}:[0-9]{2}.*/\1/' | sort | uniq -c | \
        while read count hour; do
            printf "  %s:00 - %s errors\n" "$hour" "$count"
        done
    }
    
    # Security analysis
    analyze_security() {
        echo -e "\n=== Security Analysis ==="
        
        echo "Potential security issues:"
        
        # Admin access attempts
        echo "  Admin access attempts:"
        grep -E "(admin|login|panel)" access.log | \
        awk '{printf "    %s from %s - status %s\n", $7, $1, $9}'
        
        # Failed authentications
        echo -e "\n  Failed access (403/401):"
        awk '$9 ~ /40[13]/ {printf "    %s from %s to %s\n", $9, $1, $7}' access.log
        
        # Large requests (potential DoS)
        echo -e "\n  Large requests (>5KB):"
        awk '$10 > 5000 {printf "    %s bytes from %s\n", $10, $1}' access.log
        
        # Suspicious patterns
        echo -e "\n  Suspicious patterns:"
        grep -iE "(sql|script|alert|drop|union)" access.log | \
        awk '{printf "    Suspicious request from %s: %s\n", $1, $7}' || echo "    None detected"
    }
    
    # Generate comprehensive report
    generate_report() {
        echo -e "\n=== Comprehensive Log Report ==="
        
        local report_file="log_analysis_report.txt"
        
        {
            echo "=========================================="
            echo "        WEB SERVER LOG ANALYSIS"
            echo "=========================================="
            echo "Generated: $(date)"
            echo "Analysis period: $(head -1 access.log | grep -oE '\[[^]]+\]')"
            echo
            
            # Summary statistics
            echo "SUMMARY STATISTICS"
            echo "------------------"
            echo "Total requests: $(wc -l < access.log)"
            echo "Unique visitors: $(awk '{print $1}' access.log | sort -u | wc -l)"
            echo "Total errors: $(wc -l < error.log)"
            
            # Most active IPs
            echo
            echo "TOP 5 MOST ACTIVE IPs"
            echo "---------------------"
            awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5 | \
            while read count ip; do
                echo "$ip: $count requests"
            done
            
            # Error summary
            echo
            echo "ERROR SUMMARY"
            echo "-------------"
            awk '$9 >= 400 {print $9}' access.log | sort | uniq -c | \
            while read count status; do
                echo "HTTP $status: $count occurrences"
            done
            
            # Recommendations
            echo
            echo "RECOMMENDATIONS"
            echo "---------------"
            
            local high_traffic_ips=$(awk '{print $1}' access.log | sort | uniq -c | awk '$1 > 3 {print $2}' | wc -l)
            if [[ $high_traffic_ips -gt 0 ]]; then
                echo "• Monitor high-traffic IPs for potential abuse"
            fi
            
            local errors=$(awk '$9 >= 500' access.log | wc -l)
            if [[ $errors -gt 0 ]]; then
                echo "• Investigate server errors (5xx status codes)"
            fi
            
            local forbidden=$(awk '$9 == 403' access.log | wc -l)
            if [[ $forbidden -gt 0 ]]; then
                echo "• Review access controls for 403 errors"
            fi
            
            echo
            echo "End of report"
            echo "=========================================="
            
        } > "$report_file"
        
        echo "Report generated: $report_file"
        echo "Report preview:"
        head -20 "$report_file"
    }
    
    # Run all analyses
    analyze_basic_stats
    analyze_ips
    analyze_requests
    analyze_errors
    analyze_security
    generate_report
    
    # Clean up
    rm -f access.log error.log log_analysis_report.txt
}

log_analysis_system
```

## Exercises

### Exercise 1: Configuration File Parser

Create a configuration file parser that handles multiple formats:

```bash
#!/usr/bin/env bash

# Configuration file parser
parse_config() {
    local config_file="$1"
    local format="$2"  # ini, json, yaml, key-value
    
    # TODO: Implement parsers for different config formats
    # - INI format with sections
    # - JSON format (simple)
    # - YAML format (basic)
    # - Key-value pairs
    
    echo "Parser not implemented yet"
    echo "File: $config_file"
    echo "Format: $format"
}

# Test your implementation
```

### Exercise 2: Text Report Generator

Create a system that generates formatted reports from CSV data:

```bash
#!/usr/bin/env bash

# Report generator
generate_report() {
    local csv_file="$1"
    local report_type="$2"  # summary, detailed, executive
    
    # TODO: Implement report generation
    # - Parse CSV data
    # - Calculate statistics
    # - Format output (text, markdown, HTML)
    # - Handle different report types
    
    echo "Report generator not implemented yet"
}
```

## Summary

In this chapter, you mastered:

- ✅ Regular expression fundamentals and advanced patterns
- ✅ Text processing with grep, sed, and awk
- ✅ String manipulation and validation techniques
- ✅ Data extraction and transformation
- ✅ Real-world applications: log analysis and reporting

Text processing is essential for data analysis, system administration, and automation. These skills enable you to handle complex text manipulation tasks efficiently.

**Next Steps:**
- Practice with real log files and data
- Experiment with complex regular expressions
- Build your own text processing tools
- Move on to Chapter 12: System Administration

**Key Takeaways:**
- Regular expressions are powerful but require practice
- Choose the right tool: grep for searching, sed for editing, awk for processing
- Always test regex patterns with sample data
- Combine tools with pipes for complex processing
- Consider performance with large files
