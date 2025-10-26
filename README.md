# Kami-no-Niwa (Discord Activity Frontend)

Cozy, community-driven garden inspired by the PVZ Zen Garden. This repository is for the Activity frontend only (static HTML/JS). The Discord bot and backend API live in a separate repository/service.

## Contents

- `full_garden.html` — The interactive garden UI (drag & drop items, 4x8 grid, events). Works in two modes:
  - Demo mode (no backend): local state only with default items
  - Connected mode (with backend API): loads/persists state per guild
- `db_schema.sql` — SQL schema for your PostgreSQL (used by the backend/bot service)
- `apply_schema.py` — Helper to apply the schema if you don’t have `psql`

## Running the Activity

Open `full_garden.html` directly for demo mode.

To connect it to your bot/backend API, open it with query params:

```
full_garden.html?api=https://your-bot.example.com/api&guild=<discord_guild_id>
```

- `api`: Base URL to your bot’s API (will auto-append `/api` if missing)
- `guild`: The Discord Guild ID; the backend should segregate state per guild

When `api` is omitted, the Activity runs fully client-side with demo inventory values.

## Backend expectations (lives in the bot repo)

Expose endpoints under the given `api` base:

- `GET /garden/:guildId` → `{ slots, inventory, currency, species }`
- `POST /garden/:guildId/plant` → `{ slot_index, species_id }`
- `POST /garden/:guildId/action` → `{ slot_index, action }` where action ∈ [water, fertilizer, bugSpray, music]

Use `db_schema.sql` to create the required tables. Your bot can also manage currency, seed drops, events, and alerts.

## Deploying as an Activity

- Host this static page via your preferred method (GitHub Pages or a static host)
- Register it in the Discord Developer Portal as an Activity (Embedded App) and point to the hosted URL
- Your bot service (separate repo) should expose the API URL you pass via `?api=...`

## Notes

- The UI will gracefully fall back to demo mode if the API is unreachable or not provided.
- Seeds are tracked per species in the database; the UI currently shows a combined seed count from the API. You can extend the UI to show per-species counts.
