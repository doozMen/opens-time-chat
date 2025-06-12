# ActivityWatch Modules Guide

## Available Modules

ActivityWatch consists of several modules that can be enabled for additional functionality:

### Core Modules (Usually Active by Default)
- **aw-server**: The main server that stores and serves data
- **aw-qt**: The Qt-based system tray application
- **aw-watcher-window**: Tracks active window and application
- **aw-watcher-afk**: Tracks when you're away from keyboard

### Additional Modules (Need Manual Activation)

#### 1. **aw-notify** - Smart Notifications
Sends notifications based on your activity patterns.

**Features:**
- Reminds you to take breaks
- Notifies about time spent on specific activities
- Alerts when you've been inactive

**To Enable:**
```bash
# The module should be in the ActivityWatch app bundle
# Check if it exists:
ls /Applications/ActivityWatch.app/Contents/MacOS/aw-notify

# Start it manually:
/Applications/ActivityWatch.app/Contents/MacOS/aw-notify &

# Or add to ActivityWatch startup (see configuration section)
```

#### 2. **aw-watcher-input** - Keyboard/Mouse Activity Tracker
Tracks keyboard and mouse activity intensity (not keylogging - just activity levels).

**Features:**
- Measures typing speed/intensity
- Tracks mouse movement patterns
- Helps identify high-activity periods

**To Enable:**
```bash
# Check if it exists:
ls /Applications/ActivityWatch.app/Contents/MacOS/aw-watcher-input

# Start it manually:
/Applications/ActivityWatch.app/Contents/MacOS/aw-watcher-input &
```

**Note**: On macOS, this module requires accessibility permissions:
1. System Preferences → Security & Privacy → Privacy
2. Select "Accessibility"
3. Add ActivityWatch or Terminal (if running from terminal)

## Checking Which Modules Are Running

```bash
# Check all ActivityWatch processes
ps aux | grep -E "aw-"

# Check which watchers are sending data
curl http://localhost:5600/api/0/buckets
```

## Enabling Modules Permanently

### Method 1: ActivityWatch Configuration File

Create/edit `~/.config/activitywatch/aw-qt/aw-qt.toml`:

```toml
[aw-qt]
autostart_modules = ["aw-server", "aw-watcher-afk", "aw-watcher-window", "aw-notify", "aw-watcher-input"]
```

### Method 2: Launch Script

Create a custom launch script at `~/bin/start-activitywatch.sh`:

```bash
#!/bin/bash

# Start ActivityWatch with all modules
AW_PATH="/Applications/ActivityWatch.app/Contents/MacOS"

# Start core modules
"$AW_PATH/aw-qt" &

# Wait for server to start
sleep 5

# Start additional modules
"$AW_PATH/aw-notify" &
"$AW_PATH/aw-watcher-input" &

echo "ActivityWatch started with all modules"
```

Make it executable:
```bash
chmod +x ~/bin/start-activitywatch.sh
```

### Method 3: Individual LaunchAgents

Create separate LaunchAgents for each module. Example for aw-notify:

`~/Library/LaunchAgents/net.activitywatch.notify.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>net.activitywatch.notify</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/ActivityWatch.app/Contents/MacOS/aw-notify</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/net.activitywatch.notify.plist
```

## Module Configuration

### aw-notify Configuration

Create `~/.config/activitywatch/aw-notify/config.toml`:

```toml
[notify]
# Check for notifications every X seconds
poll_time = 60

[[notify.rules]]
name = "Break reminder"
query = """
afk_events = query_bucket(find_bucket("aw-watcher-afk"));
RETURN = sum_durations(filter_period_intersect(afk_events, "not-afk"));
"""
trigger = "RETURN > 3600"  # More than 1 hour of activity
message = "You've been active for over an hour. Time for a break!"

[[notify.rules]]
name = "Productivity check"
query = """
window_events = query_bucket(find_bucket("aw-watcher-window"));
productivity_events = filter_keyvals(window_events, "app", ["Code", "Terminal", "Xcode"]);
RETURN = sum_durations(productivity_events);
"""
trigger = "RETURN > 7200"  # More than 2 hours of coding
message = "Great coding session! You've been productive for over 2 hours."
```

### aw-watcher-input Configuration

Create `~/.config/activitywatch/aw-watcher-input/config.toml`:

```toml
[watcher-input]
poll_time = 1.0  # Poll every second
```

## Verifying Modules Are Working

### Check aw-notify
```bash
# Check if bucket exists
curl http://localhost:5600/api/0/buckets | grep notify

# Check logs
tail -f ~/.local/share/activitywatch/logs/aw-notify.log
```

### Check aw-watcher-input
```bash
# Check if bucket exists
curl http://localhost:5600/api/0/buckets | grep input

# View recent input events
curl "http://localhost:5600/api/0/buckets/aw-watcher-input_$(hostname)/events?limit=10"
```

## Troubleshooting

### Module Not Starting
1. Check if the binary exists in the app bundle
2. Check permissions (especially for aw-watcher-input)
3. Check logs in `~/.local/share/activitywatch/logs/`

### Permission Issues (macOS)
For aw-watcher-input on macOS:
```bash
# Grant accessibility permissions
tccutil reset Accessibility net.activitywatch.ActivityWatch
```

Then manually add in System Preferences.

### Module Crashes
Check crash logs:
```bash
# Check system logs
log show --predicate 'process == "aw-notify"' --last 1h

# Check ActivityWatch logs
ls ~/.local/share/activitywatch/logs/
```

## Recommended Setup

For a comprehensive ActivityWatch setup, enable:
1. **Core modules** (already enabled by default)
2. **aw-notify** for break reminders and productivity notifications
3. **aw-watcher-input** for detailed activity tracking

This gives you:
- Complete activity tracking
- Smart notifications
- Detailed insights into your work patterns
- Break reminders for health