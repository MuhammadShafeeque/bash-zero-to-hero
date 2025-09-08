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
