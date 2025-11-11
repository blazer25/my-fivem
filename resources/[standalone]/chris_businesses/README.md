# Chris Businesses - Dynamic Player-Owned Business System

A premium, production-grade business management system for Qbox-based FiveM servers. This script allows players to buy, own, and manage businesses dynamically within the city.

## Features

### 💼 Business Ownership
- Players can buy or sell businesses listed for sale using their bank account
- Ownership is stored in SQL via citizenid or license
- Admins can add, edit, or remove businesses (via command or Config file)
- Transfer ownership to another player
- License fee or daily upkeep tax support

### 🏪 Management Dashboard
- Modern React + Tailwind NUI dashboard accessible via business laptop
- Five main sections:
  - **Overview** – Shows profits, active employees, current stock, and performance graph
  - **Stock** – Displays all items in storage (from ox_inventory). Owners/managers can restock, adjust prices, or view sold-out warnings
  - **Employees** – Hire/fire players, assign roles, set pay percentages or permissions
  - **Finances** – View transaction history, deposit/withdraw funds from Renewed-Banking society account
  - **Settings** – Change business name, toggle open/closed, update blip color, or list it for resale
- Role-based permissions (owner, manager, employee) stored in SQL
- All major actions log to SQL and optionally to Discord webhook

### 🛍️ Storefront Integration
- Businesses can serve as physical shops
- Stock items come directly from the business's ox_inventory storage
- Prices are set by the owner in the dashboard
- Players purchase items normally through target/NUI shop menus
- Revenue goes into the business bank account
- When stock runs out, sales disable automatically

### 💰 Banking & Economy
- Uses Renewed-Banking for all monetary actions
- Deducts player funds when buying a business
- Creates linked business account when a new business is owned
- All store sales and stock purchases affect that account balance
- Deposits and withdrawals require finance permissions
- Configurable tax rate per business type
- Auto-payout of employee wages or profit shares every X hours (configurable)

### 🗺️ Map & Interaction
- Businesses have visible map blips with icons and colors based on type
- Owners can rename or recolor their blip via the dashboard
- ox_target zones for:
  - Opening laptop/dashboard
  - Managing shop inventory
  - Accessing storage/stock area
- Commands: `/buybusiness`, `/sellbusiness`, `/openbusiness`

## Requirements

- **FiveM Server** with latest artifacts
- **Qbox Framework** (qbx_core) or QB-Core (with bridge)
- **ox_lib** (v3.20.0+)
- **oxmysql** (latest)
- **ox_inventory** (v2.42.1+)
- **ox_target** (latest)
- **Renewed-Banking** (optional but recommended)

## Installation

1. **Download and Extract**
   ```bash
   cd resources/[standalone]
   git clone <repository-url> chris_businesses
   ```

2. **Install Dependencies**
   ```bash
   cd chris_businesses/web
   npm install
   npm run build
   ```

3. **Database Setup**
   - Import the SQL file: `sql/chris_businesses.sql`
   - This will create the necessary tables

4. **Add to Server Config**
   ```cfg
   ensure chris_businesses
   ```

5. **Configure**
   - Edit `config.lua` to customize business types, permissions, and settings
   - Add your Discord webhook URL if you want transaction logging

6. **Add Business Laptop Item**
   - Add `business_laptop` to your `ox_inventory/data/items.lua`:
   ```lua
   ['business_laptop'] = {
       label = 'Business Laptop',
       weight = 2000,
       stack = false,
       close = true,
       description = 'A laptop for managing your businesses'
   }
   ```

## Configuration

### Business Types
Edit `config.lua` to add or modify business types:

```lua
Config.BusinessTypes = {
    ['general'] = {
        label = 'General Store',
        blip = {
            sprite = 52,
            color = 2,
            scale = 0.8
        },
        defaultPrice = 50000,
        maxEmployees = 5,
        taxRate = 0.05
    },
    -- Add more types...
}
```

### Permissions
Modify role permissions in `config.lua`:

```lua
Config.Roles = {
    ['owner'] = {
        label = 'Owner',
        permissions = {
            manage_employees = true,
            manage_stock = true,
            manage_finances = true,
            manage_settings = true,
            view_reports = true
        }
    },
    -- ...
}
```

## Admin Commands

- `/addbusiness` - Add a new business (requires admin)
- `/removebusiness [id]` - Remove a business
- `/buybusiness [id]` - Open business dashboard to purchase
- `/sellbusiness [id] [price]` - List business for sale
- `/openbusiness [id]` - Open business dashboard

## Exports

### Server Exports

```lua
-- Get all businesses owned by a player
exports['chris_businesses']:GetOwnedBusinesses(citizenid)

-- Add stock to a business
exports['chris_businesses']:AddBusinessStock(businessId, item, amount)

-- Pay an employee
exports['chris_businesses']:PayEmployee(businessId, citizenid, amount)
```

### Client Exports

```lua
-- Open business dashboard
exports['chris_businesses']:OpenBusinessDashboard(businessId)

-- Close business dashboard
exports['chris_businesses']:CloseBusinessDashboard()

-- Refresh businesses
exports['chris_businesses']:RefreshBusinesses()
```

## Development

### Building the NUI

```bash
cd web
npm install
npm run dev  # Development mode with hot reload
npm run build  # Production build
```

The build output goes to `web/dist/` which is served by FiveM.

## Support

For issues, questions, or feature requests, please contact Chris Stone Development.

## License

This resource is proprietary software. Unauthorized distribution is prohibited.

---

**Developed by Chris Stone**  
*Premium FiveM Resources*

