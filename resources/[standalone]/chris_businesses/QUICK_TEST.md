# Quick Test Reference - Chris Businesses

## 🚀 Quick Start (5 Minutes)

### 1. Build NUI
```bash
cd resources/[standalone]/chris_businesses/web
npm install && npm run build
```

### 2. Import Database
```sql
-- Run sql/chris_businesses.sql in your database
```

### 3. Add Test Business
```sql
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('test_store', 'Test Store', '{"x": 25.0, "y": -1347.0, "z": 29.5}', 40000, 1, 'general', 52, 2, 1);
```

### 4. Give Yourself Items
```
/giveitem [id] business_laptop 1
/addmoney [id] bank 50000
```

### 5. Test Purchase
1. Go to coordinates: 25.0, -1347.0, 29.5
2. Use ox_target → "Open Business Dashboard"
3. Click "Purchase"
4. ✅ Done!

---

## 📋 Essential Commands

### Player Commands
```
/buybusiness [id]          - Open dashboard to buy
/sellbusiness [id] [price] - List for sale
/openbusiness [id]         - Open dashboard
```

### Admin Commands
```
/removebusiness [id]       - Delete business
```

### F8 Console (Testing)
```lua
-- Add stock
exports.ox_inventory:AddItem('business_1', 'water', 50)

-- Remove stock
exports.ox_inventory:RemoveItem('business_1', 'water', 10)

-- Check owned businesses
local biz = exports['chris_businesses']:GetOwnedBusinesses('CITIZENID')
print(json.encode(biz))

-- Add stock via export
exports['chris_businesses']:AddBusinessStock(1, 'bread', 20)
```

---

## 🧪 Test Scenarios (Copy-Paste Ready)

### Scenario 1: Full Purchase Flow
```
1. /giveitem [id] business_laptop 1
2. /addmoney [id] bank 50000
3. Go to business location
4. Use ox_target → Open Dashboard
5. Click Purchase
6. ✅ Verify ownership in database
```

### Scenario 2: Stock Management
```lua
-- In F8 console:
exports.ox_inventory:AddItem('business_1', 'water', 50)
exports.ox_inventory:AddItem('business_1', 'bread', 30)
exports.ox_inventory:AddItem('business_1', 'phone', 5)
```
Then check Stock tab in dashboard.

### Scenario 3: Employee Test
```
1. Open dashboard → Employees tab
2. Click "Hire Employee"
3. Enter test citizenid: TEST001
4. Select role: Employee
5. Submit
6. ✅ Check database: SELECT * FROM chris_employees;
```

### Scenario 4: Financial Test
```
1. Dashboard → Finance tab
2. Deposit: $1000
3. Verify balance shows $1000
4. Withdraw: $500
5. Verify balance shows $500
6. ✅ Check transaction history
```

---

## 🔍 Quick Verification

### Check Database
```sql
-- All businesses
SELECT * FROM chris_businesses;

-- All employees
SELECT * FROM chris_employees;

-- Recent transactions
SELECT * FROM chris_transactions ORDER BY timestamp DESC LIMIT 10;
```

### Check Renewed-Banking
```sql
-- Business accounts
SELECT * FROM bank_accounts_new WHERE id LIKE 'business_%';
```

### Check ox_inventory Storage
```lua
-- In F8 console
local inv = exports.ox_inventory:GetInventory('business_1')
print(json.encode(inv.items))
```

---

## ⚠️ Common Issues

| Issue | Quick Fix |
|-------|-----------|
| Dashboard blank | Run `npm run build` in web folder |
| Can't purchase | Check `for_sale = 1` and `owner_identifier IS NULL` |
| Stock not showing | Verify storage `business_1` exists in ox_inventory |
| No blip on map | Check `Config.UseBlips = true` |
| Banking not working | Check Renewed-Banking is started |

---

## 📊 Expected Results Checklist

After testing, you should have:

- [ ] Business visible on map (blip)
- [ ] Can purchase business
- [ ] Dashboard opens and works
- [ ] All 5 tabs functional
- [ ] Stock management works
- [ ] Can hire/fire employees
- [ ] Can deposit/withdraw money
- [ ] Transactions logged
- [ ] Settings can be changed
- [ ] Business can be sold

---

## 🎯 10-Minute Full Test

1. **Setup (2 min)**
   - Build NUI: `npm run build`
   - Import SQL
   - Add test business (SQL above)

2. **Purchase (2 min)**
   - Give laptop + money
   - Go to location
   - Purchase business

3. **Stock (2 min)**
   - Add items via F8 console
   - Check Stock tab

4. **Employee (2 min)**
   - Hire test employee
   - Verify in database

5. **Finance (2 min)**
   - Deposit $1000
   - Withdraw $500
   - Check transactions

✅ **Done!** All core features tested.

---

## 🐛 Debug Mode

Enable in `config.lua`:
```lua
Config.Debug = true
```

This will show:
- ox_target debug zones
- Console logs
- Error details

---

## 📞 Need Help?

1. Check F8 console for errors
2. Check server console
3. Verify database data
4. Check resource restart: `restart chris_businesses`

---

**Happy Testing!** 🚀

