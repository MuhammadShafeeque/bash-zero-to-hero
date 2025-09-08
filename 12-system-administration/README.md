# Chapter 12: System Administration

System administration is one of bash's primary use cases. This chapter covers essential system administration tasks, process management, user administration, and system monitoring.

## What You'll Learn

- Process management and job control
- User and group administration
- System monitoring and resource management
- Service management and automation
- Network administration basics
- System maintenance and cleanup
- Backup and restore operations

## Process Management

### Understanding Processes

```bash
#!/usr/bin/env bash

# Process management fundamentals
process_management_demo() {
    echo "=== Process Management Fundamentals ==="
    
    # Display current processes
    echo "1. Current user processes:"
    ps -u "$(whoami)" -o pid,ppid,cmd --no-headers | head -5
    
    # Process hierarchy
    echo -e "\n2. Process tree (current user):"
    pstree -p "$(whoami)" 2>/dev/null || echo "pstree not available, using ps"
    
    # System load and resource usage
    echo -e "\n3. System load:"
    uptime
    
    # Memory usage
    echo -e "\n4. Memory usage:"
    free -h 2>/dev/null || vm_stat | head -5
    
    # Disk usage
    echo -e "\n5. Disk usage:"
    df -h | head -5
    
    # Running processes by CPU usage
    echo -e "\n6. Top CPU consumers:"
    ps aux --sort=-%cpu | head -6 | awk 'NR==1 || NR<=6'
    
    # Running processes by memory usage
    echo -e "\n7. Top memory consumers:"
    ps aux --sort=-%mem | head -6 | awk 'NR==1 || NR<=6'
}

# Process control functions
process_control() {
    echo -e "\n=== Process Control Functions ==="
    
    # Function to find processes by name
    find_process() {
        local process_name="$1"
        echo "Searching for processes matching: $process_name"
        pgrep -fl "$process_name" || echo "No processes found matching '$process_name'"
    }
    
    # Function to check if process is running
    is_process_running() {
        local process_name="$1"
        if pgrep "$process_name" >/dev/null; then
            echo "✓ Process '$process_name' is running"
            return 0
        else
            echo "✗ Process '$process_name' is not running"
            return 1
        fi
    }
    
    # Function to kill process gracefully
    kill_process_graceful() {
        local process_name="$1"
        local timeout="${2:-10}"
        
        echo "Attempting to kill process: $process_name"
        
        # Find the process
        local pids
        pids=$(pgrep "$process_name")
        
        if [[ -z "$pids" ]]; then
            echo "No process found matching: $process_name"
            return 1
        fi
        
        echo "Found PIDs: $pids"
        
        # Send TERM signal
        echo "Sending TERM signal..."
        kill -TERM $pids
        
        # Wait for graceful shutdown
        local count=0
        while [[ $count -lt $timeout ]]; do
            if ! pgrep "$process_name" >/dev/null; then
                echo "Process terminated gracefully"
                return 0
            fi
            sleep 1
            ((count++))
        done
        
        # Force kill if still running
        echo "Process still running, sending KILL signal..."
        kill -KILL $pids 2>/dev/null
        
        if pgrep "$process_name" >/dev/null; then
            echo "Failed to kill process"
            return 1
        else
            echo "Process forcefully terminated"
            return 0
        fi
    }
    
    # Process monitoring function
    monitor_process() {
        local process_name="$1"
        local interval="${2:-5}"
        local max_iterations="${3:-12}"  # Default: 1 minute
        
        echo "Monitoring process '$process_name' every ${interval}s (max ${max_iterations} iterations)"
        
        for ((i=1; i<=max_iterations; i++)); do
            echo -n "[$i] $(date +'%H:%M:%S') - "
            
            if pgrep "$process_name" >/dev/null; then
                local cpu_usage mem_usage
                cpu_usage=$(ps -C "$process_name" -o %cpu --no-headers | awk '{sum+=$1} END {print sum}')
                mem_usage=$(ps -C "$process_name" -o %mem --no-headers | awk '{sum+=$1} END {print sum}')
                echo "Running (CPU: ${cpu_usage}%, MEM: ${mem_usage}%)"
            else
                echo "Not running"
            fi
            
            sleep "$interval"
        done
    }
    
    # Example usage of process control functions
    echo "Testing process control functions:"
    
    # Look for common processes
    find_process "bash"
    is_process_running "bash"
    
    # Create a background process for testing
    echo -e "\nStarting test background process..."
    sleep 30 &
    local test_pid=$!
    echo "Started test process with PID: $test_pid"
    
    # Monitor it briefly
    echo "Monitoring test process for 10 seconds..."
    timeout 10s bash -c 'while kill -0 '$test_pid' 2>/dev/null; do echo "Process running..."; sleep 2; done' || true
    
    # Clean up test process
    kill $test_pid 2>/dev/null || true
    echo "Test process cleaned up"
}

# Job control demonstration
job_control_demo() {
    echo -e "\n=== Job Control Demonstration ==="
    
    # Background jobs
    echo "1. Starting background jobs..."
    
    # Start some background processes
    sleep 5 &
    echo "Started background job 1: PID $!"
    
    sleep 7 &
    echo "Started background job 2: PID $!"
    
    # List jobs
    echo -e "\n2. Current jobs:"
    jobs
    
    # Job control commands demonstration
    echo -e "\n3. Job control commands:"
    echo "   jobs     - List active jobs"
    echo "   fg %1    - Bring job 1 to foreground"
    echo "   bg %1    - Send job 1 to background"
    echo "   kill %1  - Kill job 1"
    echo "   disown %1 - Remove job from shell's job table"
    
    # Wait for background jobs to complete
    echo -e "\n4. Waiting for background jobs to complete..."
    wait
    echo "All background jobs completed"
}

# Run process management demos
process_management_demo
process_control
job_control_demo
```

### Advanced Process Management

```bash
#!/usr/bin/env bash

# Advanced process management techniques
advanced_process_management() {
    echo "=== Advanced Process Management ==="
    
    # Process creation and management
    process_manager() {
        local command="$1"
        local name="$2"
        local log_file="${3:-/tmp/${name}.log}"
        local pid_file="${4:-/tmp/${name}.pid}"
        
        start_process() {
            if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
                echo "Process '$name' is already running (PID: $(cat "$pid_file"))"
                return 1
            fi
            
            echo "Starting process '$name'..."
            nohup $command > "$log_file" 2>&1 &
            local pid=$!
            echo $pid > "$pid_file"
            echo "Process '$name' started with PID: $pid"
        }
        
        stop_process() {
            if [[ ! -f "$pid_file" ]]; then
                echo "PID file not found for process '$name'"
                return 1
            fi
            
            local pid
            pid=$(cat "$pid_file")
            
            if ! kill -0 "$pid" 2>/dev/null; then
                echo "Process '$name' (PID: $pid) is not running"
                rm -f "$pid_file"
                return 1
            fi
            
            echo "Stopping process '$name' (PID: $pid)..."
            kill -TERM "$pid"
            
            # Wait for graceful shutdown
            local timeout=10
            while [[ $timeout -gt 0 ]] && kill -0 "$pid" 2>/dev/null; do
                sleep 1
                ((timeout--))
            done
            
            if kill -0 "$pid" 2>/dev/null; then
                echo "Force killing process '$name'..."
                kill -KILL "$pid"
            fi
            
            rm -f "$pid_file"
            echo "Process '$name' stopped"
        }
        
        status_process() {
            if [[ ! -f "$pid_file" ]]; then
                echo "Process '$name': Not running (no PID file)"
                return 1
            fi
            
            local pid
            pid=$(cat "$pid_file")
            
            if kill -0 "$pid" 2>/dev/null; then
                local cpu_usage mem_usage runtime
                cpu_usage=$(ps -p "$pid" -o %cpu --no-headers 2>/dev/null || echo "N/A")
                mem_usage=$(ps -p "$pid" -o %mem --no-headers 2>/dev/null || echo "N/A")
                runtime=$(ps -p "$pid" -o etime --no-headers 2>/dev/null || echo "N/A")
                
                echo "Process '$name': Running"
                echo "  PID: $pid"
                echo "  CPU: ${cpu_usage}%"
                echo "  Memory: ${mem_usage}%"
                echo "  Runtime: $runtime"
                echo "  Log file: $log_file"
            else
                echo "Process '$name': Not running (stale PID file)"
                rm -f "$pid_file"
                return 1
            fi
        }
        
        restart_process() {
            echo "Restarting process '$name'..."
            stop_process
            sleep 2
            start_process
        }
        
        # Command dispatcher
        case "${5:-status}" in
            start)   start_process ;;
            stop)    stop_process ;;
            status)  status_process ;;
            restart) restart_process ;;
            *)       echo "Usage: process_manager <command> <name> [log_file] [pid_file] {start|stop|status|restart}" ;;
        esac
    }
    
    # Resource monitoring and alerts
    resource_monitor() {
        local cpu_threshold="${1:-80}"
        local mem_threshold="${2:-80}"
        local disk_threshold="${3:-90}"
        
        echo "Resource monitoring (CPU: ${cpu_threshold}%, MEM: ${mem_threshold}%, DISK: ${disk_threshold}%)"
        
        # CPU monitoring
        local cpu_usage
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' 2>/dev/null || \
                   sar 1 1 | tail -1 | awk '{print 100-$8}' 2>/dev/null || \
                   echo "0")
        
        cpu_usage=${cpu_usage%.*}  # Remove decimal part
        
        if [[ $cpu_usage -gt $cpu_threshold ]]; then
            echo "⚠️  HIGH CPU USAGE: ${cpu_usage}% (threshold: ${cpu_threshold}%)"
        else
            echo "✓ CPU usage: ${cpu_usage}%"
        fi
        
        # Memory monitoring
        if command -v free >/dev/null; then
            local mem_usage
            mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
            
            if [[ $mem_usage -gt $mem_threshold ]]; then
                echo "⚠️  HIGH MEMORY USAGE: ${mem_usage}% (threshold: ${mem_threshold}%)"
            else
                echo "✓ Memory usage: ${mem_usage}%"
            fi
        fi
        
        # Disk monitoring
        local disk_usage
        disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        
        if [[ $disk_usage -gt $disk_threshold ]]; then
            echo "⚠️  HIGH DISK USAGE: ${disk_usage}% (threshold: ${disk_threshold}%)"
        else
            echo "✓ Disk usage: ${disk_usage}%"
        fi
        
        # Top processes
        echo -e "\nTop resource consumers:"
        echo "CPU:"
        ps aux --sort=-%cpu | head -4 | tail -3 | awk '{printf "  %-10s %s%% %s\n", $1, $3, $11}'
        
        echo "Memory:"
        ps aux --sort=-%mem | head -4 | tail -3 | awk '{printf "  %-10s %s%% %s\n", $1, $4, $11}'
    }
    
    # Demonstrate advanced process management
    echo "Demonstrating process manager:"
    
    # Create a simple test script
    cat > /tmp/test_daemon.sh << 'EOF'
#!/bin/bash
while true; do
    echo "$(date): Test daemon is running" >> /tmp/test_daemon_output.log
    sleep 5
done
EOF
    chmod +x /tmp/test_daemon.sh
    
    # Test process management
    echo -e "\n1. Starting test process:"
    process_manager "/tmp/test_daemon.sh" "test_daemon" "/tmp/test_daemon.log" "/tmp/test_daemon.pid" "start"
    
    echo -e "\n2. Checking process status:"
    process_manager "/tmp/test_daemon.sh" "test_daemon" "/tmp/test_daemon.log" "/tmp/test_daemon.pid" "status"
    
    echo -e "\n3. Stopping test process:"
    process_manager "/tmp/test_daemon.sh" "test_daemon" "/tmp/test_daemon.log" "/tmp/test_daemon.pid" "stop"
    
    # Resource monitoring
    echo -e "\n4. Resource monitoring:"
    resource_monitor 70 70 80
    
    # Clean up
    rm -f /tmp/test_daemon.sh /tmp/test_daemon.log /tmp/test_daemon.pid /tmp/test_daemon_output.log
}

advanced_process_management
```

## User and Group Administration

### User Management

```bash
#!/usr/bin/env bash

# User and group administration
user_administration() {
    echo "=== User and Group Administration ==="
    
    # User information functions
    get_user_info() {
        local username="${1:-$(whoami)}"
        
        echo "User information for: $username"
        
        # Basic user info
        if id "$username" >/dev/null 2>&1; then
            echo "✓ User exists"
            echo "  UID: $(id -u "$username")"
            echo "  GID: $(id -g "$username")"
            echo "  Groups: $(groups "$username" | cut -d: -f2)"
            
            # Home directory
            local home_dir
            home_dir=$(getent passwd "$username" | cut -d: -f6)
            echo "  Home directory: $home_dir"
            
            # Shell
            local shell
            shell=$(getent passwd "$username" | cut -d: -f7)
            echo "  Shell: $shell"
            
            # Last login
            if command -v last >/dev/null; then
                local last_login
                last_login=$(last -n 1 "$username" 2>/dev/null | head -1 | awk '{print $3, $4, $5, $6}')
                echo "  Last login: ${last_login:-Never}"
            fi
        else
            echo "✗ User does not exist"
            return 1
        fi
    }
    
    # List users with specific criteria
    list_users() {
        local min_uid="${1:-1000}"
        local max_uid="${2:-60000}"
        
        echo "Regular users (UID $min_uid-$max_uid):"
        
        while IFS=: read -r username password uid gid gecos home shell; do
            if [[ $uid -ge $min_uid && $uid -le $max_uid ]]; then
                printf "  %-15s UID:%-6s Home:%-20s Shell:%s\n" \
                       "$username" "$uid" "$home" "$shell"
            fi
        done < /etc/passwd
    }
    
    # Group information
    get_group_info() {
        local groupname="$1"
        
        if [[ -z "$groupname" ]]; then
            echo "Usage: get_group_info <groupname>"
            return 1
        fi
        
        echo "Group information for: $groupname"
        
        if getent group "$groupname" >/dev/null; then
            local gid members
            gid=$(getent group "$groupname" | cut -d: -f3)
            members=$(getent group "$groupname" | cut -d: -f4)
            
            echo "✓ Group exists"
            echo "  GID: $gid"
            echo "  Members: ${members:-None}"
            
            # Users with this as primary group
            echo "  Primary group users:"
            while IFS=: read -r username password uid primary_gid gecos home shell; do
                if [[ $primary_gid -eq $gid ]]; then
                    echo "    - $username"
                fi
            done < /etc/passwd
        else
            echo "✗ Group does not exist"
            return 1
        fi
    }
    
    # Password policy check
    check_password_policy() {
        local username="$1"
        
        if [[ -z "$username" ]]; then
            echo "Usage: check_password_policy <username>"
            return 1
        fi
        
        echo "Password policy for user: $username"
        
        # Check if user exists
        if ! id "$username" >/dev/null 2>&1; then
            echo "✗ User does not exist"
            return 1
        fi
        
        # Password aging information (if available)
        if command -v chage >/dev/null; then
            echo "Password aging information:"
            chage -l "$username" 2>/dev/null | while read line; do
                echo "  $line"
            done
        fi
        
        # Account lock status
        if command -v passwd >/dev/null; then
            local status
            status=$(passwd -S "$username" 2>/dev/null | awk '{print $2}')
            case "$status" in
                "P") echo "✓ Account status: Active (password set)" ;;
                "L") echo "⚠️  Account status: Locked" ;;
                "NP") echo "⚠️  Account status: No password set" ;;
                *) echo "? Account status: Unknown ($status)" ;;
            esac
        fi
    }
    
    # sudo access check
    check_sudo_access() {
        local username="${1:-$(whoami)}"
        
        echo "Checking sudo access for: $username"
        
        # Check if user is in sudo group
        if groups "$username" | grep -q sudo; then
            echo "✓ User is in sudo group"
        elif groups "$username" | grep -q wheel; then
            echo "✓ User is in wheel group"
        else
            echo "ℹ User is not in sudo/wheel group"
        fi
        
        # Check sudoers file (simplified check)
        if [[ -f /etc/sudoers ]]; then
            if sudo grep -q "^$username" /etc/sudoers 2>/dev/null; then
                echo "✓ User has explicit sudo entry"
            else
                echo "ℹ No explicit sudo entry found"
            fi
        fi
        
        # Test sudo access (safe check)
        if sudo -n true 2>/dev/null; then
            echo "✓ Current user has passwordless sudo"
        elif sudo -l >/dev/null 2>&1; then
            echo "✓ Current user has sudo access"
        else
            echo "ℹ Current user cannot use sudo"
        fi
    }
    
    # Demonstrate user administration functions
    echo "1. Current user information:"
    get_user_info
    
    echo -e "\n2. System users:"
    list_users | head -5
    
    echo -e "\n3. Common groups:"
    echo "Available groups:"
    cut -d: -f1 /etc/group | sort | head -10 | while read group; do
        echo "  - $group"
    done
    
    echo -e "\n4. Sudo access check:"
    check_sudo_access
}

user_administration
```

## System Monitoring and Resources

### System Resource Monitoring

```bash
#!/usr/bin/env bash

# Comprehensive system monitoring
system_monitoring() {
    echo "=== System Resource Monitoring ==="
    
    # System information collector
    collect_system_info() {
        echo "System Information Report"
        echo "========================"
        echo "Generated: $(date)"
        echo
        
        # Operating system
        echo "Operating System:"
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            echo "  Name: $NAME"
            echo "  Version: $VERSION"
        elif [[ -f /etc/redhat-release ]]; then
            echo "  $(cat /etc/redhat-release)"
        else
            echo "  $(uname -s) $(uname -r)"
        fi
        
        # Kernel information
        echo -e "\nKernel:"
        echo "  Version: $(uname -r)"
        echo "  Architecture: $(uname -m)"
        
        # Hostname and network
        echo -e "\nNetwork:"
        echo "  Hostname: $(hostname)"
        echo "  FQDN: $(hostname -f 2>/dev/null || hostname)"
        
        # Uptime
        echo -e "\nUptime:"
        echo "  $(uptime)"
        
        # CPU information
        echo -e "\nCPU Information:"
        if [[ -f /proc/cpuinfo ]]; then
            local cpu_model cpu_cores
            cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ *//')
            cpu_cores=$(grep -c "^processor" /proc/cpuinfo)
            echo "  Model: $cpu_model"
            echo "  Cores: $cpu_cores"
        fi
        
        # Memory information
        echo -e "\nMemory Information:"
        if [[ -f /proc/meminfo ]]; then
            local total_mem available_mem
            total_mem=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
            available_mem=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}' 2>/dev/null || 
                          grep "MemFree" /proc/meminfo | awk '{print $2}')
            
            echo "  Total: $((total_mem / 1024)) MB"
            echo "  Available: $((available_mem / 1024)) MB"
            echo "  Used: $(((total_mem - available_mem) / 1024)) MB"
        elif command -v free >/dev/null; then
            free -h | while read line; do
                echo "  $line"
            done
        fi
        
        # Disk information
        echo -e "\nDisk Usage:"
        df -h | grep -E "^/dev|^Filesystem" | while read line; do
            echo "  $line"
        done
        
        # Network interfaces
        echo -e "\nNetwork Interfaces:"
        if command -v ip >/dev/null; then
            ip addr show | grep -E "^[0-9]+:|inet " | while read line; do
                echo "  $line"
            done
        elif command -v ifconfig >/dev/null; then
            ifconfig | grep -E "^[a-z]|inet " | while read line; do
                echo "  $line"
            done
        fi
        
        # Load average
        echo -e "\nLoad Average:"
        echo "  $(cat /proc/loadavg 2>/dev/null || uptime | sed 's/.*load average: //')"
    }
    
    # Real-time monitoring function
    realtime_monitor() {
        local interval="${1:-5}"
        local iterations="${2:-12}"
        
        echo "Real-time monitoring (${interval}s intervals, ${iterations} iterations)"
        echo "========================================================"
        
        for ((i=1; i<=iterations; i++)); do
            echo -e "\n[$(date +'%H:%M:%S')] Iteration $i/$iterations"
            echo "----------------------------------------"
            
            # CPU usage
            if command -v top >/dev/null; then
                local cpu_usage
                cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' 2>/dev/null)
                echo "CPU Usage: ${cpu_usage:-N/A}%"
            fi
            
            # Memory usage
            if command -v free >/dev/null; then
                local mem_info
                mem_info=$(free | awk 'NR==2{printf "Memory: %.1f%% (%s/%s)", $3*100/$2, $3, $2}')
                echo "$mem_info"
            fi
            
            # Load average
            local load_avg
            load_avg=$(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}' || echo "N/A")
            echo "Load Average: $load_avg"
            
            # Disk I/O (if iostat available)
            if command -v iostat >/dev/null; then
                local disk_io
                disk_io=$(iostat -d 1 1 2>/dev/null | tail -1 | awk '{print "Read: " $3 " Write: " $4}')
                echo "Disk I/O: ${disk_io:-N/A}"
            fi
            
            # Network connections
            local connections
            connections=$(netstat -tn 2>/dev/null | grep ESTABLISHED | wc -l || echo "N/A")
            echo "Network Connections: $connections"
            
            # Top process by CPU
            if command -v ps >/dev/null; then
                local top_cpu_process
                top_cpu_process=$(ps aux --sort=-%cpu | head -2 | tail -1 | awk '{print $11 " (" $3 "%)"}')
                echo "Top CPU Process: $top_cpu_process"
            fi
            
            sleep "$interval"
        done
    }
    
    # Alert system for resource thresholds
    resource_alerting() {
        local cpu_threshold="${1:-80}"
        local mem_threshold="${2:-80}"
        local disk_threshold="${3:-90}"
        local load_threshold="${4:-2.0}"
        
        echo "Resource Alerting System"
        echo "Thresholds: CPU:${cpu_threshold}% MEM:${mem_threshold}% DISK:${disk_threshold}% LOAD:${load_threshold}"
        echo "================================="
        
        local alerts=0
        
        # CPU check
        if command -v top >/dev/null; then
            local cpu_usage
            cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' 2>/dev/null)
            cpu_usage=${cpu_usage%.*}  # Remove decimal
            
            if [[ -n "$cpu_usage" && $cpu_usage -gt $cpu_threshold ]]; then
                echo "🚨 ALERT: High CPU usage: ${cpu_usage}% (threshold: ${cpu_threshold}%)"
                ((alerts++))
            else
                echo "✓ CPU usage: ${cpu_usage:-N/A}%"
            fi
        fi
        
        # Memory check
        if command -v free >/dev/null; then
            local mem_usage
            mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
            
            if [[ $mem_usage -gt $mem_threshold ]]; then
                echo "🚨 ALERT: High memory usage: ${mem_usage}% (threshold: ${mem_threshold}%)"
                ((alerts++))
            else
                echo "✓ Memory usage: ${mem_usage}%"
            fi
        fi
        
        # Disk check
        local disk_usage
        disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        
        if [[ $disk_usage -gt $disk_threshold ]]; then
            echo "🚨 ALERT: High disk usage: ${disk_usage}% (threshold: ${disk_threshold}%)"
            ((alerts++))
        else
            echo "✓ Disk usage: ${disk_usage}%"
        fi
        
        # Load average check
        local load_avg
        load_avg=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}' || echo "0")
        
        if command -v bc >/dev/null && [[ $(echo "$load_avg > $load_threshold" | bc) -eq 1 ]]; then
            echo "🚨 ALERT: High load average: $load_avg (threshold: $load_threshold)"
            ((alerts++))
        else
            echo "✓ Load average: $load_avg"
        fi
        
        # Summary
        echo -e "\nAlert Summary: $alerts alerts triggered"
        
        if [[ $alerts -gt 0 ]]; then
            echo "Recommended actions:"
            echo "- Check running processes: ps aux --sort=-%cpu"
            echo "- Check disk usage: du -sh /*"
            echo "- Check system logs: journalctl -n 50"
            echo "- Consider restarting services or rebooting if necessary"
        fi
        
        return $alerts
    }
    
    # Performance statistics collector
    collect_performance_stats() {
        local duration="${1:-60}"  # seconds
        local interval="${2:-5}"   # seconds
        
        echo "Collecting performance statistics for ${duration}s (${interval}s intervals)"
        
        local stats_file="/tmp/perf_stats_$(date +%s).log"
        local iterations=$((duration / interval))
        
        echo "Timestamp,CPU%,Memory%,Load1min,DiskUsage%,NetworkConnections" > "$stats_file"
        
        for ((i=1; i<=iterations; i++)); do
            local timestamp cpu_usage mem_usage load_avg disk_usage connections
            
            timestamp=$(date +'%Y-%m-%d %H:%M:%S')
            
            # CPU usage
            cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' 2>/dev/null || echo "0")
            cpu_usage=${cpu_usage%.*}
            
            # Memory usage
            mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}' 2>/dev/null || echo "0")
            
            # Load average
            load_avg=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}' || echo "0")
            
            # Disk usage
            disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//' 2>/dev/null || echo "0")
            
            # Network connections
            connections=$(netstat -tn 2>/dev/null | grep ESTABLISHED | wc -l || echo "0")
            
            echo "$timestamp,$cpu_usage,$mem_usage,$load_avg,$disk_usage,$connections" >> "$stats_file"
            
            echo "[$i/$iterations] Data point collected..."
            sleep "$interval"
        done
        
        echo "Performance statistics saved to: $stats_file"
        echo -e "\nSummary:"
        echo "Average CPU usage: $(awk -F, 'NR>1 {sum+=$2; count++} END {print sum/count "%"}' "$stats_file")"
        echo "Average memory usage: $(awk -F, 'NR>1 {sum+=$3; count++} END {print sum/count "%"}' "$stats_file")"
        echo "Average load: $(awk -F, 'NR>1 {sum+=$4; count++} END {print sum/count}' "$stats_file")"
        
        # Clean up stats file
        rm -f "$stats_file"
    }
    
    # Run monitoring demonstrations
    echo "1. System Information:"
    collect_system_info | head -30
    
    echo -e "\n2. Resource Alerting:"
    resource_alerting 70 70 80 1.5
    
    echo -e "\n3. Real-time monitoring (10 seconds):"
    realtime_monitor 2 5
}

system_monitoring
```

## Service Management

### Service Control and Automation

```bash
#!/usr/bin/env bash

# Service management and automation
service_management() {
    echo "=== Service Management and Automation ==="
    
    # Service status checker
    check_service_status() {
        local service_name="$1"
        
        if [[ -z "$service_name" ]]; then
            echo "Usage: check_service_status <service_name>"
            return 1
        fi
        
        echo "Checking service: $service_name"
        
        # Try systemctl first (systemd)
        if command -v systemctl >/dev/null; then
            if systemctl is-active "$service_name" >/dev/null 2>&1; then
                echo "✓ Service is active (systemd)"
                systemctl status "$service_name" --no-pager -l | head -5
                return 0
            else
                echo "✗ Service is not active (systemd)"
                return 1
            fi
        # Try service command (SysV)
        elif command -v service >/dev/null; then
            if service "$service_name" status >/dev/null 2>&1; then
                echo "✓ Service is running (SysV)"
                service "$service_name" status | head -3
                return 0
            else
                echo "✗ Service is not running (SysV)"
                return 1
            fi
        # Check if it's a process
        elif pgrep "$service_name" >/dev/null; then
            echo "✓ Process is running"
            pgrep -l "$service_name"
            return 0
        else
            echo "✗ Service/process not found"
            return 1
        fi
    }
    
    # Service dependency checker
    check_service_dependencies() {
        local service_name="$1"
        
        echo "Service dependency analysis for: $service_name"
        
        if command -v systemctl >/dev/null; then
            echo "Dependencies (systemd):"
            
            # Required by
            local required_by
            required_by=$(systemctl list-dependencies --reverse "$service_name" 2>/dev/null | tail -n +2)
            if [[ -n "$required_by" ]]; then
                echo "  Required by:"
                echo "$required_by" | head -5 | while read line; do
                    echo "    $line"
                done
            fi
            
            # Requires
            local requires
            requires=$(systemctl list-dependencies "$service_name" 2>/dev/null | tail -n +2)
            if [[ -n "$requires" ]]; then
                echo "  Requires:"
                echo "$requires" | head -5 | while read line; do
                    echo "    $line"
                done
            fi
        else
            echo "Service dependency checking requires systemd"
        fi
    }
    
    # Service health monitor
    monitor_service_health() {
        local service_name="$1"
        local check_interval="${2:-30}"  # seconds
        local max_checks="${3:-10}"      # number of checks
        
        echo "Monitoring service health: $service_name"
        echo "Check interval: ${check_interval}s, Max checks: $max_checks"
        
        local failures=0
        local consecutive_failures=0
        
        for ((i=1; i<=max_checks; i++)); do
            echo -n "[$(date +'%H:%M:%S')] Check $i/$max_checks: "
            
            if check_service_status "$service_name" >/dev/null 2>&1; then
                echo "✓ Healthy"
                consecutive_failures=0
            else
                echo "✗ Failed"
                ((failures++))
                ((consecutive_failures++))
                
                # Alert on consecutive failures
                if [[ $consecutive_failures -ge 3 ]]; then
                    echo "🚨 ALERT: Service has failed $consecutive_failures consecutive checks"
                fi
            fi
            
            sleep "$check_interval"
        done
        
        echo -e "\nHealth monitoring summary:"
        echo "Total checks: $max_checks"
        echo "Failures: $failures"
        echo "Success rate: $(( (max_checks - failures) * 100 / max_checks ))%"
        
        if [[ $failures -gt $((max_checks / 2)) ]]; then
            echo "⚠️  Service appears to be unstable"
            return 1
        else
            echo "✓ Service appears to be stable"
            return 0
        fi
    }
    
    # Service startup script generator
    generate_service_script() {
        local service_name="$1"
        local command="$2"
        local user="${3:-$(whoami)}"
        local description="${4:-Custom service}"
        
        if [[ -z "$service_name" || -z "$command" ]]; then
            echo "Usage: generate_service_script <name> <command> [user] [description]"
            return 1
        fi
        
        local script_file="/tmp/${service_name}.service"
        
        echo "Generating systemd service file: $script_file"
        
        cat > "$script_file" << EOF
[Unit]
Description=$description
After=network.target

[Service]
Type=simple
User=$user
ExecStart=$command
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
        
        echo "Service file generated:"
        cat "$script_file"
        
        echo -e "\nTo install this service:"
        echo "  sudo cp $script_file /etc/systemd/system/"
        echo "  sudo systemctl daemon-reload"
        echo "  sudo systemctl enable $service_name"
        echo "  sudo systemctl start $service_name"
        
        # Also generate SysV-style init script
        local init_script="/tmp/${service_name}_init"
        
        cat > "$init_script" << EOF
#!/bin/bash
# $service_name - $description
# chkconfig: 35 80 20
# description: $description

USER="$user"
DAEMON="$service_name"
ROOT_DIR="/var/lib/\$DAEMON"

SERVER="\$ROOT_DIR/\$DAEMON"
LOCK_FILE="/var/lock/subsys/\$DAEMON"

start() {
    if [ -f \$LOCK_FILE ]; then
        echo "\$DAEMON is locked."
        return 1
    fi
    
    echo -n "Starting \$DAEMON: "
    runuser -l "\$USER" -c "\$SERVER" && echo " OK" || echo " FAILED"
    
    if [ \$? -eq 0 ]; then
        touch \$LOCK_FILE
    fi
}

stop() {
    echo -n "Shutting down \$DAEMON: "
    pid=\$(ps -aefw | grep "\$DAEMON" | grep -v " grep " | awk '{print \$2}')
    kill -9 \$pid > /dev/null 2>&1
    [ \$? -eq 0 ] && echo " OK" || echo " FAILED"
    rm -f \$LOCK_FILE
}

restart() {
    stop
    start
}

status() {
    if [ -f \$LOCK_FILE ]; then
        echo "\$DAEMON is running."
    else
        echo "\$DAEMON is stopped."
    fi
}

case "\$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        restart
        ;;
    *)
        echo "Usage: {\$0 {start|stop|status|restart}"
        exit 1
        ;;
esac

exit \$?
EOF
        
        chmod +x "$init_script"
        echo -e "\nSysV init script also generated: $init_script"
        
        # Clean up
        rm -f "$script_file" "$init_script"
    }
    
    # Demonstrate service management
    echo "1. Common service status checks:"
    
    # Check some common services
    for service in sshd ssh httpd apache2 nginx mysql postgresql; do
        if check_service_status "$service" >/dev/null 2>&1; then
            echo "✓ $service is running"
            break
        fi
    done
    
    echo -e "\n2. Service script generation example:"
    generate_service_script "myapp" "/usr/local/bin/myapp --daemon" "myuser" "My Application Service"
    
    echo -e "\n3. Service monitoring simulation:"
    echo "Simulating service monitoring for 'bash' process..."
    monitor_service_health "bash" 2 3
}

service_management
```

## Network Administration

### Network Diagnostics and Management

```bash
#!/usr/bin/env bash

# Network administration and diagnostics
network_administration() {
    echo "=== Network Administration and Diagnostics ==="
    
    # Network interface information
    get_network_info() {
        echo "Network Interface Information"
        echo "============================="
        
        # Using ip command (preferred on modern systems)
        if command -v ip >/dev/null; then
            echo "Network interfaces (ip command):"
            ip addr show | while read line; do
                if [[ $line =~ ^[0-9]+: ]]; then
                    echo "  Interface: $(echo "$line" | awk '{print $2}' | sed 's/://')"
                elif [[ $line =~ inet\ ]]; then
                    echo "    IP: $(echo "$line" | awk '{print $2}')"
                fi
            done
            
            echo -e "\nRouting table:"
            ip route show | head -5 | while read line; do
                echo "  $line"
            done
            
        # Fallback to ifconfig
        elif command -v ifconfig >/dev/null; then
            echo "Network interfaces (ifconfig):"
            ifconfig | grep -E "^[a-z]|inet " | while read line; do
                echo "  $line"
            done
            
            echo -e "\nRouting table:"
            if command -v route >/dev/null; then
                route -n | head -5 | while read line; do
                    echo "  $line"
                done
            fi
        fi
        
        # DNS information
        echo -e "\nDNS Configuration:"
        if [[ -f /etc/resolv.conf ]]; then
            grep -E "^nameserver|^search|^domain" /etc/resolv.conf | while read line; do
                echo "  $line"
            done
        fi
    }
    
    # Network connectivity tests
    test_connectivity() {
        local targets=("8.8.8.8" "google.com" "github.com")
        
        echo "Network Connectivity Tests"
        echo "=========================="
        
        for target in "${targets[@]}"; do
            echo -n "Testing connectivity to $target: "
            
            if ping -c 1 -W 3 "$target" >/dev/null 2>&1; then
                echo "✓ Success"
            else
                echo "✗ Failed"
            fi
        done
        
        # DNS resolution test
        echo -e "\nDNS Resolution Tests:"
        for domain in "google.com" "github.com" "stackoverflow.com"; do
            echo -n "Resolving $domain: "
            
            if nslookup "$domain" >/dev/null 2>&1 || dig "$domain" >/dev/null 2>&1; then
                echo "✓ Success"
            else
                echo "✗ Failed"
            fi
        done
    }
    
    # Port scanning and service detection
    scan_ports() {
        local target="${1:-localhost}"
        local ports="${2:-22,23,25,53,80,110,143,443,993,995}"
        
        echo "Port Scanning: $target"
        echo "Ports to scan: $ports"
        echo "======================"
        
        IFS=',' read -ra PORT_ARRAY <<< "$ports"
        
        for port in "${PORT_ARRAY[@]}"; do
            echo -n "Port $port: "
            
            # Try netcat first
            if command -v nc >/dev/null; then
                if nc -z -w3 "$target" "$port" 2>/dev/null; then
                    echo "✓ Open"
                else
                    echo "✗ Closed/Filtered"
                fi
            # Fallback to telnet
            elif command -v telnet >/dev/null; then
                if timeout 3 telnet "$target" "$port" </dev/null >/dev/null 2>&1; then
                    echo "✓ Open"
                else
                    echo "✗ Closed/Filtered"
                fi
            # Last resort: /dev/tcp
            else
                if timeout 3 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null; then
                    echo "✓ Open"
                else
                    echo "✗ Closed/Filtered"
                fi
            fi
        done
    }
    
    # Network statistics and monitoring
    network_stats() {
        echo "Network Statistics"
        echo "=================="
        
        # Active connections
        echo "Active network connections:"
        if command -v netstat >/dev/null; then
            netstat -tuln | head -10 | while read line; do
                echo "  $line"
            done
        elif command -v ss >/dev/null; then
            ss -tuln | head -10 | while read line; do
                echo "  $line"
            done
        fi
        
        # Network traffic statistics
        echo -e "\nNetwork interface statistics:"
        if [[ -f /proc/net/dev ]]; then
            echo "Interface    RX Bytes    TX Bytes"
            echo "--------------------------------"
            tail -n +3 /proc/net/dev | while read line; do
                local interface rx_bytes tx_bytes
                interface=$(echo "$line" | awk -F: '{print $1}' | tr -d ' ')
                rx_bytes=$(echo "$line" | awk '{print $2}')
                tx_bytes=$(echo "$line" | awk '{print $10}')
                
                if [[ $rx_bytes -gt 0 || $tx_bytes -gt 0 ]]; then
                    printf "%-12s %8s    %8s\n" "$interface" "$rx_bytes" "$tx_bytes"
                fi
            done | head -5
        fi
        
        # ARP table
        echo -e "\nARP table (local network devices):"
        if command -v arp >/dev/null; then
            arp -a | head -5 | while read line; do
                echo "  $line"
            done
        elif [[ -f /proc/net/arp ]]; then
            head -5 /proc/net/arp | while read line; do
                echo "  $line"
            done
        fi
    }
    
    # Firewall status and rules
    check_firewall() {
        echo "Firewall Status"
        echo "==============="
        
        # Check iptables
        if command -v iptables >/dev/null; then
            echo "iptables status:"
            if iptables -L >/dev/null 2>&1; then
                echo "  ✓ iptables is accessible"
                local rule_count
                rule_count=$(iptables -L | grep -c "^Chain\|^target")
                echo "  Rules configured: $rule_count"
            else
                echo "  ✗ iptables not accessible (may require sudo)"
            fi
        fi
        
        # Check ufw (Ubuntu)
        if command -v ufw >/dev/null; then
            echo "ufw status:"
            local ufw_status
            ufw_status=$(ufw status 2>/dev/null | head -1)
            echo "  $ufw_status"
        fi
        
        # Check firewalld (CentOS/RHEL)
        if command -v firewall-cmd >/dev/null; then
            echo "firewalld status:"
            if firewall-cmd --state >/dev/null 2>&1; then
                echo "  ✓ firewalld is running"
            else
                echo "  ✗ firewalld is not running"
            fi
        fi
    }
    
    # Network troubleshooting guide
    network_troubleshooting() {
        echo "Network Troubleshooting Guide"
        echo "============================"
        
        echo "Common network issues and solutions:"
        echo
        echo "1. No internet connectivity:"
        echo "   - Check physical connections"
        echo "   - Verify IP configuration: ip addr show"
        echo "   - Test DNS: nslookup google.com"
        echo "   - Check routing: ip route show"
        echo
        echo "2. Slow network performance:"
        echo "   - Check bandwidth: iperf3 or speedtest-cli"
        echo "   - Monitor network traffic: iftop or nethogs"
        echo "   - Check for packet loss: ping -c 100 target"
        echo
        echo "3. Cannot reach specific service:"
        echo "   - Test port connectivity: nc -zv host port"
        echo "   - Check firewall rules: iptables -L"
        echo "   - Verify service is running: systemctl status service"
        echo
        echo "4. DNS resolution issues:"
        echo "   - Test DNS servers: nslookup domain dns_server"
        echo "   - Check /etc/resolv.conf"
        echo "   - Try alternative DNS: 8.8.8.8, 1.1.1.1"
        echo
        echo "Useful network commands:"
        echo "  ping, traceroute, nslookup, dig"
        echo "  netstat, ss, lsof -i"
        echo "  tcpdump, wireshark"
        echo "  iperf3, mtr, nmap"
    }
    
    # Run network administration demos
    echo "1. Network Interface Information:"
    get_network_info
    
    echo -e "\n2. Connectivity Tests:"
    test_connectivity
    
    echo -e "\n3. Port Scanning (localhost):"
    scan_ports "localhost" "22,80,443"
    
    echo -e "\n4. Network Statistics:"
    network_stats
    
    echo -e "\n5. Firewall Status:"
    check_firewall
    
    echo -e "\n6. Troubleshooting Guide:"
    network_troubleshooting
}

network_administration
```

## Exercises

### Exercise 1: System Health Dashboard

Create a comprehensive system health dashboard:

```bash
#!/usr/bin/env bash

# System Health Dashboard
create_health_dashboard() {
    # TODO: Implement a comprehensive dashboard that shows:
    # - System resource usage (CPU, Memory, Disk)
    # - Running services status
    # - Network connectivity
    # - Recent system events
    # - Performance trends
    # - Alert notifications
    
    echo "Health dashboard not implemented yet"
}

# Test your implementation
# create_health_dashboard
```

### Exercise 2: Automated Backup System

Create an automated backup system with rotation:

```bash
#!/usr/bin/env bash

# Automated Backup System
backup_system() {
    local source_dir="$1"
    local backup_dir="$2"
    local retention_days="$3"
    
    # TODO: Implement automated backup with:
    # - Incremental and full backup modes
    # - Compression and encryption options
    # - Backup verification
    # - Rotation and cleanup
    # - Email notifications
    # - Backup restoration
    
    echo "Backup system not implemented yet"
}
```

## Summary

In this chapter, you learned:

- ✅ Process management and job control
- ✅ User and group administration
- ✅ System resource monitoring and alerting
- ✅ Service management and automation
- ✅ Network administration and diagnostics
- ✅ System maintenance and troubleshooting

System administration skills are essential for managing Linux systems effectively. These techniques enable you to monitor, maintain, and troubleshoot systems professionally.

**Next Steps:**
- Practice with the exercises on real systems
- Set up monitoring and alerting
- Create automated maintenance scripts
- Move on to Chapter 13: Security and Permissions

**Key Takeaways:**
- Monitor system resources proactively
- Automate routine maintenance tasks
- Implement proper error handling and logging
- Test scripts in safe environments first
- Document your system administration procedures
