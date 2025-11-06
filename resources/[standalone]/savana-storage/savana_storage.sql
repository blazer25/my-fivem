CREATE TABLE IF NOT EXISTS `savana_storage` (
  `identifier` longtext DEFAULT NULL,
  `name` longtext DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `weight` int(11) DEFAULT NULL,
  `image` longtext DEFAULT NULL,
  `password` longtext DEFAULT NULL,
  `keyholders` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]' CHECK (json_valid(`keyholders`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
