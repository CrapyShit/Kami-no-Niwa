-- PostgreSQL schema for the Kami‑no‑Niwa community garden activity.

-- The gardens table stores each Discord server's garden.  Each guild
-- corresponds to one garden.  Additional gardens could be added for
-- different channels if desired.
CREATE TABLE IF NOT EXISTS gardens (
    id SERIAL PRIMARY KEY,
    guild_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL DEFAULT 'Community Garden'
);

-- Species of plants available in the game.  Adding new species to this
-- table will allow more plant types without changing the schema.
CREATE TABLE IF NOT EXISTS species (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- Each plant instance that exists in a garden.  stage ranges from 1 to 3.
-- last_watered and last_fertilized track when the plant was last cared for.
-- is_dead indicates if the plant has died due to neglect or an event.
CREATE TABLE IF NOT EXISTS plants (
    id SERIAL PRIMARY KEY,
    species_id INTEGER NOT NULL REFERENCES species(id),
    stage INTEGER NOT NULL CHECK (stage BETWEEN 1 AND 3),
    last_watered TIMESTAMP,
    last_fertilized TIMESTAMP,
    last_music TIMESTAMP,
    is_dead BOOLEAN NOT NULL DEFAULT FALSE
);

-- Slots represent the positions in a garden (0‑31).  Each slot belongs to
-- a garden and may contain a plant via the plant_id.  The unique
-- constraint ensures no duplicate slots per garden.
CREATE TABLE IF NOT EXISTS garden_slots (
    id SERIAL PRIMARY KEY,
    garden_id INTEGER NOT NULL REFERENCES gardens(id),
    slot_index INTEGER NOT NULL CHECK (slot_index BETWEEN 0 AND 31),
    plant_id INTEGER REFERENCES plants(id),
    UNIQUE (garden_id, slot_index)
);

-- Inventory tracks communal items (water, fertilizer, bug spray, music)
-- available to a garden.  Additional item_types can be added as needed.
CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    garden_id INTEGER NOT NULL REFERENCES gardens(id),
    item_type TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    UNIQUE (garden_id, item_type)
);

-- Currency holds the coin balance for a garden.  When plants drop coins
-- or users earn currency via the bot, update this table.
CREATE TABLE IF NOT EXISTS currency (
    id SERIAL PRIMARY KEY,
    garden_id INTEGER NOT NULL REFERENCES gardens(id),
    balance INTEGER NOT NULL DEFAULT 0,
    UNIQUE (garden_id)
);

-- Seed inventory tracks how many seeds of each species are available
-- for a garden.  This allows separate counts per plant species so
-- the shop can display seeds individually.  The UNIQUE constraint
-- prevents duplicate entries for the same garden/species.
CREATE TABLE IF NOT EXISTS seed_inventory (
    id SERIAL PRIMARY KEY,
    garden_id INTEGER NOT NULL REFERENCES gardens(id),
    species_id INTEGER NOT NULL REFERENCES species(id),
    quantity INTEGER NOT NULL DEFAULT 0,
    UNIQUE (garden_id, species_id)
);

-- Events record significant happenings (e.g., pests, droughts).  Each
-- event can target a specific plant (target_plant_id) or the entire garden.
CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    garden_id INTEGER NOT NULL REFERENCES gardens(id),
    event_type TEXT NOT NULL,
    description TEXT,
    target_plant_id INTEGER REFERENCES plants(id),
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved BOOLEAN NOT NULL DEFAULT FALSE
);

-- Seed some initial species entries.  You may run this only once; if
-- species already exist this will do nothing.
INSERT INTO species (id, name, description) VALUES
    (1, 'Murakami Flower', 'A colourful flower inspired by Takashi Murakami''s smiling blooms.'),
    (2, 'Blue Bloom', 'A serene blue flower that brings calm to the garden.'),
    (3, 'Violet Dream', 'A purple flower that thrives in dim light.'),
    (4, 'Golden Daisy', 'A sunny yellow flower that radiates warmth.'),
    (5, 'Spring Green', 'A fresh green bloom that symbolizes new beginnings.')
ON CONFLICT DO NOTHING;