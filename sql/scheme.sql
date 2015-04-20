-- DROP DATABASE IF EXISTS `cybernetix`;
CREATE DATABASE IF NOT EXISTS `cybernetix` CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE `cybernetix`;

CREATE TABLE IF NOT EXISTS `cx_group` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `key` int(2) unsigned zerofill DEFAULT '00',
    `name` varchar(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cx_member` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `group_id` int(11) unsigned NOT NULL,
    `key` int(3) unsigned zerofill DEFAULT '001',
    `name` varchar(255) NOT NULL,
    `image` varchar(255) DEFAULT NULL,
    `email` varchar(255) DEFAULT NULL,
    `phone` varchar(255) DEFAULT NULL,
    `address` text,
    `status` int(1) unsigned NOT NULL DEFAULT '2' COMMENT '0 = expelled or resigned member, 1 = inactive member, 2 = active member, 3 = outstanding member, 4 = honorary member',
    PRIMARY KEY (`id`),
    KEY `group_id` (`group_id`),
    FOREIGN KEY (`group_id`) REFERENCES `cx_group` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cx_unit` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `note` text,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cx_unit_member` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `unit_id` int(11) unsigned NOT NULL,
    `member_id` int(11) unsigned NOT NULL,
    PRIMARY KEY (`id`),
    KEY `unit_id` (`unit_id`),
    KEY `member_id` (`member_id`),
    FOREIGN KEY (`unit_id`) REFERENCES `cx_unit` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`member_id`) REFERENCES `cx_member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cx_management` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `tenure` varchar(255) NOT NULL,
    `vision` text,
    `mission` text,
    `status` int(1) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cx_management_tree` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `parent` int(11) unsigned NOT NULL DEFAULT '0',
    `name` varchar(255) NOT NULL,
    `note` text,
    `lane` int(1) unsigned NOT NULL DEFAULT '0' COMMENT '0 = command, 1 = coordination',
    `sort` int(11) unsigned NOT NULL DEFAULT '0',
    `status` int(1) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cx_management_log` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `management_id` int(11) unsigned NOT NULL,
    `tree_id` int(11) unsigned NOT NULL,
    `member_id` int(11) unsigned NOT NULL,
    `note` text,
    `status` int(1) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`),
    KEY `management_id` (`management_id`),
    KEY `tree_id` (`tree_id`),
    KEY `member_id` (`member_id`),
    FOREIGN KEY (`management_id`) REFERENCES `cx_management` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`tree_id`) REFERENCES `cx_management_tree` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`member_id`) REFERENCES `cx_member` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
