![](https://github.com/ncaneldiee/cybernetix-db/sql/image.png)

### 1. Angkatan

**A. Insert data angkatan**
```sql
INSERT INTO `cx_group` (`key`, `name`) VALUES(00, 'Angkatan ABC');
INSERT INTO `cx_group` (`key`, `name`) VALUES(02, 'Angkatan GHI');
INSERT INTO `cx_group` (`key`, `name`) VALUES(01, 'Angkatan DEF');
```
id | key | name
--- | --- | ---
1 | 00 | Angkatan ABC
2 | 01 | Angkatan GHI
3 | 02 | Angkatan DEF

**B. Sekarang sudah angkatan berapa (kolom key merupakan penanda angkatan)**
```sql
SELECT MAX(`key`) FROM `cx_group`;
```

**C. Penggunaan trigger untuk otomatisasi saat insert angkatan selanjutnya**
```sql
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
```
Lebih lanjut tentang [trigger](http://code.tutsplus.com/articles/introduction-to-mysql-triggers--net-12226)

**D. Insert data angkatan selanjutnya**
```sql
INSERT INTO `cx_group` (`name`) VALUES('Angkatan JKL');
```

**E. Merubah format key angkatan**
```sql
ALTER TABLE `cx_group` CHANGE `key` `key` int(3) unsigned zerofill DEFAULT '000';
```

---

### 2. Anggota

**A. Insert data anggota**
```sql
INSERT INTO `cx_member` (`group_id`, `key`, `name`) VALUES(1, 001, 'Dono');
INSERT INTO `cx_member` (`group_id`, `key`, `name`) VALUES(2, 001, 'Kasino');
INSERT INTO `cx_member` (`group_id`, `key`, `name`) VALUES(1, 002, 'Indro');
```
id | group_id | key | name | status
--- | --- | --- | --- | ---
1 | 1 | 001 | Dono | 1
2 | 2 | 001 | Kasino | 2
3 | 1 | 002 | Indro | 2

**B. Gunakan status untuk mencari anggota**

0 = anggota yang dikeluarkan atau mengundurkan diri, 1 = anggota tidak aktif, 2 = anggota aktif, 3 = anggota luar biasa, 4 = anggota kehormatan

**Mencari semua anggota aktif**
```sql
SELECT * FROM `cx_member` WHERE `status` = 2;
```
**Mencari semua anggota**
```sql
SELECT * FROM `cx_member` WHERE `status` > 0;
```

**C. Gunakan id sebagai penanda untuk merubah status anggota**
```sql
UPDATE `cx_member` SET `status` = 1 WHERE `id` = 1; -- Menjadi tidak aktif
```

**D. Anggota dan angkatannya**
**Semua anggota beserta angkatannya**
```sql
SELECT * FROM `cx_member`
LEFT JOIN `cx_group` ON `cx_member`.`group_id` = `cx_group`.`id`
WHERE `status` > 0;
```
**Semua anggota dalam suatu angkatan**
```sql
SELECT * FROM `cx_member` AS `m`
LEFT JOIN `cx_group` AS `g` ON `m`.`group_id` = `g`.`id`
WHERE `m`.`group_id` = 1 AND `m`.`status` > 0;
```
Penjelasan secara visual tentang [join](http://blog.codinghorror.com/a-visual-explanation-of-sql-joins)

**E. Total anggota**

**Total semua anggota**
```sql
SELECT COUNT(*) FROM `cx_member` WHERE `status` > 0;
```
**Total semua anggota dalam suatu angkatan**
```sql
SELECT COUNT(*) FROM `cx_member` AS `m`
LEFT JOIN `cx_group` AS `g` ON `m`.`group_id` = `g`.`id`
WHERE `m`.`group_id` = 1 AND `m`.`status` > 0;
```

**F. Penggunaan trigger untuk otomatisasi key anggota berdasarkan angkatannya**
```sql
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
```

**G. Insert data anggota selanjutnya**
```sql
INSERT INTO `cx_member` (`group_id`, `name`) VALUES(2, 'Kadir');
INSERT INTO `cx_member` (`group_id`, `name`) VALUES(1, 'Doyok');
```

**H. Menampilkan id anggota beserta angkatan**
```sql
SELECT CONCAT(`g`.`key`, '-', `m`.`key`) AS `id`, `g`.`name` AS `group`, `m`.`name` AS `name` FROM `cx_member` AS `m`
LEFT JOIN `cx_group` AS `g` ON `m`.`group_id` = `g`.`id`
WHERE `m`.`status` > 0;
```

**I. Anggota beserta id dan status keanggotaannya**
```sql
SELECT CONCAT(`g`.`key`, '-', `m`.`key`) AS id, `g`.`name` AS `angkatan`, `m`.`name` AS `nama`, (
CASE
    WHEN `m`.`status` = 4 THEN 'Anggota Kehormatan'
    WHEN `m`.`status` = 3 THEN 'Anggota Luar Biasa'
    WHEN `m`.`status` = 2 THEN 'Anggota Aktif'
    WHEN `m`.`status` = 1 THEN 'Anggota Tidak Aktif'
    ELSE 'Anggota Keluar'
END) AS `status`
FROM `cx_member` AS `m`
LEFT JOIN `cx_group` AS `g` ON `m`.`group_id` = `g`.`id`
WHERE `m`.`status` > 0;
```
id | angkatan | nama | status
--- | --- | --- | --- | ---
00-001 | Angkatan ABC | Dono | Anggota Tidak Aktif
00-002 | Angkatan ABC | Indro | Anggota Aktif
00-003 | Angkatan ABC | Doyok | Anggota Aktif
01-001 | Angkatan GHI | Kasino | Anggota Aktif
01-002 | Angkatan GHI | Kadir | Anggota Aktif

---

### 3. Unit Kerja

**A. Input data unit kerja**
```sql
INSERT INTO `cx_unit` (`id`, `name`) VALUES(1, 'Unit Kerja ZYX');
INSERT INTO `cx_unit` (`id`, `name`) VALUES(2, 'Unit Kerja WVU');
```
id | name
--- | ---
1 | Unit Kerja ZYX
2 | Unit Kerja WVU

**B. Input data anggota unit kerja**
```sql
INSERT INTO `cx_unit_member` (`unit_id`, `member_id`) VALUES(1, 1);
INSERT INTO `cx_unit_member` (`unit_id`, `member_id`) VALUES(2, 2);
INSERT INTO `cx_unit_member` (`unit_id`, `member_id`) VALUES(2, 3);
INSERT INTO `cx_unit_member` (`unit_id`, `member_id`) VALUES(1, 4);
INSERT INTO `cx_unit_member` (`unit_id`, `member_id`) VALUES(1, 5);
```

**C. Unit kerja dan anggota**

**Semua anggota beserta unit kerjanya**
```sql
SELECT * FROM `cx_unit` AS `u`
LEFT JOIN `cx_unit_member` AS `um` ON `um`.`unit_id` = `u`.`id`
LEFT JOIN `cx_member` AS `m` ON `um`.`member_id` = `m`.`id`
WHERE `m`.`status` > 0;
```
**Semua anggota dalam suatu unit kerja**
```sql
SELECT * FROM `cx_unit` AS `u`
LEFT JOIN `cx_unit_member` AS `um` ON `um`.`unit_id` = `u`.`id`
LEFT JOIN `cx_member` AS `m` ON `um`.`member_id` = `m`.`id`
WHERE `u`.`id` = 1 AND `m`.`status` > 0;
```

**D. Total unit kerja**

**Total semua unit kerja**
```sql
SELECT COUNT(*) FROM `cx_unit`;
```
**Total semua anggota dalam suatu unit kerja**
```sql
SELECT COUNT(*) FROM `cx_unit` AS `u`
LEFT JOIN `cx_unit_member` AS `um` ON `um`.`unit_id` = `u`.`id`
LEFT JOIN `cx_member` AS `m` ON `um`.`member_id` = `m`.`id`
WHERE `u`.`id` = 1 AND `m`.`status` > 0;
```
Tutorial [MySQL](http://www.mysqltutorial.org)

**E. Anggota beserta id, angkatan, dan unit kerjanya**
```sql
SELECT `g`.`name` AS `angkatan`, CONCAT(`g`.`key`, '-', `m`.`key`) AS id, `m`.`name` AS `nama`, `u`.`name` AS `unit` FROM `cx_unit` AS `u`
LEFT JOIN `cx_unit_member` AS `um` ON `um`.`unit_id` = `u`.`id`
LEFT JOIN `cx_member` AS `m` ON `um`.`member_id` = `m`.`id`
LEFT JOIN `cx_group` AS `g` ON `m`.`group_id` = `g`.`id`
WHERE `m`.`status` > 0;
```

**F. Anggota bergabung ke unit kerja lainnya**
```sql
INSERT INTO `cx_unit_member` (`unit_id`, `member_id`) VALUES(2, 1);
INSERT INTO `cx_unit_member` (`unit_id`, `member_id`) VALUES(1, 2);
```

**G. Anggota beserta id, angkatan, unit-unit kerjanya**
```sql
SELECT `g`.`name` AS `angkatan`, CONCAT(`g`.`key`, '-', `m`.`key`) AS id, `m`.`name` AS `nama`, GROUP_CONCAT(`u`.`name`) AS `unit` FROM `cx_unit` AS `u`
LEFT JOIN `cx_unit_member` AS `um` ON `um`.`unit_id` = `u`.`id`
LEFT JOIN `cx_member` AS `m` ON `um`.`member_id` = `m`.`id`
LEFT JOIN `cx_group` AS `g` ON `m`.`group_id` = `g`.`id`
WHERE `m`.`status` > 0
GROUP BY `m`.`id`;
```
angkatan| id| nama| unit
--- | --- | --- | ---
Angkatan ABC | 00-001 | Dono | Unit Kerja ZYX,Unit Kerja WVU
Angkatan GHI | 01-001 | Kasino | Unit Kerja WVU,Unit Kerja ZYX
Angkatan ABC | 00-002 | Indro | Unit Kerja WVU
Angkatan GHI | 01-002 | Kadir | Unit Kerja ZYX
Angkatan ABC | 00-003 | Doyok | Unit Kerja ZYX

---

### 4. Pengurus

Akan lebih baik jika melakukan peninputan data anggota lebih banyak lagi terlebih dahulu

**A. Input data struktur organisasi**
```sql
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (1, '0', 'Dewan Pengawas Organisasi', '0', '0', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (2, '1', 'Anggota Dewan Pengawas Organisasi', '0', '0', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (3, '1', 'Ketua Umum', '1', '0', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (4, '3', 'Wakil Ketua', '1', '1', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (5, '3', 'Sekretaris', '0', '2', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (6, '3', 'Bendahara', '0', '3', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (7, '3', 'Kepala Bidang Penelitian dan Pengembangan', '0', '4', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (8, '3', 'Kepala Bidang Hubungan Masyarakat', '0', '5', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (9, '3', 'Kepala Bidang Kesekretariatan', '0', '6', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (11, '7', 'Penelitian', '0', '0', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (10, '7', 'Pengembangan', '0', '0', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (12, '8', 'Dalam Kampus', '0', '0', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (13, '8', 'Luar Kampus', '0', '0', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (14, '8', 'Sosial Media', '0', '0', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (15, '9', 'Pengarsipan', '0', '0', '1');
INSERT INTO `cx_management_tree` (`id`, `parent`, `name`, `lane`, `sort`, `status`) VALUES (16, '9', 'Perlengkapan', '0', '0', '1');
```
Struktur organisasi :
```
   DPO - - - - - - - - - - - - - - Ketua Umum                                               Info :
    |                                   |                                                   --- atau | = garis hitam
    |                                   |                                                   - - - = garis putus-putus
Anggota DPO                             |- - - - - - - - Wakil Ketua
                                        |
                                        |
                                        |
                                        |
            Bendahara ------------------|------------------ Sekretaris
                                        |
                                        |
                                        |
               |------------------------|------------------------|
               |                        |                        |
               |                        |                        |
               |                        |                        |
        Kesekretariatan               Humas          Penelitian dan Pengembangan
               |                        |                        |
               |                        |                        |
               |                        |                        |
               |--- Pengarsipan         |--- Dalam Kampus        |--- Penelitian
               |--- Perlengkapan        |--- Luar Kampus         |--- Pengembangan
                                        |--- Sosial Media
```
[Hirarki data](http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql) di MySQL

**B. Input data kepengurusan**
```sql
INSERT INTO `cx_management` (`name`, `tenure`, `status`) VALUES ('Kepengurusan 123', '2014-2015', '0');
INSERT INTO `cx_management` (`name`, `tenure`, `status`) VALUES ('Kepengurusan 456', '2015-2016', '1');
```

**C. Input data pengurus**
```sql
-- Kepengurusan 2014-2015
INSERT INTO `cx_management_log` ( `management_id`, `tree_id`, `member_id`, `status`) VALUES ('1', '3', '4', '0'); -- Kadir Ketua
INSERT INTO `cx_management_log` ( `management_id`, `tree_id`, `member_id`, `status`) VALUES ('1', '4', '5', '0'); -- Doyok Wakil Ketua
INSERT INTO `cx_management_log` ( `management_id`, `tree_id`, `member_id`, `status`) VALUES ('1', '1', '3', '0'); -- Indro Ketua DPO
INSERT INTO `cx_management_log` ( `management_id`, `tree_id`, `member_id`, `status`) VALUES ('1', '2', '1', '0'); -- Dono Anggota DPO
INSERT INTO `cx_management_log` ( `management_id`, `tree_id`, `member_id`, `status`) VALUES ('1', '2', '2', '0'); -- Indro Anggota DPO
.....
-- Kepengurusan 2015-2016
INSERT INTO `cx_management_log` ( `management_id`, `tree_id`, `member_id`, `status`) VALUES ('2', '3', '1', '1'); -- Dono Ketua
INSERT INTO `cx_management_log` ( `management_id`, `tree_id`, `member_id`, `status`) VALUES ('2', '7', '2', '1'); -- Kasino Litbang
INSERT INTO `cx_management_log` ( `management_id`, `tree_id`, `member_id`, `status`) VALUES ('2', '11', '3', '1'); -- Indro Litbang Penelitian
INSERT INTO `cx_management_log` ( `management_id`, `tree_id`, `member_id`, `status`) VALUES ('2', '1', '4', '1'); -- Kadir Ketua DPO
INSERT INTO `cx_management_log` ( `management_id`, `tree_id`, `member_id`, `status`) VALUES ('2', '2', '5', '1'); -- Doyok Anggota DPO
.....
```
kepengurusan| jabatan | pengurus | komando | koordinasi
--- | --- | --- | --- | ---
2014-2015 | Dewan Pengawas Organisasi | Indro| |
2014-2015 | Anggota Dewan Pengawas Organisasi | Dono | Dewan Pengawas Organisasi |
2014-2015 | Anggota Dewan Pengawas Organisasi | Kasino | Dewan Pengawas Organisasi |
2014-2015 | Ketua Umum | Kadir | | Dewan Pengawas Organisasi
2014-2015 | Wakil Ketua | Doyok | | Ketua Umum
... | ... | ... | ... | ...
2015-2016 | Dewan Pengawas Organisasi | Kadir | |
2015-2016 | Anggota Dewan Pengawas Organisasi| Doyok | Dewan Pengawas Organisasi |
2015-2016 | Ketua Umum | Dono | | Dewan Pengawas Organisasi
2015-2016 | Kepala Bidang Penelitian dan Pengembangan | Kasino | Ketua Umum |
2015-2016 | Penelitian | Indro | Kepala Bidang Penelitian dan Pengembangan |
... | ... | ... | ... | ...

**D. Kepengurusan yang sedang berlangsung**
```sql
SELECT `ma`.`tenure` AS `kepengurusan`, `mt`.`name` AS `jabatan`, `m`.`name` AS `pengurus`,
IF(`mt`.`lane` = 0, `mtp`.`name`, '') AS `komando`,
IF(`mt`.`lane` = 1, `mtp`.`name`, '') AS `koordinasi`
FROM `cx_management_tree` AS `mt`
LEFT JOIN `cx_management_tree` AS `mtp` ON `mtp`.`id` = `mt`.`parent`
INNER JOIN `cx_management_log` AS `ml` ON `mt`.`id` = `ml`.tree_id
INNER JOIN `cx_management` AS `ma` ON `ml`.`management_id` = `ma`.id
INNER JOIN `cx_member` AS `m` ON `ml`.`member_id` = `m`.id
WHERE `ma`.`status` = 1;
```

**E. Penggunaan trigger untuk otomatisasi update status pengurus saat terjadi update status kepengurusan**
```sql
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
```
---
