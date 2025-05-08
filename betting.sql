CREATE TABLE IF NOT EXISTS `betting_bets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player` varchar(50) NOT NULL,
  `bet_id` int NOT NULL,
  `option` varchar(50) NOT NULL,
  `amount` int NOT NULL,
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;