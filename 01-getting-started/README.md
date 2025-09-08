# Chapter 1: Getting Started with Bash

## What is Bash?

**Bash** (Bourne Again Shell) is a command-line interpreter and scripting language that serves as the default shell for most Linux distributions and macOS. It's a powerful tool for:

- System administration
- Automation tasks
- File manipulation
- Process control
- Text processing

## Why Learn Bash Scripting?

1. **Automation**: Automate repetitive tasks
2. **Efficiency**: Combine multiple commands into scripts
3. **System Administration**: Manage servers and systems
4. **Portability**: Scripts work across Unix-like systems
5. **Integration**: Easily integrate with other tools

## Environment Setup

### Check Your Bash Version

```bash
bash --version
echo $BASH_VERSION
```

### Find Your Shell

```bash
echo $SHELL
which bash
```

### Set Bash as Default (if needed)

```bash
chsh -s /bin/bash
```

## Basic Terminal Navigation

### Essential Commands

```bash
# Show current directory
pwd

# List files and directories
ls
ls -la  # detailed list with hidden files
ls -lh  # human-readable file sizes

# Change directory
cd /path/to/directory
cd ~     # go to home directory
cd -     # go to previous directory
cd ..    # go up one level

# Create directories
mkdir my_directory
mkdir -p path/to/nested/directory

# Create files
touch filename.txt
echo "Hello World" > hello.txt

# Display file contents
cat filename.txt
less filename.txt  # paginated view
head filename.txt  # first 10 lines
tail filename.txt  # last 10 lines
```

## Text Editors for Bash Scripts

### Nano (Beginner-friendly)
```bash
nano script.sh
```
- **Save**: Ctrl+O
- **Exit**: Ctrl+X

### Vim (Advanced)
```bash
vim script.sh
```
- **Insert mode**: i
- **Save and exit**: :wq
- **Exit without saving**: :q!

### VS Code (GUI)
```bash
code script.sh
```

## Your First Bash Script

### Creating a Script

```bash
# Create a new script file
touch hello_world.sh

# Make it executable
chmod +x hello_world.sh

# Edit the script
nano hello_world.sh
```

### Script Content

```bash
#!/bin/bash
# This is a comment
# File: hello_world.sh
# Purpose: My first bash script

echo "Hello, World!"
echo "Welcome to Bash scripting!"
echo "Today's date is: $(date)"
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
```

### Running the Script

```bash
# Method 1: Direct execution (if executable)
./hello_world.sh

# Method 2: Using bash command
bash hello_world.sh

# Method 3: Using source command
source hello_world.sh
```

## The Shebang Line

The first line `#!/bin/bash` is called a **shebang**. It tells the system which interpreter to use.

### Common Shebangs

```bash
#!/bin/bash          # Standard bash
#!/usr/bin/env bash  # Portable bash (recommended)
#!/bin/sh            # POSIX shell
#!/usr/bin/env python3  # Python script
```

## File Permissions

### Understanding Permissions

```bash
ls -l script.sh
# Output: -rw-r--r-- 1 user group 123 date script.sh
#         ^^^^^^^^^
#         permissions
```

Permission format: `[type][owner][group][others]`
- **r**: read (4)
- **w**: write (2) 
- **x**: execute (1)

### Setting Permissions

```bash
# Make executable for owner
chmod u+x script.sh

# Make executable for everyone
chmod +x script.sh

# Set specific permissions (rwxr-xr-x)
chmod 755 script.sh

# Remove execute permission
chmod -x script.sh
```

## Environment Variables

### Common Environment Variables

```bash
echo $HOME        # Home directory
echo $USER        # Current username
echo $PATH        # Executable search path
echo $PWD         # Current working directory
echo $SHELL       # Current shell
echo $HOSTNAME    # Computer name
```

### Setting Environment Variables

```bash
# Temporary (current session only)
export MY_VAR="Hello World"
echo $MY_VAR

# Permanent (add to ~/.bashrc or ~/.bash_profile)
echo 'export MY_VAR="Hello World"' >> ~/.bashrc
source ~/.bashrc
```

## Practice Exercises

### Exercise 1: Environment Exploration

Create a script called `system_info.sh` that displays:
- Current user
- Home directory
- Current working directory
- Bash version
- Current date and time

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash
# File: system_info.sh
# Purpose: Display system information

echo "=== System Information ==="
echo "Current User: $(whoami)"
echo "Home Directory: $HOME"
echo "Working Directory: $(pwd)"
echo "Bash Version: $BASH_VERSION"
echo "Current Date: $(date)"
echo "Hostname: $HOSTNAME"
echo "=========================="
```
</details>

### Exercise 2: File Operations

Create a script that:
1. Creates a directory called `test_dir`
2. Creates three files inside it: `file1.txt`, `file2.txt`, `file3.txt`
3. Lists the contents of the directory
4. Displays the permissions of the files

<details>
<summary>Solution</summary>

```bash
#!/usr/bin/env bash
# File: file_operations.sh

echo "Creating directory and files..."
mkdir -p test_dir
cd test_dir

touch file1.txt file2.txt file3.txt
echo "Files created successfully!"

echo "Directory contents:"
ls -la

echo "File permissions:"
ls -l *.txt
```
</details>

## Key Takeaways

1. Bash is a powerful shell and scripting language
2. Always start scripts with a shebang line
3. Make scripts executable with `chmod +x`
4. Use comments to document your code
5. Environment variables provide system information
6. Practice is essential for mastering bash

## Next Steps

Now that you understand the basics, move on to [Chapter 2: Basic Syntax](../02-basic-syntax/README.md) to learn about bash syntax and structure.

## Quick Reference

```bash
# Script template
#!/usr/bin/env bash
# Description of script

# Your code here

# Make executable
chmod +x script.sh

# Run script
./script.sh
```
