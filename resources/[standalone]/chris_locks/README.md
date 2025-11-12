# Chris Locks System

Premium, modular door-locking system for Qbox/QB-Core servers with ox_doorlock integration.

## Features
- Multiple lock types: password, item, job/gang, owner (business ready)
- Hidden interactions with `E` key (ox_target optional)
- Server-authoritative locking & auto relock timers
- Ox Lib notifications and React password modal
- Admin tooling: `/addlock`, `/removelock`, `/listlocks`, `/lockdebug`
- Full database persistence (MySQL)

## Installation
1. Copy `chris_locks` into `resources/[standalone]/`.
2. Add to your `server.cfg` after framework resources:
   ```cfg
   ensure ox_lib
   ensure oxmysql
   ensure ox_doorlock
   ensure qbx_core  # or qb-core
   ensure chris_locks
   ```
3. Import `sql/chris_locks.sql` or allow the resource to auto-create the table on first start.
4. (Optional) Build the premium NUI:
   ```bash
   cd resources/[standalone]/chris_locks/ui
   npm install
   npm run build
   ```

## Commands
- `/addlock <id> <type> <arg> <x> <y> <z> <radius> <doorId> <duration> <hidden>`
- `/removelock <id>`
- `/listlocks`
- `/lockdebug`

Grant admins access using ACE permissions:
```cfg
add_ace group.admin chrislocks.admin allow
```

## Exports
```lua
exports('isLocked', function(lockId) end)
exports('unlockDoor', function(lockId) end)
exports('lockDoor', function(lockId) end)
exports('addAuthorizedPlayer', function(lockId, identifier) end)
```

## Credits
- Author: Chris Hepburn
