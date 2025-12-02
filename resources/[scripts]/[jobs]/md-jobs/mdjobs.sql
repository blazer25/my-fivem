-------------------------------------------------------------------------------
-- !! STOP !! - This SQL runs automatically unless Config.AutorunSQL = false --
-------------------------------------------------------------------------------
CREATE TABLE
  IF NOT EXISTS `mdjobs_catering` (
    `id` INT (11) NOT NULL AUTO_INCREMENT,
    `job` VARCHAR(50) NOT NULL,
    `time` VARCHAR(50) NOT NULL,
    `data` LONGTEXT NOT NULL,
    `totals` LONGTEXT NOT NULL,
    `details` LONGTEXT NOT NULL,
    `employees` LONGTEXT NOT NULL,
    `delivered` TINYINT (1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_mdjobs_catering_job` (`job`)
  ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb3 COLLATE = utf8mb3_general_ci;

CREATE TABLE
  IF NOT EXISTS `mdjobs_closedshop` (
    `id` INT (11) NOT NULL AUTO_INCREMENT,
    `job` VARCHAR(50) NOT NULL,
    `label` TEXT NOT NULL,
    `items` TEXT NOT NULL,
    `prices` TEXT NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_mdjobs_closedshop_job` (`job`)
  ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb3 COLLATE = utf8mb3_general_ci;

CREATE TABLE
  IF NOT EXISTS `mdjobs_completed_catering` (
    `id` INT (11) NOT NULL AUTO_INCREMENT,
    `job` VARCHAR(50) NOT NULL,
    `receipt` LONGTEXT  NOT NULL,
    `employees` LONGTEXT NOT NULL,
    `totals` LONGTEXT DEFAULT NULL,
    `customer` LONGTEXT DEFAULT NULL,
    `vehicle_returned` TINYINT (1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_mdjobs_completed_catering_job` (`job`)
  ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb3 COLLATE = utf8mb3_general_ci;

-- Run these if Config.AutorunSQL = false and migrating to a newer version
ALTER TABLE `mdjobs_catering`
ADD COLUMN IF NOT EXISTS `delivered` TINYINT (1) NOT NULL DEFAULT 0,
ADD INDEX IF NOT EXISTS `idx_mdjobs_catering_job` (`job`);

ALTER TABLE `mdjobs_closedshop` MODIFY COLUMN `job` VARCHAR(50) NOT NULL,
ADD INDEX IF NOT EXISTS `idx_mdjobs_closedshop_job` (`job`);

ALTER TABLE `mdjobs_completed_catering` MODIFY COLUMN `job` VARCHAR(50) NOT NULL,
MODIFY COLUMN `receipt` LONGTEXT NOT NULL,
ADD COLUMN IF NOT EXISTS `vehicle_returned` TINYINT (1) NOT NULL DEFAULT 0,
ADD INDEX IF NOT EXISTS `idx_mdjobs_completed_catering_job` (`job`);