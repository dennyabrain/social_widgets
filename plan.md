# Social Widgets Platform - Plan

## Mission
Build a self-service platform for adding social widgets (polls, comments, whiteboards, etc.) to static websites via embeddable iframes.

## Design Philosophy
Minimal & clean aesthetic with excellent UX focused on developers and content creators.

## Phase 1: Core Platform + Poll Widget
- [x] Generate Phoenix LiveView project `social_widgets`
- [x] Start the server to follow along
- [x] Replace home page with static mockup of dashboard design
- [x] Create Widget management context (3 steps)
  - [x] Generate migration for `widgets` table with fields:
    - name (string) - user-friendly name
    - widget_type (string) - "poll", "comments", "whiteboard", etc
    - embed_code (string) - unique identifier for embedding
    - config (map) - JSON config specific to widget type
    - timestamps
  - [x] Create Widgets context module with CRUD operations
  - [x] Seed a sample poll widget for testing
- [x] Build Dashboard LiveView (2 steps)
  - [x] Create DashboardLive with widget listing and creation form
  - [x] Create dashboard template with minimal design
- [x] Implement Poll Widget (4 steps)
  - [x] Generate migration for `poll_options` and `poll_votes` tables
  - [x] Create Polls context for poll-specific operations
  - [x] Create PollWidgetLive for embeddable poll interface
  - [x] Add PubSub broadcasting for real-time vote updates
- [x] Create embeddable iframe routes (1 step)
  - [x] Add `/embed/:embed_code` route with minimal layout
- [x] Match layouts to minimal & clean design (2 steps)
  - [x] Update app.css with minimal theme (light mode, clean typography)
  - [x] Update root.html.heex and Layouts.app to match design
- [x] Update router with all routes (1 step)
- [x] Visit app to verify functionality (1 step)

## Future Widget Types
- Comments (threaded, real-time)
- Collaborative whiteboard/canvas
- Live reactions/emoji bar
- Newsletter signup
- Q&A board

