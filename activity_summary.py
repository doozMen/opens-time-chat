#!/usr/bin/env python3
"""
Process ActivityWatch data to create hourly summaries
"""

import json
from datetime import datetime, timedelta
from collections import defaultdict
import sys

def process_events(events, hour_label):
    """Process events and create summary by app"""
    app_summary = defaultdict(float)
    activity_details = defaultdict(list)
    
    for event in events:
        app = event['data'].get('app', 'Unknown')
        title = event['data'].get('title', 'No title')
        duration = event.get('duration', 0)
        
        app_summary[app] += duration
        activity_details[app].append({
            'title': title,
            'duration': duration,
            'timestamp': event['timestamp']
        })
    
    print(f'\n{hour_label} Activity Summary:')
    print('=' * 70)
    
    total_time = sum(app_summary.values())
    if total_time == 0:
        print('No activity recorded')
        return
    
    # Sort apps by total duration
    sorted_apps = sorted(app_summary.items(), key=lambda x: x[1], reverse=True)
    
    for app, total_duration in sorted_apps:
        minutes = total_duration / 60
        percentage = (total_duration / total_time * 100)
        print(f'\n{app}: {minutes:.1f} minutes ({percentage:.1f}%)')
        
        # Show top activities for this app
        app_activities = activity_details[app]
        # Group by title and sum durations
        title_durations = defaultdict(float)
        for activity in app_activities:
            title_durations[activity['title']] += activity['duration']
        
        # Show top 3 activities
        top_activities = sorted(title_durations.items(), key=lambda x: x[1], reverse=True)[:3]
        for title, duration in top_activities:
            activity_minutes = duration / 60
            print(f'  - {title[:60]}{"..." if len(title) > 60 else ""}: {activity_minutes:.1f} min')
    
    print(f'\nTotal tracked time: {total_time/60:.1f} minutes')

# Example usage
if __name__ == "__main__":
    # This will be called with the event data
    print("ActivityWatch Data Analysis - June 12, 2025 (7 AM - 1 AM)")
    print("=" * 70)