# Complete Installation Guide - Chris Businesses

## ✅ Pre-Installation Checklist

- [ ] FiveM Server running
- [ ] Qbox Framework (qbx_core) installed
- [ ] ox_lib installed
- [ ] oxmysql installed
- [ ] ox_inventory installed
- [ ] ox_target installed
- [ ] Renewed-Banking installed (optional but recommended)
- [ ] Node.js installed (for building NUI)

---

## 📦 Step 1: Install Resource

1. **Copy Resource Folder**
   - Ensure `chris_businesses` is in `resources/[standalone]/chris_businesses/`

2. **Verify File Structure**
   ```
   chris_businesses/
   ├── fxmanifest.lua
   ├── config.lua
   ├── shared.lua
   ├── client.lua
   ├── server.lua
   ├── sql/
   │   └── chris_businesses.sql
   └── web/
       └── dist/
           └── index.html
   ```

---

## 🗄️ Step 2: Database Setup

The resource will **automatically create tables** on first start, but you can also import manually:

### Option A: Automatic (Recommended)
- Just start the resource - tables are created automatically!

### Option B: Manual Import
1. Open your MySQL database (phpMyAdmin, HeidiSQL, etc.)
2. Select your FiveM database
3. Import `sql/chris_businesses.sql`
4. Verify 3 tables created:
   - `chris_businesses`
   - `chris_transactions`
   - `chris_employees`

---

## 🎒 Step 3: Add Business Laptop Item

The business laptop item has **already been added** to `resources/[ox]/ox_inventory/data/items.lua`:

```lua
['business_laptop'] = {
    label = 'Business Laptop',
    weight = 2000,
    stack = false,
    close = true,
    description = 'A laptop for managing your businesses...',
    client = {
        export = 'chris_businesses.useBusinessLaptop'
    }
}
```

**No action needed** - the item is ready to use!

---

## ⚙️ Step 4: Server Configuration

1. **Add to server.cfg**
   ```cfg
   ensure chris_businesses
   ```
   
   **OR** it will load automatically if you have:
   ```cfg
   ensure [standalone]
   ```

2. **Verify Load Order**
   Make sure these load BEFORE chris_businesses:
   ```cfg
   ensure ox_lib
   ensure oxmysql
   ensure ox_target
   ensure ox_inventory
   ensure qbx_core
   ```

---

## 🎨 Step 5: Build NUI Dashboard (Optional but Recommended)

For the full React dashboard interface:

1. **Navigate to web folder**
   ```bash
   cd resources/[standalone]/chris_businesses/web
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Build for production**
   ```bash
   npm run build
   ```

4. **Verify build**
   - Check that `web/dist/` folder contains built files
   - `index.html` should exist

**Note:** The placeholder HTML works for testing, but build the NUI for the full dashboard experience.

---

## 🚀 Step 6: Start Server

1. **Restart your FiveM server**
   - Full restart recommended for first installation

2. **Check Console**
   You should see:
   ```
   Started resource chris_businesses
   ```

3. **Verify No Errors**
   - No SQL errors
   - No missing file warnings (after build)
   - Tables created successfully

---

## ✅ Step 7: Verify Installation

### Test 1: Check Resource Started
In server console:
```
restart chris_businesses
```
Should see: `Started resource chris_businesses`

### Test 2: Check Database Tables
```sql
SHOW TABLES LIKE 'chris_%';
```
Should show 3 tables.

### Test 3: Give Yourself Laptop
In-game or via admin:
```
/giveitem [your_id] business_laptop 1
```

### Test 4: Create Test Business
```sql
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('test_store', 'Test Store', '{"x": 25.0, "y": -1347.0, "z": 29.5}', 40000, 1, 'general', 52, 2, 1);
```

### Test 5: Test in Game
1. Go to coordinates: `25.0, -1347.0, 29.5`
2. Use business laptop from inventory
3. Dashboard should open!

---

## 🎯 Quick Start Commands

### Give Items
```
/giveitem [id] business_laptop 1
/addmoney [id] bank 50000
```

### Admin Commands
```
/removebusiness [id]     - Delete business
```

### Player Commands
```
/buybusiness [id]        - Open dashboard to buy
/sellbusiness [id] [price] - List for sale
/openbusiness [id]       - Open dashboard
```

---

## 🔧 Configuration

Edit `config.lua` to customize:

- **Business Types**: Add/modify business types
- **Roles & Permissions**: Adjust employee permissions
- **Tax Rates**: Set default tax per business type
- **Banking**: Enable/disable Renewed-Banking integration
- **Webhooks**: Add Discord webhook URL for logging

---

## 🐛 Troubleshooting

### Resource Won't Start
- Check all dependencies are loaded
- Verify file paths in fxmanifest.lua
- Check server console for specific errors

### Database Errors
- Verify MySQL connection string in server.cfg
- Check database permissions
- Tables are created automatically - no manual import needed

### Laptop Item Not Working
- Verify item exists in ox_inventory/data/items.lua
- Restart ox_inventory: `restart ox_inventory`
- Check item name matches Config.LaptopItem

### Dashboard Won't Open
- Build NUI: `npm run build` in web folder
- Check browser console (F12) for errors
- Verify web/dist/index.html exists

### No Businesses Showing
- Add a business to database (see Test 4 above)
- Check business coordinates are valid
- Verify `for_sale = 1` for unowned businesses

---

## 📚 Next Steps

1. **Add Your First Business**
   - Use SQL or admin commands
   - Set coordinates, price, type

2. **Test Purchase Flow**
   - Give yourself laptop + money
   - Purchase business
   - Verify ownership

3. **Build Full NUI**
   - Install Node.js if not already
   - Build React dashboard
   - Enjoy full interface!

4. **Configure Settings**
   - Edit config.lua
   - Add business types
   - Set up webhooks

---

## 🎉 Installation Complete!

Your business system is now installed and ready to use!

**Need Help?**
- Check `TESTING_GUIDE.md` for full testing walkthrough
- Check `QUICK_TEST.md` for quick reference
- Review `README.md` for feature documentation

---

**Developed by Chris Stone**  
*Premium FiveM Resources*

