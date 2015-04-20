USE `cybernetix`;

DELIMITER $$;
    DROP TRIGGER IF EXISTS `group_key`;
    CREATE TRIGGER `group_key` BEFORE INSERT ON `cx_group`
    FOR EACH ROW
    BEGIN
        SET NEW.key = (SELECT MAX(`key`) FROM `cx_group`) + 1;

        IF NEW.key IS NULL THEN
           SET NEW.key = 00;
        END IF;
    END$$
DELIMITER ;

DELIMITER $$;
    DROP TRIGGER IF EXISTS `member_key`;
    CREATE TRIGGER `member_key` BEFORE INSERT ON `cx_member`
    FOR EACH ROW
    BEGIN
        SET NEW.key = (
            SELECT MAX(`m`.`key`) FROM `cx_member` AS `m`
            LEFT JOIN `cx_group` AS `g` ON `m`.`group_id` = `g`.`id`
            WHERE `m`.`group_id` = NEW.group_id
        ) + 1;

        IF NEW.key IS NULL THEN
           SET NEW.key = 001;
        END IF;
    END$$
DELIMITER ;

DELIMITER $$;
    DROP TRIGGER IF EXISTS `management_status`;
    CREATE TRIGGER `management_status` AFTER UPDATE ON `cx_management`
    FOR EACH ROW
    BEGIN
        UPDATE `cx_management_log`
        SET `status` = NEW.status
        WHERE `management_id` = NEW.id;
    END$$
DELIMITER ;
