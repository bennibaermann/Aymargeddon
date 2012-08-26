-- MySQL dump 9.09
--
-- Host: localhost    Database: RAGNAROEK
-- ------------------------------------------------------
-- Server version	4.0.16-log

--
-- Table structure for table `ALLIANCE`
--

DROP TABLE IF EXISTS ALLIANCE;
CREATE TABLE ALLIANCE (
  GAME smallint(5) unsigned NOT NULL default '0',
  PLAYER smallint(5) NOT NULL default '0',
  OTHER smallint(5) NOT NULL default '0',
  STATUS enum('NEUTRAL','ALLIED','FRIEND','FOE','BETRAY') NOT NULL default 'NEUTRAL',
  PRIMARY KEY  (GAME,PLAYER,OTHER)
) TYPE=InnoDB COMMENT='friend or foe?';

--
-- Table structure for table `COMMAND`
--

DROP TABLE IF EXISTS COMMAND;
CREATE TABLE COMMAND (
  ID mediumint(9) NOT NULL auto_increment,
  GAME smallint(5) unsigned NOT NULL default '0',
  EXEC datetime NOT NULL default '0000-00-00 00:00:00',
  SUBMIT datetime NOT NULL default '0000-00-00 00:00:00',
  PLAYER smallint(5) NOT NULL default '0',
  COMMAND enum('SEND_MSG','MOVE_WITH','PRAY','PRODUCE','FIGHT_EARTHLING','FIGHT_GOD','CH_STATUS','MOVE','BUILD_TEMPLE','CH_ADORING','CH_ACTION','BLESS_PRIEST','BLESS_HERO','DIE_ORDER','MOVE_MTN','INCARNATE','BUILD_ARK','PLAGUE','FLOOD','DESTROY','CH_LUCK') NOT NULL default 'CH_STATUS',
  LOCATION varchar(7) default NULL,
  MOBILE mediumint(8) unsigned NOT NULL default '0',
  ARGUMENTS text NOT NULL,
  ACK datetime default NULL,
  DONE datetime default NULL,
  PRIMARY KEY  (ID),
  KEY EXEC (EXEC)
) TYPE=InnoDB COMMENT='here the commands of players are stored';

--
-- Table structure for table `EARTHLING`
--

DROP TABLE IF EXISTS EARTHLING;
CREATE TABLE EARTHLING (
  GAME smallint(6) NOT NULL default '0',
  PLAYER smallint(6) NOT NULL default '0',
  DYING enum('PKH','PHK','HPK','HKP','KPH','KHP') NOT NULL default 'KHP',
  HERO smallint(6) NOT NULL default '0',
  PRIMARY KEY  (GAME,PLAYER)
) TYPE=InnoDB COMMENT='info special for each earthling';

--
-- Table structure for table `EVENT`
--

DROP TABLE IF EXISTS EVENT;
CREATE TABLE EVENT (
  ID mediumint(9) unsigned NOT NULL auto_increment,
  GAME smallint(6) NOT NULL default '0',
  LOCATION char(5) NOT NULL default '',
  TAG char(30) NOT NULL default '',
  ARG1 char(25) NOT NULL default '',
  ARG2 char(25) NOT NULL default '',
  ARG3 char(25) NOT NULL default '',
  ARG4 char(25) NOT NULL default '',
  COMMAND_ID mediumint(9) NOT NULL default '0',
  TIME datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (ID)
) TYPE=InnoDB;

--
-- Table structure for table `GAME`
--

DROP TABLE IF EXISTS GAME;
CREATE TABLE GAME (
  GAME smallint(5) unsigned NOT NULL default '0',
  NAME varchar(20) NOT NULL default '',
  SIZE smallint(5) unsigned NOT NULL default '0',
  SPEED int(11) NOT NULL default '1800',
  FORTUNE tinyint(3) unsigned NOT NULL default '0',
  LAST_TEMPLE varchar(7) NOT NULL default '',
  TEMPLE_SIZE smallint(3) unsigned NOT NULL default '1',
  START_MANA smallint(5) unsigned NOT NULL default '20',
  RUNNING enum('Y','N') NOT NULL default 'Y',
  PRIMARY KEY  (GAME)
) TYPE=InnoDB COMMENT='here some generell global information is stored';

--
-- Table structure for table `GOD`
--

DROP TABLE IF EXISTS GOD;
CREATE TABLE GOD (
  GAME smallint(5) unsigned NOT NULL default '0',
  PLAYER smallint(5) NOT NULL default '0',
  MANA smallint(5) unsigned NOT NULL default '0',
  DEATH_HERO smallint(5) unsigned NOT NULL default '0',
  DEATH_AVATAR smallint(5) unsigned NOT NULL default '0',
  ARRIVAL char(7) NOT NULL default '',
  PRIMARY KEY  (GAME,PLAYER)
) TYPE=InnoDB COMMENT='here some god-related stuff is stored';

--
-- Table structure for table `LOCALIZE`
--

DROP TABLE IF EXISTS LOCALIZE;
CREATE TABLE LOCALIZE (
  TAG varchar(25) NOT NULL default '',
  LANGUAGE enum('DE','EN') NOT NULL default 'DE',
  TEXT text NOT NULL,
  PRIMARY KEY  (TAG,LANGUAGE)
) TYPE=InnoDB;

--
-- Table structure for table `MAP`
--

DROP TABLE IF EXISTS MAP;
CREATE TABLE MAP (
  GAME smallint(6) unsigned NOT NULL default '0',
  LOCATION varchar(7) NOT NULL default '',
  HOME smallint(6) NOT NULL default '0',
  OCCUPANT smallint(6) NOT NULL default '0',
  TERRAIN enum('PLAIN','WATER','CITY','MOUNTAIN','ISLE','POLE','AYMARGEDDON') NOT NULL default 'PLAIN',
  TEMPLE enum('Y','N') NOT NULL default 'N',
  PLAGUE set('PESTILENTIA','INFLUENZA','TUBERCULOSIS') default NULL,
  LAST_PRODUCE timestamp(14) NOT NULL,
  ATTACKER smallint(5) unsigned default '0',
  GOD_ATTACKER smallint(5) unsigned default '0',
  NAME varchar(20) NOT NULL default '',
  FLUXLINE set('N','S','SW','NW','SE','NE') NOT NULL default '',
  PRIMARY KEY  (GAME,LOCATION)
) TYPE=InnoDB COMMENT='This is the main map of the world';

--
-- Table structure for table `MESSAGE`
--

DROP TABLE IF EXISTS MESSAGE;
CREATE TABLE MESSAGE (
  ID mediumint(8) unsigned NOT NULL auto_increment,
  GAME smallint(5) unsigned NOT NULL default '0',
  TIME datetime NOT NULL default '0000-00-00 00:00:00',
  MFROM smallint(5) NOT NULL default '0',
  MTO smallint(5) NOT NULL default '0',
  LOCATION varchar(7) NOT NULL default '',
  TYPE enum('MESSAGE','ERROR','WARNING') NOT NULL default 'MESSAGE',
  MSG_TEXT text NOT NULL,
  MSG_TAG varchar(25) NOT NULL default '',
  ARG1 varchar(25) NOT NULL default '',
  ARG2 varchar(25) NOT NULL default '',
  ARG3 varchar(25) NOT NULL default '',
  ARG4 varchar(25) NOT NULL default '',
  PRIMARY KEY  (ID),
  KEY TIME (TIME)
) TYPE=InnoDB COMMENT='here messages to the players are stored';

--
-- Table structure for table `MOBILE`
--

DROP TABLE IF EXISTS MOBILE;
CREATE TABLE MOBILE (
  ID mediumint(8) unsigned NOT NULL default '0',
  GAME smallint(5) unsigned NOT NULL default '0',
  LOCATION char(7) NOT NULL default '',
  TYPE enum('WARRIOR','HERO','PRIEST','PROPHET','AVATAR','ARK') NOT NULL default 'WARRIOR',
  OWNER smallint(5) NOT NULL default '0',
  ADORING smallint(5) unsigned NOT NULL default '0',
  COUNT smallint(5) unsigned NOT NULL default '0',
  AVAILABLE enum('Y','N') NOT NULL default 'Y',
  STATUS enum('BLOCK','HELP','IGNORE') NOT NULL default 'BLOCK',
  COMMAND_ID mediumint(9) NOT NULL default '0',
  MOVE_WITH mediumint(6) unsigned default '0',
  PRIMARY KEY  (ID)
) TYPE=InnoDB COMMENT='Here all mobile objects are stored';

--
-- Table structure for table `PLAYER`
--

DROP TABLE IF EXISTS PLAYER;
CREATE TABLE PLAYER (
  PLAYER smallint(5) NOT NULL default '0',
  REALNAME varchar(30) NOT NULL default '',
  EMAIL varchar(40) NOT NULL default '',
  SECURITY enum('USER','FRIEND','TRUSTED') NOT NULL default 'USER',
  DESCRIPTION text NOT NULL,
  PICTURE blob NOT NULL,
  EARTHLING_SCORE smallint(6) NOT NULL default '0',
  GOD_SCORE smallint(6) NOT NULL default '0',
  BLOCKED enum('N','Y') NOT NULL default 'N',
  LANGUAGE char(2) NOT NULL default '',
  LOGIN varchar(20) NOT NULL default '',
  PASSWORD varchar(20) NOT NULL default '',
  GAMES_PLAYED_EARTHLING smallint(5) unsigned NOT NULL default '0',
  GAMES_PLAYED_GOD smallint(5) unsigned NOT NULL default '0',
  PRIMARY KEY  (PLAYER),
  UNIQUE KEY PLAYER (PLAYER),
  UNIQUE KEY LOGIN (LOGIN),
  UNIQUE KEY EMAIL (EMAIL)
) TYPE=InnoDB COMMENT='information for players, which are not related to a game';

--
-- Table structure for table `ROLE`
--

DROP TABLE IF EXISTS ROLE;
CREATE TABLE ROLE (
  GAME smallint(5) unsigned NOT NULL default '0',
  PLAYER smallint(5) NOT NULL default '0',
  NICKNAME varchar(20) default NULL,
  ROLE enum('OBSERVER','EARTHLING','GOD') NOT NULL default 'EARTHLING',
  GENDER enum('MALE','FEMALE','PLURAL') NOT NULL default 'PLURAL',
  DESCRIPTION text,
  PICTURE blob,
  PRIMARY KEY  (GAME,PLAYER)
) TYPE=InnoDB COMMENT='which player plays which role?';

