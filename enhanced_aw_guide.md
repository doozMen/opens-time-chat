# Enhanced ActivityWatch Analysis Guide with Claude Code Integration

## Quick Reference for Claude/AI Assistants

### 🚨 Critical: Timezone Handling

**ActivityWatch stores all timestamps in UTC!**

When analyzing data for users, always:
1. Ask for their timezone first OR check their location (Brussels = UTC+2/CEST)
2. Convert all timestamps to local time for display
3. Include timezone notation in reports

```javascript
// Example conversion
const utcTime = "2025-06-12T14:00:00Z";
const brusselsTime = new Date(utcTime).toLocaleString('en-GB', {
    timeZone: 'Europe/Brussels',
    hour12: false
});
```

## 🤖 Claude Code Integration Instructions

### Setting Up Claude Code for ActivityWatch Analysis

When working with ActivityWatch data analysis, Claude Code can significantly streamline your workflow by automating data collection, processing, and report generation. Here's how to leverage Claude Code effectively:

#### Core Claude Code Tasks for ActivityWatch

**Task 1: Automated Data Collection and Processing**
```bash
# Claude Code can execute these commands to gather comprehensive activity data
# Ask Claude Code to: "Help me collect and process today's ActivityWatch data for analysis"

# The agent should:
# 1. Query available ActivityWatch buckets
# 2. Fetch events for specified date range
# 3. Process timezone conversions
# 4. Calculate key productivity metrics
# 5. Generate structured output for further analysis
```

**Claude Code Prompt Example:**
```
I need you to help me analyze my ActivityWatch data for today. Please:

1. First, list all available ActivityWatch buckets to understand what data sources we have
2. Fetch window events for today (convert times from UTC to Brussels timezone)
3. Calculate key metrics: total work time, context switches, app distribution
4. Identify productivity patterns and focus periods
5. Generate a summary that I can use for my daily timesheet

My timezone is Europe/Brussels (UTC+2). Look for any context markers like ✳ symbols in window titles that indicate my manual annotations.
```

#### Task 2: Context Integration and Enrichment

**Setting Up Context-Aware Analysis**
Claude Code can bridge your ActivityWatch data with your context annotation system to create richer insights.

```bash
# Claude Code workflow for context enrichment
# Ask: "Integrate my context annotations with ActivityWatch data to show enriched activity patterns"

# The agent should:
# 1. Read context annotations from your context system
# 2. Correlate timestamps between ActivityWatch and context data
# 3. Create enriched timeline showing both activities and manual context
# 4. Identify patterns where context annotations improve productivity insights
```

#### Task 3: Automated Report Generation

**Daily Timesheet Creation**
Claude Code can automate the entire process of creating your comprehensive HTML timesheets.

```bash
# Comprehensive timesheet generation
# Ask: "Create my daily timesheet report combining ActivityWatch data, context annotations, and productivity insights"

# The agent should:
# 1. Gather all data sources (ActivityWatch, contexts, any GitLab activity)
# 2. Process and correlate timestamps
# 3. Identify work phases and productivity patterns
# 4. Generate the complete HTML timesheet with styling
# 5. Include actionable insights and recommendations
```

#### Task 4: Development Workflow Integration

**Project Context Analysis**
When working on specific tickets or projects, Claude Code can help correlate your activity data with your development work.

```bash
# Project-specific analysis
# Ask: "Analyze my work patterns for ticket CA-5006 by correlating ActivityWatch data with Git commits and development context"

# The agent should:
# 1. Search for ticket references in window titles and context annotations
# 2. Correlate with Git activity if available
# 3. Analyze development workflow patterns (Xcode → testing → documentation cycles)
# 4. Provide insights on development efficiency and context switching
```

### 📊 Advanced Claude Code Workflows

#### Workflow 1: Multi-Day Productivity Analysis

**Prompt for Claude Code:**
```
I want to analyze my productivity patterns across the last week. Please:

1. Collect ActivityWatch data for the past 7 days
2. Process timezone conversions to Brussels time
3. Identify recurring patterns in my work schedule
4. Analyze context switching frequency and its impact on productivity
5. Compare different types of work sessions (development vs. meetings vs. documentation)
6. Generate recommendations for optimizing my schedule

Create visualizations showing:
- Daily productivity heatmaps
- App usage trends over time
- Focus quality ratings by time of day
- Context switching patterns

Output the analysis as both a detailed report and a summary dashboard.
```

#### Workflow 2: Development Environment Optimization

**Prompt for Claude Code:**
```
Help me optimize my development environment based on ActivityWatch data:

1. Analyze my tool usage patterns (Xcode, Terminal, browsers, communication apps)
2. Identify inefficient context switches between development tools
3. Look for patterns where certain app combinations lead to better productivity
4. Suggest workflow improvements based on successful focus periods
5. Create a configuration guide for my development setup

Focus on:
- Which development phases benefit from different tool configurations
- How communication interruptions affect coding sessions
- Optimal scheduling for different types of development work
- Tool usage recommendations for maintaining flow state
```

#### Workflow 3: Integration with Your Server-Side Swift Goals

**Prompt for Claude Code:**
```
I'm building server-side Swift applications and exploring the Swift-Erlang actor system. Help me:

1. Analyze how my current development patterns align with distributed systems work
2. Identify time blocks that would be optimal for deep architectural work
3. Track progress on server-side Swift learning and experimentation
4. Correlate productivity patterns with different types of systems programming tasks

Create insights about:
- How my mobile development experience translates to server-side work
- Optimal time allocation for learning new paradigms (actor systems, distributed computing)
- Development workflow adaptations needed for server-side projects
- Market research time vs. implementation time ratios
```

### 🔧 Technical Implementation with Claude Code

#### Setting Up Your Analysis Environment

**File Structure Claude Code Should Maintain:**
```
activitywatch-analysis/
├── data/
│   ├── raw-events/          # Raw ActivityWatch exports
│   ├── processed/           # Cleaned and timezone-converted data
│   └── contexts/            # Context annotation exports
├── reports/
│   ├── daily/               # Daily timesheet HTML files
│   ├── weekly/              # Weekly productivity summaries
│   └── insights/            # Analysis insights and trends
├── scripts/
│   ├── data-collection.js   # ActivityWatch data fetching
│   ├── timezone-conversion.js
│   ├── context-integration.js
│   └── report-generation.js
└── templates/
    ├── timesheet-template.html
    └── insight-template.md
```

**Claude Code Setup Commands:**
```bash
# Ask Claude Code to: "Set up my ActivityWatch analysis environment with proper file structure and initial scripts"

# The agent should:
# 1. Create the directory structure above
# 2. Write initial data collection scripts
# 3. Set up timezone conversion utilities
# 4. Create template files for reports
# 5. Configure any necessary dependencies
```

### 🎯 Productivity Optimization with Claude Code

#### Continuous Improvement Loop

**Weekly Review Process:**
```
Every Friday, ask Claude Code to:

1. Generate comprehensive weekly productivity report
2. Compare this week's patterns to previous weeks
3. Identify improvement opportunities
4. Suggest schedule optimizations for next week
5. Update productivity tracking configuration based on findings

Questions for Claude Code to explore:
- What time blocks produced the highest quality work?
- How did different project types affect my productivity patterns?
- Which context switching patterns should I avoid?
- What environmental factors (meetings, interruptions) had the biggest impact?
```

#### Integration with Your "Opens Voice" Project

**Voice-Driven Analysis Commands:**
```
As you develop your voice-driven workflow system, ask Claude Code to:

1. Design voice commands for triggering productivity analysis
2. Create voice-activated timesheet generation
3. Build spoken queries for productivity insights
4. Develop voice interfaces for context annotation

Example voice workflow:
"Generate my productivity report for today focusing on the deep linking implementation work"
↓
Claude Code processes ActivityWatch data, finds CA-5006 references, creates targeted analysis
```

### 🚀 Advanced Integration Scenarios

#### Scenario 1: Market Research Correlation

When researching your "Opens Voice" market opportunity:
```bash
# Ask Claude Code to: "Track and analyze my market research activities to optimize research-to-development ratios"

# The agent should:
# 1. Identify browser-based research sessions in ActivityWatch data
# 2. Correlate research time with subsequent development productivity
# 3. Track learning curve patterns for new technologies
# 4. Suggest optimal research scheduling based on productivity patterns
```

#### Scenario 2: Distributed Systems Learning Optimization

```bash
# Ask Claude Code to: "Optimize my learning schedule for server-side Swift and actor system concepts"

# The agent should:
# 1. Track time spent on different learning activities
# 2. Correlate learning sessions with subsequent implementation success
# 3. Identify optimal cognitive load patterns for complex concepts
# 4. Suggest scheduling strategies for balancing learning with implementation
```

### 📈 Metrics and KPIs Claude Code Should Track

#### Core Productivity Metrics
- **Focus Quality Score**: Based on context switching frequency and session duration
- **Context Coherence**: How well activities align with stated context annotations
- **Learning Efficiency**: Progress tracking for new technologies and concepts
- **Development Velocity**: Code output relative to time invested
- **Research ROI**: How research time translates to implementation insights

#### Custom Metrics for Your Goals
- **Server-Side Swift Progress**: Tracking learning and implementation milestones
- **Market Research Effectiveness**: Converting research insights to actionable opportunities
- **Voice Interface Development**: Progress on "Opens Voice" prototype
- **Actor System Understanding**: Depth of knowledge building in distributed systems

### 🔍 Troubleshooting and Optimization

#### Common Issues Claude Code Can Solve

**Data Quality Problems:**
```bash
# Ask: "Identify and fix data quality issues in my ActivityWatch analysis pipeline"
# Claude Code should detect timezone inconsistencies, missing data periods, and format issues
```

**Performance Optimization:**
```bash
# Ask: "Optimize my productivity analysis scripts for faster processing and better insights"
# Claude Code can refactor analysis code and improve data processing efficiency
```

**Integration Challenges:**
```bash
# Ask: "Resolve integration issues between ActivityWatch, context annotations, and GitLab activity tracking"
# Claude Code can debug connectivity issues and improve data correlation accuracy
```

---

## Example Claude Code Session for Daily Analysis

Here's a complete example of how to work with Claude Code for your daily productivity analysis:

**Initial Request:**
```
I need a comprehensive analysis of my productivity today (June 13, 2025). I'm in Brussels timezone (UTC+2). Please:

1. Collect my ActivityWatch data for today
2. Look for any context markers (✳ symbols) in window titles
3. Integrate with my GitLab activity if possible
4. Generate insights about my work on the CA-5006 ticket
5. Create a beautiful HTML timesheet
6. Provide recommendations for tomorrow's schedule

Focus particularly on my server-side Swift exploration and any market research for the "Opens Voice" project.
```

**Follow-up Analysis:**
```
Based on today's data, help me understand:
- How my iOS development patterns translate to server-side work
- Whether my afternoon productivity drop is consistent with previous days
- If my context switching during the deep linking implementation was efficient
- How to better structure research time for the actor system learning

Create actionable insights I can apply tomorrow.
```

This integration transforms your ActivityWatch analysis from a manual, time-consuming process into an automated, insight-rich workflow that supports your broader goals of building innovative voice-driven systems and advancing your server-side Swift expertise.
