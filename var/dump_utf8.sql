-- MySQL dump 10.13  Distrib 5.5.24, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: RAGNAROEK
-- ------------------------------------------------------
-- Server version	5.5.24-0ubuntu0.12.04.1
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
-- Dumping data for table `ALLIANCE`
--

LOCK TABLES `ALLIANCE` WRITE;
/*!40000 ALTER TABLE `ALLIANCE` DISABLE KEYS */;
/*!40000 ALTER TABLE `ALLIANCE` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8 COMMENT='here the commands of players are stored';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COMMAND`
--

LOCK TABLES `COMMAND` WRITE;
/*!40000 ALTER TABLE `COMMAND` DISABLE KEYS */;
INSERT  IGNORE INTO `COMMAND` (`ID`, `GAME`, `EXEC`, `SUBMIT`, `PLAYER`, `COMMAND`, `LOCATION`, `MOBILE`, `ARGUMENTS`, `ACK`, `DONE`) VALUES (79,1,'2012-09-19 14:21:35','2012-09-19 14:11:35',-1,'PRODUCE','1_3',0,'PEACE=12, ROLE=-1','2012-09-19 14:11:35','0000-00-00 00:00:00'),(80,1,'2012-09-19 14:21:35','2012-09-19 14:11:35',-1,'PRODUCE','13_6',0,'PEACE=12, ROLE=-1','2012-09-19 14:11:35','0000-00-00 00:00:00'),(81,1,'2012-09-19 14:21:35','2012-09-19 14:11:35',3,'PRODUCE','7_3',0,'PEACE=12, ROLE=3','2012-09-19 14:11:35','0000-00-00 00:00:00'),(82,1,'2012-09-19 14:21:35','2012-09-19 14:11:35',-1,'PRODUCE','0_1',0,'PEACE=12, ROLE=-1','2012-09-19 14:11:35','0000-00-00 00:00:00'),(83,1,'2012-09-19 14:21:35','2012-09-19 14:11:35',-1,'PRODUCE','4_3',0,'PEACE=12, ROLE=-1','2012-09-19 14:11:35','0000-00-00 00:00:00'),(84,1,'2012-09-19 14:21:35','2012-09-19 14:11:35',-1,'PRODUCE','10_2',0,'PEACE=12, ROLE=-1','2012-09-19 14:11:35','0000-00-00 00:00:00');
/*!40000 ALTER TABLE `COMMAND` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `EARTHLING`
--

LOCK TABLES `EARTHLING` WRITE;
/*!40000 ALTER TABLE `EARTHLING` DISABLE KEYS */;
INSERT  IGNORE INTO `EARTHLING` (`GAME`, `PLAYER`, `DYING`, `HERO`) VALUES (1,3,'KHP',0);
/*!40000 ALTER TABLE `EARTHLING` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EVENT`
--

LOCK TABLES `EVENT` WRITE;
/*!40000 ALTER TABLE `EVENT` DISABLE KEYS */;
INSERT  IGNORE INTO `EVENT` (`ID`, `GAME`, `LOCATION`, `TAG`, `ARG1`, `ARG2`, `ARG3`, `ARG4`, `COMMAND_ID`, `TIME`) VALUES (79,1,'1_3','EVENT_PRODUCE_WARRIOR','unassigned position','','','',79,'2012-09-19 14:21:35'),(80,1,'13_6','EVENT_PRODUCE_WARRIOR','unassigned position','','','',80,'2012-09-19 14:21:35'),(81,1,'7_3','EVENT_PRODUCE_WARRIOR','qwe','','','',81,'2012-09-19 14:21:35'),(82,1,'0_1','EVENT_PRODUCE_WARRIOR','unassigned position','','','',82,'2012-09-19 14:21:35'),(83,1,'4_3','EVENT_PRODUCE_WARRIOR','unassigned position','','','',83,'2012-09-19 14:21:35'),(84,1,'10_2','EVENT_PRODUCE_WARRIOR','unassigned position','','','',84,'2012-09-19 14:21:35');
/*!40000 ALTER TABLE `EVENT` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `GAME`
--

LOCK TABLES `GAME` WRITE;
/*!40000 ALTER TABLE `GAME` DISABLE KEYS */;
INSERT  IGNORE INTO `GAME` (`GAME`, `NAME`, `SIZE`, `SPEED`, `FORTUNE`, `LAST_TEMPLE`, `TEMPLE_SIZE`, `START_MANA`, `RUNNING`) VALUES (1,'zweit',7,30,3,'',1,33,'Y');
/*!40000 ALTER TABLE `GAME` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `GOD`
--

LOCK TABLES `GOD` WRITE;
/*!40000 ALTER TABLE `GOD` DISABLE KEYS */;
/*!40000 ALTER TABLE `GOD` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `LOCALIZE`
--

LOCK TABLES `LOCALIZE` WRITE;
/*!40000 ALTER TABLE `LOCALIZE` DISABLE KEYS */;
INSERT  IGNORE INTO `LOCALIZE` (`TAG`, `LANGUAGE`, `TEXT`) VALUES ('ADJ_ADORING','DE',', Anbeter von'),('ADJ_ADORING','EN',' adoring'),('ADJ_HERE','DE','Hier'),('ADJ_HERE','EN','Here'),('ART_DAT_PL','DE','den'),('ART_DAT_PL','EN','the'),('BATTLE_REPORT','DE','Kampfbericht f?r'),('BATTLE_REPORT','EN','Battle report for'),('BUILD_ARK','DE','Arche bauen'),('BUILD_ARK','EN','build ark'),('CHANGE_PASSWORD','DE','Wenn Du Dein Passwort ?ndern willst, gib das neue Passwort bitte hier zweimal ein.'),('CHANGE_PASSWORD','EN','If you want to change your password, please insert it here two times.'),('CH_LUCK','DE','Gl?cksfaktor ?ndern'),('CH_LUCK','EN','change fortune'),('CITY_HEADING','DE','Rangfolge der Erdlinge:'),('CITY_HEADING','EN','Ranking of earthlings:'),('CMD_BLESS_HERO','DE','Held weihen'),('CMD_BLESS_HERO','EN','bless hero'),('CMD_BLESS_HERO_MSG','DE','Anzahl neue Helden'),('CMD_BLESS_HERO_MSG','EN','Number of new heros'),('CMD_BLESS_PRIEST','DE','Priester weihen'),('CMD_BLESS_PRIEST','EN','bless priest'),('CMD_BLESS_PRIEST_MSG','DE','Weihe einen neuen Priester'),('CMD_BLESS_PRIEST_MSG','EN','Bless a new priest'),('CMD_BUILD_ARK','DE','Arche bauen'),('CMD_BUILD_ARK','EN','build ark'),('CMD_BUILD_ARK_MSG','DE','Baue Arche in'),('CMD_BUILD_ARK_MSG','EN','Build ark in'),('CMD_BUILD_TEMPLE','DE','Tempel bauen'),('CMD_BUILD_TEMPLE','EN','build temple'),('CMD_BUILD_TEMPLE_MSG','DE','Baue einen Tempel in'),('CMD_BUILD_TEMPLE_MSG','EN','build temple in'),('CMD_CH_ACTION_MSG','DE','W?hle neue Avatar-Aktion'),('CMD_CH_ACTION_MSG','EN','Choose new avatar action'),('CMD_CH_ADORING_MSG','DE','Deine Helden beten jetzt zu'),('CMD_CH_ADORING_MSG','EN','Your heros now adoring'),('CMD_CH_LUCK','DE','Gl?cksfaktor ?ndern'),('CMD_CH_LUCK','EN','change luck'),('CMD_CH_LUCK_MSG','DE','Ver?ndere den Gl?cksfaktor um'),('CMD_CH_LUCK_MSG','EN','Change luck-factor about'),('CMD_CH_STATUS_MSG','DE','Setze deine neue Beziehung zu'),('CMD_CH_STATUS_MSG','EN','Set your new relation to'),('CMD_COUNT','DE','Anzahl'),('CMD_COUNT','EN','Number'),('CMD_DESTROY','DE','Tempel zerst?ren'),('CMD_DESTROY','EN','destroy temple'),('CMD_DESTROY_MSG','DE','Zerst?re den Tempel in'),('CMD_DESTROY_MSG','EN','Destroy the temple at'),('CMD_DIE_ORDER','DE','Sterbereihenfolge ?ndern'),('CMD_DIE_ORDER','EN','change die-order'),('CMD_DIE_ORDER_MSG','DE','W?hle die neue Sterbe-Reihenfolge deiner Einheiten'),('CMD_DIE_ORDER_MSG','EN','Choose the new die-order of your units'),('CMD_ERROR_MSG','DE','unvollst?ndiger Befehl'),('CMD_ERROR_MSG','EN','incomplete command'),('CMD_FLOOD','DE','?berfluten'),('CMD_FLOOD','EN','flood'),('CMD_FLOOD_MSG','DE','?berflute'),('CMD_FLOOD_MSG','EN','flood'),('CMD_INCARNATE','DE','Avatare erschaffen'),('CMD_INCARNATE','EN','create avatars'),('CMD_INCARNATE_MSG','DE','Anzahl der neuen Avatare'),('CMD_INCARNATE_MSG','EN','Number of new avatars'),('CMD_MOVE','DE','bewegen'),('CMD_MOVE','EN','move'),('CMD_MOVE_MSG','DE','bewege %1 in Richtung <br>M?gliche Richtungen: <br> <table>\r\n<tr><td></td><td>N</td><td></td></tr>\r\n<tr><td>NW</td><td></td><td>NE</td></tr>\r\n<tr><td>SW</td><td></td><td>SE</td></tr>\r\n<tr><td></td><td>S</td><td></td></tr>\r\n</table>\r\n'),('CMD_MOVE_MSG','EN','move %1 in direction <br>Possible directions:<br><table>\r\n<tr><td></td><td>N</td><td></td></tr>\r\n<tr><td>NW</td><td></td><td>NE</td></tr>\r\n<tr><td>SW</td><td></td><td>SE</td></tr>\r\n<tr><td></td><td>S</td><td></td></tr>\r\n</table>\r\n'),('CMD_MOVE_MTN','DE','Berg versetzten'),('CMD_MOVE_MTN','EN','move mountain'),('CMD_MOVE_MTN_MSG','DE','soll versetzt werden nach'),('CMD_MOVE_MTN_MSG','EN','should be moved to'),('CMD_PLAGUE','DE','verseuchen'),('CMD_PLAGUE','EN','init plague'),('CMD_PLAGUE_MSG','DE','W?hle Seuche f?r'),('CMD_PLAGUE_MSG','EN','Choose plague for'),('CONQUERED_ARKS','DE','Eroberte Archen'),('CONQUERED_ARKS','EN','Conquered arks'),('DEAD_AVATARS','DE','Tote Avatare'),('DEAD_AVATARS','EN','dead avatars'),('DEAD_HEROS','DE','Gefallene Helden'),('DEAD_HEROS','EN','Dead heros'),('DEAD_PRIESTS','DE','Gefallene Priester'),('DEAD_PRIESTS','EN','Dead priests'),('DEAD_WARRIORS','DE','Gefallene Krieger'),('DEAD_WARRIORS','EN','Dead warriors'),('END_OF_GAME','DE','Das Spiel ist aus! Die Gewinner entnehmt ihr bitte der Statistik.'),('END_OF_GAME','EN','The game is over! For winners look in the statistic section.'),('ERROR_NO_LOGIN','DE','Um diese Aymargeddon-Seite anzusehen, m?ssen Sie sich erst <a href=\"login.epl\">einloggen</a>, da der Inhalt f?r jeden Spieler verschieden ist.'),('ERROR_NO_LOGIN','EN','To view this aymargeddon page you first need to <a href=\"login.epl\">login</a>, because it\'s content is different for each player.'),('EVENT_ARK_APPROACHING','DE','Von %1 kommt eine Arche.'),('EVENT_ARK_APPROACHING','EN','An ark comes from %1.'),('EVENT_BUILD_ARK','DE','Spieler %1 baut eine Arche.'),('EVENT_BUILD_ARK','EN','Player %1 builds an ark.'),('EVENT_BUILD_TEMPLE','DE','Ein Tempel f?r den Gott %2 der Gr??e %3 wird fertig.'),('EVENT_BUILD_TEMPLE','EN','A temple for god %2 with size %3 will be finished.'),('EVENT_FIGHT_GOD','DE','Hier findet ein Avatarkampf zwischen %2 und %3 statt.'),('EVENT_FIGHT_GOD','EN','Here is an avatar fight between %2 and %3.'),('EVENT_FLOOD','DE','Der Gott %1 hat die Sintflut herbeigerufen! '),('EVENT_FLOOD','EN','The god %1 will flood this aerea!'),('EVENT_MOBILE_APPROACHING','DE','Aus %2 kommen %3 %4 von Spieler %1 hier an.'),('EVENT_MOBILE_APPROACHING','EN','From field %2 will come %3 %4 from player %1.'),('EVENT_PRODUCE_PRIEST','DE','Ein Priester beendet seine Ausbildung.'),('EVENT_PRODUCE_PRIEST','EN','A priest finish his training.'),('EVENT_PRODUCE_WARRIOR','DE','Ein Krieger beendet seine Ausbildung.'),('EVENT_PRODUCE_WARRIOR','EN','A warrior finish his training.'),('FIELD_AYMARGEDDON','DE','Aymargeddon'),('FIELD_AYMARGEDDON','EN','Aymargeddon'),('FIELD_CITY','DE','Die Stadt'),('FIELD_CITY','EN','The city'),('FIELD_ISLE','DE','Die Insel'),('FIELD_ISLE','EN','The island'),('FIELD_MOUNTAIN','DE','Der Berg'),('FIELD_MOUNTAIN','EN','The mountain'),('FIELD_PLAIN','DE','Die Ebene'),('FIELD_PLAIN','EN','The plain'),('FIELD_POLE','DE','Der Manapol'),('FIELD_POLE','EN','The mana pole'),('FIELD_WATER','DE','Das Wasserfeld'),('FIELD_WATER','EN','The water field'),('FIGHTING_STRENGTH','DE','Kampfst?rke'),('FIGHTING_STRENGTH','EN','Fighting strength'),('FIGHT_AVATAR','DE','Avatarkampf'),('FIGHT_AVATAR','EN','avatar fight'),('FIGHT_EARTHLING','DE','%1 versucht dieses Feld zu erobern.'),('FIGHT_EARTHLING','EN','%1 trys to conquer this field.'),('FLANKING','DE','Flankierungsbonus'),('FLANKING','EN','Flanking'),('FORM_BACK_BUTTON','DE','zur?ck'),('FORM_BACK_BUTTON','EN','back'),('FORM_OK_BUTTON','DE','senden'),('FORM_OK_BUTTON','EN','submit'),('GEN_FEMALE','DE','Frau'),('GEN_FEMALE','EN','Woman'),('GEN_MALE','DE','Mann'),('GEN_MALE','EN','Man'),('GEN_PLURAL','DE','Gruppe'),('GEN_PLURAL','EN','Group'),('GLOBAL','DE','allen Feldern'),('GLOBAL','EN','all places'),('GOD','DE','Gott'),('GOD','EN','god'),('GODS_HELP','DE','G?ttlicher Unterst?tzung'),('GODS_HELP','EN','Help of gods'),('HOMECITY','DE','Es ist die Heimatstadt'),('HOMECITY','EN','It\'s the home town'),('HOMEHOLY','DE','Es ist ein heiliger Berg'),('HOMEHOLY','EN','It\'s a holy mountain'),('INCARNATE','DE','Avatar erschaffen'),('INCARNATE','EN','create avatar'),('LANG_ENGLISH','DE','Englisch'),('LANG_ENGLISH','EN','English'),('LANG_GERMAN','DE','Deutsch'),('LANG_GERMAN','EN','German'),('LANG_WELCOME','DE','W?hlen Sie ihre bevorzugte Sprache'),('LANG_WELCOME','EN','Choose your favorite language'),('LAST_BATTLE_HEADING','DE','Derzeitige Kampfst?rken der G?tter in der letzten Schlacht:'),('LAST_BATTLE_HEADING','EN','Actual fighting power of gods for the last battle:'),('LAST_BATTLE_LINE','DE','%1 k?mpft mit St?rke %2.'),('LAST_BATTLE_LINE','EN','%1 fights with strength %2.'),('LOGIN_EMAIL','DE','e-Mail Adresse'),('LOGIN_EMAIL','EN','email'),('LOGIN_FAILED','DE','Login fehlgeschlagen. Falsches Passwort oder unbekannter Benutzername.'),('LOGIN_FAILED','EN','Login failed. Wrong password or unknown username.'),('LOGIN_PASSWORD','DE','Passwort'),('LOGIN_PASSWORD','EN','password'),('LOGIN_REALNAME','DE','richtiger Name'),('LOGIN_REALNAME','EN','real name'),('LOGIN_REG_ERROR','DE','Die Anmeldung ist fehlgeschlagen. Vielleicht ist der Benutzername schon vergeben. Nicht vergessen: Jeder Benutzer darf nur <strong>einen</strong> Account bei uns haben!!'),('LOGIN_REG_ERROR','EN','We couldn\'t register you. Maybe the login name is already in use. Always remember: any user is only allowed <strong>one</strong> account on this server!!'),('LOGIN_REG_FORM_HEAD','DE','Suchen sie sich einen Benutzernamen aus:'),('LOGIN_REG_FORM_HEAD','EN','Choose your login name:'),('LOGIN_REG_LINK','DE','anmelden'),('LOGIN_REG_LINK','EN','register'),('LOGIN_REG_MSG','DE','Wenn Du noch keinen Aymargeddon-Account hast, solltest Du dich'),('LOGIN_REG_MSG','EN','If you don\'t have an aymargeddon account, you should'),('LOGIN_REG_OK_HEAD','DE','Die Anmeldung hat geklappt.'),('LOGIN_REG_OK_HEAD','EN','You are now registered.'),('LOGIN_REG_OK_TAIL','DE','Das Passwort f?r den Account wird an die angegebene Adresse geschickt.'),('LOGIN_REG_OK_TAIL','EN','The password for your account will be sent to your email adress.'),('LOGIN_REG_RETURN','DE','zur?ck zum Eingang'),('LOGIN_REG_RETURN','EN','back to the login'),('LOGIN_USERNAME','DE','Benutzername'),('LOGIN_USERNAME','EN','Username'),('LOGIN_WELCOME','DE','Der Eingang zu <strong>Aymargeddon</strong>!'),('LOGIN_WELCOME','EN','The Entrance to <strong>Aymargeddon</strong>!'),('LUCK','DE','Gew?rfelt'),('LUCK','EN','Dice roll'),('MOBILE_ARK','DE','Arche'),('MOBILE_ARK','EN','ark'),('MOBILE_ARK_PL','DE','Archen'),('MOBILE_ARK_PL','EN','arks'),('MOBILE_AVATAR','DE','Avatar'),('MOBILE_AVATAR','EN','avatar'),('MOBILE_AVATAR_PL','DE','Avatare'),('MOBILE_AVATAR_PL','EN','avatars'),('MOBILE_BLOCK','DE','blockieren'),('MOBILE_BLOCK','EN','block'),('MOBILE_HELP','DE','helfen'),('MOBILE_HELP','EN','help'),('MOBILE_HERO','DE','Held'),('MOBILE_HERO','EN','hero'),('MOBILE_HERO_PL','DE','Helden'),('MOBILE_HERO_PL','EN','heros'),('MOBILE_IGNORE','DE','ignorieren'),('MOBILE_IGNORE','EN','ignore'),('MOBILE_PRIEST','DE','Priester'),('MOBILE_PRIEST','EN','priest'),('MOBILE_PRIEST_PL','DE','Priester'),('MOBILE_PRIEST_PL','EN','priests'),('MOBILE_PROPHET','DE','Prophet'),('MOBILE_PROPHET','EN','prophet'),('MOBILE_PROPHET_PL','DE','Propheten'),('MOBILE_PROPHET_PL','EN','prophets'),('MOBILE_WARRIOR','DE','Krieger'),('MOBILE_WARRIOR','EN','warrior'),('MOBILE_WARRIOR_PL','DE','Krieger'),('MOBILE_WARRIOR_PL','EN','warriors'),('MOVE','DE','bewegen'),('MOVE','EN','move'),('MSG_AVATAR_DEAD','DE','In %1 starb ein Avatar von %2 im Kampf. Er k?mpft jetzt in der letzten Schlacht f?r seinen Gott.'),('MSG_AVATAR_DEAD','EN','In %1 died an avatar of %2. He fights now in the last battle for his god.'),('MSG_BLESS_HERO','DE','Der Gott %1 hat in %3 einen Krieger gesegnet, so da? dieser fortan heroische Kr?fte entfalten kann.'),('MSG_BLESS_HERO','EN','The god %1 has blessed a warrior from %2 in %3. He is from now on called \'HERO\'!'),('MSG_BLESS_PRIEST','DE','%1 hat einen Krieger von %2 in %3 zum Priester geweiht.'),('MSG_BLESS_PRIEST','EN','%1 blessed a warrior from %2 in %3. It is now a priest.'),('MSG_BUILD_ARK','DE','%1 hat in %2 eine Arche gebaut.'),('MSG_BUILD_ARK','EN','%1 has build an ark in %2.'),('MSG_BUILD_TEMPLE','DE','%1 hat in %3 einen Tempel zu Ehren von %2 errichtet. Es ist der gr??te Tempel weit und breit!'),('MSG_BUILD_TEMPLE','EN','%1 has build a temple to pray to %3 in %2. It is the largest temple in the world!'),('MSG_CANT_ATTACK_ALLIE','DE','Fehler bei Verarbeitung von Befehl %1: Du kannst Deinen Verb?ndeten %2 nicht angreifen in Feld %3.'),('MSG_CANT_ATTACK_ALLIE','EN','Error during process of command %1: You cant yttack your allie %2 in field %3.'),('MSG_CANT_BUILD_HERE','DE','Fehler bei Verarbeitung von Befehl %1: Das kann man auf Feld %2 nicht bauen.'),('MSG_CANT_BUILD_HERE','EN','Error during process of command %1: You cant build this in field %2.'),('MSG_CANT_DESTROY_DEFENDED','DE','Du kannst den Tempel in %1 nicht zerst?ren, weil er von Priestern eines anderen Gottes besch?tzt wird.'),('MSG_CANT_DESTROY_DEFENDED','EN','You cant destroy the temple in %1. The temple is defended by unorthodox priests.'),('MSG_CANT_DESTROY_MOUNTAIN','DE','Du kannst den Tempel auf dem Berg %1 nicht zerst?ren.'),('MSG_CANT_DESTROY_MOUNTAIN','EN','You cant destroy the temple on mountain %1.'),('MSG_CANT_DESTROY_OWN','DE','Du kannst den Tempel in %1 nicht zerst?ren da er Dir selbst geh?rt.'),('MSG_CANT_DESTROY_OWN','EN','You cant destroy your very own temple in %1.'),('MSG_CANT_FLOOD_TERRAIN','DE','Du kannst %1 nicht ?berfluten: Falsches Terrain %2.'),('MSG_CANT_FLOOD_TERRAIN','EN','You cant flood %1: Wrong terrain %2.'),('MSG_CANT_LEAVE_AYMARGEDDO','DE','Fehler bei Verarbeitung von Befehl %1: Du kannst die Aymargeddon in Feld %2 nicht verlassen!'),('MSG_CANT_LEAVE_AYMARGEDDO','EN','Error during process of command %1: You cant leave Aymargeddon in field %2.'),('MSG_CANT_MOVE_ATTACKED','DE','Du kannst keine %2 aus %1 bewegen, so lange dort gek?mpft wird.'),('MSG_CANT_MOVE_ATTACKED','EN','You cant move %2 from %1 during fight.'),('MSG_CANT_MOVE_PLAGUE','DE','%2 k?nnen sich in %1 nicht bewegen, weil sie von der %3 betroffen sind.'),('MSG_CANT_MOVE_PLAGUE','EN','%2 cant move in %1 because of %3.'),('MSG_CANT_MOVE_TO_POLE','DE','Fehler bei Verarbeitung von Befehl %1: Du kannst Dich nicht auf den Pol %2 bewegen.'),('MSG_CANT_MOVE_TO_POLE','EN','Error during process of command %1: You cant move to pole %2.'),('MSG_CANT_RESCUE_WORLD','DE','Du kannst den Tempel in %2 nicht mehr zerst?ren, weil nur noch %1 Tempelbaupl?tze unbesetzt sind. Das Ende der Welt ist unaufhaltsam!'),('MSG_CANT_RESCUE_WORLD','EN','You cant destroy the temple in %2. There are only %1 unbuild temples left. The end of the world is irresistible.'),('MSG_CANT_SWIM','DE','Fehler bei Verarbeitung von Befehl %1: %3 k?nnen nicht schwimmen in %2.'),('MSG_CANT_SWIM','EN','Error during process of command %1: %3 cant swim in %2.'),('MSG_CHANGE_FORTUNE','DE','%1 hat den Gl?cksfaktor von %2 auf %3 ge?ndert.'),('MSG_CHANGE_FORTUNE','EN','%1 changed the fortune from %2 to %3.'),('MSG_CH_ACTION','DE','Die Avatare in %2 haben jetzt den Status %1.'),('MSG_CH_ACTION','EN','The avatars in %2 now have the status %1.'),('MSG_CH_STATUS','DE','Dein neuer Status gegen?ber %1 ist jetzt %2.'),('MSG_CH_STATUS','EN','Your new status regarding %1 is now %2.'),('MSG_DESTROY_NEED_AVATAR','DE','Du brauchst einen Avatar um den Tempel in %1 zerst?ren zu k?nnen.'),('MSG_DESTROY_NEED_AVATAR','EN','You need an avatar to destroy the temple in %1.'),('MSG_DIE_ORDER','DE','Du hast Deine Sterbereihenfolge ge?ndert. Sie lautet jetzt: %1.'),('MSG_DIE_ORDER','EN','You changed your die order to %1.'),('MSG_DONT_MOVE_WITH','DE','Nicht mehr mitbewegen.'),('MSG_DONT_MOVE_WITH','EN','Don\'t move with any mobile.'),('MSG_EARTHLING_CANT_MOVE_T','DE','Fehler bei Verarbeitung von Befehl %1: Du als Erdling kannst keine %2 bewegen.'),('MSG_EARTHLING_CANT_MOVE_T','EN','Error during process of command %1: Earthlings cant move %2.'),('MSG_FIGHT_DIE','DE','Ein %2 von %1 in %3 stirbt.'),('MSG_FIGHT_DIE','EN','A %2 from %1 in %3 dies.'),('MSG_FIGHT_END','DE','Die Horden von %1 griffen %2 in %4 an. %3 gewann.'),('MSG_FIGHT_END','EN','The army of %1 attacked %2 in %4. %3 won the battle.'),('MSG_FIGHT_RETREAT','DE','%4 %2 von %1 ziehen sich aus %3 zur?ck.'),('MSG_FIGHT_RETREAT','EN','%4 %2 from %1 retreats from %3.'),('MSG_FIGHT_RETREAT_DIE','DE','%4 %2 von %1 sterben in %3 weil sie keine R?ckzugsm?glichkeit haben.'),('MSG_FIGHT_RETREAT_DIE','EN','%4 %2 from %1 die in %3: No way to retreat.'),('MSG_FLOOD','DE','%1 hat das Feld %2 ?berflutet. Aus %3 wurde %4.'),('MSG_FLOOD','EN','%1 has flooded %2. The old terrain %3 is now %4.'),('MSG_FLOOD_NEED_AVATAR','DE','Zum ?berfluten von %1 braucht man einen Avatar.'),('MSG_FLOOD_NEED_AVATAR','EN','You need an avatar in %1 to flood this field.'),('MSG_GOD_CANT_MOVE_TYPE','DE','Fehler bei Verarbeitung von Befehl %1: Als Gott kannst Du keine %2 bewegen.'),('MSG_GOD_CANT_MOVE_TYPE','EN','Error during process of command %1: Gods cant move type %2.'),('MSG_INCARNATE','DE','%1 inkarnierte einen Avatar in %2.'),('MSG_INCARNATE','EN','%1 incarnates an avatar in %2.'),('MSG_MOBILE_ARRIVES','DE','%1 %2 von %3 sind in %4 angekommen.'),('MSG_MOBILE_ARRIVES','EN','%1 %2 from %3 arrived in %4.'),('MSG_MOBILE_DRAWN','DE','%1 %2 von %3 sind in %4 j?mmerlich ersoffen.'),('MSG_MOBILE_DRAWN','EN','%1 %2 from %3 drawn in %4.'),('MSG_MOVE_NO_TARGET','DE','Fehler bei Verarbeitung von Befehl %1: Von Feld %2 gibt es kein Feld in Richtung %3.'),('MSG_MOVE_NO_TARGET','EN','Error during process of command %1: There is no field in direction %3 from field %2.'),('MSG_MOVE_WITH','DE','Bewegt sich mit'),('MSG_MOVE_WITH','EN','Moves with'),('MSG_NOT_ENOUGH_MANA','DE','Dir fehlt Mana um den Befehl \"%1\" in %2 auszuf?hren.'),('MSG_NOT_ENOUGH_MANA','EN','You lack mana to execute the command \"%1\" in %2.'),('MSG_NOT_ENOUGH_MOBILES','DE','Fehler bei Verarbeitung von Befehl %1: %2 sind zu wenige in Feld %3.'),('MSG_NOT_ENOUGH_MOBILES','EN','Error during process of command %1: %2 is not enough in field %3.'),('MSG_NO_SUCH_MOBILE','DE','Fehler: Eine Einheit mit der ID %1 konnte nicht gefunden werden.'),('MSG_NO_SUCH_MOBILE','EN','Error: Cant find mobile with ID %1.'),('MSG_NO_SUCH_ROLE','DE','Fehler bei Verarbeitung des Befehls %1: Du kannst Deinen Status gegen?ber jemandem, den es nicht gibt, wohl kaum ?ndern.'),('MSG_NO_SUCH_ROLE','EN','Error during process of command %1: You cant change your status to unknown players.'),('MSG_NO_TEMPLE_TO_DESTROY','DE','Du kannst in %1 keinen Tempel zerst?ren: Es ist keiner da.'),('MSG_NO_TEMPLE_TO_DESTROY','EN','You cant destroy an non existent temple in %1.'),('MSG_STATUS_INVALID','DE','Fehler bei Verarbeitung von Befehl %1: Unbekannter Status \"%2\"'),('MSG_STATUS_INVALID','EN','Error during process of command %1: Unknown status \"%2\"'),('MSG_TEMPLE_DESTROYD','DE','%3 hat in %1 einen Tempel, der %2 geweiht war, zerst?rt.'),('MSG_TEMPLE_DESTROYD','EN','%3 destroyd the temple of god %2 in %1.'),('MSG_TRANSPORTS','DE','reist zusammen mit'),('MSG_TRANSPORTS','EN','travels with'),('MSG_WRONG_TYPE','DE','Fehler bei Verarbeitung von Befehl %1: Falscher Typ %2 in Feld %3.'),('MSG_WRONG_TYPE','EN','Error during process of command %1: Wrong Type %2 in field %3.'),('NEW_HEROS','DE','Neue Helden'),('NEW_HEROS','EN','new heros'),('NOBODY','DE','niemand'),('NOBODY','EN','nobody'),('NOM_CHARNAME','DE','Charaktername'),('NOM_CHARNAME','EN','Character name'),('NOM_DESCRIPTION','DE','Beschreibung'),('NOM_DESCRIPTION','EN','Description'),('NOM_GENDER','DE','Geschlecht'),('NOM_GENDER','EN','Gender'),('NOM_ROLE','DE','Rolle'),('NOM_ROLE','EN','Role'),('NOT_OCCUPIED','DE','unbesetzt'),('NOT_OCCUPIED','EN','not occupied'),('OCCUPIED','DE','besetzt von'),('OCCUPIED','EN','occupied by'),('OWN_MANA','DE','Du hast %1 Mana zur Verf?gung.<p>'),('OWN_MANA','EN','You have %1 mana.<p>'),('PAGE_LANGUAGE','DE','Sprache'),('PAGE_LANGUAGE','EN','Language'),('PAGE_LOGIN','DE','Einloggen'),('PAGE_LOGIN','EN','Login'),('PAGE_LOGOUT','DE','Ausloggen'),('PAGE_LOGOUT','EN','Logout'),('PAGE_MAP','DE','Karte'),('PAGE_MAP','EN','Map'),('PAGE_PLAYER','DE','Spieler'),('PAGE_PLAYER','EN','Player'),('PAGE_REFERENCE','DE','Kurzreferenz'),('PAGE_REFERENCE','EN','short reference'),('PAGE_RULES','DE','Regeln'),('PAGE_RULES','EN','Rules'),('PAGE_START','DE','Start'),('PAGE_START','EN','Start'),('PEOPLE_OR_ARK','DE','Leute (oder Archen)'),('PEOPLE_OR_ARK','EN','people (or arks)'),('PLAGUE_IN_FIELD','DE','Hier grassiert die %1.'),('PLAGUE_IN_FIELD','EN','Here rampant %1.'),('PLAYER_CHOOSE_GAME','DE','Du musst erst ein Spiel w?hlen, bevor es mehr zu sehen gibt.'),('PLAYER_CHOOSE_GAME','EN','You must choose a game if you want to see more.'),('PLAYER_CREATE_CHAR','DE','Erschaffe deinen Charakter f?r'),('PLAYER_CREATE_CHAR','EN','Create your character for'),('PLAYER_DELETE_MESSAGES','DE','Alle nachrichten l?schen.'),('PLAYER_DELETE_MESSAGES','EN','Delete all messages.'),('PLAYER_EVENTS','DE','Ereignisse'),('PLAYER_EVENTS','EN','Events'),('PLAYER_GAMES_NONE','DE','keine'),('PLAYER_GAMES_NONE','EN','none'),('PLAYER_MESSAGES','DE','Folgende Nachrichten sind f?r dich eingetroffen:'),('PLAYER_MESSAGES','EN','You got the following new messages:'),('PLAYER_MESSAGES_HEADING','DE','Nachrichten'),('PLAYER_MESSAGES_HEADING','EN','Messages'),('PLAYER_NO_EVENTS','DE','Keine bekannten Ereignisse f?r Dich.'),('PLAYER_NO_EVENTS','EN','No known events'),('PLAYER_NO_MESSAGE','DE','Es gibt keine neuen Nachrichten f?r dich.'),('PLAYER_NO_MESSAGE','EN','There are no new messages for you.'),('PLAYER_OPENGAMES','DE','<strong>offene Spiele</strong>'),('PLAYER_OPENGAMES','EN','<strong>open games</strong>'),('PLAYER_OWN_GAMES','DE','<strong>eigene Spiele</strong>'),('PLAYER_OWN_GAMES','EN','<strong>own games</strong>'),('PLAYER_STATISTIC','DE','Statistik'),('PLAYER_STATISTIC','EN','Statistics'),('PLAYER_TO_MAP','DE','Zur Karte'),('PLAYER_TO_MAP','EN','To the map'),('PLAYER_WELCOME','DE','Willkommen bei'),('PLAYER_WELCOME','EN','Welcome to'),('PPRO_DAT3_PL','DE','euch'),('PPRO_DAT3_PL','EN','you'),('PPRO_DAT3_SG','DE','dir'),('PPRO_DAT3_SG','EN','you'),('PPRO_DAT_F','DE','ihr'),('PPRO_DAT_F','EN','her'),('PPRO_DAT_M','DE','ihm'),('PPRO_DAT_M','EN','him'),('PPRO_DAT_PL','DE','ihnen'),('PPRO_DAT_PL','EN','them'),('PPRO_GEN_F','DE','ihr'),('PPRO_GEN_F','EN','her'),('PPRO_GEN_M','DE','sein'),('PPRO_GEN_M','EN','his'),('PPRO_GEN_PL','DE','ihr'),('PPRO_GEN_PL','EN','their'),('PREP_IS_PL','DE','sind'),('PREP_IS_PL','EN','are'),('PREP_IS_SG','DE','ist'),('PREP_IS_SG','EN','is'),('PREP_OWN_PL','DE','deiner'),('PREP_OWN_PL','EN','of your'),('PREP_OWN_SG','DE','von'),('PREP_OWN_SG','EN','of'),('REGISTER_MAIL_SUBJECT','DE','Willkommen bei Aymargeddon!'),('REGISTER_MAIL_SUBJECT','EN','Welcome to Aymargeddon!'),('REGISTER_MAIL_TEXT','DE','Hallo %1,\r\n\r\nHerzlich willkommen bei Aymargeddon. Dein Login lautet %2 und Dein Paswort lautet %3.\r\n\r\nBitte trage Dich auch auf die Mailingliste ein. Das geht so: Schicke eine Mail an \r\n\r\nmajordomo@informatik.uni-frankfurt.de\r\n\r\nmit folgendem Inhalt:\r\n\r\nsubscribe ragnaroek\r\n\r\nSolltet ihr wieder von dieser Liste runter wollen, schickt ihr einfach ein:\r\n\r\nunsubscribe ragnaroek\r\n\r\nViel Spa? w?nscht das Aymargeddon Development Team'),('REGISTER_MAIL_TEXT','EN','Hello %1,\r\n\r\nWelcome to Aymargeddon. Your login is %2 and your password is %3.\r\n\r\nYou should also subscribe to the mailing list:\r\n\r\nPlease send a mail to\r\n\r\nmajordomo@informatik.uni-frankfurt.de\r\n\r\nwith the following content:\r\n\r\nsubscribe ragnaroek\r\n\r\nIf you want to get rid of the mails you send\r\n\r\nunsubscribe ragnaroek\r\n\r\n\r\nHave fun!\r\n\r\nThe Aymargeddon Development Team'),('ROLE_EARTHLING','DE','Erdling'),('ROLE_EARTHLING','EN','earthling'),('ROLE_GOD','DE','Gott'),('ROLE_GOD','EN','god'),('ROLE_OBSERVER','DE','Beobachter'),('ROLE_OBSERVER','EN','observer'),('SEND_MESSAGE','DE','kontaktieren'),('SEND_MESSAGE','EN','contact'),('SEND_MESSAGE_TO','DE','Nachricht an %1:'),('SEND_MESSAGE_TO','EN','Message to %1:'),('STATISTIC_EARTHLING_CITY','DE','%1 hat %2 St?dte.'),('STATISTIC_EARTHLING_CITY','EN','%1 has %2 citys.'),('STATISTIC_FORTUNE','DE','Der Gl?cksfaktor ist %1.<p>'),('STATISTIC_FORTUNE','EN','Fortune is %1.<p>'),('STATISTIC_NEW_TEMPLES','DE','Es sind zur Zeit %1 Tempel in Bau'),('STATISTIC_NEW_TEMPLES','EN','%1 temples will be build.'),('STATISTIC_SPEED','DE','Spielgeschwindigkeit: Eine Zeiteinheit dauert %1.<p>'),('STATISTIC_SPEED','EN','Game speed: One time intervall is %1.<p>'),('STATISTIC_UNBUILD','DE','%1 Tempel sind noch nicht gebaut.'),('STATISTIC_UNBUILD','EN','%1 temples are unbuild.'),('STAT_ALLIED','DE','Alliiert'),('STAT_ALLIED','EN','allied'),('STAT_BETRAY','DE','Verrat'),('STAT_BETRAY','EN','betray'),('STAT_FOE','DE','Feind'),('STAT_FOE','EN','enemy'),('STAT_FRIEND','DE','Freund'),('STAT_FRIEND','EN','friend'),('STAT_NEUTRAL','DE','Neutral'),('STAT_NEUTRAL','EN','neutral'),('SUM_OF_STRENGTH','DE','Gesamtst?rke'),('SUM_OF_STRENGTH','EN','Total strength'),('SUNKEN_ARKS','DE','Gesunkene Archen'),('SUNKEN_ARKS','EN','Sunken arks'),('TEMPLE','DE','Hier steht ein Tempel'),('TEMPLE','EN','Here is a temple'),('TEST_TAG','DE','ich %1, dass %2! Prozent: %% hier nochmal: %2 %1'),('TIME_WITH_DAYS','DE','In %1 Tagen, %2 Stunden, %3 Minuten und %4 Sekunden'),('TIME_WITH_DAYS','EN','In %1 days, %2 hours, %3 minutes and %4 seconds'),('TIME_WITH_HOURS','DE','In %1 Stunden, %2 Minuten und %3 Sekunden'),('TIME_WITH_HOURS','EN','In %1 hours, %2 minutes and %3 seconds'),('TIME_WITH_MINUTES','DE','In %1 Minuten und %2 Sekunden'),('TIME_WITH_MINUTES','EN','In %1 minutes and %2 seconds'),('TIME_WITH_SECONDS','DE','In %1 Sekunden'),('TIME_WITH_SECONDS','EN','In %1 seconds'),('UNASSIGNED','DE','nicht vergebene Position'),('UNASSIGNED','EN','unassigned position'),('UNAVAILABLE_UNITS','DE','besch?ftigte Einheiten'),('UNAVAILABLE_UNITS','EN','unavailable units'),('WINNER_IS','DE','Sieger ist'),('WINNER_IS','EN','Winner is');
/*!40000 ALTER TABLE `LOCALIZE` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `MAP`
--

LOCK TABLES `MAP` WRITE;
/*!40000 ALTER TABLE `MAP` DISABLE KEYS */;
INSERT  IGNORE INTO `MAP` (`GAME`, `LOCATION`, `HOME`, `OCCUPANT`, `TERRAIN`, `TEMPLE`, `PLAGUE`, `LAST_PRODUCE`, `ATTACKER`, `GOD_ATTACKER`, `NAME`, `FLUXLINE`) VALUES (1,'0_0',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'0_1',-1,-1,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'0_2',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'0_3',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'0_4',-1,0,'MOUNTAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'0_5',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'0_6',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'10_0',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'10_1',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'10_2',-1,-1,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'10_3',-1,0,'MOUNTAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'10_4',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'10_5',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'10_6',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'11_0',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'11_1',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'11_2',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'11_3',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'11_4',0,0,'ISLE','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'11_5',0,0,'ISLE','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'11_6',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'12_0',-1,0,'MOUNTAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'12_1',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'12_2',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'12_3',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'12_4',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'12_5',0,0,'ISLE','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'12_6',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'13_0',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'13_1',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'13_2',-1,0,'MOUNTAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'13_3',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'13_4',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'13_5',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'13_6',-1,-1,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'1_0',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'1_1',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'1_2',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'1_3',-1,-1,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'1_4',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'1_5',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'1_6',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'2_0',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'2_1',0,0,'ISLE','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'2_2',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'2_3',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'2_4',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'2_5',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'2_6',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'3_0',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'3_1',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'3_2',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'3_3',-1,0,'MOUNTAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'3_4',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'3_5',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'3_6',0,0,'AYMARGEDDON','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'4_0',0,0,'ISLE','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'4_1',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'4_2',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'4_3',-1,-1,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'4_4',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'4_5',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'4_6',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'5_0',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'5_1',0,0,'ISLE','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'5_2',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'5_3',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'5_4',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'5_5',0,0,'ISLE','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'5_6',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'6_0',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'6_1',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'6_2',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'6_3',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'6_4',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'6_5',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'6_6',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'7_0',0,0,'ISLE','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'7_1',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'7_2',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'7_3',3,3,'CITY','N',NULL,'2012-09-19 10:20:45',0,0,'',''),(1,'7_4',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'7_5',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'7_6',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'8_0',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'8_1',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'8_2',-1,0,'MOUNTAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'8_3',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'8_4',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'8_5',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'8_6',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'9_0',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'9_1',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'9_2',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'9_3',0,0,'PLAIN','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'9_4',0,0,'CITY','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'9_5',0,0,'WATER','N',NULL,'2012-09-19 09:26:26',0,0,'',''),(1,'9_6',0,0,'POLE','N',NULL,'2012-09-19 09:26:26',0,0,'','');
/*!40000 ALTER TABLE `MAP` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `MESSAGE`
--

LOCK TABLES `MESSAGE` WRITE;
/*!40000 ALTER TABLE `MESSAGE` DISABLE KEYS */;
/*!40000 ALTER TABLE `MESSAGE` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `MOBILE`
--

LOCK TABLES `MOBILE` WRITE;
/*!40000 ALTER TABLE `MOBILE` DISABLE KEYS */;
INSERT  IGNORE INTO `MOBILE` (`ID`, `GAME`, `LOCATION`, `TYPE`, `OWNER`, `ADORING`, `COUNT`, `AVAILABLE`, `STATUS`, `COMMAND_ID`, `MOVE_WITH`) VALUES (1,1,'1_3','WARRIOR',-1,0,12,'Y','BLOCK',0,0),(2,1,'4_3','WARRIOR',-1,0,12,'Y','BLOCK',0,0),(3,1,'10_2','WARRIOR',-1,0,12,'Y','BLOCK',0,0),(5,1,'13_6','WARRIOR',-1,0,12,'Y','BLOCK',0,0),(6,1,'7_3','WARRIOR',3,0,14,'Y','BLOCK',0,0),(7,1,'0_1','WARRIOR',-1,0,12,'Y','BLOCK',0,0);
/*!40000 ALTER TABLE `MOBILE` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `PLAYER`
--

LOCK TABLES `PLAYER` WRITE;
/*!40000 ALTER TABLE `PLAYER` DISABLE KEYS */;
INSERT  IGNORE INTO `PLAYER` (`PLAYER`, `REALNAME`, `EMAIL`, `SECURITY`, `DESCRIPTION`, `PICTURE`, `EARTHLING_SCORE`, `GOD_SCORE`, `BLOCKED`, `LANGUAGE`, `LOGIN`, `PASSWORD`, `GAMES_PLAYED_EARTHLING`, `GAMES_PLAYED_GOD`) VALUES (-1,'Admin','root@aymargeddon.de','TRUSTED','Ich darf alles!','',0,0,'N','EN','admin','a1lan1ik',0,0),(1,'Benni Baermann','benni@obda.de','FRIEND','Ein Tester','',0,0,'N','DE','benni','atlantik',0,0),(2,'Dominikus Scherkl','dom@scherkl.de','FRIEND','Testspieler','',0,0,'N','DE','dom','ichbins',0,0),(3,'Ralf Zessin','Ralf.Zessin@rz-guru.de','USER','','',0,0,'N','DE','ralfz','DummBatz',0,0),(4,'Sebastian','SBojanowski@gmx.de','USER','','',0,0,'N','EN','Jojo','wEDdg',0,0),(5,'Nicolas Diederichs','einrad@gmx.net','USER','','',0,0,'N','EN','Goblin','cQuMPMUU',0,0),(6,'Olaf Ohlenmacher','olf@obda.de','USER','','',0,0,'N','EN','olf','schlange',0,0),(7,'Andreas Scholz','Andreas.Scholz1@epost.de','USER','','',0,0,'N','EN','MSI','jcucF',0,0),(8,'Dustin Braun','Dustinhier@aol.com','USER','','',0,0,'N','DE','DarkDustin','zAhCr3w',0,0),(9,'Jens K','jens.kurlanda@web.de','USER','','',0,0,'N','EN','Cruelanda','wahnsinn',0,0),(10,'Christine','ch-bauer@gmx.de','USER','','',0,0,'N','EN','Christine','wattwurm',0,0),(11,'Ernst Preussler','erps@informatik.uni-frankfurt.de','USER','','',0,0,'N','DE','erps','k6FNQK',0,0),(12,'zed zed','stantzos@new-media.gr','USER','','',0,0,'N','EN','zed','d6MZA',0,0),(13,'Viktor Ahrens','webmaster@alatron.de','USER','','',0,0,'N','EN','Alatron','eMxiK3F',0,0),(14,'Nick','nick.schiller@gmx.de','USER','','',0,0,'N','EN','Masood','hmXY9t',0,0),(15,'Silent','cool_alex4@hotmail.com','USER','','',0,0,'N','EN','SilentSniper','diPTI',0,0),(16,'Marko','marko_gerdt@web.de','USER','','',0,0,'N','DE','Tigerente','XpcTC',0,0),(17,'Jens Kleinschmidt','aymar@stryer.de','USER','','',0,0,'N','EN','ulysses_f','gpzPn',0,0),(18,'Johannes','fir3.fox@gmx.at','USER','','',0,0,'N','EN','Fir3.Fox','vmGVYJ',0,0),(19,'Stefan Meyer','aasgeier@chefmail.de','USER','','',0,0,'N','EN','Stem','qtFH',0,0),(20,'ich','artjom1917@gmx.de','USER','','',0,0,'N','DE','Curse','5TMaDsS',0,0),(21,'Daniela','31416@web.de','USER','','',0,0,'N','DE','Sati','L4uwmoH',0,0),(22,'Matthias Schneider','gvirus@gvirus.de','USER','','',0,0,'N','DE','Dante','dVkae',0,0),(23,'Andreas Karg','Andreas_karg@web.de','USER','','',0,0,'N','EN','Mutabor','QmZ6uMDC',0,0),(24,'Jan Torben Zimbehl','book_of_moon@web.de','USER','','',0,0,'N','DE','Jay_Phil','Ir4wTt',0,0),(25,'Witali','www.witalimik@web.de','USER','','',0,0,'N','DE','Mik','RVUQFzu',0,0),(26,'Felix','Hawk.2@web.de','USER','','',0,0,'N','EN','Hawk','QCGK',0,0),(27,'Leonard','cabe@vr-web.de','USER','','',0,0,'N','EN','plopo123','YmtmQa',0,0),(28,'Angel','AngelDM2001@yahoo.ca','USER','','',0,0,'N','EN','Angel','Wu2JPxT3',0,0),(29,'Florian','Flori008@hotmail.de','USER','','',0,0,'N','EN','Flori007','5Cqp9ZA',0,0),(30,'Ulrike','vielebriefe@gmx.at','USER','','',0,0,'N','DE','Galaxie','cULqhgT',0,0),(31,'Simone','simone.bueser@gmx.net','USER','','',0,0,'N','DE','Amiziras','SIgDg',0,0),(32,'kennste jemanden der','crazy-devil14@gmx.de','USER','','',0,0,'N','DE','d?nsch-hei?t','geF2353G',0,0),(33,'Mas73rm1nD','Mastermind50@lycos.de','USER','','',0,0,'N','DE','Da_RnB-pLaYa','iuinim',0,0),(34,'jennifer','jennyengelqaol.com','USER','','',0,0,'N','DE','jennyengel','bPi4v',0,0),(35,'Angela','Xanlox@aol.com','USER','','',0,0,'N','DE','Xanlox','9vpVcW',0,0),(36,'Bernd','b.koreck@aon.at','USER','','',0,0,'N','DE','Yoru','FLIEQut',0,0),(37,'Thomas Riedel','-','USER','','',0,0,'N','DE','Mr T','Txre722',0,0),(38,'Alexander','baca@hotmail.de','USER','','',0,0,'N','EN','prince','2avYVHMN',0,0),(39,'Christoph Broers','christoph@broers.de','USER','','',0,0,'N','DE','Christoph','os59Dh',0,0),(40,'Marc Wipfler','marc@le-wi.de','USER','','',0,0,'N','DE','Marc','SNTvRn',0,0),(41,'Marten','maso007@hotmail.com','USER','','',0,0,'N','DE','maso007','baTPm',0,0),(42,'Daniel','xdiaz@web.de','USER','','',0,0,'N','DE','Diaz','cUG4D',0,0),(43,'bram','bram_bannink@hotmail.com','USER','','',0,0,'N','EN','brammie','i3GMsbM',0,0),(44,'Alexander Nickol','dark5@gmx.de','USER','','',0,0,'N','DE','Parasit','KWFaKrLj',0,0),(45,'Sarah','Hoshi_Maru@gmx.de','USER','','',0,0,'N','EN','Fischerjunge','HnsVR',0,0),(46,'Florian Steinkellner','flubon@aon.at','USER','','',0,0,'N','DE','Flubon','osGWcS',0,0),(47,'Max Zitzer','Maxwellzitzer@web.de','USER','','',0,0,'N','DE','Maxwell','i9IdYi',0,0),(48,'manju','hallo@yahoo.ch','USER','','',0,0,'N','EN','lol','mD9wtv',0,0),(49,'LuC','luckyjol@gmx.net','USER','','',0,0,'N','DE','luckyjol','JhXWVt',0,0),(50,'Stefan Stroth','firedervil@web.de','USER','','',0,0,'N','DE','FireDervil','K3irEXc',0,0),(51,'Siren','s.regner@arcor.de','USER','','',0,0,'N','DE','TheExedos','xyzs4TP',0,0),(52,'Nils','ntonagel@web.de','USER','','',0,0,'N','EN','trucidare','b6FRWr',0,0),(53,'Loow','loow@gmx.de','USER','','',0,0,'N','DE','Bosko','bDfXLZ',0,0),(54,'kud','flo@blacktron.de','USER','','',0,0,'N','EN','kud','gDFk7',0,0),(55,'sfhhfs','Diego-SAN@gmx.de','USER','','',0,0,'N','DE','Diego-san','XZI7bK',0,0),(56,'acer','01721700650@vodafone.de','USER','','',0,0,'N','DE','Acer','JfYmm',0,0),(57,'Sascha','www.SaitowSascha@.de','USER','','',0,0,'N','EN','Zero','hGNxstz',0,0),(58,'wongsuk','wongsuk@ggs.ch','USER','','',0,0,'N','EN','Thailee','4wQPd',0,0);
/*!40000 ALTER TABLE `PLAYER` ENABLE KEYS */;
UNLOCK TABLES;

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

--
-- Dumping data for table `ROLE`
--

LOCK TABLES `ROLE` WRITE;
/*!40000 ALTER TABLE `ROLE` DISABLE KEYS */;
INSERT  IGNORE INTO `ROLE` (`GAME`, `PLAYER`, `NICKNAME`, `ROLE`, `GENDER`, `DESCRIPTION`, `PICTURE`) VALUES (1,3,'qwe','EARTHLING','PLURAL','none',NULL);
/*!40000 ALTER TABLE `ROLE` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-09-19 14:14:54
