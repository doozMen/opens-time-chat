#!/bin/bash

# Script to enable additional ActivityWatch modules

AW_PATH="/Applications/ActivityWatch.app/Contents/MacOS"

echo "ActivityWatch Module Enabler"
echo "============================"
echo ""

# Check if ActivityWatch is installed
if [ ! -d "/Applications/ActivityWatch.app" ]; then
    echo "❌ ActivityWatch not found in /Applications/"
    exit 1
fi

# Function to check if a process is running
is_running() {
    pgrep -f "$1" > /dev/null
}

# Function to check if module exists
module_exists() {
    [ -f "$AW_PATH/$1" ]
}

# Function to start a module
start_module() {
    local module=$1
    local name=$2
    
    if module_exists "$module"; then
        if is_running "$module"; then
            echo "✅ $name is already running"
        else
            echo "🚀 Starting $name..."
            "$AW_PATH/$module" &
            sleep 2
            if is_running "$module"; then
                echo "✅ $name started successfully"
            else
                echo "❌ Failed to start $name"
            fi
        fi
    else
        echo "⚠️  $name not found in ActivityWatch bundle"
    fi
}

# Check core modules
echo "Core Modules:"
echo "-------------"
start_module "aw-server" "AW Server"
start_module "aw-watcher-window" "Window Watcher"
start_module "aw-watcher-afk" "AFK Watcher"

echo ""
echo "Additional Modules:"
echo "------------------"

# Check and start aw-notify
start_module "aw-notify" "Notification Module"

# Check and start aw-watcher-input
if module_exists "aw-watcher-input"; then
    echo ""
    echo "📝 Input Watcher requires accessibility permissions on macOS."
    echo "   Please grant permissions in System Preferences → Security & Privacy → Accessibility"
    echo ""
    read -p "Have you granted accessibility permissions? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        start_module "aw-watcher-input" "Input Watcher"
    else
        echo "⏭️  Skipping Input Watcher. Enable it manually after granting permissions."
    fi
else
    echo "⚠️  Input Watcher not found in ActivityWatch bundle"
fi

echo ""
echo "Current ActivityWatch processes:"
echo "-------------------------------"
ps aux | grep -E "aw-" | grep -v grep | awk '{print "• " $11}'

echo ""
echo "Active buckets:"
echo "--------------"
curl -s http://localhost:5600/api/0/buckets 2>/dev/null | grep -o '"id":"[^"]*"' | cut -d'"' -f4 | while read bucket; do
    echo "• $bucket"
done

echo ""
echo "✨ Done! Check the ActivityWatch web UI at http://localhost:5600"