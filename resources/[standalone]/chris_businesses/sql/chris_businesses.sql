-- ============================================
-- Chris Businesses - Database Schema
-- Dynamic Player-Owned Business System
-- ============================================

-- Main businesses table
CREATE TABLE IF NOT EXISTS `chris_businesses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `owner_identifier` VARCHAR(60) DEFAULT NULL,
    `owner_name` VARCHAR(100) DEFAULT NULL,
    `coords` JSON NOT NULL,
    `stock` JSON DEFAULT NULL,
    `balance` INT DEFAULT 0,
    `price` INT DEFAULT 0,
    `for_sale` BOOLEAN DEFAULT TRUE,
    `employees` JSON DEFAULT NULL,
    `business_type` VARCHAR(50) DEFAULT 'general',
    `blip_sprite` INT DEFAULT 52,
    `blip_color` INT DEFAULT 2,
    `is_open` BOOLEAN DEFAULT TRUE,
    `settings` JSON DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_owner` (`owner_identifier`),
    INDEX `idx_for_sale` (`for_sale`),
    INDEX `idx_business_type` (`business_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Transaction logging table
CREATE TABLE IF NOT EXISTS `chris_transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `business_id` INT NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `amount` INT NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `citizenid` VARCHAR(60) DEFAULT NULL,
    `metadata` JSON DEFAULT NULL,
    `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_business` (`business_id`),
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_timestamp` (`timestamp`),
    FOREIGN KEY (`business_id`) REFERENCES `chris_businesses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Employee management table
CREATE TABLE IF NOT EXISTS `chris_employees` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `business_id` INT NOT NULL,
    `citizenid` VARCHAR(60) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `role` VARCHAR(50) NOT NULL DEFAULT 'employee',
    `permissions` JSON DEFAULT NULL,
    `salary` INT DEFAULT 0,
    `hired_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_paid` TIMESTAMP DEFAULT NULL,
    UNIQUE KEY `unique_employee` (`business_id`, `citizenid`),
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_business` (`business_id`),
    FOREIGN KEY (`business_id`) REFERENCES `chris_businesses`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

