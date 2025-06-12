#!/bin/bash

# Installation script for ActivityWatch Monitor with Notifications

echo "Installing ActivityWatch Monitor with Notifications..."

# Make the monitor script executable
chmod +x activitywatch-monitor-notify.sh

# Copy the LaunchAgent to the correct location
cp com.activitywatch.monitor.plist ~/Library/LaunchAgents/

# Create logs directory if it doesn't exist
mkdir -p ~/Library/Logs

# Unload the agent if it's already loaded (ignore errors)
launchctl unload ~/Library/LaunchAgents/com.activitywatch.monitor.plist 2>/dev/null

# Load the agent
launchctl load ~/Library/LaunchAgents/com.activitywatch.monitor.plist

# Start it immediately
launchctl start com.activitywatch.monitor

echo "✅ ActivityWatch Monitor installed and started!"
echo ""
echo "The monitor will:"
echo "- Check if ActivityWatch is running every 5 minutes"
echo "- Show a notification if it stops"
echo "- Attempt to restart it automatically"
echo "- Log activity to ~/Library/Logs/activitywatch-monitor.log"
echo ""
echo "To stop the monitor: launchctl stop com.activitywatch.monitor"
echo "To uninstall: launchctl unload ~/Library/LaunchAgents/com.activitywatch.monitor.plist"