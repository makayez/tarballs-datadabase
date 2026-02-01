# Tarball's Dadabase

World of Warcraft addon that automatically shares content (dad jokes, demotivational sayings, guild quotes) in party/raid chat based on configurable triggers.

## Features

- **Multiple Content Types:**
  - Dad Jokes - Classic groaners and puns
  - Demotivational Sayings - For when things go wrong
  - Guild Quotes - Your guild's memorable moments
- **Flexible Triggers:**
  - Party/Raid wipes
  - Personal death
- **Group Targeting:**
  - Enable separately for raids and parties
- **Full Content Management:**
  - Add/remove content for each type
  - Import new default content on updates
- In-game configuration panel with tabs for each content type
- Persistent settings across logins
- Manual commands for guild/say chat
- Modular architecture for easy expansion

## Installation

1. Download the addon files
2. Extract to `World of Warcraft/_retail_/Interface/AddOns/TarballsDadabase/`
3. Restart WoW or reload UI (`/reload`)

## Commands

```
/dadabase                    - Open configuration panel
/dadabase version            - Display addon version
/dadabase on                 - Enable all modules
/dadabase off                - Disable all modules
/dadabase say                - Send content (to party if grouped, raid if in raid, otherwise /say)
/dadabase guild              - Send content to guild chat
/dadabase cooldown <seconds> - Set global cooldown between messages (0-60)
/dadabase status             - Show current settings and module status
/dadabase debug              - Toggle debug mode
```

## Configuration

Access the configuration panel via `/dadabase` or through the WoW Interface Options under Addons.

### Settings Tab
- View current version
- Adjust global cooldown slider (0-60 seconds)

### Content Type Tabs (Dad Jokes, Demotivational, Guild Quotes)
Each content type has its own tab with:

**Enable/Disable:**
- Master toggle for the content type

**Triggers:**
- Party/Raid wipes - Send content when the group wipes
- Personal death - Send content when you die

**Groups:**
- Raids - Enable for raid groups
- Parties - Enable for party groups

**Content Management:**
- Edit all content in a multi-line text editor
- Add custom content (one per line)
- Remove any content (delete the line)
- Reset to defaults button available

## Content Database

The addon uses a change-tracking system to manage content efficiently. Default content is stored in the addon code, while only your customizations (additions and deletions) are saved to your SavedVariables. This means:
- New default content automatically appears when you update the addon
- Items you delete stay deleted (won't reappear in updates)
- Custom items you add are preserved across updates
- SavedVariables stays small regardless of content size

**Default Content:**
- Dad Jokes: 100+ classic dad jokes and puns (enabled by default for wipes in raids/parties)
- Demotivational: 30 demotivational sayings (disabled by default)
- Guild Quotes: Empty - populate with your guild's memorable quotes (disabled by default)

**How It Works:**
When a trigger event occurs (wipe or death), the addon:
1. Checks which content types are enabled
2. Filters by the current trigger type and group
3. Combines all matching content into a pool
4. Randomly selects one item to send

## Saved Variables

Settings are stored in `WTF/Account/<account>/SavedVariables/TarballsDadabase.lua`:
- `cooldown` - Global seconds between messages (default: 10)
- `debug` - Debug mode toggle (default: false)
- `modules` - Per-module settings:
  - `enabled` - Module enable/disable
  - `triggers` - Which triggers are active (wipe, death)
  - `groups` - Which groups are active (raid, party)
  - `userAdditions` - Custom content items you've added
  - `userDeletions` - Default items you've removed
  - `dbVersion` - Database version for tracking updates

## Architecture

The addon uses a modular architecture:
- `Database.lua` - Generic content management for all modules
- `Core.lua` - Event handling, triggers, slash commands
- `Config.lua` - Configuration panel framework
- `Modules/DadJokes.lua` - Dad jokes module
- `Modules/Demotivational.lua` - Demotivational sayings module
- `Modules/GuildQuotes.lua` - Guild quotes module

New content types can be easily added by creating a new module file.

## Version

Current version: 0.3.0
