-- ============================================
-- Add Your First Test Business
-- Copy and paste this into your MySQL database
-- ============================================

-- Option 1: Downtown 24/7 Store (near spawn)
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES (
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

-- Option 2: Legion Square Store
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES (
    'legion_store',
    'Legion Square Store',
    '{"x": 195.0, "y": -933.0, "z": 29.7}',
    50000,
    1,
    'general',
    52,
    2,
    1
);

-- Option 3: Paleto Bay Store
INSERT INTO chris_businesses (name, label, coords, price, for_sale, business_type, blip_sprite, blip_color, is_open)
VALUES (
    'paleto_store',
    'Paleto Bay Store',
    '{"x": 1728.0, "y": 6415.0, "z": 35.0}',
    35000,
    1,
    'general',
    52,
    2,
    1
);

-- After adding, restart the resource:
-- restart chris_businesses

