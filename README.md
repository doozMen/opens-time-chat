# Opens Time Chat

A collection of tools and integrations for enhancing time tracking and activity monitoring with ActivityWatch, providing AI-powered context and analysis capabilities.

## Overview

This repository serves as the parent project for several interconnected tools that work together to provide intelligent time tracking and activity analysis:

- **ActivityWatch Integration**: Connect to ActivityWatch for comprehensive computer usage tracking
- **AI Context Analysis**: Use LLMs to analyze and categorize your activities
- **MCP Server**: Model Context Protocol server for seamless AI integration
- **Command-line Tools**: Swift-based CLI for adding context annotations

## Child Repositories

### 1. [ActivityWatch MCP Server](https://github.com/doozMen/activitywatch-mcp-server)
A Model Context Protocol (MCP) server that provides ActivityWatch integration for Large Language Models (LLMs).

**Features:**
- List ActivityWatch buckets
- Execute AQL (ActivityWatch Query Language) queries
- Retrieve raw events from specific buckets
- Access ActivityWatch settings

**Use Cases:**
- Query your activity data through AI assistants
- Generate reports and summaries of your computer usage
- Analyze productivity patterns

### 2. [Activity Tagger](https://github.com/doozMen/activity-tagger)
A Swift command-line tool for adding contextual annotations to ActivityWatch data.

**Features:**
- Add context tags to time periods
- Query activities with context
- Search through annotated data
- Generate summaries with enriched context
- Batch process historical data

**Use Cases:**
- Tag work sessions with project names
- Add meeting context to calendar events
- Categorize browsing sessions
- Create meaningful activity reports

### 3. [ActivityWatch](activitywatch/)
The main ActivityWatch application (included as a submodule).

**Note:** This is the official ActivityWatch repository. See [ActivityWatch.net](https://activitywatch.net/) for more information.

## Getting Started

### Prerequisites

- [ActivityWatch](https://activitywatch.net/) installed and running
- Node.js 18+ (for MCP server)
- Swift 5.9+ (for aw-context-tool)
- An MCP-compatible AI client (like Claude Desktop)

### Installation

1. Clone this repository with submodules:
```bash
git clone --recursive https://github.com/doozMen/opens-time-chat.git
cd opens-time-chat
```

2. Set up the MCP server:
```bash
cd activitywatch-mcp-server
npm install
npm run build
```

3. Build the aw-context-tool:
```bash
cd ../aw-context-tool
swift build
```

### Configuration

#### MCP Server Configuration

Add to your Claude Desktop configuration (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "activitywatch": {
      "command": "node",
      "args": ["/path/to/opens-time-chat/activitywatch-mcp-server/build/index.js"],
      "env": {
        "ACTIVITYWATCH_URL": "http://localhost:5600"
      }
    }
  }
}
```

#### Activity Tagger Usage

```bash
# Add context to current activity
swift run aw-context add --tag "project:opens-time-chat" --category "development"

# Query activities with context
swift run aw-context query --start "2024-06-12" --end "2024-06-13"

# Search for specific contexts
swift run aw-context search --tag "project:opens-time-chat"
```

## Architecture

```
opens-time-chat/
├── activitywatch-mcp-server/  # MCP server for AI integration
├── aw-context-tool/           # Swift CLI for context annotation
├── activitywatch/            # ActivityWatch core (submodule)
└── CLAUDE.md                 # Development guidelines
```

## Use Cases

1. **AI-Powered Time Analysis**: Use Claude or other LLMs to analyze your ActivityWatch data and provide insights about your productivity patterns.

2. **Project Time Tracking**: Tag your activities with project names and generate accurate time reports for billing or personal analysis.

3. **Focus Session Analysis**: Identify and analyze deep work sessions, distractions, and context switches.

4. **Automated Categorization**: Use AI to automatically categorize your activities based on window titles and application usage.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to the individual repositories.

## License

Each child repository has its own license. Please refer to the individual repositories for license information.

## Acknowledgments

- [ActivityWatch](https://activitywatch.net/) for providing the foundation for time tracking
- The MCP (Model Context Protocol) community for enabling AI integrations