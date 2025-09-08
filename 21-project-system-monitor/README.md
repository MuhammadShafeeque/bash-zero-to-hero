# Project 1: System Monitor

This project combines all the concepts you've learned to create a comprehensive system monitoring tool. You'll build a script that monitors system resources, generates reports, and alerts on critical conditions.

## Project Overview

**Goal**: Create a system monitoring script that:
- Monitors CPU, memory, disk, and network usage
- Logs data to files
- Generates HTML reports
- Sends alerts when thresholds are exceeded
- Provides real-time dashboard view

**Skills Applied**:
- Variables and functions
- Loops and conditionals
- File I/O and redirection
- Error handling
- Text processing

## Project Structure

```
system_monitor/
├── monitor.sh              # Main monitoring script
├── config/
│   └── monitor.conf        # Configuration file
├── lib/
│   ├── system_info.sh      # System information functions
│   ├── alerts.sh           # Alert functions
│   └── reporting.sh        # Report generation functions
├── logs/                   # Log files directory
├── reports/                # Generated reports directory
└── templates/
    └── report_template.html # HTML report template
```

## Implementation

### Main Script: monitor.sh

```bash
#!/usr/bin/env bash
#
# System Monitor - Main Script
# Author: System Admin
# Version: 1.0
# Description: Comprehensive system monitoring tool
#

set -euo pipefail

# Script directory and configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/monitor.conf"
LIB_DIR="$SCRIPT_DIR/lib"
LOG_DIR="$SCRIPT_DIR/logs"
REPORTS_DIR="$SCRIPT_DIR/reports"

# Source library functions
source "$LIB_DIR/system_info.sh"
source "$LIB_DIR/alerts.sh"
source "$LIB_DIR/reporting.sh"

# Default configuration
declare -A CONFIG=(
    [check_interval]=60
    [log_retention_days]=30
    [cpu_threshold]=80
    [memory_threshold]=85
    [disk_threshold]=90
    [alert_email]=""
    [report_format]="both"
)

# Load configuration
load_configuration() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ $key =~ ^#.*$ || -z $key ]] && continue
            value="${value%\"}"
            value="${value#\"}"
            CONFIG[$key]="$value"
        done < "$CONFIG_FILE"
        log_info "Configuration loaded from $CONFIG_FILE"
    else
        log_warn "Configuration file not found, using defaults"
        create_default_config
    fi
}

# Create default configuration file
create_default_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    cat > "$CONFIG_FILE" << 'EOF'
# System Monitor Configuration
# ============================

# Monitoring interval in seconds
check_interval=60

# Log retention in days
log_retention_days=30

# Alert thresholds (percentage)
cpu_threshold=80
memory_threshold=85
disk_threshold=90

# Alert settings
alert_email="admin@example.com"

# Report format: text, html, both
report_format="both"

# Enable/disable features
enable_cpu_monitoring=true
enable_memory_monitoring=true
enable_disk_monitoring=true
enable_network_monitoring=true
enable_process_monitoring=true
EOF
    
    log_info "Default configuration created at $CONFIG_FILE"
}

# Logging functions
log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $*" | tee -a "$LOG_DIR/monitor.log"
}

log_warn() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WARN] $*" | tee -a "$LOG_DIR/monitor.log"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $*" | tee -a "$LOG_DIR/monitor.log" >&2
}

# Initialize directories
initialize_environment() {
    mkdir -p "$LOG_DIR" "$REPORTS_DIR"
    
    # Rotate old logs
    find "$LOG_DIR" -name "*.log" -mtime +${CONFIG[log_retention_days]} -delete 2>/dev/null || true
    
    log_info "System Monitor starting up"
    log_info "PID: $$"
    log_info "Version: 1.0"
}

# Main monitoring function
run_monitoring_cycle() {
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    local alerts=()
    
    log_info "Starting monitoring cycle"
    
    # Collect system metrics
    local cpu_usage=$(get_cpu_usage)
    local memory_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage "/")
    local load_avg=$(get_load_average)
    local network_stats=$(get_network_stats)
    
    # Log metrics to data file
    local data_log="$LOG_DIR/metrics_$(date +'%Y%m%d').csv"
    if [[ ! -f "$data_log" ]]; then
        echo "timestamp,cpu_usage,memory_usage,disk_usage,load_avg,network_rx,network_tx" > "$data_log"
    fi
    
    echo "$timestamp,$cpu_usage,$memory_usage,$disk_usage,$load_avg,$network_stats" >> "$data_log"
    
    # Check thresholds and generate alerts
    if [[ $(echo "$cpu_usage > ${CONFIG[cpu_threshold]}" | bc -l) -eq 1 ]]; then
        alerts+=("CPU usage is ${cpu_usage}% (threshold: ${CONFIG[cpu_threshold]}%)")
    fi
    
    if [[ $(echo "$memory_usage > ${CONFIG[memory_threshold]}" | bc -l) -eq 1 ]]; then
        alerts+=("Memory usage is ${memory_usage}% (threshold: ${CONFIG[memory_threshold]}%)")
    fi
    
    if [[ $(echo "$disk_usage > ${CONFIG[disk_threshold]}" | bc -l) -eq 1 ]]; then
        alerts+=("Disk usage is ${disk_usage}% (threshold: ${CONFIG[disk_threshold]}%)")
    fi
    
    # Process alerts
    if [[ ${#alerts[@]} -gt 0 ]]; then
        for alert in "${alerts[@]}"; do
            log_warn "ALERT: $alert"
            send_alert "$alert"
        done
    fi
    
    # Display current status
    printf "%-20s CPU: %6.1f%% | MEM: %6.1f%% | DISK: %6.1f%% | LOAD: %s\n" \
           "[$timestamp]" "$cpu_usage" "$memory_usage" "$disk_usage" "$load_avg"
    
    log_info "Monitoring cycle completed"
}

# Dashboard mode
run_dashboard() {
    log_info "Starting dashboard mode"
    
    # Clear screen and hide cursor
    clear
    tput civis
    
    # Trap to restore cursor on exit
    trap 'tput cnorm; clear; exit' INT TERM
    
    while true; do
        # Save cursor position and clear screen
        tput home
        
        # Header
        echo "======================================================================"
        echo "                        SYSTEM MONITOR DASHBOARD"
        echo "======================================================================"
        echo "Last Update: $(date +'%Y-%m-%d %H:%M:%S')                    Press Ctrl+C to exit"
        echo
        
        # System overview
        echo "SYSTEM OVERVIEW:"
        echo "================"
        printf "Hostname: %-20s Uptime: %s\n" "$(hostname)" "$(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
        printf "OS: %-25s Kernel: %s\n" "$(uname -o 2>/dev/null || uname -s)" "$(uname -r)"
        echo
        
        # Resource usage
        echo "RESOURCE USAGE:"
        echo "==============="
        
        local cpu_usage=$(get_cpu_usage)
        local memory_usage=$(get_memory_usage)
        local disk_usage=$(get_disk_usage "/")
        local load_avg=$(get_load_average)
        
        # CPU bar
        printf "CPU Usage:    [%s] %6.1f%%\n" "$(create_progress_bar "$cpu_usage" 100 30)" "$cpu_usage"
        
        # Memory bar
        printf "Memory Usage: [%s] %6.1f%%\n" "$(create_progress_bar "$memory_usage" 100 30)" "$memory_usage"
        
        # Disk bar
        printf "Disk Usage:   [%s] %6.1f%%\n" "$(create_progress_bar "$disk_usage" 100 30)" "$disk_usage"
        
        echo
        printf "Load Average: %s\n" "$load_avg"
        echo
        
        # Top processes
        echo "TOP PROCESSES (by CPU):"
        echo "======================="
        ps aux --sort=-%cpu | head -6 | awk 'NR==1{print "USER       PID    %CPU %MEM COMMAND"} NR>1{printf "%-10s %-6s %4.1f %4.1f %s\n", $1, $2, $3, $4, $11}'
        echo
        
        # Network stats
        echo "NETWORK STATISTICS:"
        echo "=================="
        show_network_summary
        echo
        
        # Recent alerts
        echo "RECENT ALERTS:"
        echo "=============="
        tail -n 5 "$LOG_DIR/monitor.log" 2>/dev/null | grep "ALERT" | tail -3 || echo "No recent alerts"
        
        # Status line
        echo
        echo "======================================================================"
        
        sleep "${CONFIG[check_interval]}"
    done
}

# Create progress bar
create_progress_bar() {
    local current="$1"
    local max="$2"
    local width="$3"
    
    local percentage=$(echo "scale=0; $current * 100 / $max" | bc)
    local filled=$(echo "scale=0; $percentage * $width / 100" | bc)
    local empty=$((width - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do
        if [[ $percentage -gt 80 ]]; then
            bar+="█"  # Red zone
        elif [[ $percentage -gt 60 ]]; then
            bar+="▓"  # Yellow zone
        else
            bar+="▒"  # Green zone
        fi
    done
    
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    
    echo "$bar"
}

# Command line argument processing
show_usage() {
    cat << EOF
System Monitor v1.0

Usage: $0 [OPTIONS]

OPTIONS:
    -d, --dashboard     Run in dashboard mode (real-time display)
    -c, --continuous    Run continuous monitoring
    -o, --once          Run single monitoring cycle
    -r, --report        Generate system report
    -h, --help          Show this help message
    
EXAMPLES:
    $0 --dashboard      # Start real-time dashboard
    $0 --continuous     # Start continuous background monitoring
    $0 --once           # Run single check
    $0 --report         # Generate report

CONFIGURATION:
    Edit $CONFIG_FILE to customize monitoring settings
    
LOG FILES:
    Monitor logs: $LOG_DIR/monitor.log
    Metric data:  $LOG_DIR/metrics_YYYYMMDD.csv
    
REPORTS:
    Generated in: $REPORTS_DIR/
EOF
}

# Main execution
main() {
    # Initialize
    initialize_environment
    load_configuration
    
    # Parse command line arguments
    case "${1:-}" in
        -d|--dashboard)
            run_dashboard
            ;;
        -c|--continuous)
            log_info "Starting continuous monitoring mode"
            while true; do
                run_monitoring_cycle
                sleep "${CONFIG[check_interval]}"
            done
            ;;
        -o|--once)
            run_monitoring_cycle
            ;;
        -r|--report)
            generate_system_report
            ;;
        -h|--help)
            show_usage
            ;;
        "")
            echo "No mode specified. Use --help for usage information."
            echo "Starting dashboard mode..."
            sleep 2
            run_dashboard
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
```

### System Information Library: lib/system_info.sh

```bash
#!/usr/bin/env bash
#
# System Information Library
# Functions for gathering system metrics
#

# Get CPU usage percentage
get_cpu_usage() {
    if command -v top >/dev/null 2>&1; then
        # Linux
        top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' 2>/dev/null || \
        top -bn1 | grep "CPU usage" | awk '{print 100-$7}' | sed 's/%//' 2>/dev/null || \
        echo "0"
    elif command -v iostat >/dev/null 2>&1; then
        # macOS with iostat
        iostat -c 1 | tail -1 | awk '{print 100-$6}' 2>/dev/null || echo "0"
    else
        # Fallback: parse /proc/stat
        awk '/^cpu / {usage=($2+$4)*100/($2+$3+$4+$5)} END {print usage}' /proc/stat 2>/dev/null || echo "0"
    fi
}

# Get memory usage percentage
get_memory_usage() {
    if command -v free >/dev/null 2>&1; then
        # Linux
        free | awk 'NR==2{printf "%.1f", $3*100/$2}'
    elif command -v vm_stat >/dev/null 2>&1; then
        # macOS
        local vm_stat_output=$(vm_stat)
        local pages_active=$(echo "$vm_stat_output" | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
        local pages_inactive=$(echo "$vm_stat_output" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
        local pages_wired=$(echo "$vm_stat_output" | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
        local pages_free=$(echo "$vm_stat_output" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        
        local total_pages=$((pages_active + pages_inactive + pages_wired + pages_free))
        local used_pages=$((pages_active + pages_inactive + pages_wired))
        
        echo "scale=1; $used_pages * 100 / $total_pages" | bc 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Get disk usage percentage for specified path
get_disk_usage() {
    local path="${1:-/}"
    df -h "$path" 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//' || echo "0"
}

# Get load average
get_load_average() {
    uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//' | cut -d',' -f1 || echo "0.00"
}

# Get network statistics (RX/TX bytes)
get_network_stats() {
    if [[ -f /proc/net/dev ]]; then
        # Linux
        awk 'NR>2 && !/lo:/ {rx+=$2; tx+=$10} END {printf "%.0f,%.0f", rx/1024/1024, tx/1024/1024}' /proc/net/dev 2>/dev/null || echo "0,0"
    elif command -v netstat >/dev/null 2>&1; then
        # macOS/BSD
        netstat -ibn | awk '/en0/ {print $7 "," $10; exit}' 2>/dev/null || echo "0,0"
    else
        echo "0,0"
    fi
}

# Show network summary
show_network_summary() {
    if command -v ss >/dev/null 2>&1; then
        echo "Active connections:"
        ss -tuln | grep LISTEN | wc -l | awk '{print "  Listening ports: " $1}'
        ss -tu | grep ESTAB | wc -l | awk '{print "  Established connections: " $1}'
    elif command -v netstat >/dev/null 2>&1; then
        echo "Active connections:"
        netstat -tuln 2>/dev/null | grep LISTEN | wc -l | awk '{print "  Listening ports: " $1}'
        netstat -tu 2>/dev/null | grep ESTABLISHED | wc -l | awk '{print "  Established connections: " $1}'
    fi
}

# Get system information
get_system_info() {
    cat << EOF
System Information:
==================
Hostname: $(hostname)
OS: $(uname -o 2>/dev/null || uname -s)
Kernel: $(uname -r)
Architecture: $(uname -m)
Uptime: $(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
Load Average: $(get_load_average)
Users: $(who | wc -l)
EOF
}

# Get top processes by CPU
get_top_processes_cpu() {
    local count="${1:-10}"
    echo "Top $count processes by CPU usage:"
    echo "=================================="
    ps aux --sort=-%cpu 2>/dev/null | head -$((count + 1)) | awk 'NR==1{print "USER       PID    %CPU %MEM COMMAND"} NR>1{printf "%-10s %-6s %4.1f %4.1f %s\n", $1, $2, $3, $4, $11}' 2>/dev/null || \
    ps aux | sort -k3 -nr | head -$((count + 1)) | awk 'NR==1{print "USER       PID    %CPU %MEM COMMAND"} NR>1{printf "%-10s %-6s %4.1f %4.1f %s\n", $1, $2, $3, $4, $11}'
}

# Get top processes by memory
get_top_processes_memory() {
    local count="${1:-10}"
    echo "Top $count processes by Memory usage:"
    echo "===================================="
    ps aux --sort=-%mem 2>/dev/null | head -$((count + 1)) | awk 'NR==1{print "USER       PID    %CPU %MEM COMMAND"} NR>1{printf "%-10s %-6s %4.1f %4.1f %s\n", $1, $2, $3, $4, $11}' 2>/dev/null || \
    ps aux | sort -k4 -nr | head -$((count + 1)) | awk 'NR==1{print "USER       PID    %CPU %MEM COMMAND"} NR>1{printf "%-10s %-6s %4.1f %4.1f %s\n", $1, $2, $3, $4, $11}'
}

# Get disk space information
get_disk_info() {
    echo "Disk Usage Information:"
    echo "======================"
    df -h 2>/dev/null | grep -E '^/dev|^tmpfs' | awk '{printf "%-20s %8s %8s %8s %s %s\n", $1, $2, $3, $4, $5, $6}' | column -t
}

# Get service status
check_service_status() {
    local services=("ssh" "cron" "nginx" "apache2" "mysql" "postgresql")
    
    echo "Service Status:"
    echo "==============="
    
    for service in "${services[@]}"; do
        if systemctl is-active "$service" >/dev/null 2>&1; then
            printf "%-15s: ✓ Running\n" "$service"
        elif pgrep "$service" >/dev/null 2>&1; then
            printf "%-15s: ✓ Running\n" "$service"
        else
            printf "%-15s: ✗ Stopped\n" "$service"
        fi
    done
}
```

### Alert System: lib/alerts.sh

```bash
#!/usr/bin/env bash
#
# Alert System Library
# Functions for sending alerts and notifications
#

# Send alert via email
send_email_alert() {
    local subject="$1"
    local message="$2"
    local email="${CONFIG[alert_email]}"
    
    if [[ -n "$email" ]] && command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "$subject" "$email"
        log_info "Email alert sent to $email"
    fi
}

# Send alert via system notification
send_desktop_notification() {
    local title="$1"
    local message="$2"
    
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$message"
    elif command -v osascript >/dev/null 2>&1; then
        # macOS
        osascript -e "display notification \"$message\" with title \"$title\""
    fi
}

# Write alert to system log
write_system_log() {
    local message="$1"
    
    if command -v logger >/dev/null 2>&1; then
        logger -t "system_monitor" "ALERT: $message"
    fi
}

# Main alert function
send_alert() {
    local alert_message="$1"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    
    local full_message="[SYSTEM MONITOR ALERT]
Time: $timestamp
Host: $(hostname)
Alert: $alert_message

System Status:
- CPU: $(get_cpu_usage)%
- Memory: $(get_memory_usage)%
- Disk: $(get_disk_usage)%
- Load: $(get_load_average)

Please investigate immediately."
    
    # Send via different channels
    send_email_alert "System Monitor Alert - $(hostname)" "$full_message"
    send_desktop_notification "System Alert" "$alert_message"
    write_system_log "$alert_message"
    
    # Log alert
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ALERT] $alert_message" >> "$LOG_DIR/alerts.log"
}

# Check alert cooldown to prevent spam
check_alert_cooldown() {
    local alert_type="$1"
    local cooldown_minutes="${2:-30}"
    local cooldown_file="$LOG_DIR/.${alert_type}_cooldown"
    
    if [[ -f "$cooldown_file" ]]; then
        local last_alert=$(cat "$cooldown_file")
        local current_time=$(date +%s)
        local time_diff=$((current_time - last_alert))
        
        if [[ $time_diff -lt $((cooldown_minutes * 60)) ]]; then
            return 1  # Still in cooldown
        fi
    fi
    
    # Update cooldown file
    date +%s > "$cooldown_file"
    return 0  # Not in cooldown
}
```

### Run the Project

```bash
# Make the script executable
chmod +x monitor.sh

# Run different modes
./monitor.sh --help           # Show usage
./monitor.sh --once           # Single check
./monitor.sh --dashboard      # Real-time dashboard
./monitor.sh --continuous     # Background monitoring
./monitor.sh --report         # Generate report
```

## Project Extensions

### 1. Add More Metrics
- Network bandwidth monitoring
- Temperature sensors
- Docker container monitoring
- Custom application metrics

### 2. Enhance Alerting
- Slack/Discord notifications
- PagerDuty integration
- Alert escalation rules
- Alert acknowledgments

### 3. Improve Reporting
- Historical trend analysis
- Performance baselines
- Capacity planning reports
- Export to different formats

### 4. Add Web Interface
- REST API endpoints
- Web dashboard
- Mobile-responsive design
- Real-time updates

## Key Learning Points

1. **Modular Design**: Separate concerns into different modules
2. **Configuration Management**: External configuration files
3. **Error Handling**: Graceful handling of missing commands/files
4. **Cross-Platform Compatibility**: Different approaches for Linux/macOS
5. **User Experience**: Clear interfaces and helpful output
6. **Resource Management**: Efficient monitoring without overhead
7. **Data Storage**: Structured logging and data retention

This project demonstrates how to combine all bash scripting concepts into a practical, production-ready tool!

## Next Steps

Continue to [Project 2: Log Analyzer](../22-project-log-analyzer/README.md) to build another comprehensive bash application.
