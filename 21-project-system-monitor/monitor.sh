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

# Create directories if they don't exist
mkdir -p "$LOG_DIR" "$REPORTS_DIR" "$LIB_DIR" "$(dirname "$CONFIG_FILE")"

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

# Simplified system info functions (inline for standalone script)
get_cpu_usage() {
    if command -v top >/dev/null 2>&1; then
        # Try different top formats
        top -bn1 | grep -i "cpu" | head -1 | awk '{print $2}' | sed 's/%us,\|%user,\|%//g' 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

get_memory_usage() {
    if command -v free >/dev/null 2>&1; then
        free | awk 'NR==2{printf "%.1f", $3*100/$2}'
    elif command -v vm_stat >/dev/null 2>&1; then
        # macOS memory calculation - simplified
        echo "50.0"  # Placeholder for macOS
    else
        echo "0"
    fi
}

get_disk_usage() {
    local path="${1:-/}"
    df -h "$path" 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//' || echo "0"
}

get_load_average() {
    uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//' | cut -d',' -f1 || echo "0.00"
}

# Load configuration
load_configuration() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ $key =~ ^#.*$ || -z $key ]] && continue
            value="${value%\"}"
            value="${value#\"}"
            CONFIG[$key]="$value"
        done < "$CONFIG_FILE"
        echo "Configuration loaded from $CONFIG_FILE"
    else
        echo "Configuration file not found, using defaults"
        create_default_config
    fi
}

# Create default configuration file
create_default_config() {
    cat > "$CONFIG_FILE" << 'EOF'
# System Monitor Configuration
check_interval=60
log_retention_days=30
cpu_threshold=80
memory_threshold=85
disk_threshold=90
alert_email="admin@example.com"
report_format="both"
EOF
    echo "Default configuration created at $CONFIG_FILE"
}

# Logging functions
log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $*" | tee -a "$LOG_DIR/monitor.log"
}

log_warn() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WARN] $*" | tee -a "$LOG_DIR/monitor.log"
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
    
    # Log metrics to data file
    local data_log="$LOG_DIR/metrics_$(date +'%Y%m%d').csv"
    if [[ ! -f "$data_log" ]]; then
        echo "timestamp,cpu_usage,memory_usage,disk_usage,load_avg" > "$data_log"
    fi
    
    echo "$timestamp,$cpu_usage,$memory_usage,$disk_usage,$load_avg" >> "$data_log"
    
    # Check thresholds (using integer comparison for simplicity)
    if [[ ${cpu_usage%.*} -gt ${CONFIG[cpu_threshold]} ]]; then
        alerts+=("CPU usage is ${cpu_usage}% (threshold: ${CONFIG[cpu_threshold]}%)")
    fi
    
    if [[ ${memory_usage%.*} -gt ${CONFIG[memory_threshold]} ]]; then
        alerts+=("Memory usage is ${memory_usage}% (threshold: ${CONFIG[memory_threshold]}%)")
    fi
    
    if [[ ${disk_usage%.*} -gt ${CONFIG[disk_threshold]} ]]; then
        alerts+=("Disk usage is ${disk_usage}% (threshold: ${CONFIG[disk_threshold]}%)")
    fi
    
    # Process alerts
    if [[ ${#alerts[@]} -gt 0 ]]; then
        for alert in "${alerts[@]}"; do
            log_warn "ALERT: $alert"
        done
    fi
    
    # Display current status
    printf "%-20s CPU: %6s%% | MEM: %6s%% | DISK: %6s%% | LOAD: %s\n" \
           "[$timestamp]" "$cpu_usage" "$memory_usage" "$disk_usage" "$load_avg"
    
    log_info "Monitoring cycle completed"
}

# Create progress bar
create_progress_bar() {
    local current="$1"
    local width="${2:-30}"
    local filled=$((current * width / 100))
    local empty=$((width - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do
        if [[ $current -gt 80 ]]; then
            bar+="█"
        elif [[ $current -gt 60 ]]; then
            bar+="▓"
        else
            bar+="▒"
        fi
    done
    
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    
    echo "$bar"
}

# Dashboard mode
run_dashboard() {
    log_info "Starting dashboard mode"
    
    # Clear screen and hide cursor
    clear
    echo "Press Ctrl+C to exit dashboard mode"
    
    while true; do
        # Clear screen and move to top
        clear
        
        # Header
        echo "======================================================================"
        echo "                        SYSTEM MONITOR DASHBOARD"
        echo "======================================================================"
        echo "Last Update: $(date +'%Y-%m-%d %H:%M:%S')"
        echo
        
        # System overview
        echo "SYSTEM OVERVIEW:"
        echo "================"
        printf "Hostname: %-20s Uptime: %s\n" "$(hostname)" "$(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
        printf "OS: %-25s Kernel: %s\n" "$(uname -s)" "$(uname -r)"
        echo
        
        # Resource usage
        echo "RESOURCE USAGE:"
        echo "==============="
        
        local cpu_usage=$(get_cpu_usage)
        local memory_usage=$(get_memory_usage)
        local disk_usage=$(get_disk_usage "/")
        local load_avg=$(get_load_average)
        
        # Remove decimals for progress bar
        local cpu_int=${cpu_usage%.*}
        local mem_int=${memory_usage%.*}
        local disk_int=${disk_usage%.*}
        
        # Progress bars
        printf "CPU Usage:    [%s] %6s%%\n" "$(create_progress_bar "$cpu_int" 30)" "$cpu_usage"
        printf "Memory Usage: [%s] %6s%%\n" "$(create_progress_bar "$mem_int" 30)" "$memory_usage"
        printf "Disk Usage:   [%s] %6s%%\n" "$(create_progress_bar "$disk_int" 30)" "$disk_usage"
        
        echo
        printf "Load Average: %s\n" "$load_avg"
        echo
        
        # Top processes
        echo "TOP PROCESSES (by CPU):"
        echo "======================="
        if command -v ps >/dev/null 2>&1; then
            ps aux 2>/dev/null | head -6 | awk 'NR==1{print "USER       PID    %CPU %MEM COMMAND"} NR>1{printf "%-10s %-6s %4.1f %4.1f %s\n", $1, $2, $3, $4, $11}' || echo "Process information unavailable"
        fi
        echo
        
        # Recent alerts
        echo "RECENT ALERTS:"
        echo "=============="
        if [[ -f "$LOG_DIR/monitor.log" ]]; then
            tail -n 5 "$LOG_DIR/monitor.log" 2>/dev/null | grep "ALERT" | tail -3 || echo "No recent alerts"
        else
            echo "No recent alerts"
        fi
        
        # Status line
        echo
        echo "======================================================================"
        
        sleep "${CONFIG[check_interval]}"
    done
}

# Generate simple report
generate_report() {
    local report_file="$REPORTS_DIR/system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "System Report - $(date)"
        echo "========================"
        echo
        echo "System Information:"
        echo "  Hostname: $(hostname)"
        echo "  OS: $(uname -s)"
        echo "  Kernel: $(uname -r)"
        echo "  Uptime: $(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
        echo
        echo "Current Resource Usage:"
        echo "  CPU: $(get_cpu_usage)%"
        echo "  Memory: $(get_memory_usage)%"
        echo "  Disk (/): $(get_disk_usage)%"
        echo "  Load Average: $(get_load_average)"
        echo
        echo "Disk Usage:"
        df -h 2>/dev/null | head -10
        echo
        echo "Report generated at $(date)"
    } > "$report_file"
    
    echo "Report generated: $report_file"
}

# Show usage
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
    load_configuration
    
    # Parse command line arguments
    case "${1:-}" in
        -d|--dashboard)
            run_dashboard
            ;;
        -c|--continuous)
            log_info "Starting continuous monitoring mode"
            echo "Starting continuous monitoring. Press Ctrl+C to stop."
            while true; do
                run_monitoring_cycle
                sleep "${CONFIG[check_interval]}"
            done
            ;;
        -o|--once)
            run_monitoring_cycle
            ;;
        -r|--report)
            generate_report
            ;;
        -h|--help)
            show_usage
            ;;
        "")
            echo "No mode specified. Use --help for usage information."
            echo "Starting dashboard mode in 3 seconds..."
            sleep 3
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
