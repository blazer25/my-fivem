CREATE TABLE IF NOT EXISTS `savana_truckerjob` (
  `#` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `currentXP` int(11) DEFAULT NULL,
  PRIMARY KEY (`#`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `savana_truckerjob` (`#`, `citizenid`, `currentXP`) VALUES
	(5, 'ALM03061', 395);