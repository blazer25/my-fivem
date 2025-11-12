# Admin Guide - Adding Businesses

## Quick Add via Database

### Method 1: SQL Query
```sql
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES (
    'unique_name',           -- Unique identifier (no spaces, use underscores)
    'Display Name',          -- Name shown to players
    '{"x": 0.0, "y": 0.0, "z": 0.0}',  -- Coordinates (JSON format)
    50000,                   -- Price in dollars
    1,                       -- 1 = for sale, 0 = not for sale
    'general',               -- Business type (see list below)
    52,                      -- Blip sprite ID
    2,                       -- Blip color ID
    1                        -- 1 = open, 0 = closed
);
```

### Method 2: Use Pre-made SQL File
See `sql/COMMON_BUSINESSES.sql` for ready-to-use locations!

---

## Available Business Types

### Stores
- `'247'` - 24/7 Store ($40,000)
- `'general'` - General Store ($50,000)
- `'supermarket'` - Supermarket ($75,000)
- `'liquor'` - Liquor Store ($60,000)
- `'hardware'` - Hardware Store ($80,000)
- `'clothing'` - Clothing Store ($70,000)
- `'electronics'` - Electronics Store ($90,000)

### Gas Stations
- `'gas_station'` - Gas Station ($150,000)
- `'gas_station_large'` - Large Gas Station ($250,000)

### Food & Drink
- `'restaurant'` - Restaurant ($75,000)
- `'fastfood'` - Fast Food ($50,000)
- `'coffee'` - Coffee Shop ($45,000)
- `'bar'` - Bar ($80,000)

### Services
- `'mechanic'` - Mechanic Shop ($100,000)
- `'tattoo'` - Tattoo Shop ($60,000)
- `'barber'` - Barber Shop ($55,000)
- `'pharmacy'` - Pharmacy ($85,000)
- `'bank'` - Bank ($500,000)

### Entertainment
- `'nightclub'` - Nightclub ($200,000)
- `'casino'` - Casino ($1,000,000)
- `'gym'` - Gym ($120,000)

### Industrial
- `'warehouse'` - Warehouse ($300,000)
- `'factory'` - Factory ($500,000)

---

## Finding Coordinates

### In-Game Method
1. Go to the location where you want the business
2. Open F8 console
3. Type: `getcoords` or use a coordinate script
4. Copy the coordinates

### Coordinate Format
```json
{"x": 25.0, "y": -1347.0, "z": 29.5}
```

---

## Blip Sprites & Colors

### Common Blip Sprites
- `52` - Store/Shop
- `93` - Food/Restaurant
- `72` - Mechanic
- `361` - Gas Station
- `75` - Tattoo
- `71` - Barber
- `51` - Medical/Pharmacy
- `108` - Bank
- `679` - Casino
- `311` - Gym

### Common Blip Colors
- `0` - White
- `1` - Red
- `2` - Green
- `3` - Blue
- `4` - Yellow
- `5` - Orange
- `27` - Purple
- `46` - Pink

---

## Examples

### Add a Gas Station
```sql
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES (
    'my_gas_station',
    'My Gas Station',
    '{"x": 167.06, "y": -1553.56, "z": 28.26}',
    150000,
    1,
    'gas_station',
    361,
    1,
    1
);
```

### Add a 24/7 Store
```sql
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES (
    'my_247_store',
    'My 24/7 Store',
    '{"x": 25.0, "y": -1347.0, "z": 29.5}',
    40000,
    1,
    '247',
    52,
    2,
    1
);
```

### Add a Restaurant
```sql
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES (
    'my_restaurant',
    'My Restaurant',
    '{"x": -1193.0, "y": -895.0, "z": 13.99}',
    75000,
    1,
    'restaurant',
    93,
    5,
    1
);
```

---

## After Adding

1. **Restart Resource**
   ```
   restart chris_businesses
   ```

2. **Verify in Game**
   - Check map for blip
   - Go to location
   - Use business laptop
   - Should see business in menu

3. **Test Purchase**
   - Give yourself money: `/addmoney [id] bank 100000`
   - Use laptop near business
   - Purchase business

---

## Bulk Add Multiple Businesses

You can add multiple businesses in one query:

```sql
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open) VALUES
('store1', 'Store 1', '{"x": 25.0, "y": -1347.0, "z": 29.5}', 40000, 1, '247', 52, 2, 1),
('store2', 'Store 2', '{"x": 195.0, "y": -933.0, "z": 29.7}', 40000, 1, '247', 52, 2, 1),
('gas1', 'Gas Station 1', '{"x": 167.06, "y": -1553.56, "z": 28.26}', 150000, 1, 'gas_station', 361, 1, 1);
```

---

## Tips

- **Unique Names**: Use unique `name` field (no duplicates)
- **Valid Coords**: Make sure coordinates are valid (check in-game)
- **For Sale**: Set `for_sale = 1` to allow players to purchase
- **Price**: Set reasonable prices based on business type
- **Blips**: Choose appropriate sprite/color for business type

---

**Need Help?** Check `COMMON_BUSINESSES.sql` for ready-to-use examples!

