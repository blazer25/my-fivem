CREATE TABLE IF NOT EXISTS `fishing_levels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `river_level` int(11) NOT NULL DEFAULT 1,
  `river_xp` int(11) NOT NULL DEFAULT 0,
  `lake_level` int(11) NOT NULL DEFAULT 1,
  `lake_xp` int(11) NOT NULL DEFAULT 0,
  `sea_level` int(11) NOT NULL DEFAULT 1,
  `sea_xp` int(11) NOT NULL DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid` (`citizenid`),
  KEY `river_level` (`river_level`),
  KEY `lake_level` (`lake_level`),
  KEY `sea_level` (`sea_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

