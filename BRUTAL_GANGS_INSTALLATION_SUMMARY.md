# Brutal Gangs Installation Summary

## ✅ Installation Completed

All installation steps have been completed according to the official installation guide.

---

## 📋 Completed Steps

### 1. ✅ SQL File Created
- Created `resources/[standalone]/brutal_gangs/brutal_gangs.sql`
- Contains SQL to create `brutal_gangs` table
- Contains SQL to add `gang_rank` and `last_gang` columns to `players` table

**⚠️ IMPORTANT: You still need to import this SQL file into your database!**

### 2. ✅ Configuration Updated
- Changed `Config.Core` from 'ESX' to 'QBCORE' in `config.lua`
- Loaded event verified: Already set to 'QBCore:Client:OnPlayerLoaded' ✅

### 3. ✅ Server Configuration
- Added `ensure brutal_gangs` to `server.cfg` at line 140
- Positioned correctly after [standalone] folder load
- Loads after qbx_core and dependencies

### 4. ✅ Required Items Added
- Added `spraycan` item to `ox_inventory/data/items.lua`
- Added `sprayremover` item to `ox_inventory/data/items.lua`
- Items configured with proper weight, stack, and close settings

### 5. ✅ QBOX Core Modifications
- **Modified `qbx_core/server/commands.lua`**: Updated setgang command to trigger `brutal_gangs:server:qbcore-gang-update` event
- **Modified `qbx_core/shared/gangs.lua`**: Cleared all gangs, kept only 'none' gang
- **Created backup**: `qbx_core/shared/gangs.lua.backup` (original file saved)

### 6. ⚠️ Webhook Configuration (Optional)
- Webhook file exists at `sv_utils.lua`
- Currently set to placeholder: `'YOUR-WEBHOOK'`
- Can be configured later if needed

---

## 🔴 Action Required

### MUST DO BEFORE USING:
1. **Import SQL File**: 
   - Import `resources/[standalone]/brutal_gangs/brutal_gangs.sql` into your database
   - This creates the `brutal_gangs` table and adds columns to `players` table

2. **Remove Players from Gangs**:
   - **CRITICAL**: Make sure NO players are in any gang in the database before starting the server
   - The `gangs.lua` file has been cleared, so existing gang memberships will cause errors
   - You can use SQL to set all players' gangs to 'none' before starting

### Optional:
3. **Configure Discord Webhook** (if desired):
   - Edit `resources/[standalone]/brutal_gangs/sv_utils.lua`
   - Replace `'YOUR-WEBHOOK'` with your Discord webhook URL

---

## 📝 Files Modified

1. ✅ `resources/[standalone]/brutal_gangs/config.lua` - Core changed to QBCORE
2. ✅ `server.cfg` - Added ensure brutal_gangs
3. ✅ `resources/[ox]/ox_inventory/data/items.lua` - Added spraycan and sprayremover
4. ✅ `resources/[qbx]/qbx_core/server/commands.lua` - Modified setgang command
5. ✅ `resources/[qbx]/qbx_core/shared/gangs.lua` - Cleared gangs (backup created)

---

## 📝 Files Created

1. ✅ `resources/[standalone]/brutal_gangs/brutal_gangs.sql` - SQL import file
2. ✅ `resources/[qbx]/qbx_core/shared/gangs.lua.backup` - Backup of original gangs file

---

## ⚠️ Important Notes

1. **Players Must Be Removed from Gangs First**: 
   - Before starting the server, ensure all players have their gang set to 'none' in the database
   - The installation guide specifically states: "Before you do this step make sure that none of the players are in any gang in the sql"

2. **Gang Creation**:
   - Gangs will now be created and managed through the Brutal Gangs system
   - The old static gangs (lostmc, ballas, vagos, etc.) have been removed
   - Players will create gangs through the in-game gang menu

3. **SetGang Command**:
   - The setgang command now properly triggers Brutal Gangs events
   - This ensures proper integration between qbx_core and brutal_gangs

4. **Items**:
   - Spray can and spray remover items are now in the inventory
   - These are required for graffiti creation/removal features

---

## 🧪 Testing Checklist

After importing SQL and clearing player gangs:

- [ ] Server starts without errors
- [ ] Resource `brutal_gangs` loads successfully
- [ ] Gang menu opens with `/gangmenu` command
- [ ] Can create a new gang
- [ ] Can add members to gang
- [ ] Spray can item works for graffiti
- [ ] Spray remover item works
- [ ] SetGang command works for admins

---

## 📚 Additional Resources

- Installation Guide: https://docs.brutalscripts.com
- Discord Support: https://discord.gg/85u2u5c8q9

---

## ✅ Installation Status: COMPLETE

All code modifications are complete. The only remaining steps are:
1. Import the SQL file
2. Clear player gangs from database
3. Restart server

