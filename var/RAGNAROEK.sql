-- MySQL dump 10.13  Distrib 5.5.24, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: RAGNAROEK
-- ------------------------------------------------------
-- Server version	5.5.24-0ubuntu0.12.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ALLIANCE`
--

DROP TABLE IF EXISTS `ALLIANCE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ALLIANCE` (
  `GAME` smallint(5) unsigned NOT NULL DEFAULT '0',
  `PLAYER` smallint(5) NOT NULL DEFAULT '0',
  `OTHER` smallint(5) NOT NULL DEFAULT '0',
  `STATUS` enum('NEUTRAL','ALLIED','FRIEND','FOE','BETRAY') NOT NULL DEFAULT 'NEUTRAL',
  PRIMARY KEY (`GAME`,`PLAYER`,`OTHER`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='friend or foe?';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `COMMAND`
--

DROP TABLE IF EXISTS `COMMAND`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `COMMAND` (
  `ID` mediumint(9) NOT NULL AUTO_INCREMENT,
  `GAME` smallint(5) unsigned NOT NULL DEFAULT '0',
  `EXEC` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `SUBMIT` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `PLAYER` smallint(5) NOT NULL DEFAULT '0',
  `COMMAND` enum('SEND_MSG','MOVE_WITH','PRAY','PRODUCE','FIGHT_EARTHLING','FIGHT_GOD','CH_STATUS','MOVE','BUILD_TEMPLE','CH_ADORING','CH_ACTION','BLESS_PRIEST','BLESS_HERO','DIE_ORDER','MOVE_MTN','INCARNATE','BUILD_ARK','PLAGUE','FLOOD','DESTROY','CH_LUCK') NOT NULL DEFAULT 'CH_STATUS',
  `LOCATION` varchar(7) DEFAULT NULL,
  `MOBILE` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `ARGUMENTS` text NOT NULL,
  `ACK` datetime DEFAULT NULL,
  `DONE` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `EXEC` (`EXEC`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8 COMMENT='here the commands of players are stored';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `EARTHLING`
--

DROP TABLE IF EXISTS `EARTHLING`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `EARTHLING` (
  `GAME` smallint(6) NOT NULL DEFAULT '0',
  `PLAYER` smallint(6) NOT NULL DEFAULT '0',
  `DYING` enum('PKH','PHK','HPK','HKP','KPH','KHP') NOT NULL DEFAULT 'KHP',
  `HERO` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`GAME`,`PLAYER`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='info special for each earthling';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `EVENT`
--

DROP TABLE IF EXISTS `EVENT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `EVENT` (
  `ID` mediumint(9) unsigned NOT NULL AUTO_INCREMENT,
  `GAME` smallint(6) NOT NULL DEFAULT '0',
  `LOCATION` char(5) NOT NULL DEFAULT '',
  `TAG` char(30) NOT NULL DEFAULT '',
  `ARG1` char(25) NOT NULL DEFAULT '',
  `ARG2` char(25) NOT NULL DEFAULT '',
  `ARG3` char(25) NOT NULL DEFAULT '',
  `ARG4` char(25) NOT NULL DEFAULT '',
  `COMMAND_ID` mediumint(9) NOT NULL DEFAULT '0',
  `TIME` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GAME`
--

DROP TABLE IF EXISTS `GAME`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GAME` (
  `GAME` smallint(5) unsigned NOT NULL DEFAULT '0',
  `NAME` varchar(20) NOT NULL DEFAULT '',
  `SIZE` smallint(5) unsigned NOT NULL DEFAULT '0',
  `SPEED` int(11) NOT NULL DEFAULT '1800',
  `FORTUNE` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `LAST_TEMPLE` varchar(7) NOT NULL DEFAULT '',
  `TEMPLE_SIZE` smallint(3) unsigned NOT NULL DEFAULT '1',
  `START_MANA` smallint(5) unsigned NOT NULL DEFAULT '20',
  `RUNNING` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`GAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='here some generell global information is stored';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GOD`
--

DROP TABLE IF EXISTS `GOD`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GOD` (
  `GAME` smallint(5) unsigned NOT NULL DEFAULT '0',
  `PLAYER` smallint(5) NOT NULL DEFAULT '0',
  `MANA` smallint(5) unsigned NOT NULL DEFAULT '0',
  `DEATH_HERO` smallint(5) unsigned NOT NULL DEFAULT '0',
  `DEATH_AVATAR` smallint(5) unsigned NOT NULL DEFAULT '0',
  `ARRIVAL` char(7) NOT NULL DEFAULT '',
  PRIMARY KEY (`GAME`,`PLAYER`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='here some god-related stuff is stored';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `LOCALIZE`
--

DROP TABLE IF EXISTS `LOCALIZE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LOCALIZE` (
  `TAG` varchar(25) NOT NULL DEFAULT '',
  `LANGUAGE` enum('DE','EN') NOT NULL DEFAULT 'DE',
  `TEXT` text NOT NULL,
  PRIMARY KEY (`TAG`,`LANGUAGE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `MAP`
--

DROP TABLE IF EXISTS `MAP`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MAP` (
  `GAME` smallint(6) unsigned NOT NULL DEFAULT '0',
  `LOCATION` varchar(7) NOT NULL DEFAULT '',
  `HOME` smallint(6) NOT NULL DEFAULT '0',
  `OCCUPANT` smallint(6) NOT NULL DEFAULT '0',
  `TERRAIN` enum('PLAIN','WATER','CITY','MOUNTAIN','ISLE','POLE','AYMARGEDDON') NOT NULL DEFAULT 'PLAIN',
  `TEMPLE` enum('Y','N') NOT NULL DEFAULT 'N',
  `PLAGUE` set('PESTILENTIA','INFLUENZA','TUBERCULOSIS') DEFAULT NULL,
  `LAST_PRODUCE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ATTACKER` smallint(5) unsigned DEFAULT '0',
  `GOD_ATTACKER` smallint(5) unsigned DEFAULT '0',
  `NAME` varchar(20) NOT NULL DEFAULT '',
  `FLUXLINE` set('N','S','SW','NW','SE','NE') NOT NULL DEFAULT '',
  PRIMARY KEY (`GAME`,`LOCATION`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='This is the main map of the world';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `MESSAGE`
--

DROP TABLE IF EXISTS `MESSAGE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MESSAGE` (
  `ID` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `GAME` smallint(5) unsigned NOT NULL DEFAULT '0',
  `TIME` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `MFROM` smallint(5) NOT NULL DEFAULT '0',
  `MTO` smallint(5) NOT NULL DEFAULT '0',
  `LOCATION` varchar(7) NOT NULL DEFAULT '',
  `TYPE` enum('MESSAGE','ERROR','WARNING') NOT NULL DEFAULT 'MESSAGE',
  `MSG_TEXT` text NOT NULL,
  `MSG_TAG` varchar(25) NOT NULL DEFAULT '',
  `ARG1` varchar(25) NOT NULL DEFAULT '',
  `ARG2` varchar(25) NOT NULL DEFAULT '',
  `ARG3` varchar(25) NOT NULL DEFAULT '',
  `ARG4` varchar(25) NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  KEY `TIME` (`TIME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='here messages to the players are stored';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `MOBILE`
--

DROP TABLE IF EXISTS `MOBILE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MOBILE` (
  `ID` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `GAME` smallint(5) unsigned NOT NULL DEFAULT '0',
  `LOCATION` char(7) NOT NULL DEFAULT '',
  `TYPE` enum('WARRIOR','HERO','PRIEST','PROPHET','AVATAR','ARK') NOT NULL DEFAULT 'WARRIOR',
  `OWNER` smallint(5) NOT NULL DEFAULT '0',
  `ADORING` smallint(5) unsigned NOT NULL DEFAULT '0',
  `COUNT` smallint(5) unsigned NOT NULL DEFAULT '0',
  `AVAILABLE` enum('Y','N') NOT NULL DEFAULT 'Y',
  `STATUS` enum('BLOCK','HELP','IGNORE') NOT NULL DEFAULT 'BLOCK',
  `COMMAND_ID` mediumint(9) NOT NULL DEFAULT '0',
  `MOVE_WITH` mediumint(6) unsigned DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Here all mobile objects are stored';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PLAYER`
--

DROP TABLE IF EXISTS `PLAYER`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PLAYER` (
  `PLAYER` smallint(5) NOT NULL DEFAULT '0',
  `REALNAME` varchar(30) NOT NULL DEFAULT '',
  `EMAIL` varchar(40) NOT NULL DEFAULT '',
  `SECURITY` enum('USER','FRIEND','TRUSTED') NOT NULL DEFAULT 'USER',
  `DESCRIPTION` text NOT NULL,
  `PICTURE` blob NOT NULL,
  `EARTHLING_SCORE` smallint(6) NOT NULL DEFAULT '0',
  `GOD_SCORE` smallint(6) NOT NULL DEFAULT '0',
  `BLOCKED` enum('N','Y') NOT NULL DEFAULT 'N',
  `LANGUAGE` char(2) NOT NULL DEFAULT '',
  `LOGIN` varchar(20) NOT NULL DEFAULT '',
  `PASSWORD` varchar(20) NOT NULL DEFAULT '',
  `GAMES_PLAYED_EARTHLING` smallint(5) unsigned NOT NULL DEFAULT '0',
  `GAMES_PLAYED_GOD` smallint(5) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`PLAYER`),
  UNIQUE KEY `PLAYER` (`PLAYER`),
  UNIQUE KEY `LOGIN` (`LOGIN`),
  UNIQUE KEY `EMAIL` (`EMAIL`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='information for players, which are not related to a game';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ROLE`
--

DROP TABLE IF EXISTS `ROLE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ROLE` (
  `GAME` smallint(5) unsigned NOT NULL DEFAULT '0',
  `PLAYER` smallint(5) NOT NULL DEFAULT '0',
  `NICKNAME` varchar(20) DEFAULT NULL,
  `ROLE` enum('OBSERVER','EARTHLING','GOD') NOT NULL DEFAULT 'EARTHLING',
  `GENDER` enum('MALE','FEMALE','PLURAL') NOT NULL DEFAULT 'PLURAL',
  `DESCRIPTION` text,
  `PICTURE` blob,
  PRIMARY KEY (`GAME`,`PLAYER`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='which player plays which role?';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-09-23 12:14:38
