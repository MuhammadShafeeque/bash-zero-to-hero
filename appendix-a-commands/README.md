# Appendix A: Command Reference

This appendix provides a quick reference to the most commonly used bash commands and built-ins that are essential for scripting.

## File and Directory Operations

### File Listing and Information

```bash
# List files and directories
ls                    # List current directory
ls -la               # Long format, including hidden files
ls -lh               # Human-readable file sizes
ls -lt               # Sort by modification time
ls -lS               # Sort by file size
ls *.txt             # List only .txt files

# File information
file filename        # Determine file type
stat filename        # Detailed file information
du -h filename       # File/directory size
wc filename          # Word, line, character count
wc -l filename       # Line count only
```

### File Operations

```bash
# Create files and directories
touch filename       # Create empty file
mkdir dirname        # Create directory
mkdir -p path/to/dir # Create nested directories

# Copy, move, delete
cp source dest       # Copy file
cp -r source dest    # Copy directory recursively
mv oldname newname   # Move/rename file
rm filename          # Delete file
rm -r dirname        # Delete directory recursively
rm -f filename       # Force delete (no prompts)

# Links
ln -s target link    # Create symbolic link
ln target link       # Create hard link
```

### File Content Operations

```bash
# View file contents
cat filename         # Display entire file
less filename        # Paginated view
head filename        # First 10 lines
head -n 5 filename   # First 5 lines
tail filename        # Last 10 lines
tail -f filename     # Follow file (live updates)

# Edit files
nano filename        # Simple text editor
vim filename         # Advanced text editor
```

## Text Processing

### Search and Filter

```bash
# Find text in files
grep pattern file    # Search for pattern
grep -i pattern file # Case-insensitive search
grep -r pattern dir  # Recursive search
grep -n pattern file # Show line numbers
grep -v pattern file # Invert match (exclude pattern)

# Find files
find /path -name "*.txt"           # Find by filename
find /path -type f                 # Find files only
find /path -type d                 # Find directories only
find /path -size +1M               # Find files larger than 1MB
find /path -mtime -7               # Modified in last 7 days
find /path -exec command {} \;     # Execute command on found files
```

### Text Manipulation

```bash
# Sort and unique
sort file            # Sort lines
sort -n file         # Numeric sort
sort -r file         # Reverse sort
uniq file            # Remove duplicate lines
sort file | uniq     # Sort and remove duplicates

# Cut and paste
cut -d',' -f1 file   # Extract first field (CSV)
cut -c1-10 file      # Extract characters 1-10
paste file1 file2    # Merge files side by side

# Stream editing
sed 's/old/new/g' file         # Replace all occurrences
sed '/pattern/d' file          # Delete lines matching pattern
sed -n '1,10p' file            # Print lines 1-10
awk '{print $1}' file          # Print first field
awk -F',' '{print $2}' file    # Use comma as field separator
```

## Process Management

### Process Information

```bash
# List processes
ps                   # Current user processes
ps aux               # All processes
ps -ef               # All processes (different format)
top                  # Real-time process monitor
htop                 # Enhanced process monitor (if available)

# Process tree
pstree               # Show process tree
pgrep pattern        # Find process IDs by name
pidof program        # Get PID of program
```

### Process Control

```bash
# Background and foreground
command &            # Run in background
jobs                 # List background jobs
fg %1                # Bring job 1 to foreground
bg %1                # Send job 1 to background
nohup command &      # Run immune to hangup signal

# Kill processes
kill PID             # Terminate process
kill -9 PID          # Force kill process
killall program      # Kill all instances of program
pkill pattern        # Kill processes matching pattern
```

## System Information

### System Status

```bash
# System information
uname -a             # All system information
hostname             # Computer name
whoami               # Current username
id                   # User and group IDs
uptime               # System uptime and load
date                 # Current date and time
cal                  # Calendar

# Resource usage
df -h                # Disk usage
free -h              # Memory usage (Linux)
du -h directory      # Directory size
lscpu                # CPU information (Linux)
lsblk                # List block devices (Linux)
```

### Network Information

```bash
# Network status
ping host            # Test connectivity
wget url             # Download file
curl url             # Transfer data from server
netstat -tuln        # Show listening ports
ss -tuln             # Modern replacement for netstat
ip addr              # Show IP addresses (Linux)
ifconfig             # Network interface configuration
```

## File Permissions and Ownership

### Permission Commands

```bash
# Change permissions
chmod 755 file       # Set specific permissions
chmod +x file        # Add execute permission
chmod -w file        # Remove write permission
chmod u+r,g+w file   # Add read for user, write for group

# Change ownership
chown user file      # Change owner
chown user:group file # Change owner and group
chgrp group file     # Change group only

# View permissions
ls -l file           # Show detailed permissions
stat file            # Detailed file information
```

### Permission Values

```bash
# Numeric permissions
4 = read (r)
2 = write (w)
1 = execute (x)

# Common combinations
755 = rwxr-xr-x      # Owner: rwx, Group: r-x, Others: r-x
644 = rw-r--r--      # Owner: rw-, Group: r--, Others: r--
600 = rw-------      # Owner: rw-, Group: ---, Others: ---
```

## Archive and Compression

### Tar Archives

```bash
# Create archives
tar -czf archive.tar.gz files    # Create gzipped tar
tar -cjf archive.tar.bz2 files   # Create bzip2 tar
tar -cf archive.tar files        # Create uncompressed tar

# Extract archives
tar -xzf archive.tar.gz          # Extract gzipped tar
tar -xjf archive.tar.bz2         # Extract bzip2 tar
tar -xf archive.tar              # Extract uncompressed tar

# List archive contents
tar -tzf archive.tar.gz          # List gzipped tar contents
tar -tf archive.tar              # List tar contents
```

### Compression

```bash
# Compress files
gzip file            # Compress with gzip
bzip2 file           # Compress with bzip2
zip archive.zip files # Create zip archive

# Decompress files
gunzip file.gz       # Decompress gzip
bunzip2 file.bz2     # Decompress bzip2
unzip archive.zip    # Extract zip archive
```

## Input/Output Redirection

### Redirection Operators

```bash
# Output redirection
command > file       # Redirect stdout to file (overwrite)
command >> file      # Redirect stdout to file (append)
command 2> file      # Redirect stderr to file
command &> file      # Redirect both stdout and stderr
command > /dev/null  # Discard output

# Input redirection
command < file       # Use file as input
command << EOF       # Here document
text content
EOF
```

### Pipes

```bash
# Pipe operations
command1 | command2  # Pipe output of cmd1 to cmd2
command | tee file   # Write to file and stdout
command | grep pattern # Filter output
command | sort | uniq # Chain multiple commands
```

## Environment and Variables

### Environment Variables

```bash
# View variables
env                  # All environment variables
echo $VAR            # Display variable value
printenv VAR         # Display variable value

# Set variables
export VAR=value     # Set and export variable
VAR=value            # Set local variable
unset VAR            # Remove variable

# Common variables
$HOME                # Home directory
$PATH                # Executable search path
$USER                # Current username
$PWD                 # Current directory
$SHELL               # Current shell
```

## Job Control

### Background Jobs

```bash
# Job control
Ctrl+Z               # Suspend current job
jobs                 # List jobs
bg                   # Resume job in background
fg                   # Resume job in foreground
disown               # Remove job from job table

# Job references
%1                   # Job number 1
%%                   # Current job
%+                   # Current job
%-                   # Previous job
```

## Bash Built-ins

### Control Structures

```bash
# Conditionals
if [[ condition ]]; then
    commands
elif [[ condition ]]; then
    commands
else
    commands
fi

# Loops
for var in list; do
    commands
done

while [[ condition ]]; do
    commands
done

until [[ condition ]]; do
    commands
done

# Case statement
case $var in
    pattern1)
        commands
        ;;
    pattern2)
        commands
        ;;
    *)
        commands
        ;;
esac
```

### Functions

```bash
# Function definition
function_name() {
    local var="$1"
    echo "result"
    return 0
}

# Function call
result=$(function_name "argument")
function_name "argument"
```

## String Operations

### String Manipulation

```bash
# String length
${#string}

# Substring
${string:position}      # From position to end
${string:position:length} # Substring of length

# Pattern replacement
${string/pattern/replacement}  # Replace first match
${string//pattern/replacement} # Replace all matches

# Pattern removal
${string#pattern}       # Remove shortest match from beginning
${string##pattern}      # Remove longest match from beginning
${string%pattern}       # Remove shortest match from end
${string%%pattern}      # Remove longest match from end

# Case conversion
${string^^}             # Convert to uppercase
${string,,}             # Convert to lowercase
```

### Parameter Expansion

```bash
# Default values
${var:-default}         # Use default if var is unset
${var:=default}         # Set var to default if unset
${var:+alternate}       # Use alternate if var is set
${var:?error}           # Error if var is unset
```

## Test Conditions

### File Tests

```bash
[[ -f file ]]           # File exists and is regular file
[[ -d directory ]]      # Directory exists
[[ -e path ]]           # Path exists
[[ -r file ]]           # File is readable
[[ -w file ]]           # File is writable
[[ -x file ]]           # File is executable
[[ -s file ]]           # File exists and is not empty
[[ -L file ]]           # File is symbolic link
```

### String Tests

```bash
[[ -z string ]]         # String is empty
[[ -n string ]]         # String is not empty
[[ string1 == string2 ]] # Strings are equal
[[ string1 != string2 ]] # Strings are not equal
[[ string1 < string2 ]]  # String1 is less than string2
[[ string =~ pattern ]]  # String matches regex pattern
```

### Numeric Tests

```bash
[[ num1 -eq num2 ]]     # Numbers are equal
[[ num1 -ne num2 ]]     # Numbers are not equal
[[ num1 -lt num2 ]]     # num1 is less than num2
[[ num1 -le num2 ]]     # num1 is less than or equal to num2
[[ num1 -gt num2 ]]     # num1 is greater than num2
[[ num1 -ge num2 ]]     # num1 is greater than or equal to num2
```

## Quick Reference Cards

### Essential Commands

| Command | Description | Example |
|---------|-------------|---------|
| `ls` | List files | `ls -la` |
| `cd` | Change directory | `cd /home/user` |
| `pwd` | Print working directory | `pwd` |
| `cp` | Copy files | `cp file1 file2` |
| `mv` | Move/rename files | `mv old new` |
| `rm` | Remove files | `rm file` |
| `mkdir` | Create directory | `mkdir dirname` |
| `grep` | Search text | `grep pattern file` |
| `find` | Find files | `find . -name "*.txt"` |
| `ps` | List processes | `ps aux` |

### File Permissions

| Symbol | Permission | Numeric |
|--------|------------|---------|
| `r` | Read | 4 |
| `w` | Write | 2 |
| `x` | Execute | 1 |
| `rwx` | Full access | 7 |
| `r-x` | Read and execute | 5 |
| `r--` | Read only | 4 |

### Redirection

| Operator | Description |
|----------|-------------|
| `>` | Redirect stdout |
| `>>` | Append stdout |
| `2>` | Redirect stderr |
| `&>` | Redirect both |
| `<` | Redirect stdin |
| `|` | Pipe |
| `\|&` | Pipe stderr |

This reference guide covers the most commonly used commands and concepts in bash scripting. Keep it handy for quick lookups while writing scripts!
