CREATE TABLE IF NOT EXISTS `chris_locks` (
  `id` VARCHAR(50) PRIMARY KEY,
  `type` VARCHAR(30) NOT NULL,
  `coords` JSON NOT NULL,
  `radius` FLOAT DEFAULT 2.5,
  `password` VARCHAR(64) NULL,
  `item` VARCHAR(64) NULL,
  `job` VARCHAR(128) NULL,
  `owner_identifier` VARCHAR(60) NULL,
  `targetDoorId` VARCHAR(64) NULL,
  `doorData` LONGTEXT NULL,
  `hidden` BOOLEAN DEFAULT TRUE,
  `unlockDuration` INT DEFAULT 300,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
