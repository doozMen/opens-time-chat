# Wispr Flow + ActivityWatch Integration Plan

## Overview
Create an automated time tracking system that combines Wispr Flow's voice transcriptions with ActivityWatch's window tracking data to generate comprehensive time entries without manual input.

## Goals
1. Zero-friction time tracking - no behavior change required
2. Automatic ticket/task detection from window titles
3. Natural language work annotations from voice dictations
4. Intelligent work session boundary detection
5. Rich contextual time reports

## Architecture

### Data Sources
1. **Wispr Flow Database**
   - Location: `~/Library/Application Support/Wispr Flow/flow.sqlite`
   - Key fields: timestamp, formattedText, app, duration, numWords
   - Access via: wispr-flow-reader CLI tool

2. **ActivityWatch API**
   - Window titles containing ticket numbers (e.g., "CA-5006-tracking-events")
   - Application usage patterns
   - Active/idle time detection

### Integration Components

#### 1. Data Synchronization Service
```swift
// Polls both data sources and correlates events
class TimeTrackingSyncService {
    - Poll Wispr Flow for new transcriptions
    - Query ActivityWatch for corresponding window events
    - Match timestamps within reasonable windows (±30 seconds)
    - Generate enriched time entries
}
```

#### 2. Session Detection Algorithm
- Transcription gaps > 5 minutes = new session
- App switches to non-work apps = session boundary
- Idle time > 10 minutes = session end
- Meeting apps = separate session type

#### 3. Content Classification
```swift
enum WorkType {
    case coding(ticket: String?)
    case meeting(participants: [String])
    case review(pullRequest: String?)
    case planning
    case debugging
    case documentation
}

// Detect from transcription content + window title
```

#### 4. Time Entry Generation
```swift
struct TimeEntry {
    let startTime: Date
    let endTime: Date
    let ticket: String?
    let description: String  // From transcription
    let workType: WorkType
    let application: String
    let wordCount: Int      // Productivity metric
}
```

## Implementation Phases

### Phase 1: Data Access Layer (Week 1)
- [ ] Create Swift package for unified data access
- [ ] Implement Wispr Flow database reader (✓ Already done)
- [ ] Implement ActivityWatch API client
- [ ] Create data correlation engine

### Phase 2: Session Detection (Week 2)
- [ ] Implement gap-based session detection
- [ ] Add app-switch session boundaries
- [ ] Create idle time detection
- [ ] Test with real data

### Phase 3: Content Intelligence (Week 3)
- [ ] Build keyword extraction for work types
- [ ] Implement ticket number detection from window titles
- [ ] Create meeting detection from app + transcription length
- [ ] Add natural language processing for status updates

### Phase 4: Time Entry Generation (Week 4)
- [ ] Design time entry data model
- [ ] Implement entry generation logic
- [ ] Create deduplication system
- [ ] Add manual override capability

### Phase 5: Reporting & Export (Week 5)
- [ ] Build daily/weekly summary reports
- [ ] Create export to common formats (CSV, JSON)
- [ ] Add integration with existing time tracking systems
- [ ] Implement privacy controls

## Technical Details

### Correlation Algorithm
```swift
func correlateEvents(transcription: WisprTranscription, 
                    activityEvents: [ActivityWatchEvent]) -> TimeEntry? {
    // Find ActivityWatch events within ±30 seconds of transcription
    let timeWindow = 30.0 // seconds
    let relevantEvents = activityEvents.filter { event in
        abs(event.timestamp.timeIntervalSince(transcription.timestamp)) <= timeWindow
    }
    
    // Extract ticket from window title
    let ticket = extractTicketNumber(from: relevantEvents)
    
    // Classify work type
    let workType = classifyWork(transcription: transcription, 
                                events: relevantEvents)
    
    // Generate time entry
    return TimeEntry(...)
}
```

### Privacy Considerations
- All processing happens locally
- No data leaves the user's machine
- User can exclude sensitive transcriptions
- Configurable keyword filtering

## Success Metrics
1. Time tracking accuracy > 90%
2. Zero manual entry required for 80% of work
3. < 5% false positive rate for session detection
4. Rich context available for 100% of tracked time

## Future Enhancements
1. Machine learning for better work classification
2. Integration with calendar for meeting context
3. Automatic invoice generation
4. Team productivity analytics (with consent)
5. Voice commands for time tracking operations

## Dependencies
- wispr-flow-reader (already created)
- ActivityWatch MCP server
- Swift 6.1+
- SQLite.swift
- macOS 15+

## Risks & Mitigations
1. **Privacy concerns**: All processing local, clear user control
2. **Data quality**: Implement confidence scoring, manual review
3. **Performance**: Use efficient queries, background processing
4. **Accuracy**: Allow manual corrections, learn from feedback

## Next Steps
1. Review and refine this plan
2. Set up development environment
3. Create proof of concept for correlation
4. Test with one week of real data
5. Iterate based on findings