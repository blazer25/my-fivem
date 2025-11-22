# Character Selector & Black Screen Fix

## Issues Fixed

### 1. Character Not Showing in Preview
**Problem:** Character preview was failing because it tried to use illenium-appearance which might not be installed.

**Fix:**
- Added checks for illenium-appearance availability before using it
- Made preview work even without appearance data
- Added error handling for appearance application

### 2. Black Screen After Character Selection
**Problem:** Player was spawning before PlayerData was synced from server, causing black screen.

**Fixes Applied:**
- Added proper wait mechanism for PlayerData to be available
- Added event listener for `QBCore:Client:OnPlayerLoaded` to know when data is ready
- Improved spawn logic with proper fade in/out handling
- Added timeout protection (10 seconds max wait)
- Ensured player spawns at correct position even if data isn't ready

### 3. Character Loading Callback
**Problem:** Server callback wasn't returning success status properly.

**Fix:**
- Added return value to `bub-multichar:server:loadCharacter` callback
- Client now checks if character loaded successfully before spawning

## Files Modified

1. **resources/[standalone]/bub-multichar/client/main.lua**
   - Fixed `previewPed()` to handle missing illenium-appearance
   - Fixed `randomPed()` to handle missing illenium-appearance
   - Fixed `spawnLastLocation()` to wait for PlayerData
   - Fixed `playCharacter` callback to handle loading properly
   - Added `playerDataReady` flag and event listener

2. **resources/[standalone]/bub-multichar/server/main.lua**
   - Fixed `loadCharacter` callback to return success status

## How It Works Now

1. **Character Preview:**
   - Checks if character has appearance data
   - If illenium-appearance is available, applies it
   - Falls back to random ped if no data available
   - Works even without illenium-appearance installed

2. **Character Selection:**
   - Fades out screen
   - Loads character on server
   - Waits for PlayerData to sync (with timeout)
   - Spawns player at last known position (or default spawn)
   - Triggers player loaded events
   - Fades in screen

3. **Error Handling:**
   - If character load fails, shows error and doesn't spawn
   - If PlayerData doesn't sync in 10 seconds, uses default spawn
   - All appearance operations are wrapped in pcall for safety

## Testing

After restarting bub-multichar:

1. **Character Preview:**
   - [ ] Characters show in selector (even without appearance data)
   - [ ] No errors in console about illenium-appearance

2. **Character Selection:**
   - [ ] Screen fades out when selecting character
   - [ ] Character loads successfully
   - [ ] Screen fades in after spawn
   - [ ] Player spawns at correct location
   - [ ] No black screen

3. **New Character Creation:**
   - [ ] Can create new character
   - [ ] Appearance menu opens (if illenium-appearance installed)
   - [ ] Character spawns correctly after creation

## Next Steps

1. **Restart bub-multichar:**
   ```bash
   restart bub-multichar
   ```

2. **Test character selection:**
   - Login to server
   - Select a character
   - Verify no black screen
   - Verify character spawns correctly

3. **If issues persist:**
   - Check server console for errors
   - Verify qbx_core is loading PlayerData correctly
   - Check if illenium-appearance is needed (for appearance preview)

