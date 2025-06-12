# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains two main projects:

1. **ActivityWatch MCP Server** (`activitywatch-mcp-server/`) - A Model Context Protocol server for ActivityWatch integration with LLMs
2. **ActivityWatch** (`activitywatch/`) - The main ActivityWatch application (submodule)

## Common Development Commands

### ActivityWatch MCP Server

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Run tests
npm test

# Run specific test
npm test src/getSettings.test.ts

# Development mode (watch)
npm run dev

# Start server
npm start
```

### ActivityWatch (Python)

```bash
# Build all modules
make build

# Run tests
make test

# Run linting
make lint

# Run type checking
make typecheck

# Clean build artifacts
make clean

# Update submodules and rebuild
make update
```

## Architecture

### ActivityWatch MCP Server
- **Language**: TypeScript
- **Framework**: Model Context Protocol SDK
- **Test Framework**: Jest
- **Main Components**:
  - `src/index.ts` - Main server entry point with MCP tool implementations
  - `src/bucketList.ts` - List ActivityWatch buckets
  - `src/query.ts` - Execute AQL queries
  - `src/rawEvents.ts` - Get raw events from buckets
  - `src/getSettings.ts` - Get ActivityWatch settings

### ActivityWatch
- **Language**: Python (with some Rust components)
- **Build System**: Make + Poetry
- **Main Modules**:
  - `aw-core` - Core library
  - `aw-client` - Client library for watchers
  - `aw-server` - REST API server
  - `aw-server-rust` - Rust implementation of server
  - `aw-qt` - Qt-based UI
  - `aw-watcher-afk` - AFK detection
  - `aw-watcher-window` - Window tracking

## Key Technical Details

### MCP Server Query Format
When implementing ActivityWatch queries through the MCP server, ensure queries follow this format:
- `timeperiods`: Array of date ranges as strings (e.g., `["2024-10-28/2024-10-29"]`)
- `query`: Array containing complete query strings with statements separated by semicolons

Example:
```json
{
  "timeperiods": ["2024-10-28/2024-10-29"],
  "query": ["events = query_bucket('aw-watcher-window_hostname'); RETURN = events;"]
}
```

### Testing
- MCP Server uses Jest with TypeScript support
- Tests can be run in isolation using `npm test <file>`
- Test environment is set via `cross-env NODE_ENV=test`

### API Endpoints
The MCP server connects to ActivityWatch at `http://localhost:5600` and provides these tools:
- `list-buckets` - List available buckets
- `run-query` - Execute AQL queries
- `get-events` - Retrieve raw events
- `get-settings` - Access ActivityWatch settings