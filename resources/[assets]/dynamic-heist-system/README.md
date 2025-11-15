# Dynamic Heist System

## Overview
The Dynamic Heist System is a framework-agnostic heist ecosystem for FiveM. It includes scalable difficulty, loot tables, evidence simulation, dispatch payloads, and storyline-ready progression hooks. Works with **ESX**, **QBCore**, or standalone economies.

## Feature Highlights
- **Heist Catalog:** Fleeca, Jewellery, Warehouse Drug Steal, Scrap Yard, Armored Truck, Mansion infiltration – each defined via config only.
- **Dynamic Difficulty:** Police-count tier locking, cooldown stretching/shrinking based on response speed, reputation requirements.
- **Loot Economy:** Tiered cash, marked bills, valuables, contraband, cyber items, plus hooks to unlock blackmarket vendors or crafting recipes.
- **Evidence & Countermeasures:** DNA, prints, hair, tamper logs with mitigation items (gloves, masks, bleach, jammers).
- **Dispatch Suite:** Alarm metadata, stage info, GPS waypoints, and evidence logs routed to on-duty police.
- **Storyline Ready:** Reputation progression, tier unlocks, NPC quest hooks, and configurable bonuses for chain heists.

## Setup Instructions
1. Extract the project into your FiveM resources folder.
2. Add the following to your `server.cfg`:
   ```cfg
   ensure dynamic-heist-system
   ```
3. Edit `config/config.lua` to tune cooldown logic, loot tiers, evidence chances, and heist definitions.

## Configuration Guide
- **Global Controls:** `Config.GlobalCooldown`, `Config.PoliceScaling`, `Config.Progression`, `Config.Evidence`, and `Config.LootTiers`.
- **Per-Heist Entries (`Config.Heists`)**  
  Each heist defines label, map coordinates, trigger radius, required police/tools, tier, stages, response presets, rewards, and cooldown. Add new entries to introduce more content with no code changes.
- **Framework Selection:** Set `Config.Framework` to `qb`, `esx`, or `standalone`. QBCore/ESX grants payouts directly; standalone emits `heist:receiveLoot` for custom handling.

## Server Logic
- `server/heist_logic.lua`: Manages state machine, reputation, cooldowns, loot distribution, evidence creation, and hooks (`heist:onStart`, `heist:onComplete`, `heist:onFail`, `heist:lootGranted`, `heist:unlockBlackmarket`).
- `server/police_alerts.lua`: Builds dispatch payloads, selects on-duty police, relays alerts + evidence snapshots, and exposes `exports("GetEvidenceLog")`.

## Client Logic
- `client/main.lua`: Detects heist hotspots, requests access, runs stage timers, plays animations, and reacts to completion/failure events.
- `client/ui.lua`: Lightweight helpers for 3D prompts, notifications, and progress placeholders. Swap with your custom NUI/progress bars if desired.
- `client/animations.lua`: Central place for drilling/thermite/C4/loot/zip-tie animations or scenario fallbacks.

## Commands & Events
- `/start_heist <heistId> [playerId]` (ACE `heist.admin` or console) – force start a heist for testing. Defaults to Fleeca and the caller.
- Client event `heist:requestStart` is fired automatically when players press `E` near configured locations.
- Police integrations subscribe to `heist:policeAlert` for HUD overlays/radios; criminals listen to `heist:notify` / `heist:complete`.

## In-Game Admin Editing
Administrators with ACE `heist.admin` can change heist definitions live via `/heistadmin`:
- `list`, `info <id>` – inspect registered heists.
- `create <id>`, `delete <id>` – manage entries (new heists default to player location overrides).
- `setpos <id> [radius]`, `set <id> <label|tier|radius|requiredPolice|cooldown> <value>` – update metadata directly at your character's position.
- `stageadd <id> <type> <duration> <label>`, `stagedel <id> <index>` – curate multi-step flows.
- `items <id> item1,item2`, `responses <id> <alarm> [dispatch]`, `rewards <id> <tier> [bonus list]` – connect requirements, dispatch payloads, rewards.
- `save`, `reload` – persist or restore overrides via `data/heists.json`.

Changes broadcast instantly to connected players; saved data survives restarts without touching Lua files.

## Evidence & Counterplay
Players leave DNA, fingerprints, hair, and tamper logs unless they bring mitigation items listed in `Config.Evidence.mitigationItems`. Integrate these items with your inventories to reward planning.

## Testing & Balancing Checklist
1. **Base Flow**
   - `/start_heist fleeca` while standing near the entrance.
   - Complete each stage and confirm payouts + cooldowns update.
2. **Police Scaling**
   - Toggle on-duty cops (ACE `heist.police` or framework jobs) and verify tier gating.
3. **Evidence**
   - Run stages without gloves/masks to ensure `heist:evidenceGenerated` logs data. Re-run with mitigation items flagged in metadata to see drops decrease.
4. **Dispatch**
   - Join as police and confirm `heist:policeAlert` sets a waypoint, prints stage info, and logs evidence.
5. **Progression**
   - Use `exports['dynamic-heist-system']:GetHeistReputation(playerId)` to observe reputation changes after success/failure.
6. **Economy Hooks**
   - Verify loot cascades into crafting/blackmarket unlock events (`heist:unlockBlackmarket`).

Document additional internal test cases (solo vs. squad, low vs. high police) in your staff wiki as you extend the system.

## Upgrade Roadmap Ideas
- **NPC & Guard AI:** smarter patrol routes, randomized guard compositions, panic behaviors, surrendered hostages, and reinforcement timers tied to alarm states.
- **Content Packs:** turnkey configs for Fleeca, Vangelico, Armored Truck, Mansion, Warehouse, CEO Labs, Dockyard containers, Factory blueprints, Casino backroom, each with unique tools/rewards.
- **Economy Links:** craft-only items from heists powering advanced drug production, unlocking blackmarket stock, backroom business upgrades, and laundering mechanics.
- **Heist Reputation:** expand `Config.Progression` into a server-wide storyline where tiers (stores → warehouses → banks → trucks → casino) require successful escapes and special tools.
- **Police Gameplay:** extend `server/police_alerts.lua` hooks for CCTV feeds, DNA scanners, casing tracking, alarm terminals, dispatch map zones, helicopter spotlight AI, spike strips, and forensic evidence flows.

## Notes
This project was built with simplicity in mind and serves as a foundation for more advanced heist systems. Contributions and suggestions are welcome!

---

### Created by: AlexFutureDev  
Email: alex.future.dev@example.com  
Learning Software Engineering | Age: 18  
