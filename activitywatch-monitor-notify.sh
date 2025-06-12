#!/bin/bash

# ActivityWatch Monitor with Notifications
# This script monitors ActivityWatch and shows notifications if it stops

# Configuration
CHECK_INTERVAL=300  # Check every 5 minutes (in seconds)
AW_URL="http://localhost:5600/api/0/info"
LOG_FILE="$HOME/Library/Logs/activitywatch-monitor.log"
LAST_NOTIFICATION_FILE="/tmp/aw-last-notification"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to show notification
show_notification() {
    local title="$1"
    local message="$2"
    local sound="${3:-Glass}"  # Default sound is Glass
    
    osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\""
    log "Notification shown: $title - $message"
}

# Function to check if we should show notification (rate limiting)
should_show_notification() {
    if [ ! -f "$LAST_NOTIFICATION_FILE" ]; then
        return 0
    fi
    
    local last_notification=$(cat "$LAST_NOTIFICATION_FILE")
    local current_time=$(date +%s)
    local time_diff=$((current_time - last_notification))
    
    # Only show notification if 30 minutes have passed since last one
    if [ $time_diff -gt 1800 ]; then
        return 0
    else
        return 1
    fi
}

# Function to update last notification time
update_notification_time() {
    date +%s > "$LAST_NOTIFICATION_FILE"
}

# Function to check if ActivityWatch is responding
check_activitywatch() {
    # Try to connect to ActivityWatch API
    if curl -s --connect-timeout 5 "$AW_URL" > /dev/null 2>&1; then
        return 0  # ActivityWatch is running
    else
        return 1  # ActivityWatch is not responding
    fi
}

# Function to check if ActivityWatch processes are running
check_processes() {
    if pgrep -f "aw-server" > /dev/null && pgrep -f "aw-qt" > /dev/null; then
        return 0  # Processes are running
    else
        return 1  # Processes are not running
    fi
}

# Function to restart ActivityWatch
restart_activitywatch() {
    log "Attempting to restart ActivityWatch..."
    
    # Kill any existing processes
    pkill -f "aw-" 2>/dev/null
    sleep 2
    
    # Start ActivityWatch
    open -a "/Applications/ActivityWatch.app"
    
    # Wait for it to start
    sleep 15
    
    # Check if it started successfully
    if check_activitywatch; then
        show_notification "ActivityWatch Restarted" "ActivityWatch has been automatically restarted and is now running." "Hero"
        log "ActivityWatch restarted successfully"
        return 0
    else
        show_notification "ActivityWatch Restart Failed" "Failed to restart ActivityWatch. Please start it manually." "Basso"
        log "Failed to restart ActivityWatch"
        return 1
    fi
}

# Main monitoring loop
log "ActivityWatch monitor started"
show_notification "ActivityWatch Monitor" "Monitoring started. You'll be notified if ActivityWatch stops." "Pop"

# Initialize - check if ActivityWatch is running at start
if ! check_activitywatch; then
    show_notification "ActivityWatch Not Running" "ActivityWatch is not running. Starting it now..." "Glass"
    restart_activitywatch
fi

while true; do
    if ! check_activitywatch; then
        log "ActivityWatch is not responding"
        
        # Check if processes are still running
        if check_processes; then
            log "Processes are running but API not responding"
            if should_show_notification; then
                show_notification "ActivityWatch Not Responding" "ActivityWatch processes are running but not responding. You may need to restart it." "Glass"
                update_notification_time
            fi
        else
            log "ActivityWatch processes are not running"
            if should_show_notification; then
                show_notification "ActivityWatch Stopped" "ActivityWatch has stopped running. Attempting to restart..." "Sosumi"
                update_notification_time
                
                # Try to restart
                restart_activitywatch
            fi
        fi
    else
        # ActivityWatch is running fine
        # Clear last notification time if it exists
        rm -f "$LAST_NOTIFICATION_FILE" 2>/dev/null
    fi
    
    # Wait before next check
    sleep $CHECK_INTERVAL
done