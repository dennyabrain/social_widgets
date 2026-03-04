# Social Widgets Platform - Plan

## Mission
Build a self-service platform for adding social widgets (polls, comments, whiteboards, etc.) to static websites via embeddable iframes.

## Design Philosophy
Minimal & clean aesthetic with excellent UX focused on developers and content creators.

## Phase 1: Core Platform + Poll Widget
- [x] Generate Phoenix LiveView project `social_widgets`
- [ ] Start the server to follow along
- [ ] Replace home page with static mockup of dashboard design
- [ ] Create Widget management context (3 steps)
  - [ ] Generate migration for `widgets` table with fields:
    - name (string) - user-friendly name
    - widget_type (string) - "poll", "comments", "whiteboard", etc
    - embed_code (string) - unique identifier for embedding
    - config (map) - JSON config specific to widget type
    - timestamps
  - [ ] Create Widgets context module with CRUD operations
  - [ ] Seed a sample poll widget for testing
- [ ] Build Dashboard LiveView (2 steps)
  - [ ] Create DashboardLive with widget listing and creation form
  - [ ] Create dashboard template with minimal design
- [ ] Implement Poll Widget (4 steps)
  - [ ] Generate migration for `poll_options` and `poll_votes` tables
  - [ ] Create Polls context for poll-specific operations
  - [ ] Create PollWidgetLive for embeddable poll interface
  - [ ] Add PubSub broadcasting for real-time vote updates
- [ ] Create embeddable iframe routes (1 step)
  - [ ] Add `/embed/:embed_code` route with minimal layout
- [ ] Match layouts to minimal & clean design (2 steps)
  - [ ] Update app.css with minimal theme (light mode, clean typography)
  - [ ] Update root.html.heex and Layouts.app to match design
- [ ] Update router with all routes (1 step)
- [ ] Visit app to verify functionality (1 step)
- [ ] Reserve 2 steps for debugging

## Future Widget Types
- Comments (threaded, real-time)
- Collaborative whiteboard/canvas
- Live reactions/emoji bar
- Newsletter signup
- Q&A board
