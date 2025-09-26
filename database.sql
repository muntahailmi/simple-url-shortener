
# Dump of table links
# ------------------------------------------------------------

DROP TABLE IF EXISTS `links`;

CREATE TABLE `links` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(15) DEFAULT NULL,
  `url` text,
  `visits` int DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `last_visited` datetime DEFAULT NULL,
  `ip` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;



# Dump of table visits
# ------------------------------------------------------------

DROP TABLE IF EXISTS `visits`;

CREATE TABLE `visits` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(15) DEFAULT NULL,
  `visit_date` datetime DEFAULT NULL,
  `referer` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
