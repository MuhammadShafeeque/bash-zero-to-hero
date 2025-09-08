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
df -h | grep -E '^/dev/' 2>/dev/null || df -h | grep -E '^/'

echo "-------------------------------------"

# Memory information (if available)
if command -v free >/dev/null 2>&1; then
    echo "MEMORY USAGE:"
    free -h
elif command -v vm_stat >/dev/null 2>&1; then
    echo "MEMORY USAGE (macOS):"
    vm_stat | head -5
fi
