# Wispr + ActivityWatch Implementation Guide

## Quick Start Implementation

### Step 1: Create the Integration Package

```bash
cd ~/Developer/opens-time-chat
mkdir wispr-activitywatch-integration
cd wispr-activitywatch-integration
swift package init --type executable --name TimeTracker
```

### Step 2: Basic Integration Code

```swift
// Sources/TimeTracker/main.swift
import Foundation
import SQLite
import ArgumentParser

@main
struct TimeTracker: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "timetrack",
        abstract: "Automated time tracking using Wispr Flow and ActivityWatch"
    )
    
    func run() async throws {
        let tracker = TimeTrackingService()
        try await tracker.generateTimeEntries(for: Date())
    }
}

// Sources/TimeTracker/TimeTrackingService.swift
class TimeTrackingService {
    private let wisprReader = WisprFlowReader()
    private let activityWatch = ActivityWatchClient()
    
    func generateTimeEntries(for date: Date) async throws -> [TimeEntry] {
        // 1. Fetch Wispr transcriptions for the date
        let transcriptions = try await wisprReader.getTranscriptions(for: date)
        
        // 2. Fetch ActivityWatch events
        let events = try await activityWatch.getWindowEvents(for: date)
        
        // 3. Correlate and generate time entries
        return correlateData(transcriptions: transcriptions, events: events)
    }
    
    private func correlateData(transcriptions: [Transcription], 
                              events: [WindowEvent]) -> [TimeEntry] {
        var entries: [TimeEntry] = []
        
        for transcription in transcriptions {
            // Find matching window event within 30 seconds
            let matchingEvents = events.filter { event in
                abs(event.timestamp.timeIntervalSince(transcription.timestamp)) <= 30
            }
            
            if let event = matchingEvents.first {
                let entry = TimeEntry(
                    startTime: transcription.timestamp,
                    duration: estimateDuration(from: transcription, to: events),
                    ticket: extractTicket(from: event.windowTitle),
                    description: transcription.text,
                    application: event.appName,
                    workType: classifyWork(transcription.text)
                )
                entries.append(entry)
            }
        }
        
        return mergeAdjacentEntries(entries)
    }
}
```

### Step 3: Ticket Extraction

```swift
extension TimeTrackingService {
    func extractTicket(from windowTitle: String) -> String? {
        // Match patterns like "CA-5006", "JIRA-123", etc.
        let patterns = [
            #"[A-Z]+-\d+"#,           // JIRA style
            #"#\d+"#,                 // GitHub style
            #"ticket[-_]?\d+"#        // Generic
        ]
        
        for pattern in patterns {
            if let match = windowTitle.range(of: pattern, 
                                           options: .regularExpression) {
                return String(windowTitle[match])
            }
        }
        return nil
    }
}
```

### Step 4: Work Classification

```swift
enum WorkType: String {
    case coding = "Development"
    case debugging = "Debugging"
    case meeting = "Meeting"
    case review = "Code Review"
    case planning = "Planning"
    case documentation = "Documentation"
    
    static func classify(from text: String) -> WorkType {
        let lowercased = text.lowercased()
        
        switch lowercased {
        case let t where t.contains("meeting") || t.contains("standup"):
            return .meeting
        case let t where t.contains("review") || t.contains("pr "):
            return .review
        case let t where t.contains("fix") || t.contains("debug") || t.contains("error"):
            return .debugging
        case let t where t.contains("plan") || t.contains("design"):
            return .planning
        case let t where t.contains("document") || t.contains("readme"):
            return .documentation
        default:
            return .coding
        }
    }
}
```

### Step 5: Session Detection

```swift
struct WorkSession {
    let startTime: Date
    let endTime: Date
    let entries: [TimeEntry]
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
}

extension TimeTrackingService {
    func detectSessions(from entries: [TimeEntry]) -> [WorkSession] {
        guard !entries.isEmpty else { return [] }
        
        var sessions: [WorkSession] = []
        var currentSession: [TimeEntry] = []
        
        let sortedEntries = entries.sorted { $0.startTime < $1.startTime }
        
        for (index, entry) in sortedEntries.enumerated() {
            if currentSession.isEmpty {
                currentSession.append(entry)
            } else {
                let lastEntry = currentSession.last!
                let gap = entry.startTime.timeIntervalSince(lastEntry.startTime)
                
                // New session if gap > 5 minutes
                if gap > 300 {
                    sessions.append(WorkSession(
                        startTime: currentSession.first!.startTime,
                        endTime: lastEntry.startTime.addingTimeInterval(lastEntry.duration),
                        entries: currentSession
                    ))
                    currentSession = [entry]
                } else {
                    currentSession.append(entry)
                }
            }
        }
        
        // Add final session
        if !currentSession.isEmpty {
            sessions.append(WorkSession(
                startTime: currentSession.first!.startTime,
                endTime: currentSession.last!.startTime.addingTimeInterval(
                    currentSession.last!.duration
                ),
                entries: currentSession
            ))
        }
        
        return sessions
    }
}
```

### Step 6: Report Generation

```swift
struct DailyReport {
    let date: Date
    let sessions: [WorkSession]
    let totalTime: TimeInterval
    let byTicket: [String: TimeInterval]
    let byWorkType: [WorkType: TimeInterval]
    
    func generateMarkdown() -> String {
        """
        # Daily Time Report - \(date.formatted(date: .abbreviated, time: .omitted))
        
        **Total Time**: \(formatDuration(totalTime))
        
        ## Sessions
        \(sessions.map { session in
            """
            ### \(session.startTime.formatted(date: .omitted, time: .shortened)) - \(session.endTime.formatted(date: .omitted, time: .shortened))
            Duration: \(formatDuration(session.duration))
            
            \(session.entries.map { entry in
                "- **\(entry.ticket ?? "No ticket")**: \(entry.description)"
            }.joined(separator: "\n"))
            """
        }.joined(separator: "\n\n"))
        
        ## Time by Ticket
        \(byTicket.map { ticket, time in
            "- \(ticket): \(formatDuration(time))"
        }.joined(separator: "\n"))
        
        ## Time by Activity
        \(byWorkType.map { type, time in
            "- \(type.rawValue): \(formatDuration(time))"
        }.joined(separator: "\n"))
        """
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
```

### Step 7: Real-time Monitoring

```swift
// Create a daemon that monitors both data sources
class TimeTrackingDaemon {
    private var wisprObserver: FileSystemWatcher?
    private var lastProcessedTranscription: Date?
    
    func start() {
        // Monitor Wispr Flow database for changes
        let dbPath = "~/Library/Application Support/Wispr Flow/flow.sqlite"
        wisprObserver = FileSystemWatcher(path: dbPath) { [weak self] in
            self?.processNewTranscriptions()
        }
        
        // Process every 5 minutes
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            self.generateIncrementalReport()
        }
    }
    
    private func processNewTranscriptions() {
        // Check for new transcriptions since last check
        // Correlate with ActivityWatch data
        // Update running time entries
    }
}
```

## Usage Examples

### Basic Daily Report
```bash
# Generate today's report
timetrack report

# Generate report for specific date
timetrack report --date 2025-06-13

# Export to JSON
timetrack export --format json --output timesheet.json
```

### Real-time Monitoring
```bash
# Start the daemon
timetrack monitor

# View current session
timetrack status
```

### Custom Queries
```bash
# Time spent on specific ticket
timetrack query --ticket "CA-5006"

# Time in meetings this week
timetrack query --type meeting --period week

# Export for invoicing
timetrack export --client "ProjectX" --format csv
```

## Configuration File

Create `~/.timetrack/config.json`:
```json
{
    "workingHours": {
        "start": "09:00",
        "end": "18:00"
    },
    "excludeApps": ["Safari", "Messages"],
    "minimumSessionDuration": 300,
    "ticketPatterns": [
        "[A-Z]+-\\d+",
        "#\\d+"
    ],
    "workKeywords": {
        "debugging": ["fix", "bug", "error", "issue"],
        "meeting": ["standup", "meeting", "discussion", "call"],
        "review": ["review", "pr", "merge request"]
    }
}
```

## Privacy & Security

1. **All data stays local** - No cloud sync
2. **Encrypted storage** - Option to encrypt time entries
3. **Selective tracking** - Exclude personal apps/websites
4. **Data retention** - Auto-delete after X days
5. **Export filtering** - Remove sensitive descriptions

## Next Steps

1. Install dependencies:
   ```bash
   brew install swift-format swiftlint
   ```

2. Clone the integration repo:
   ```bash
   git clone https://github.com/yourusername/wispr-activitywatch-integration
   ```

3. Build and test:
   ```bash
   swift build
   swift test
   ```

4. Run with sample data:
   ```bash
   swift run timetrack report --date 2025-06-13
   ```

This implementation provides a solid foundation for automated time tracking that requires zero manual input while providing rich, contextual time entries.