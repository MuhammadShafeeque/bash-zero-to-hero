# Chapter 13: Security and Permissions

Security is paramount in system administration and automation. This chapter covers file permissions, access controls, security best practices, and implementing secure bash scripts.

## What You'll Learn

- File permissions and ownership management
- Access control lists (ACLs) and special permissions
- User authentication and authorization
- Secure scripting practices
- Security auditing and monitoring
- Encryption and key management
- Network security basics

## File Permissions and Ownership

### Understanding Permission Systems

```bash
#!/usr/bin/env bash

# File permissions and ownership management
permission_management() {
    echo "=== File Permissions and Ownership Management ==="
    
    # Create test environment
    setup_test_environment() {
        local test_dir="permission_test"
        echo "Setting up test environment: $test_dir"
        
        mkdir -p "$test_dir"/{files,scripts,sensitive}
        
        # Create test files with different permissions
        echo "Regular file content" > "$test_dir/files/document.txt"
        echo "#!/bin/bash\necho 'Hello World'" > "$test_dir/scripts/hello.sh"
        echo "Sensitive information" > "$test_dir/sensitive/secret.txt"
        echo "Configuration data" > "$test_dir/config.conf"
        
        # Set various permissions for demonstration
        chmod 644 "$test_dir/files/document.txt"
        chmod 755 "$test_dir/scripts/hello.sh"
        chmod 600 "$test_dir/sensitive/secret.txt"
        chmod 644 "$test_dir/config.conf"
        
        echo "Test environment created"
    }
    
    # Permission analysis function
    analyze_permissions() {
        local path="$1"
        
        if [[ ! -e "$path" ]]; then
            echo "Path does not exist: $path"
            return 1
        fi
        
        echo "Permission analysis for: $path"
        echo "=============================="
        
        # Get file stats
        local perms owner group size modified
        perms=$(stat -c "%a %A" "$path" 2>/dev/null || stat -f "%OLp %Sp" "$path" 2>/dev/null)
        owner=$(stat -c "%U" "$path" 2>/dev/null || stat -f "%Su" "$path" 2>/dev/null)
        group=$(stat -c "%G" "$path" 2>/dev/null || stat -f "%Sg" "$path" 2>/dev/null)
        size=$(stat -c "%s" "$path" 2>/dev/null || stat -f "%z" "$path" 2>/dev/null)
        modified=$(stat -c "%y" "$path" 2>/dev/null || stat -f "%Sm" "$path" 2>/dev/null)
        
        echo "Permissions: $perms"
        echo "Owner: $owner"
        echo "Group: $group"
        echo "Size: $size bytes"
        echo "Modified: $modified"
        
        # Parse permissions
        local octal symbolic
        octal=$(echo "$perms" | awk '{print $1}')
        symbolic=$(echo "$perms" | awk '{print $2}')
        
        echo -e "\nPermission breakdown:"
        
        # Owner permissions
        local owner_perms=${octal:0:1}
        echo "Owner ($owner):"
        [[ $((owner_perms & 4)) -eq 4 ]] && echo "  ✓ Read" || echo "  ✗ Read"
        [[ $((owner_perms & 2)) -eq 2 ]] && echo "  ✓ Write" || echo "  ✗ Write"
        [[ $((owner_perms & 1)) -eq 1 ]] && echo "  ✓ Execute" || echo "  ✗ Execute"
        
        # Group permissions
        local group_perms=${octal:1:1}
        echo "Group ($group):"
        [[ $((group_perms & 4)) -eq 4 ]] && echo "  ✓ Read" || echo "  ✗ Read"
        [[ $((group_perms & 2)) -eq 2 ]] && echo "  ✓ Write" || echo "  ✗ Write"
        [[ $((group_perms & 1)) -eq 1 ]] && echo "  ✓ Execute" || echo "  ✗ Execute"
        
        # Others permissions
        local other_perms=${octal:2:1}
        echo "Others:"
        [[ $((other_perms & 4)) -eq 4 ]] && echo "  ✓ Read" || echo "  ✗ Read"
        [[ $((other_perms & 2)) -eq 2 ]] && echo "  ✓ Write" || echo "  ✗ Write"
        [[ $((other_perms & 1)) -eq 1 ]] && echo "  ✓ Execute" || echo "  ✗ Execute"
        
        # Special permissions
        echo -e "\nSpecial permissions:"
        [[ "$symbolic" =~ s ]] && echo "  ✓ Setuid" || echo "  ✗ Setuid"
        [[ "$symbolic" =~ s ]] && echo "  ✓ Setgid" || echo "  ✗ Setgid"
        [[ "$symbolic" =~ t ]] && echo "  ✓ Sticky bit" || echo "  ✗ Sticky bit"
        
        # Security assessment
        echo -e "\nSecurity assessment:"
        
        # World writable check
        if [[ $((other_perms & 2)) -eq 2 ]]; then
            echo "  ⚠️  WARNING: File is world-writable"
        fi
        
        # World executable check for non-directories
        if [[ ! -d "$path" && $((other_perms & 1)) -eq 1 ]]; then
            echo "  ⚠️  WARNING: File is world-executable"
        fi
        
        # No permissions for others
        if [[ $other_perms -eq 0 ]]; then
            echo "  ✓ Good: No permissions for others"
        fi
        
        # Owner-only read for sensitive files
        if [[ $octal == "600" ]]; then
            echo "  ✓ Excellent: Owner-only read/write (secure for sensitive files)"
        fi
    }
    
    # Permission modification functions
    set_secure_permissions() {
        local file="$1"
        local file_type="${2:-regular}"  # regular, script, config, sensitive
        
        echo "Setting secure permissions for: $file (type: $file_type)"
        
        case "$file_type" in
            "script")
                chmod 755 "$file"  # rwxr-xr-x
                echo "  Set to 755 (executable by all, writable by owner)"
                ;;
            "config")
                chmod 644 "$file"  # rw-r--r--
                echo "  Set to 644 (readable by all, writable by owner)"
                ;;
            "sensitive")
                chmod 600 "$file"  # rw-------
                echo "  Set to 600 (owner read/write only)"
                ;;
            "directory")
                chmod 755 "$file"  # rwxr-xr-x
                echo "  Set to 755 (accessible by all, writable by owner)"
                ;;
            *)
                chmod 644 "$file"  # rw-r--r--
                echo "  Set to 644 (default: readable by all, writable by owner)"
                ;;
        esac
    }
    
    # Bulk permission audit
    audit_permissions() {
        local directory="$1"
        local report_file="${2:-/tmp/permission_audit.txt}"
        
        echo "Auditing permissions in: $directory"
        echo "Report will be saved to: $report_file"
        
        {
            echo "Permission Audit Report"
            echo "======================="
            echo "Directory: $directory"
            echo "Generated: $(date)"
            echo
            
            echo "SECURITY ISSUES FOUND:"
            echo "====================="
            
            # Find world-writable files
            echo "World-writable files:"
            find "$directory" -type f -perm -002 2>/dev/null | while read file; do
                echo "  WARNING: $file"
            done
            
            # Find world-writable directories
            echo -e "\nWorld-writable directories:"
            find "$directory" -type d -perm -002 2>/dev/null | while read dir; do
                echo "  WARNING: $dir"
            done
            
            # Find setuid files
            echo -e "\nSetuid files:"
            find "$directory" -type f -perm -4000 2>/dev/null | while read file; do
                echo "  ATTENTION: $file (setuid)"
            done
            
            # Find setgid files
            echo -e "\nSetgid files:"
            find "$directory" -type f -perm -2000 2>/dev/null | while read file; do
                echo "  ATTENTION: $file (setgid)"
            done
            
            # Find files with no owner
            echo -e "\nFiles with no owner:"
            find "$directory" -nouser 2>/dev/null | while read file; do
                echo "  WARNING: $file (no owner)"
            done
            
            # Find files with no group
            echo -e "\nFiles with no group:"
            find "$directory" -nogroup 2>/dev/null | while read file; do
                echo "  WARNING: $file (no group)"
            done
            
            echo -e "\nDETAILED FILE LISTING:"
            echo "====================="
            find "$directory" -type f -exec ls -la {} \; 2>/dev/null | head -20
            
        } > "$report_file"
        
        echo "Audit complete. Summary:"
        echo "  World-writable files: $(find "$directory" -type f -perm -002 2>/dev/null | wc -l)"
        echo "  Setuid files: $(find "$directory" -type f -perm -4000 2>/dev/null | wc -l)"
        echo "  Files with no owner: $(find "$directory" -nouser 2>/dev/null | wc -l)"
        
        # Display first few issues
        echo -e "\nFirst few security issues found:"
        grep -E "WARNING|ATTENTION" "$report_file" | head -5
    }
    
    # Run permission management demo
    setup_test_environment
    
    echo -e "\n1. Permission Analysis Examples:"
    test_dir="permission_test"
    
    for file in "$test_dir/files/document.txt" "$test_dir/scripts/hello.sh" "$test_dir/sensitive/secret.txt"; do
        echo -e "\n" && echo "="*50
        analyze_permissions "$file"
    done
    
    echo -e "\n2. Setting Secure Permissions:"
    set_secure_permissions "$test_dir/scripts/hello.sh" "script"
    set_secure_permissions "$test_dir/sensitive/secret.txt" "sensitive"
    
    echo -e "\n3. Permission Audit:"
    audit_permissions "$test_dir"
    
    # Clean up
    rm -rf "$test_dir" /tmp/permission_audit.txt
}

permission_management
```

### Access Control Lists (ACLs)

```bash
#!/usr/bin/env bash

# Advanced Access Control Lists (ACLs)
access_control_lists() {
    echo "=== Access Control Lists (ACLs) ==="
    
    # Check ACL support
    check_acl_support() {
        echo "Checking ACL support..."
        
        # Check if ACL commands are available
        if command -v getfacl >/dev/null && command -v setfacl >/dev/null; then
            echo "✓ ACL commands available"
        else
            echo "✗ ACL commands not available (install acl package)"
            echo "  Ubuntu/Debian: sudo apt-get install acl"
            echo "  CentOS/RHEL: sudo yum install acl"
            return 1
        fi
        
        # Check filesystem ACL support
        local test_file="/tmp/acl_test_$$"
        touch "$test_file"
        
        if setfacl -m u:$(whoami):rw "$test_file" 2>/dev/null; then
            echo "✓ Filesystem supports ACLs"
            rm -f "$test_file"
        else
            echo "✗ Filesystem does not support ACLs"
            echo "  Mount with acl option: mount -o remount,acl /"
            rm -f "$test_file"
            return 1
        fi
    }
    
    # ACL demonstration
    demonstrate_acls() {
        local test_dir="acl_demo"
        
        echo "ACL Demonstration"
        echo "=================="
        
        # Create test environment
        mkdir -p "$test_dir"
        echo "Test content" > "$test_dir/test_file.txt"
        
        echo "1. Default permissions:"
        ls -la "$test_dir/test_file.txt"
        
        if ! command -v getfacl >/dev/null; then
            echo "ACL commands not available, skipping demo"
            rm -rf "$test_dir"
            return 1
        fi
        
        echo -e "\n2. Current ACL:"
        getfacl "$test_dir/test_file.txt" 2>/dev/null || echo "No ACL support or file doesn't exist"
        
        # Set ACL for specific user (using current user as example)
        local current_user=$(whoami)
        echo -e "\n3. Setting ACL for user '$current_user':"
        
        if setfacl -m u:$current_user:rw "$test_dir/test_file.txt" 2>/dev/null; then
            echo "✓ ACL set successfully"
            echo "Updated ACL:"
            getfacl "$test_dir/test_file.txt" 2>/dev/null | head -10
        else
            echo "✗ Failed to set ACL (filesystem may not support ACLs)"
        fi
        
        # Set default ACL for directory
        echo -e "\n4. Setting default ACL for directory:"
        if setfacl -d -m u:$current_user:rwx "$test_dir" 2>/dev/null; then
            echo "✓ Default ACL set for directory"
            echo "Directory ACL:"
            getfacl "$test_dir" 2>/dev/null | head -10
        else
            echo "✗ Failed to set default ACL"
        fi
        
        # Test inheritance
        echo -e "\n5. Testing ACL inheritance:"
        echo "New file content" > "$test_dir/new_file.txt"
        if getfacl "$test_dir/new_file.txt" >/dev/null 2>&1; then
            echo "New file ACL (should inherit from directory):"
            getfacl "$test_dir/new_file.txt" 2>/dev/null | head -10
        fi
        
        # Clean up
        rm -rf "$test_dir"
    }
    
    # ACL management functions
    acl_management_functions() {
        echo "ACL Management Functions"
        echo "======================="
        
        # Function to add user ACL
        add_user_acl() {
            local file="$1"
            local user="$2"
            local permissions="$3"  # e.g., "rw", "rwx"
            
            if [[ ! -e "$file" ]]; then
                echo "File does not exist: $file"
                return 1
            fi
            
            if ! id "$user" >/dev/null 2>&1; then
                echo "User does not exist: $user"
                return 1
            fi
            
            echo "Adding ACL: user '$user' gets '$permissions' on '$file'"
            
            if command -v setfacl >/dev/null; then
                if setfacl -m u:$user:$permissions "$file" 2>/dev/null; then
                    echo "✓ ACL added successfully"
                    return 0
                else
                    echo "✗ Failed to add ACL"
                    return 1
                fi
            else
                echo "✗ setfacl command not available"
                return 1
            fi
        }
        
        # Function to remove user ACL
        remove_user_acl() {
            local file="$1"
            local user="$2"
            
            echo "Removing ACL for user '$user' from '$file'"
            
            if command -v setfacl >/dev/null; then
                if setfacl -x u:$user "$file" 2>/dev/null; then
                    echo "✓ ACL removed successfully"
                    return 0
                else
                    echo "✗ Failed to remove ACL"
                    return 1
                fi
            else
                echo "✗ setfacl command not available"
                return 1
            fi
        }
        
        # Function to show effective permissions
        show_effective_permissions() {
            local file="$1"
            local user="${2:-$(whoami)}"
            
            echo "Effective permissions for user '$user' on file '$file':"
            
            if [[ ! -e "$file" ]]; then
                echo "✗ File does not exist"
                return 1
            fi
            
            # Check if user is owner
            local file_owner
            file_owner=$(stat -c "%U" "$file" 2>/dev/null || stat -f "%Su" "$file" 2>/dev/null)
            
            if [[ "$user" == "$file_owner" ]]; then
                echo "  User is file owner"
                local owner_perms
                owner_perms=$(stat -c "%a" "$file" 2>/dev/null | cut -c1)
                echo "  Owner permissions: $owner_perms"
            fi
            
            # Check group membership
            local file_group
            file_group=$(stat -c "%G" "$file" 2>/dev/null || stat -f "%Sg" "$file" 2>/dev/null)
            
            if groups "$user" 2>/dev/null | grep -q "$file_group"; then
                echo "  User is member of file group: $file_group"
            fi
            
            # Show ACL if available
            if command -v getfacl >/dev/null; then
                local user_acl
                user_acl=$(getfacl "$file" 2>/dev/null | grep "^user:$user:")
                if [[ -n "$user_acl" ]]; then
                    echo "  Specific ACL: $user_acl"
                fi
            fi
        }
        
        # Example usage
        echo "Example ACL management (using current user):"
        local test_file="/tmp/acl_example_$$"
        echo "Test content" > "$test_file"
        
        show_effective_permissions "$test_file"
        
        # Clean up
        rm -f "$test_file"
    }
    
    # Run ACL demonstrations
    check_acl_support
    echo -e "\n"
    demonstrate_acls
    echo -e "\n"
    acl_management_functions
}

access_control_lists
```

## Secure Scripting Practices

### Input Validation and Sanitization

```bash
#!/usr/bin/env bash

# Secure scripting practices and input validation
secure_scripting() {
    echo "=== Secure Scripting Practices ==="
    
    # Input validation functions
    input_validation() {
        echo "Input Validation Techniques"
        echo "=========================="
        
        # Email validation
        validate_email() {
            local email="$1"
            local regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
            
            if [[ "$email" =~ $regex ]]; then
                echo "✓ Valid email: $email"
                return 0
            else
                echo "✗ Invalid email: $email"
                return 1
            fi
        }
        
        # Username validation
        validate_username() {
            local username="$1"
            local min_length=3
            local max_length=32
            
            # Check length
            if [[ ${#username} -lt $min_length || ${#username} -gt $max_length ]]; then
                echo "✗ Username length must be between $min_length and $max_length characters"
                return 1
            fi
            
            # Check for valid characters (alphanumeric, underscore, hyphen)
            if [[ ! "$username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
                echo "✗ Username contains invalid characters (only a-z, A-Z, 0-9, _, - allowed)"
                return 1
            fi
            
            # Must start with letter
            if [[ ! "$username" =~ ^[a-zA-Z] ]]; then
                echo "✗ Username must start with a letter"
                return 1
            fi
            
            echo "✓ Valid username: $username"
            return 0
        }
        
        # File path validation
        validate_file_path() {
            local file_path="$1"
            local allowed_base="${2:-/tmp}"
            
            # Resolve path to prevent directory traversal
            local resolved_path
            if ! resolved_path=$(realpath "$file_path" 2>/dev/null); then
                echo "✗ Invalid file path: $file_path"
                return 1
            fi
            
            # Check if path is within allowed base
            if [[ "$resolved_path" != "$allowed_base"* ]]; then
                echo "✗ File path outside allowed directory: $resolved_path"
                return 1
            fi
            
            # Check for dangerous characters
            if [[ "$file_path" =~ \.\./|//|[<>|&;] ]]; then
                echo "✗ File path contains dangerous characters: $file_path"
                return 1
            fi
            
            echo "✓ Valid file path: $resolved_path"
            return 0
        }
        
        # IP address validation
        validate_ip() {
            local ip="$1"
            local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
            
            if [[ ! "$ip" =~ $regex ]]; then
                echo "✗ Invalid IP format: $ip"
                return 1
            fi
            
            # Check each octet
            IFS='.' read -ra octets <<< "$ip"
            for octet in "${octets[@]}"; do
                if [[ $octet -gt 255 || $octet -lt 0 ]]; then
                    echo "✗ Invalid IP address (octet out of range): $ip"
                    return 1
                fi
            done
            
            echo "✓ Valid IP address: $ip"
            return 0
        }
        
        # Port number validation
        validate_port() {
            local port="$1"
            
            if [[ ! "$port" =~ ^[0-9]+$ ]]; then
                echo "✗ Port must be numeric: $port"
                return 1
            fi
            
            if [[ $port -lt 1 || $port -gt 65535 ]]; then
                echo "✗ Port must be between 1 and 65535: $port"
                return 1
            fi
            
            echo "✓ Valid port: $port"
            return 0
        }
        
        # Test validation functions
        echo "Testing validation functions:"
        echo
        
        echo "Email validation:"
        validate_email "user@example.com"
        validate_email "invalid.email"
        validate_email "test@domain.co.uk"
        
        echo -e "\nUsername validation:"
        validate_username "john_doe"
        validate_username "123invalid"
        validate_username "valid_user-name"
        validate_username "a"  # too short
        
        echo -e "\nFile path validation:"
        validate_file_path "/tmp/safe_file.txt"
        validate_file_path "../../../etc/passwd"
        validate_file_path "/tmp/subdir/file.txt"
        
        echo -e "\nIP address validation:"
        validate_ip "192.168.1.1"
        validate_ip "256.1.1.1"
        validate_ip "10.0.0.1"
        
        echo -e "\nPort validation:"
        validate_port "80"
        validate_port "65536"
        validate_port "443"
        validate_port "abc"
    }
    
    # Input sanitization
    input_sanitization() {
        echo -e "\nInput Sanitization Techniques"
        echo "============================"
        
        # Remove dangerous characters
        sanitize_filename() {
            local filename="$1"
            
            # Remove/replace dangerous characters
            filename="${filename//[^a-zA-Z0-9._-]/}"  # Keep only safe chars
            filename="${filename//\.\./}"             # Remove ..
            filename="${filename#.}"                  # Remove leading dot
            filename="${filename%.}"                  # Remove trailing dot
            
            # Ensure not empty
            if [[ -z "$filename" ]]; then
                filename="sanitized_file"
            fi
            
            echo "$filename"
        }
        
        # Sanitize shell input (prevent command injection)
        sanitize_shell_input() {
            local input="$1"
            
            # Remove or escape dangerous characters
            input="${input//[;&|<>(){}[\]$`\\]/}"     # Remove shell metacharacters
            input="${input//[[:space:]]+/ }"          # Normalize whitespace
            input="${input#"${input%%[![:space:]]*}"}" # Trim leading space
            input="${input%"${input##*[![:space:]]}"}" # Trim trailing space
            
            echo "$input"
        }
        
        # HTML/XML sanitization
        sanitize_html() {
            local input="$1"
            
            # Escape HTML special characters
            input="${input//&/&amp;}"
            input="${input//</&lt;}"
            input="${input//>/&gt;}"
            input="${input//\"/&quot;}"
            input="${input//\'/&#39;}"
            
            echo "$input"
        }
        
        # Test sanitization
        echo "Testing sanitization functions:"
        echo
        
        echo "Filename sanitization:"
        echo "Original: '../../../etc/passwd'"
        echo "Sanitized: $(sanitize_filename '../../../etc/passwd')"
        echo "Original: 'file<>name|.txt'"
        echo "Sanitized: $(sanitize_filename 'file<>name|.txt')"
        
        echo -e "\nShell input sanitization:"
        echo "Original: 'hello; rm -rf /'"
        echo "Sanitized: $(sanitize_shell_input 'hello; rm -rf /')"
        echo "Original: 'user\$(whoami)'"
        echo "Sanitized: $(sanitize_shell_input 'user$(whoami)')"
        
        echo -e "\nHTML sanitization:"
        echo "Original: '<script>alert(\"XSS\")</script>'"
        echo "Sanitized: $(sanitize_html '<script>alert("XSS")</script>')"
    }
    
    # Secure parameter handling
    secure_parameter_handling() {
        echo -e "\nSecure Parameter Handling"
        echo "========================"
        
        # Safe parameter processing
        process_parameters_safely() {
            local operation="$1"
            shift  # Remove first parameter
            local -a files=("$@")  # Remaining parameters as array
            
            echo "Processing operation: $operation"
            echo "Number of files: ${#files[@]}"
            
            # Validate operation
            case "$operation" in
                "list"|"copy"|"move"|"delete")
                    echo "✓ Valid operation: $operation"
                    ;;
                *)
                    echo "✗ Invalid operation: $operation"
                    echo "Allowed operations: list, copy, move, delete"
                    return 1
                    ;;
            esac
            
            # Validate each file parameter
            local valid_files=()
            for file in "${files[@]}"; do
                if validate_file_path "$file" "/tmp" >/dev/null 2>&1; then
                    valid_files+=("$file")
                    echo "✓ Valid file: $file"
                else
                    echo "✗ Invalid file: $file (skipping)"
                fi
            done
            
            echo "Processing ${#valid_files[@]} valid files..."
            # Process valid files here
        }
        
        # Demonstrate safe parameter handling
        echo "Testing parameter handling:"
        process_parameters_safely "list" "/tmp/file1.txt" "/tmp/file2.txt" "../etc/passwd"
    }
    
    # Run secure scripting demonstrations
    input_validation
    input_sanitization
    secure_parameter_handling
}

secure_scripting
```

### Secrets Management and Encryption

```bash
#!/usr/bin/env bash

# Secrets management and encryption
secrets_management() {
    echo "=== Secrets Management and Encryption ==="
    
    # Environment-based secrets management
    environment_secrets() {
        echo "Environment-Based Secrets Management"
        echo "==================================="
        
        # Function to load secrets from environment file
        load_secrets() {
            local env_file="${1:-.env}"
            
            if [[ ! -f "$env_file" ]]; then
                echo "Environment file not found: $env_file"
                return 1
            fi
            
            echo "Loading secrets from: $env_file"
            
            # Validate file permissions (should be 600)
            local perms
            perms=$(stat -c "%a" "$env_file" 2>/dev/null || stat -f "%OLp" "$env_file" 2>/dev/null)
            
            if [[ "$perms" != "600" ]]; then
                echo "⚠️  WARNING: Environment file has insecure permissions: $perms"
                echo "   Recommended: chmod 600 $env_file"
            fi
            
            # Source the file safely
            set -a  # Export all variables
            source "$env_file"
            set +a  # Stop exporting
            
            echo "✓ Secrets loaded successfully"
        }
        
        # Function to validate required secrets
        validate_secrets() {
            local -a required_vars=("$@")
            local missing_vars=()
            
            echo "Validating required secrets..."
            
            for var in "${required_vars[@]}"; do
                if [[ -z "${!var:-}" ]]; then
                    missing_vars+=("$var")
                    echo "✗ Missing: $var"
                else
                    echo "✓ Found: $var"
                fi
            done
            
            if [[ ${#missing_vars[@]} -gt 0 ]]; then
                echo "❌ Missing required secrets: ${missing_vars[*]}"
                return 1
            else
                echo "✅ All required secrets are present"
                return 0
            fi
        }
        
        # Create example environment file
        cat > /tmp/example.env << 'EOF'
# Database configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=myapp
DB_PASSWORD=super_secret_password

# API keys
API_KEY=sk-1234567890abcdef
WEBHOOK_SECRET=whsec_abcdef123456

# Encryption settings
ENCRYPTION_KEY=base64:abcdef1234567890
EOF
        
        chmod 600 /tmp/example.env
        
        echo "Example environment file created at /tmp/example.env"
        echo "Contents (passwords masked):"
        sed 's/PASSWORD=.*/PASSWORD=***MASKED***/g; s/SECRET=.*/SECRET=***MASKED***/g; s/KEY=.*/KEY=***MASKED***/g' /tmp/example.env
        
        # Demonstrate secrets loading
        echo -e "\nTesting secrets management:"
        load_secrets "/tmp/example.env"
        validate_secrets "DB_HOST" "DB_USER" "DB_PASSWORD" "API_KEY"
        
        # Clean up
        rm -f /tmp/example.env
        unset DB_HOST DB_PORT DB_USER DB_PASSWORD API_KEY WEBHOOK_SECRET ENCRYPTION_KEY
    }
    
    # Simple encryption/decryption using OpenSSL
    encryption_functions() {
        echo -e "\nEncryption Functions"
        echo "==================="
        
        # Check if OpenSSL is available
        if ! command -v openssl >/dev/null; then
            echo "OpenSSL not available, skipping encryption demo"
            return 1
        fi
        
        # Encrypt text
        encrypt_text() {
            local text="$1"
            local password="$2"
            
            echo "Encrypting text..."
            echo -n "$text" | openssl enc -aes-256-cbc -a -salt -pass pass:"$password" 2>/dev/null
        }
        
        # Decrypt text
        decrypt_text() {
            local encrypted_text="$1"
            local password="$2"
            
            echo "Decrypting text..."
            echo -n "$encrypted_text" | openssl enc -aes-256-cbc -d -a -salt -pass pass:"$password" 2>/dev/null
        }
        
        # Encrypt file
        encrypt_file() {
            local input_file="$1"
            local output_file="$2"
            local password="$3"
            
            if [[ ! -f "$input_file" ]]; then
                echo "Input file not found: $input_file"
                return 1
            fi
            
            echo "Encrypting file: $input_file -> $output_file"
            openssl enc -aes-256-cbc -salt -in "$input_file" -out "$output_file" -pass pass:"$password" 2>/dev/null
            
            if [[ $? -eq 0 ]]; then
                echo "✓ File encrypted successfully"
                # Secure delete original (simple version)
                shred -u "$input_file" 2>/dev/null || rm -f "$input_file"
                echo "✓ Original file securely deleted"
            else
                echo "✗ Encryption failed"
                return 1
            fi
        }
        
        # Decrypt file
        decrypt_file() {
            local input_file="$1"
            local output_file="$2"
            local password="$3"
            
            if [[ ! -f "$input_file" ]]; then
                echo "Encrypted file not found: $input_file"
                return 1
            fi
            
            echo "Decrypting file: $input_file -> $output_file"
            openssl enc -aes-256-cbc -d -salt -in "$input_file" -out "$output_file" -pass pass:"$password" 2>/dev/null
            
            if [[ $? -eq 0 ]]; then
                echo "✓ File decrypted successfully"
            else
                echo "✗ Decryption failed (wrong password?)"
                return 1
            fi
        }
        
        # Generate secure password
        generate_password() {
            local length="${1:-16}"
            local chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*'
            
            # Use /dev/urandom for randomness
            if [[ -r /dev/urandom ]]; then
                tr -dc "$chars" < /dev/urandom | head -c "$length"
                echo
            else
                # Fallback to using date and random
                echo "$(date +%s | sha256sum | head -c $length)"
            fi
        }
        
        # Hash password (for storage)
        hash_password() {
            local password="$1"
            local salt="${2:-$(openssl rand -hex 16)}"
            
            echo "Salt: $salt"
            echo "Hash: $(echo -n "$password$salt" | sha256sum | cut -d' ' -f1)"
        }
        
        # Demonstration
        echo "Testing encryption functions:"
        
        # Text encryption
        local test_text="This is a secret message"
        local password="my_secure_password_123"
        
        echo -e "\nOriginal text: $test_text"
        
        local encrypted
        encrypted=$(encrypt_text "$test_text" "$password")
        echo "Encrypted: $encrypted"
        
        local decrypted
        decrypted=$(decrypt_text "$encrypted" "$password")
        echo "Decrypted: $decrypted"
        
        # File encryption
        echo -e "\nFile encryption test:"
        echo "Secret file content" > /tmp/secret.txt
        echo "Created test file: /tmp/secret.txt"
        
        encrypt_file "/tmp/secret.txt" "/tmp/secret.txt.enc" "$password"
        
        if [[ -f "/tmp/secret.txt.enc" ]]; then
            echo "Encrypted file size: $(wc -c < /tmp/secret.txt.enc) bytes"
            
            decrypt_file "/tmp/secret.txt.enc" "/tmp/secret_decrypted.txt" "$password"
            
            if [[ -f "/tmp/secret_decrypted.txt" ]]; then
                echo "Decrypted content: $(cat /tmp/secret_decrypted.txt)"
            fi
        fi
        
        # Password generation
        echo -e "\nPassword generation:"
        echo "12-char password: $(generate_password 12)"
        echo "16-char password: $(generate_password 16)"
        
        # Password hashing
        echo -e "\nPassword hashing:"
        hash_password "user_password_123"
        
        # Clean up
        rm -f /tmp/secret.txt /tmp/secret.txt.enc /tmp/secret_decrypted.txt
    }
    
    # Key management
    key_management() {
        echo -e "\nKey Management"
        echo "============="
        
        # Generate SSH key pair
        generate_ssh_key() {
            local key_name="${1:-id_rsa_test}"
            local key_type="${2:-rsa}"
            local key_size="${3:-2048}"
            local comment="${4:-Generated by script}"
            
            local key_path="/tmp/$key_name"
            
            echo "Generating SSH key pair..."
            echo "Type: $key_type, Size: $key_size"
            echo "Private key: $key_path"
            echo "Public key: $key_path.pub"
            
            ssh-keygen -t "$key_type" -b "$key_size" -f "$key_path" -C "$comment" -N "" >/dev/null 2>&1
            
            if [[ $? -eq 0 ]]; then
                echo "✓ SSH key pair generated successfully"
                echo "Public key content:"
                cat "$key_path.pub"
                
                # Show key fingerprint
                local fingerprint
                fingerprint=$(ssh-keygen -lf "$key_path.pub" 2>/dev/null)
                echo "Fingerprint: $fingerprint"
                
                # Set secure permissions
                chmod 600 "$key_path"
                chmod 644 "$key_path.pub"
                echo "✓ Secure permissions set"
            else
                echo "✗ Failed to generate SSH key pair"
                return 1
            fi
            
            # Clean up
            rm -f "$key_path" "$key_path.pub"
        }
        
        # Generate random key
        generate_random_key() {
            local key_length="${1:-32}"  # bytes
            local encoding="${2:-hex}"   # hex, base64
            
            echo "Generating random key ($key_length bytes, $encoding encoding):"
            
            if [[ "$encoding" == "base64" ]]; then
                openssl rand -base64 "$key_length"
            else
                openssl rand -hex "$key_length"
            fi
        }
        
        # Demonstrate key management
        echo "SSH key generation:"
        generate_ssh_key "test_key" "rsa" "2048" "Test key for demo"
        
        echo -e "\nRandom key generation:"
        echo "32-byte hex key: $(generate_random_key 32 hex)"
        echo "24-byte base64 key: $(generate_random_key 24 base64)"
    }
    
    # Run secrets management demonstrations
    environment_secrets
    encryption_functions
    key_management
}

secrets_management
```

## Security Auditing and Monitoring

### System Security Audit

```bash
#!/usr/bin/env bash

# Security auditing and monitoring
security_auditing() {
    echo "=== Security Auditing and Monitoring ==="
    
    # Comprehensive security audit
    system_security_audit() {
        echo "System Security Audit"
        echo "===================="
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "User: $(whoami)"
        echo
        
        local audit_report="/tmp/security_audit_$(date +%s).txt"
        
        {
            echo "SYSTEM SECURITY AUDIT REPORT"
            echo "============================="
            echo "Generated: $(date)"
            echo "Hostname: $(hostname)"
            echo "Operating System: $(uname -a)"
            echo
            
            # User account security
            echo "1. USER ACCOUNT SECURITY"
            echo "========================"
            
            # Check for accounts with no password
            echo "Accounts with no password:"
            awk -F: '($2 == "" || $2 == "!") {print "  " $1}' /etc/shadow 2>/dev/null || echo "  Cannot access /etc/shadow (requires root)"
            
            # Check for UID 0 accounts (should only be root)
            echo -e "\nAccounts with UID 0 (root privileges):"
            awk -F: '$3 == 0 {print "  " $1}' /etc/passwd
            
            # Check for users with shell access
            echo -e "\nUsers with shell access:"
            awk -F: '$7 ~ /\/bin\/(bash|sh|zsh|fish)/ {print "  " $1 " (" $7 ")"}' /etc/passwd | head -10
            
            # Check for inactive users
            echo -e "\nUsers not logged in recently (last 30 days):"
            if command -v lastlog >/dev/null; then
                lastlog -t 30 2>/dev/null | tail -n +2 | head -5
            else
                echo "  lastlog command not available"
            fi
            
            # File permission security
            echo -e "\n2. FILE PERMISSION SECURITY"
            echo "============================"
            
            # World-writable files in system directories
            echo "World-writable files in system directories:"
            find /etc /bin /sbin /usr/bin /usr/sbin -type f -perm -002 2>/dev/null | head -5 | while read file; do
                echo "  WARNING: $file"
            done
            
            # SUID files
            echo -e "\nSUID files:"
            find /usr /bin /sbin -type f -perm -4000 2>/dev/null | head -10 | while read file; do
                echo "  $file"
            done
            
            # Files with no owner or group
            echo -e "\nFiles with no owner:"
            find /home /tmp -nouser 2>/dev/null | head -5 | while read file; do
                echo "  WARNING: $file"
            done
            
            # Network security
            echo -e "\n3. NETWORK SECURITY"
            echo "==================="
            
            # Listening services
            echo "Listening network services:"
            if command -v netstat >/dev/null; then
                netstat -tuln 2>/dev/null | grep LISTEN | head -10 | while read line; do
                    echo "  $line"
                done
            elif command -v ss >/dev/null; then
                ss -tuln 2>/dev/null | grep LISTEN | head -10 | while read line; do
                    echo "  $line"
                done
            fi
            
            # Open ports
            echo -e "\nOpen TCP ports:"
            netstat -tuln 2>/dev/null | awk '/tcp.*LISTEN/ {print $4}' | cut -d: -f2 | sort -n | uniq | head -10 | while read port; do
                echo "  Port $port"
            done
            
            # Process security
            echo -e "\n4. PROCESS SECURITY"
            echo "==================="
            
            # Processes running as root
            echo "Processes running as root:"
            ps aux | awk '$1 == "root" {print "  " $11}' | sort | uniq | head -10
            
            # Processes with unusual network activity
            echo -e "\nProcesses with network connections:"
            if command -v lsof >/dev/null; then
                lsof -i 2>/dev/null | awk 'NR>1 {print "  " $1 " (PID " $2 ") - " $8}' | head -5
            else
                echo "  lsof not available"
            fi
            
            # System configuration security
            echo -e "\n5. SYSTEM CONFIGURATION"
            echo "======================="
            
            # SSH configuration check
            if [[ -f /etc/ssh/sshd_config ]]; then
                echo "SSH configuration security:"
                
                # Check for root login
                if grep -q "^PermitRootLogin.*yes" /etc/ssh/sshd_config; then
                    echo "  WARNING: Root login enabled"
                else
                    echo "  OK: Root login disabled/restricted"
                fi
                
                # Check for password authentication
                if grep -q "^PasswordAuthentication.*yes" /etc/ssh/sshd_config; then
                    echo "  INFO: Password authentication enabled"
                else
                    echo "  OK: Password authentication disabled"
                fi
                
                # Check SSH protocol version
                if grep -q "^Protocol.*1" /etc/ssh/sshd_config; then
                    echo "  WARNING: SSH Protocol 1 enabled (insecure)"
                else
                    echo "  OK: SSH Protocol 2 (secure)"
                fi
            fi
            
            # Firewall status
            echo -e "\nFirewall status:"
            if command -v ufw >/dev/null; then
                ufw status 2>/dev/null | head -3
            elif command -v firewall-cmd >/dev/null; then
                echo "  firewalld: $(firewall-cmd --state 2>/dev/null || echo 'not running')"
            elif command -v iptables >/dev/null; then
                local iptables_rules
                iptables_rules=$(iptables -L 2>/dev/null | wc -l)
                echo "  iptables: $iptables_rules rules configured"
            else
                echo "  No firewall detected"
            fi
            
            # Log file permissions
            echo -e "\n6. LOG FILE SECURITY"
            echo "===================="
            
            echo "Log file permissions:"
            for log_file in /var/log/auth.log /var/log/secure /var/log/messages /var/log/syslog; do
                if [[ -f "$log_file" ]]; then
                    ls -la "$log_file" | awk '{print "  " $1 " " $3 " " $4 " " $9}'
                fi
            done
            
            # Security recommendations
            echo -e "\n7. SECURITY RECOMMENDATIONS"
            echo "==========================="
            
            echo "Based on this audit, consider the following actions:"
            echo "1. Regularly update system packages"
            echo "2. Review user accounts and remove unnecessary accounts"
            echo "3. Implement strong password policies"
            echo "4. Enable and configure firewall"
            echo "5. Monitor system logs regularly"
            echo "6. Use key-based SSH authentication"
            echo "7. Disable unnecessary services"
            echo "8. Implement file integrity monitoring"
            echo "9. Regular security audits"
            echo "10. Backup critical data regularly"
            
            echo
            echo "Audit completed: $(date)"
            
        } > "$audit_report"
        
        echo "Security audit completed!"
        echo "Report saved to: $audit_report"
        echo
        echo "Report summary:"
        grep -E "WARNING|CRITICAL|ERROR" "$audit_report" | head -5 || echo "No critical issues found in this scan"
        
        # Display first part of report
        echo -e "\nFirst 30 lines of report:"
        head -30 "$audit_report"
        
        # Clean up
        rm -f "$audit_report"
    }
    
    # File integrity monitoring
    file_integrity_monitoring() {
        echo -e "\nFile Integrity Monitoring"
        echo "========================"
        
        # Create baseline checksums
        create_baseline() {
            local directory="$1"
            local baseline_file="${2:-/tmp/baseline_checksums.txt}"
            
            echo "Creating baseline checksums for: $directory"
            echo "Baseline file: $baseline_file"
            
            find "$directory" -type f -exec md5sum {} \; 2>/dev/null > "$baseline_file"
            
            local file_count
            file_count=$(wc -l < "$baseline_file")
            echo "✓ Baseline created with $file_count files"
        }
        
        # Check for changes
        check_integrity() {
            local directory="$1"
            local baseline_file="${2:-/tmp/baseline_checksums.txt}"
            local report_file="${3:-/tmp/integrity_report.txt}"
            
            if [[ ! -f "$baseline_file" ]]; then
                echo "Baseline file not found: $baseline_file"
                return 1
            fi
            
            echo "Checking file integrity against baseline..."
            
            {
                echo "File Integrity Check Report"
                echo "==========================="
                echo "Generated: $(date)"
                echo "Directory: $directory"
                echo "Baseline: $baseline_file"
                echo
                
                # Generate current checksums
                local temp_checksums="/tmp/current_checksums_$$.txt"
                find "$directory" -type f -exec md5sum {} \; 2>/dev/null > "$temp_checksums"
                
                # Find differences
                echo "CHANGES DETECTED:"
                echo "=================="
                
                # Files that have changed
                echo "Modified files:"
                comm -23 <(sort "$temp_checksums") <(sort "$baseline_file") | while read sum file; do
                    if grep -q "$file" "$baseline_file"; then
                        echo "  MODIFIED: $file"
                    fi
                done
                
                # New files
                echo -e "\nNew files:"
                comm -23 <(awk '{print $2}' "$temp_checksums" | sort) <(awk '{print $2}' "$baseline_file" | sort) | while read file; do
                    echo "  NEW: $file"
                done
                
                # Deleted files
                echo -e "\nDeleted files:"
                comm -23 <(awk '{print $2}' "$baseline_file" | sort) <(awk '{print $2}' "$temp_checksums" | sort) | while read file; do
                    echo "  DELETED: $file"
                done
                
                rm -f "$temp_checksums"
                
            } > "$report_file"
            
            echo "Integrity check completed"
            echo "Report saved to: $report_file"
            
            # Show summary
            local changes
            changes=$(grep -c "MODIFIED\|NEW\|DELETED" "$report_file" 2>/dev/null || echo "0")
            if [[ $changes -gt 0 ]]; then
                echo "⚠️  $changes changes detected"
            else
                echo "✓ No changes detected"
            fi
        }
        
        # Demonstrate file integrity monitoring
        local test_dir="/tmp/integrity_test"
        mkdir -p "$test_dir"
        
        # Create test files
        echo "Test file 1" > "$test_dir/file1.txt"
        echo "Test file 2" > "$test_dir/file2.txt"
        
        echo "Creating baseline for test directory..."
        create_baseline "$test_dir"
        
        # Simulate changes
        echo "Simulating file changes..."
        echo "Modified content" > "$test_dir/file1.txt"  # Modify existing file
        echo "New file content" > "$test_dir/file3.txt"  # Add new file
        rm -f "$test_dir/file2.txt"                      # Delete file
        
        echo "Checking integrity after changes..."
        check_integrity "$test_dir"
        
        # Clean up
        rm -rf "$test_dir" /tmp/baseline_checksums.txt /tmp/integrity_report.txt
    }
    
    # Log monitoring
    log_monitoring() {
        echo -e "\nLog Monitoring"
        echo "============="
        
        # Security event detector
        detect_security_events() {
            local log_file="${1:-/var/log/auth.log}"
            local time_window="${2:-1440}"  # minutes (24 hours)
            
            if [[ ! -f "$log_file" ]]; then
                echo "Log file not found: $log_file"
                echo "Note: This function requires access to system logs"
                return 1
            fi
            
            echo "Analyzing security events in: $log_file"
            echo "Time window: last $time_window minutes"
            
            # Failed login attempts
            echo -e "\nRecent failed login attempts:"
            grep "Failed password" "$log_file" | tail -5 | while read line; do
                echo "  $line"
            done
            
            # Successful logins
            echo -e "\nRecent successful logins:"
            grep "Accepted password\|Accepted publickey" "$log_file" | tail -5 | while read line; do
                echo "  $line"
            done
            
            # Su attempts
            echo -e "\nSu attempts:"
            grep "su:" "$log_file" | tail -3 | while read line; do
                echo "  $line"
            done
            
            # Sudo usage
            echo -e "\nSudo usage:"
            grep "sudo:" "$log_file" | tail -3 | while read line; do
                echo "  $line"
            done
        }
        
        # Create a simple log monitor that would work
        echo "Security log analysis (simulated):"
        echo "This would normally analyze system logs like:"
        echo "  - /var/log/auth.log (authentication events)"
        echo "  - /var/log/secure (security events)"
        echo "  - /var/log/messages (system messages)"
        echo "  - /var/log/syslog (system log)"
        echo
        echo "Common security events to monitor:"
        echo "  - Failed login attempts"
        echo "  - Successful logins from unusual locations"
        echo "  - Privilege escalation (su/sudo usage)"
        echo "  - File permission changes"
        echo "  - Network connection anomalies"
        echo "  - Service start/stop events"
    }
    
    # Run security auditing demonstrations
    system_security_audit
    file_integrity_monitoring
    log_monitoring
}

security_auditing
```

## Exercises

### Exercise 1: Security Hardening Script

Create a comprehensive security hardening script:

```bash
#!/usr/bin/env bash

# Security Hardening Script
security_hardening() {
    # TODO: Implement security hardening that includes:
    # - User account security (disable unnecessary accounts)
    # - SSH hardening (disable root login, change default port)
    # - Firewall configuration
    # - File permission hardening
    # - Service hardening (disable unnecessary services)
    # - Log monitoring setup
    # - Automatic updates configuration
    # - Intrusion detection setup
    
    echo "Security hardening script not implemented yet"
}

# Test your implementation
```

### Exercise 2: Compliance Checker

Create a compliance checker for security standards:

```bash
#!/usr/bin/env bash

# Compliance Checker
compliance_checker() {
    local standard="$1"  # CIS, NIST, etc.
    
    # TODO: Implement compliance checking for:
    # - Password policies
    # - Account lockout policies
    # - File permissions
    # - Network configuration
    # - Logging and monitoring
    # - Access controls
    # - Generate compliance report
    
    echo "Compliance checker not implemented yet"
}
```

## Summary

In this chapter, you mastered:

- ✅ File permissions and ownership management
- ✅ Access control lists (ACLs) and special permissions
- ✅ Secure scripting practices and input validation
- ✅ Secrets management and encryption
- ✅ Security auditing and monitoring
- ✅ File integrity monitoring

Security is fundamental to system administration and script development. These skills help you create secure, robust systems that protect against common vulnerabilities and attacks.

**Next Steps:**
- Practice implementing security measures
- Conduct regular security audits
- Set up monitoring and alerting
- Move on to Chapter 14: Performance and Optimization

**Key Takeaways:**
- Always validate and sanitize input
- Follow the principle of least privilege
- Implement defense in depth
- Monitor and audit regularly
- Keep systems updated and patched
- Use encryption for sensitive data
