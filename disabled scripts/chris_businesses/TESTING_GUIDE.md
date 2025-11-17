# Complete Testing Walkthrough - Chris Businesses

This guide will walk you through testing every feature of the business system step-by-step.

## Prerequisites Setup

### Step 1: Build the NUI Dashboard

```bash
# Navigate to web directory
cd resources/[standalone]/chris_businesses/web

# Install dependencies
npm install

# Build for production
npm run build
```

**Expected Result:** You should see a `dist/` folder created with built files.

### Step 2: Database Setup

1. Open your MySQL database (phpMyAdmin, HeidiSQL, etc.)
2. Select your FiveM database
3. Import `sql/chris_businesses.sql`
4. Verify tables created:
   - `chris_businesses`
   - `chris_transactions`
   - `chris_employees`

### Step 3: Add Business Laptop Item

Edit `resources/[ox]/ox_inventory/data/items.lua` and add:

```lua
['business_laptop'] = {
    label = 'Business Laptop',
    weight = 2000,
    stack = false,
    close = true,
    description = 'A laptop for managing your businesses'
}
```

### Step 4: Add to server.cfg

```cfg
ensure chris_businesses
```

### Step 5: Restart Server

Restart your FiveM server to load the resource.

---

## Testing Walkthrough

### PHASE 1: Admin Setup - Creating a Business

#### Test 1.1: Add Business via Database

1. Open your database
2. Run this SQL query:

```sql
INSERT INTO chris_businesses (
    name, 
    label, 
    coords, 
    price, 
    for_sale, 
    business_type,
    blip_sprite,
    blip_color,
    is_open
) VALUES (
    'downtown_247',
    'Downtown 24/7',
    '{"x": 25.0, "y": -1347.0, "z": 29.5}',
    40000,
    1,
    '247',
    52,
    2,
    1
);
```

**Expected Result:**
- Business created with ID 1
- Should appear in game after server restart

#### Test 1.2: Verify Business in Game

1. Join your server
2. Check map for blip at coordinates (25.0, -1347.0, 29.5)
3. Go to that location
4. You should see an ox_target interaction zone

**Expected Result:**
- Blue blip on map labeled "Downtown 24/7"
- Interaction zone when you approach

---

### PHASE 2: Player Purchase - Buying a Business

#### Test 2.1: Get Business Laptop

1. Give yourself the laptop item:
   ```
   /giveitem [your_id] business_laptop 1
   ```

2. Verify you have it in inventory

#### Test 2.2: Check Bank Balance

1. Check your bank balance (should have at least $40,000)
2. If not, give yourself money:
   ```
   /addmoney [your_id] bank 50000
   ```

#### Test 2.3: Purchase Business

1. Go to business location (25.0, -1347.0, 29.5)
2. Use ox_target (aim at the zone)
3. Select "Open Business Dashboard"
4. Dashboard should open showing:
   - Business name: "Downtown 24/7"
   - Price: $40,000
   - Status: For Sale
   - "Purchase" button available

5. Click "Purchase" button
6. Confirm the purchase

**Expected Result:**
- Notification: "Business purchased successfully"
- Dashboard refreshes showing you as owner
- Business no longer shows "For Sale"
- Your bank balance decreased by $40,000

#### Test 2.4: Verify Ownership

1. Check database:
   ```sql
   SELECT * FROM chris_businesses WHERE id = 1;
   ```
   - `owner_identifier` should be your citizenid
   - `for_sale` should be 0

2. Check Renewed-Banking (if enabled):
   - Account `business_1` should exist
   - Balance should be $0

---

### PHASE 3: Dashboard Overview

#### Test 3.1: Access Dashboard

1. Go to business location
2. Use ox_target → "Open Business Dashboard"
3. Dashboard opens with Overview tab

**Expected Result:**
- Sidebar with 5 tabs visible
- Overview tab showing:
  - Balance: $0
  - Employees: 0
  - Stock Items: 0
  - Status: Open
- Weekly profit chart (may show mock data)
- Recent transactions section

#### Test 3.2: Navigate Tabs

Click through each tab:
- Overview ✓
- Stock ✓
- Employees ✓
- Finance ✓
- Settings ✓

**Expected Result:**
- Each tab loads correctly
- No errors in F8 console

---

### PHASE 4: Stock Management

#### Test 4.1: Add Stock via ox_inventory

1. Open F8 console
2. Run this command:
   ```lua
   exports.ox_inventory:AddItem('business_1', 'water', 50)
   ```

**Expected Result:**
- 50 water bottles added to business inventory

#### Test 4.2: View Stock in Dashboard

1. Open business dashboard
2. Go to "Stock" tab
3. Should see "water" with quantity 50

**Expected Result:**
- Stock tab shows:
  - Item name: "water"
  - Label: "Water" (from ox_inventory)
  - Quantity: 50 units
  - Green indicator (stock > 10)

#### Test 4.3: Test Low Stock Alert

1. Remove most stock:
   ```lua
   exports.ox_inventory:RemoveItem('business_1', 'water', 45)
   ```

2. Refresh dashboard (click refresh button)
3. Go to Stock tab

**Expected Result:**
- Water shows 5 units
- Red "Low stock" indicator
- Yellow alert banner at top: "1 item(s) are running low"

---

### PHASE 5: Employee Management

#### Test 5.1: Hire an Employee

1. Open dashboard → Employees tab
2. Click "Hire Employee" button
3. Modal opens with fields:
   - Citizen ID
   - Role (dropdown: Employee or Manager)

4. Enter:
   - Citizen ID: [Another player's citizenid or test ID]
   - Role: "Employee"

5. Click "Submit"

**Expected Result:**
- Success notification: "Employee hired successfully"
- Employee appears in list
- Shows name, role, citizenid

#### Test 5.2: Verify Employee in Database

```sql
SELECT * FROM chris_employees WHERE business_id = 1;
```

**Expected Result:**
- Row exists with:
  - `business_id`: 1
  - `citizenid`: The one you entered
  - `role`: "employee"
  - `permissions`: JSON with employee permissions

#### Test 5.3: Hire a Manager

1. Click "Hire Employee" again
2. Enter different citizenid
3. Select role: "Manager"
4. Submit

**Expected Result:**
- Manager appears in list
- Shows blue "Manager" badge
- Different icon than employee

#### Test 5.4: Test Permissions

**As Employee:**
1. Have another player (the employee) join
2. They go to business location
3. Use laptop to open dashboard
4. Try to access different tabs

**Expected Result:**
- Employee can VIEW all tabs
- Employee CANNOT:
  - Hire/fire employees
  - Deposit/withdraw money
  - Change settings

**As Manager:**
1. Have manager player open dashboard
2. Test permissions

**Expected Result:**
- Manager CAN:
  - Hire/fire employees
  - Manage stock
  - Deposit/withdraw money
- Manager CANNOT:
  - Change business settings
  - List for sale

#### Test 5.5: Fire Employee

1. As owner, go to Employees tab
2. Find an employee
3. Click "Fire" button
4. Confirm in modal

**Expected Result:**
- Success notification
- Employee removed from list
- Database row deleted

---

### PHASE 6: Financial Management

#### Test 6.1: Deposit Money

1. Open dashboard → Finance tab
2. Click "Deposit Money"
3. Modal opens
4. Enter amount: 1000
5. Click "Submit"

**Expected Result:**
- Success notification: "Deposit successful"
- Balance updates to $1,000
- Transaction appears in history
- Your bank balance decreased by $1,000

#### Test 6.2: Verify Transaction Log

1. Check Finance tab → Transaction History
2. Should see deposit entry:
   - Type: "deposit"
   - Amount: $1,000
   - Description: "Deposit from [Your Name]"
   - Timestamp

#### Test 6.3: Check Database Transaction

```sql
SELECT * FROM chris_transactions WHERE business_id = 1 ORDER BY timestamp DESC LIMIT 1;
```

**Expected Result:**
- Transaction record exists
- Type: "deposit"
- Amount: 1000
- citizenid: Your citizenid

#### Test 6.4: Withdraw Money

1. Finance tab → "Withdraw Money"
2. Enter amount: 500
3. Submit

**Expected Result:**
- Success notification
- Balance decreases to $500
- Your bank balance increases by $500
- Transaction logged

#### Test 6.5: Test Insufficient Funds

1. Try to withdraw $10,000 (more than balance)
2. Submit

**Expected Result:**
- Error notification: "Insufficient business funds"
- Balance unchanged
- No transaction created

---

### PHASE 7: Storefront Sales (Customer Experience)

#### Test 7.1: Set Up Shop

1. As owner, ensure business is "Open" (Settings tab)
2. Ensure stock exists (we have 5 water bottles)

#### Test 7.2: Customer Purchase (Simplified - Full shop UI would need implementation)

**Note:** The shop interface is prepared but needs full implementation. For now, test via exports:

1. As a different player (customer)
2. Go to business location
3. Use ox_target → "Browse Store"

**Current State:** Shows notification "Shop interface coming soon"

**To test sales manually:**
```lua
-- In F8 console, simulate a purchase
TriggerServerEvent('chris_businesses:purchaseItem', 1, 'water', 1, 5)
```

**Expected Result:**
- Customer loses $5 cash
- Customer gains 1 water
- Business inventory loses 1 water
- Business account gains $5
- Transaction logged

#### Test 7.3: Verify Sale Transaction

1. As owner, check Finance tab
2. Transaction history should show:
   - Type: "sale"
   - Amount: $5
   - Description: "Sale: water x1"

---

### PHASE 8: Settings Management

#### Test 8.1: Change Business Name

1. Dashboard → Settings tab
2. Click "Edit" next to Business Name
3. Enter new name: "Premium 24/7 Downtown"
4. Submit

**Expected Result:**
- Success notification
- Name updates in dashboard
- Database updated

#### Test 8.2: Toggle Open/Closed

1. Settings tab
2. Toggle switch next to "Business Status"
3. Click to close business

**Expected Result:**
- Status changes to "Closed"
- Toggle shows red/closed state
- Database `is_open` = 0

4. Toggle back to open

**Expected Result:**
- Status: "Open"
- Toggle shows green/open state

#### Test 8.3: List Business for Sale

1. Settings tab → Owner Actions
2. Click "List Business for Sale"
3. Enter price: 50000
4. Submit

**Expected Result:**
- Success notification
- Business now shows "For Sale" in database
- Price updated to $50,000
- Other players can now purchase it

---

### PHASE 9: Selling Business

#### Test 9.1: Sell to Another Player

1. As current owner, list business for sale (from Test 8.3)
2. Have another player approach business
3. They use laptop → Open dashboard
4. They see "Purchase" button (business is for sale)
5. They click Purchase

**Expected Result:**
- New player becomes owner
- Old owner's ownership removed
- Money transferred to new owner's bank
- Business account remains (balance stays)

#### Test 9.2: Verify Transfer

1. Check database:
   ```sql
   SELECT owner_identifier, owner_name, for_sale FROM chris_businesses WHERE id = 1;
   ```

**Expected Result:**
- `owner_identifier`: New player's citizenid
- `owner_name`: New player's name
- `for_sale`: 0 (no longer for sale)

---

### PHASE 10: Admin Commands

#### Test 10.1: Remove Business

1. As admin, run:
   ```
   /removebusiness 1
   ```

**Expected Result:**
- Success notification
- Business removed from database
- Blip removed from map
- Zones removed

#### Test 10.2: Add Business via Command

**Note:** The `/addbusiness` command needs coordinates. For now, use database method.

---

### PHASE 11: Exports Testing

#### Test 11.1: Get Owned Businesses

In F8 console:
```lua
local businesses = exports['chris_businesses']:GetOwnedBusinesses('YOUR_CITIZENID')
print(json.encode(businesses))
```

**Expected Result:**
- Returns array of businesses you own
- Shows all business data

#### Test 11.2: Add Stock via Export

```lua
exports['chris_businesses']:AddBusinessStock(1, 'bread', 20)
```

**Expected Result:**
- 20 bread added to business_1 inventory
- Appears in Stock tab

#### Test 11.3: Pay Employee via Export

```lua
exports['chris_businesses']:PayEmployee(1, 'EMPLOYEE_CITIZENID', 500)
```

**Expected Result:**
- $500 removed from business account
- $500 added to employee's bank
- Transaction logged

---

### PHASE 12: Edge Cases & Error Handling

#### Test 12.1: Purchase Without Funds

1. Give yourself only $100
2. Try to buy business for $40,000

**Expected Result:**
- Error: "Insufficient funds"
- Purchase fails
- No ownership change

#### Test 12.2: Access Dashboard Without Laptop

1. Remove business_laptop from inventory
2. Try to open dashboard

**Expected Result:**
- Error: "You need a business laptop"
- Dashboard doesn't open

#### Test 12.3: Employee Tries to Withdraw

1. As employee, open dashboard
2. Go to Finance tab
3. Try to withdraw money

**Expected Result:**
- Withdraw button may not appear (permission check)
- Or error: "You do not have permission"

#### Test 12.4: Purchase Already Owned Business

1. Business is owned
2. Another player tries to purchase

**Expected Result:**
- Error: "Business is already owned"
- Purchase fails

#### Test 12.5: Close Business, Try to Shop

1. Owner closes business
2. Customer tries to use shop

**Expected Result:**
- Error: "This business is currently closed"
- Shop doesn't open

---

## Verification Checklist

After completing all tests, verify:

- [ ] Database tables created correctly
- [ ] NUI dashboard builds and loads
- [ ] Business blips appear on map
- [ ] ox_target zones work
- [ ] Purchase flow works end-to-end
- [ ] Dashboard all tabs functional
- [ ] Stock management works
- [ ] Employee hire/fire works
- [ ] Permissions enforced correctly
- [ ] Financial transactions work
- [ ] Settings can be changed
- [ ] Business can be listed for sale
- [ ] Business can be sold to another player
- [ ] Renewed-Banking integration works (if enabled)
- [ ] Transaction logging works
- [ ] Exports function correctly
- [ ] Error handling works
- [ ] No F8 console errors

---

## Common Issues & Solutions

### Issue: Dashboard doesn't open
**Solution:** 
- Check NUI built: `npm run build` in web folder
- Check fxmanifest.lua paths
- Check F8 console for errors

### Issue: "Business not found"
**Solution:**
- Verify business exists in database
- Check business ID is correct
- Restart resource: `restart chris_businesses`

### Issue: Can't purchase business
**Solution:**
- Check `for_sale = 1` in database
- Check `owner_identifier IS NULL`
- Verify player has enough money
- Check server console for errors

### Issue: Stock not showing
**Solution:**
- Verify ox_inventory storage exists: `business_1`
- Check items are actually in storage
- Refresh dashboard

### Issue: Renewed-Banking not working
**Solution:**
- Check Renewed-Banking is started
- Check Config.Banking.Enabled = true
- Verify account creation in Renewed-Banking database

---

## Performance Testing

1. **Load Test:**
   - Create 50 businesses
   - Verify all blips load
   - Check server performance

2. **Concurrent Access:**
   - Multiple players access same business
   - Multiple transactions simultaneously
   - Verify no race conditions

3. **Database Performance:**
   - Check query times
   - Verify indexes working
   - Monitor transaction table growth

---

## Final Notes

- All features should work smoothly
- No errors in F8 console
- Database remains consistent
- Permissions properly enforced
- Money transactions accurate

If any test fails, check:
1. F8 console for errors
2. Server console for errors
3. Database for data consistency
4. Resource restart if needed

Good luck testing! 🚀

