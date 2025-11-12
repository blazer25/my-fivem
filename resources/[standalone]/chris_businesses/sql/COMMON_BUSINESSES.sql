-- ============================================
-- Common Business Locations for FiveM
-- Copy and paste these to add businesses to your server
-- ============================================

-- ============================================
-- 24/7 STORES
-- ============================================

-- Downtown 24/7
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('downtown_247', 'Downtown 24/7', '{"x": 25.0, "y": -1347.0, "z": 29.5}', 40000, 1, '247', 52, 2, 1);

-- Legion Square 24/7
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('legion_247', 'Legion Square 24/7', '{"x": 195.0, "y": -933.0, "z": 29.7}', 40000, 1, '247', 52, 2, 1);

-- Paleto Bay 24/7
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('paleto_247', 'Paleto Bay 24/7', '{"x": 1728.0, "y": 6415.0, "z": 35.0}', 40000, 1, '247', 52, 2, 1);

-- Sandy Shores 24/7
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('sandy_247', 'Sandy Shores 24/7', '{"x": 1960.0, "y": 3740.0, "z": 32.3}', 40000, 1, '247', 52, 2, 1);

-- ============================================
-- GAS STATIONS
-- ============================================

-- Grove Street Gas Station
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('grove_gas', 'Grove Street Gas Station', '{"x": -40.94, "y": -1751.7, "z": 28.42}', 150000, 1, 'gas_station', 361, 1, 1);

-- Davis Avenue Gas Station
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('davis_gas', 'Davis Avenue Gas Station', '{"x": 167.06, "y": -1553.56, "z": 28.26}', 150000, 1, 'gas_station', 361, 1, 1);

-- Dutch London Xero Gas Station
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('dutch_gas', 'Dutch London Xero', '{"x": -531.2, "y": -1220.83, "z": 17.45}', 150000, 1, 'gas_station', 361, 1, 1);

-- Little Seoul Gas Station
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('little_seoul_gas', 'Little Seoul Gas Station', '{"x": -706.08, "y": -915.42, "z": 19.21}', 150000, 1, 'gas_station', 361, 1, 1);

-- Mirror Park Gas Station
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('mirror_gas', 'Mirror Park Gas Station', '{"x": 1165.05, "y": -324.49, "z": 69.2}', 150000, 1, 'gas_station', 361, 1, 1);

-- Paleto Bay Gas Station
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('paleto_gas', 'Paleto Bay Gas Station', '{"x": 179.0, "y": 6602.0, "z": 31.8}', 150000, 1, 'gas_station', 361, 1, 1);

-- ============================================
-- LIQUOR STORES
-- ============================================

-- Rob's Liquor - Downtown
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('robs_liquor_1', 'Rob\'s Liquor Downtown', '{"x": -1226.48, "y": -907.58, "z": 12.32}', 60000, 1, 'liquor', 93, 1, 1);

-- Rob's Liquor - Vinewood
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('robs_liquor_2', 'Rob\'s Liquor Vinewood', '{"x": -1469.78, "y": -366.72, "z": 40.2}', 60000, 1, 'liquor', 93, 1, 1);

-- ============================================
-- SUPERMARKETS
-- ============================================

-- Legion Square Supermarket
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('legion_supermarket', 'Legion Square Supermarket', '{"x": 31.62, "y": -1315.87, "z": 29.52}', 75000, 1, 'supermarket', 52, 2, 1);

-- ============================================
-- RESTAURANTS
-- ============================================

-- Burger Shot - Downtown
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('burgershot_1', 'Burger Shot Downtown', '{"x": -1193.0, "y": -895.0, "z": 13.99}', 50000, 1, 'fastfood', 93, 1, 1);

-- ============================================
-- MECHANIC SHOPS
-- ============================================

-- LS Customs - Downtown
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('lsc_downtown', 'LS Customs Downtown', '{"x": -362.0, "y": -131.0, "z": 38.0}', 100000, 1, 'mechanic', 72, 1, 1);

-- ============================================
-- BARS
-- ============================================

-- Tequi-la-la
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('tequila_la', 'Tequi-la-la', '{"x": -565.0, "y": 276.0, "z": 83.0}', 80000, 1, 'bar', 93, 27, 1);

-- ============================================
-- PHARMACIES
-- ============================================

-- Pillbox Medical Pharmacy
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES ('pillbox_pharmacy', 'Pillbox Pharmacy', '{"x": 322.0, "y": -580.0, "z": 43.3}', 85000, 1, 'pharmacy', 51, 2, 1);

-- ============================================
-- NOTES
-- ============================================
-- After adding businesses, restart the resource:
-- restart chris_businesses
--
-- To find more coordinates, use:
-- /tp [x] [y] [z] in-game
-- Or use a coordinate finder script
--
-- Business types available:
-- '247', 'general', 'supermarket', 'liquor', 'hardware', 'clothing', 'electronics'
-- 'gas_station', 'gas_station_large'
-- 'restaurant', 'fastfood', 'coffee', 'bar'
-- 'mechanic', 'tattoo', 'barber', 'pharmacy', 'bank'
-- 'nightclub', 'casino', 'gym'
-- 'warehouse', 'factory'

