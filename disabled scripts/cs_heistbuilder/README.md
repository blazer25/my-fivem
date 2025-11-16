# CS Heist Builder Framework

Premium, modular Qbox-ready heist framework with a full in-city builder workflow, reputation gating, police integration, cinematic step handling, and dual storage (JSON/MySQL).

## Features
- Config-driven heists with modular step types defined in `shared/heist_types.lua`.
- `/hb` command suite for creating/customising heists in-game (entry capture, steps, guards, loot, testing).
- Reputation system with configurable gains/losses and tier locks.
- Police integration (dispatch alerts, evidence hooks, last-known blips, CCTV triggers).
- Cinematic client experience (thermite FX, drilling animations, loot grabs, progress UI, sound cues).
- Storage toggle: JSON files under `configs/heists/` or MySQL table `heistbuilder_heists`.
- ox_lib callbacks + qbx_core detection, works with ox_target, ox_inventory.

## Installation
1. Drop `cs_heistbuilder` into your resources folder.
2. Ensure dependencies (`ox_lib`, `ox_target`, `ox_inventory`, `qbx_core`, `oxmysql`).
3. Add `ensure cs_heistbuilder` to `server.cfg` after dependencies.
4. Import MySQL schema when using SQL storage:
   ```sql
   CREATE TABLE IF NOT EXISTS heistbuilder_heists (
     heist_id VARCHAR(64) PRIMARY KEY,
     data LONGTEXT NOT NULL
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
   ```
5. Grant builder permission via ACE (`add_ace group.admin command.heistbuilder allow`) or qbx group.
6. Restart the server.

## Configuration Overview
- `shared/config_heists.lua` defines global settings (`Storage`, `Reputation`, `Evidence`, `Dispatch`, `RewardPools`).
- `Config.Heists` contains example entries. Each includes:
  ```lua
  {
      id = 'fleeca_boulevard',
      label = 'Fleeca: Boulevard',
      tier = 2,
      requiredPolice = 3,
      cooldownMinutes = 45,
      entryPoint = { x = -354.4, y = -55.1, z = 49.0 },
      escapeRadius = 50.0,
      minPlayers = 2,
      maxPlayers = 4,
      steps = { { type = 'cut_power', ... }, ... },
      guards = { { weapon = 'WEAPON_CARBINERIFLE', coords = {...} } },
      rewards = { cash = { min = 120000, max = 180000 }, items = { { item = 'goldbar', count = 2 } } },
      evidence = { dna = true, cctv = true }
  }
  ```
- Storage toggle: set `Config.Storage.Mode` to `json` or `mysql`. JSON files live in `configs/heists/<id>.json`.

## Step Types (`shared/heist_types.lua`)
| Type            | Description                                    |
|-----------------|------------------------------------------------|
| `hack_panel`    | Progress-based hacking minigame placeholder    |
| `disable_alarm` | Cuts alarm grid, reduces dispatch severity     |
| `cut_power`     | Thermite FX to blackout whole building         |
| `drill_boxes`   | Drill animation for lockboxes                  |
| `grab_loot`     | Loot animation with bagging FX                 |
| `thermal_charge`| Vault breaching VFX/SFX                        |
| `safe_crack`    | Tumblers sequence + server-generated code      |
| `escape`        | Reach the configured escape radius             |

Add new step types by extending `HeistStepTypes` structure (each entry defines `startClient` + `startServer`).

## Admin Commands (In-Game `/hb`)
- `/hb create <id>` – start new draft.
- `/hb setlabel <label>` – update draft name.
- `/hb setentry` – capture current coords as entry.
- `/hb addstep <type>` – add step at look direction.
- `/hb addguard <weapon>` – add guard spawn & weapon.
- `/hb addloot <type>` – add loot/reward entry.
- `/hb save` – persist to storage (JSON/MySQL).
- `/hb test` – instantly start heist for yourself.
- `/hb help` – view quick reference.

## Runtime Flow
1. Heists loaded from storage (or defaults) into server cache.
2. Players can start heists via UI/command if reputation, cooldown, and police requirements are met.
3. Client executes each step via modular handlers; server validates results and fires dispatch/evidence hooks.
4. Successful runs pay out `rewards` and reputation; failures deduct rep and notify police.

## Customisation Tips
- Expand `Config.RewardPools` for randomised payouts and use them in heist rewards.
- Add new guard templates or integrate NPC spawners inside `server/main.lua` (hooks provided).
- Use `CS_HEIST_STEP_TYPES` to register bespoke interactions (e.g., laser grid minigame, hacking UI, CCTV camera puzzle).
- Toggle storage mode per environment (JSON for dev, MySQL for live).

## Troubleshooting
- Missing commands? Ensure ACE `command.heistbuilder` or qbx admin group is granted.
- No heists listed? Create one via `/hb create` then `/hb save`, or seed `Config.Heists` entries.
- Dispatch not firing? Confirm police resource listens to `cs_heistbuilder:client:dispatch` (wrapper provided in `client/police.lua`).
- ox_lib errors? Update to latest release; this resource uses context menus, progress circles, and callbacks.

Happy building and stay cinematic! 💼
