USE `cybernetix`;

CREATE TABLE IF NOT EXISTS `cx_admin` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `email` varchar(255) NOT NULL,
    `password` varchar(255) NOT NULL,
    `status` int(1) NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cx_admin_role` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cx_admin_role_relation` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `admin_id` int(11) unsigned NOT NULL,
    `role_id` int(11) unsigned NOT NULL,
    PRIMARY KEY (`id`),
    KEY `admin_id` (`admin_id`),
    KEY `role_id` (`role_id`),
    FOREIGN KEY (`admin_id`) REFERENCES `cx_admin` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`role_id`) REFERENCES `cx_admin_role` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cx_admin_permission` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `code` varchar(255) NOT NULL,
    `name` varchar(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cx_admin_permission_relation` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `permission_id` int(11) unsigned NOT NULL,
    `role_id` int(11) unsigned NOT NULL,
    PRIMARY KEY (`id`),
    KEY `permission_id` (`permission_id`),
    KEY `role_id` (`role_id`),
    FOREIGN KEY (`permission_id`) REFERENCES `cx_admin_permission` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`role_id`) REFERENCES `cx_admin_role` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
