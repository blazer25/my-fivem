-- Brutal Gangs SQL Installation
-- For QBOX/QBCore Framework

-- Create the brutal_gangs table
CREATE TABLE IF NOT EXISTS `brutal_gangs` (
  `job` varchar(50) NOT NULL,
  `label` varchar(50) DEFAULT NULL,
  `level` int(11) DEFAULT 0,
  `datas` longtext DEFAULT NULL,
  `vehicles` longtext DEFAULT NULL,
  UNIQUE KEY `job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Add gang_rank and last_gang columns to players table
ALTER TABLE `players` 
ADD COLUMN IF NOT EXISTS `gang_rank` text NULL DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `last_gang` text NULL DEFAULT NULL;

