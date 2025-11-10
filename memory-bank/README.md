# Memory Bank

This directory contains the **Cursor Memory Bank** for the Zero-to-Running Developer Environment project.

## Purpose

The Memory Bank serves as the persistent knowledge base for this project. After each Cursor session reset, these files provide complete context about:
- What the project is and why it exists
- Current state and progress
- Technical decisions and architecture
- What's working and what's left to build
- Active considerations and next steps

## File Structure

### Core Files (Must Read First)

1. **`projectbrief.md`** - Foundation document
   - Project overview and goals
   - Core problem and solution
   - Success metrics
   - Technology stack summary
   - Out of scope items

2. **`productContext.md`** - Product perspective
   - Why this project exists
   - Problems it solves
   - How it should work
   - User experience goals
   - User journeys

3. **`systemPatterns.md`** - Architecture and design
   - System architecture overview
   - Key technical decisions
   - Design patterns in use
   - Component relationships
   - Security and scalability considerations

4. **`techContext.md`** - Technical details
   - Complete technology stack
   - Development setup requirements
   - Project structure
   - Configuration details
   - Technical constraints

5. **`activeContext.md`** - Current state (READ THIS FIRST!)
   - What we're working on right now
   - Recent changes and decisions
   - Current blockers
   - Next immediate steps
   - Active questions and answers

6. **`progress.md`** - Status tracking
   - What's complete
   - What's in progress
   - What's not built yet
   - PR status breakdown
   - Success metrics progress

## Reading Order for New Sessions

When starting a new Cursor session:

1. **Start with:** `activeContext.md` - Get immediate context on current work
2. **Then read:** `progress.md` - Understand what's done and what's next
3. **Reference as needed:** Other files for deeper context on specific areas

## Updating Guidelines

### When to Update

- After completing a PR or major milestone → Update `progress.md`
- When making architectural decisions → Update `systemPatterns.md`
- When scope or requirements change → Update `projectbrief.md`
- After any significant work session → Update `activeContext.md`
- When user requests "**update memory bank**" → Review ALL files

### What to Update

- **`activeContext.md`**: Update most frequently (every session)
- **`progress.md`**: Update when tasks complete or status changes
- **`systemPatterns.md`**: Update when architecture evolves
- **`techContext.md`**: Update when tech stack changes
- **`productContext.md`**: Update rarely (only if product direction shifts)
- **`projectbrief.md`**: Update rarely (only if core scope changes)

## Current Project Status

**Phase:** Planning Complete, Ready to Begin Implementation  
**Next Step:** Start PR #0 (Git Repository Setup)  
**Blockers:** None

See `activeContext.md` and `progress.md` for detailed current status.

