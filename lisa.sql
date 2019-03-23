-- phpMyAdmin SQL Dump
-- version 4.8.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Erstellungszeit: 24. Mrz 2019 um 00:21
-- Server-Version: 10.1.34-MariaDB
-- PHP-Version: 7.2.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `lisa`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `password` varchar(256) NOT NULL,
  `level` int(11) NOT NULL,
  `skin` int(11) NOT NULL,
  `health` float NOT NULL,
  `money` int(11) NOT NULL,
  `bank_balance` int(11) NOT NULL,
  `score` int(11) NOT NULL,
  `score_timer` int(11) NOT NULL,
  `spawn_x` float NOT NULL,
  `spawn_y` float NOT NULL,
  `spawn_z` float NOT NULL,
  `spawn_a` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `checkpoints`
--

CREATE TABLE `checkpoints` (
  `id` int(11) NOT NULL,
  `pos_x` float NOT NULL,
  `pos_y` float NOT NULL,
  `pos_z` float NOT NULL,
  `size` float NOT NULL,
  `position` varchar(256) NOT NULL,
  `usuage` int(11) NOT NULL,
  `company` int(11) NOT NULL DEFAULT '0',
  `description` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `checkpoints`
--

INSERT INTO `checkpoints` (`id`, `pos_x`, `pos_y`, `pos_z`, `size`, `position`, `usuage`, `company`, `description`) VALUES(1, 1314.18, 155.038, 20.0906, 5, 'Montgomery, San Andreas', 2, 0, '');
INSERT INTO `checkpoints` (`id`, `pos_x`, `pos_y`, `pos_z`, `size`, `position`, `usuage`, `company`, `description`) VALUES(2, 1420.37, 353.566, 18.6054, 5, 'Montgomery, San Andreas', 2, 0, '');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `companies`
--

CREATE TABLE `companies` (
  `id` int(11) NOT NULL,
  `name` varchar(256) NOT NULL,
  `leader` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `companies`
--

INSERT INTO `companies` (`id`, `name`, `leader`) VALUES(1, 'The Mower-Company', -1);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `objects`
--

CREATE TABLE `objects` (
  `id` int(11) NOT NULL,
  `model` int(11) NOT NULL,
  `pos_x` float NOT NULL,
  `pos_y` float NOT NULL,
  `pos_z` float NOT NULL,
  `rot_x` float NOT NULL,
  `rot_y` float NOT NULL,
  `rot_z` float NOT NULL,
  `draw_distance` int(11) NOT NULL,
  `description` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `objects`
--

INSERT INTO `objects` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `draw_distance`, `description`) VALUES(1, 971, -1935.99, 239.129, 34.321, -0, -0, 0, 0, '');
INSERT INTO `objects` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `draw_distance`, `description`) VALUES(2, 971, -2716.05, 217.942, 4.3494, -0, 0, 90, 0, '');
INSERT INTO `objects` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `draw_distance`, `description`) VALUES(3, 971, 2386.68, 1043.56, 10.8203, -0, 0, 0, 0, '');
INSERT INTO `objects` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `draw_distance`, `description`) VALUES(4, 971, 1843.27, -1854.59, 12.0828, -0, 0, 270, 0, '');
INSERT INTO `objects` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `draw_distance`, `description`) VALUES(5, 971, 1025.28, -1029.23, 32.1016, -0, 0, 0, 0, '');
INSERT INTO `objects` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `draw_distance`, `description`) VALUES(6, 971, 488.234, -1735.46, 11.1416, -0, 0, 174, 0, '');
INSERT INTO `objects` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `draw_distance`, `description`) VALUES(7, 971, 2071.54, -1831.41, 13.5469, -0, 0, 90, 0, '');
INSERT INTO `objects` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `draw_distance`, `description`) VALUES(8, 971, 719.82, -462.477, 16.3359, -0, 0, 0, 0, '');
INSERT INTO `objects` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `draw_distance`, `description`) VALUES(9, 971, -1904.46, 277.858, 41.0469, -0, 0, 0, 0, '');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `pickups`
--

CREATE TABLE `pickups` (
  `id` int(11) NOT NULL,
  `model` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `pos_x` float NOT NULL,
  `pos_y` float NOT NULL,
  `pos_z` float NOT NULL,
  `world` int(11) NOT NULL,
  `company` int(11) NOT NULL DEFAULT '0',
  `description` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `pickups`
--

INSERT INTO `pickups` (`id`, `model`, `type`, `pos_x`, `pos_y`, `pos_z`, `world`, `company`, `description`) VALUES(1, 1274, 2, 1679.05, 1432.06, 10.7746, -1, 0, 'bank_tmp_lv');
INSERT INTO `pickups` (`id`, `model`, `type`, `pos_x`, `pos_y`, `pos_z`, `world`, `company`, `description`) VALUES(2, 1277, 1, 1689.99, 1410.08, 11.6912, -1, 0, 'neulandbewohner');
INSERT INTO `pickups` (`id`, `model`, `type`, `pos_x`, `pos_y`, `pos_z`, `world`, `company`, `description`) VALUES(3, 1277, 1, 1698.37, 1408.46, 10.7368, -1, 0, 'BecciiGo');
INSERT INTO `pickups` (`id`, `model`, `type`, `pos_x`, `pos_y`, `pos_z`, `world`, `company`, `description`) VALUES(4, 1275, 2, 1228.09, 182.801, 20.2523, -1, 1, 'mower');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vehicles`
--

CREATE TABLE `vehicles` (
  `id` int(11) NOT NULL,
  `model` int(11) NOT NULL,
  `pos_x` float NOT NULL,
  `pos_y` float NOT NULL,
  `pos_z` float NOT NULL,
  `rot` float NOT NULL,
  `color1` int(11) NOT NULL,
  `color2` int(11) NOT NULL,
  `respawn_delay` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `company` int(11) NOT NULL DEFAULT '0',
  `numberplate` varchar(64) NOT NULL DEFAULT 'LiSA'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Daten für Tabelle `vehicles`
--

INSERT INTO `vehicles` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot`, `color1`, `color2`, `respawn_delay`, `owner`, `company`, `numberplate`) VALUES(1, 411, 1697.22, 1421.49, 10.7613, 0, 18, 1, -1, 2, 0, 'LiSA');
INSERT INTO `vehicles` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot`, `color1`, `color2`, `respawn_delay`, `owner`, `company`, `numberplate`) VALUES(2, 411, 1698.37, 1410.46, 10.7368, 0, 4, 4, -1, 2, 0, 'LiSA');
INSERT INTO `vehicles` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot`, `color1`, `color2`, `respawn_delay`, `owner`, `company`, `numberplate`) VALUES(3, 487, 1730.39, 1416.98, 10.7251, 301.385, 0, 0, -1, 2, 0, 'LiSA');
INSERT INTO `vehicles` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot`, `color1`, `color2`, `respawn_delay`, `owner`, `company`, `numberplate`) VALUES(4, 583, 1698.93, 1477.32, 10.7655, 324.447, 0, 0, -1, 2, 0, 'LiSA');
INSERT INTO `vehicles` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot`, `color1`, `color2`, `respawn_delay`, `owner`, `company`, `numberplate`) VALUES(5, 606, 1702.02, 1485.18, 10.7748, 70.9053, 0, 0, -1, 2, 0, 'LiSA');
INSERT INTO `vehicles` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot`, `color1`, `color2`, `respawn_delay`, `owner`, `company`, `numberplate`) VALUES(6, 450, 1738.48, 1474.49, 10.8203, 263.195, 0, 0, -1, 2, 0, 'LiSA');
INSERT INTO `vehicles` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot`, `color1`, `color2`, `respawn_delay`, `owner`, `company`, `numberplate`) VALUES(7, 403, 1762.33, 1482.38, 9.84257, 339.308, 0, 0, -1, 2, 0, 'LiSA');
INSERT INTO `vehicles` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot`, `color1`, `color2`, `respawn_delay`, `owner`, `company`, `numberplate`) VALUES(8, 590, 1748.05, 1517.3, 10.8129, 286.828, 0, 0, -1, 2, 0, 'LiSA');
INSERT INTO `vehicles` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot`, `color1`, `color2`, `respawn_delay`, `owner`, `company`, `numberplate`) VALUES(16, 448, 1680.19, 1392.18, 10.7285, 213.8, 0, 0, -1, 2, 0, 'LiSA');
INSERT INTO `vehicles` (`id`, `model`, `pos_x`, `pos_y`, `pos_z`, `rot`, `color1`, `color2`, `respawn_delay`, `owner`, `company`, `numberplate`) VALUES(17, 552, 1738.38, 1438.18, 10.8203, 225.861, 5, 8, -1, 2, 0, 'LiSA');

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `checkpoints`
--
ALTER TABLE `checkpoints`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `objects`
--
ALTER TABLE `objects`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `pickups`
--
ALTER TABLE `pickups`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `checkpoints`
--
ALTER TABLE `checkpoints`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT für Tabelle `companies`
--
ALTER TABLE `companies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT für Tabelle `objects`
--
ALTER TABLE `objects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT für Tabelle `pickups`
--
ALTER TABLE `pickups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT für Tabelle `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
