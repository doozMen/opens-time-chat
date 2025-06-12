# ActivityWatch Daemon Setup Guide (macOS)

## Problem
ActivityWatch may stop running during the day due to:
- System sleep/wake cycles
- Memory pressure
- Crashes or unexpected termination
- macOS App Nap or energy saving features

## Solution Options

### Option 1: LaunchAgent (Recommended)

Create a LaunchAgent to run ActivityWatch as a user service that starts automatically and restarts if it crashes.

#### 1. Create LaunchAgent plist file

Create `~/Library/LaunchAgents/net.activitywatch.ActivityWatch.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>net.activitywatch.ActivityWatch</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/ActivityWatch.app/Contents/MacOS/aw-qt</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
        <key>Crashed</key>
        <true/>
    </dict>
    
    <key>ProcessType</key>
    <string>Interactive</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/activitywatch.err</string>
    
    <key>StandardOutPath</key>
    <string>/tmp/activitywatch.out</string>
    
    <key>ThrottleInterval</key>
    <integer>30</integer>
</dict>
</plist>
```

#### 2. Load the LaunchAgent

```bash
# Load the agent
launchctl load ~/Library/LaunchAgents/net.activitywatch.ActivityWatch.plist

# Start it immediately
launchctl start net.activitywatch.ActivityWatch

# Check status
launchctl list | grep activitywatch
```

#### 3. Manage the service

```bash
# Stop the service
launchctl stop net.activitywatch.ActivityWatch

# Unload (disable) the service
launchctl unload ~/Library/LaunchAgents/net.activitywatch.ActivityWatch.plist

# Reload after making changes
launchctl unload ~/Library/LaunchAgents/net.activitywatch.ActivityWatch.plist
launchctl load ~/Library/LaunchAgents/net.activitywatch.ActivityWatch.plist
```

### Option 2: Shell Script with Monitoring

Create a monitoring script that checks and restarts ActivityWatch:

#### 1. Create monitor script

Save as `~/bin/activitywatch-monitor.sh`:

```bash
#!/bin/bash

# ActivityWatch monitor script
# Checks if ActivityWatch is running and restarts if needed

AW_APP="/Applications/ActivityWatch.app"
AW_BINARY="$AW_APP/Contents/MacOS/aw-qt"
LOG_FILE="$HOME/Library/Logs/activitywatch-monitor.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

check_and_start() {
    # Check if ActivityWatch processes are running
    if ! pgrep -f "aw-server" > /dev/null; then
        log "ActivityWatch not running. Starting..."
        
        # Kill any zombie processes
        pkill -f "aw-" 2>/dev/null
        sleep 2
        
        # Start ActivityWatch
        open -a "$AW_APP" &
        
        # Wait for startup
        sleep 10
        
        # Verify it started
        if pgrep -f "aw-server" > /dev/null; then
            log "ActivityWatch started successfully"
        else
            log "Failed to start ActivityWatch"
        fi
    else
        log "ActivityWatch is running"
    fi
}

# Main loop
while true; do
    check_and_start
    # Check every 5 minutes
    sleep 300
done
```

#### 2. Make it executable

```bash
chmod +x ~/bin/activitywatch-monitor.sh
```

#### 3. Create LaunchAgent for the monitor

Create `~/Library/LaunchAgents/com.user.activitywatch-monitor.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.activitywatch-monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/YOUR_USERNAME/bin/activitywatch-monitor.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

### Option 3: Using `brew services` (If installed via Homebrew)

If ActivityWatch was installed via Homebrew:

```bash
# Start and enable auto-start
brew services start activitywatch

# Check status
brew services list | grep activitywatch

# Stop service
brew services stop activitywatch

# Restart service
brew services restart activitywatch
```

### Option 4: System Preferences Login Items

For a simpler but less robust solution:

1. Open System Preferences → Users & Groups
2. Select your user account
3. Click "Login Items" tab
4. Click "+" and add ActivityWatch.app
5. Check "Hide" if you don't want the window to show

## Additional Recommendations

### 1. Prevent App Nap

Add to ActivityWatch's Info.plist:
```xml
<key>NSAppSleepDisabled</key>
<true/>
```

Or via Terminal:
```bash
defaults write net.activitywatch.ActivityWatch NSAppSleepDisabled -bool YES
```

### 2. Energy Settings

Ensure your Mac doesn't sleep when you need tracking:
```bash
# Prevent sleep while on AC power
sudo pmset -c sleep 0

# Prevent hard disk sleep
sudo pmset -c disksleep 0

# Keep network alive
sudo pmset -c tcpkeepalive 1
```

### 3. Monitoring and Alerts

Create a simple alert system:

```bash
#!/bin/bash
# Save as ~/bin/aw-check-alert.sh

if ! curl -s http://localhost:5600/api/0/info > /dev/null 2>&1; then
    osascript -e 'display notification "ActivityWatch server is not responding" with title "ActivityWatch Alert"'
fi
```

Add to crontab:
```bash
# Check every 30 minutes
*/30 * * * * /Users/YOUR_USERNAME/bin/aw-check-alert.sh
```

## Troubleshooting

### Check logs
```bash
# LaunchAgent logs
tail -f /tmp/activitywatch.err
tail -f /tmp/activitywatch.out

# Monitor script log
tail -f ~/Library/Logs/activitywatch-monitor.log

# ActivityWatch logs
tail -f ~/.local/share/activitywatch/logs/aw-server.log
```

### Common issues

1. **Port already in use**: Kill existing processes
   ```bash
   lsof -i :5600 | grep LISTEN | awk '{print $2}' | xargs kill -9
   ```

2. **Permission issues**: Reset permissions
   ```bash
   chmod -R 755 /Applications/ActivityWatch.app
   ```

3. **Database corruption**: Backup and reset
   ```bash
   mv ~/.local/share/activitywatch ~/.local/share/activitywatch.backup
   ```

## Recommended Setup

For maximum reliability, use **Option 1 (LaunchAgent)** combined with:
- Energy settings to prevent sleep
- NSAppSleepDisabled setting
- Regular monitoring via the check script

This ensures ActivityWatch:
- Starts automatically on login
- Restarts if it crashes
- Doesn't get suspended by macOS
- Alerts you if it stops working