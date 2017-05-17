-- MySQL dump 10.13  Distrib 5.7.18, for Linux (x86_64)
--
-- Host: localhost    Database: RAGNAROEK
-- ------------------------------------------------------
-- Server version	5.7.18-0ubuntu0.16.04.1

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
INSERT INTO `LOCALIZE` (`TAG`, `LANGUAGE`, `TEXT`) VALUES ('ADJ_ADORING','DE',', Anbeter von'),('ADJ_ADORING','EN',' adoring'),('ADJ_HERE','DE','Hier'),('ADJ_HERE','EN','Here'),('ART_DAT_PL','DE','den'),('ART_DAT_PL','EN','the'),('BATTLE_REPORT','DE','Kampfbericht für'),('BATTLE_REPORT','EN','Battle report for'),('BUILD_ARK','DE','Arche bauen'),('BUILD_ARK','EN','build ark'),('CHANGE_PASSWORD','DE','Wenn Du Dein Passwort ändern willst, gib das neue Passwort bitte hier zweimal ein.'),('CHANGE_PASSWORD','EN','If you want to change your password, please insert it here two times.'),('CH_LUCK','DE','Glücksfaktor ändern'),('CH_LUCK','EN','change fortune'),('CITY_HEADING','DE','Rangfolge der Erdlinge:'),('CITY_HEADING','EN','Ranking of earthlings:'),('CMD_BLESS_HERO','DE','Held weihen'),('CMD_BLESS_HERO','EN','bless hero'),('CMD_BLESS_HERO_MSG','DE','Anzahl neue Helden'),('CMD_BLESS_HERO_MSG','EN','Number of new heros'),('CMD_BLESS_PRIEST','DE','Priester weihen'),('CMD_BLESS_PRIEST','EN','bless priest'),('CMD_BLESS_PRIEST_MSG','DE','Weihe einen neuen Priester'),('CMD_BLESS_PRIEST_MSG','EN','Bless a new priest'),('CMD_BUILD_ARK','DE','Arche bauen'),('CMD_BUILD_ARK','EN','build ark'),('CMD_BUILD_ARK_MSG','DE','Baue Arche in'),('CMD_BUILD_ARK_MSG','EN','Build ark in'),('CMD_BUILD_TEMPLE','DE','Tempel bauen'),('CMD_BUILD_TEMPLE','EN','build temple'),('CMD_BUILD_TEMPLE_MSG','DE','Baue einen Tempel in'),('CMD_BUILD_TEMPLE_MSG','EN','build temple in'),('CMD_CH_ACTION_MSG','DE','Wähle neue Avatar-Aktion'),('CMD_CH_ACTION_MSG','EN','Choose new avatar action'),('CMD_CH_ADORING_MSG','DE','Deine Helden beten jetzt zu'),('CMD_CH_ADORING_MSG','EN','Your heros now adoring'),('CMD_CH_LUCK','DE','Glücksfaktor ändern'),('CMD_CH_LUCK','EN','change luck'),('CMD_CH_LUCK_MSG','DE','Verändere den Glücksfaktor um'),('CMD_CH_LUCK_MSG','EN','Change luck-factor about'),('CMD_CH_STATUS_MSG','DE','Setze deine neue Beziehung zu'),('CMD_CH_STATUS_MSG','EN','Set your new relation to'),('CMD_COUNT','DE','Anzahl'),('CMD_COUNT','EN','Number'),('CMD_DESTROY','DE','Tempel zerstören'),('CMD_DESTROY','EN','destroy temple'),('CMD_DESTROY_MSG','DE','Zerstöre den Tempel in'),('CMD_DESTROY_MSG','EN','Destroy the temple at'),('CMD_DIE_ORDER','DE','Sterbereihenfolge ändern'),('CMD_DIE_ORDER','EN','change die-order'),('CMD_DIE_ORDER_MSG','DE','Wähle die neue Sterbe-Reihenfolge deiner Einheiten'),('CMD_DIE_ORDER_MSG','EN','Choose the new die-order of your units'),('CMD_ERROR_MSG','DE','unvollständiger Befehl'),('CMD_ERROR_MSG','EN','incomplete command'),('CMD_FLOOD','DE','überfluten'),('CMD_FLOOD','EN','flood'),('CMD_FLOOD_MSG','DE','überflute'),('CMD_FLOOD_MSG','EN','flood'),('CMD_INCARNATE','DE','Avatare erschaffen'),('CMD_INCARNATE','EN','create avatars'),('CMD_INCARNATE_MSG','DE','Anzahl der neuen Avatare'),('CMD_INCARNATE_MSG','EN','Number of new avatars'),('CMD_MOVE','DE','bewegen'),('CMD_MOVE','EN','move'),('CMD_MOVE_MSG','DE','bewege %1 in Richtung <br>Mögliche Richtungen: <br> <table>\r\n<tr><td></td><td>N</td><td></td></tr>\r\n<tr><td>NW</td><td></td><td>NE</td></tr>\r\n<tr><td>SW</td><td></td><td>SE</td></tr>\r\n<tr><td></td><td>S</td><td></td></tr>\r\n</table>\r\n'),('CMD_MOVE_MSG','EN','move %1 in direction <br>Possible directions:<br><table>\r\n<tr><td></td><td>N</td><td></td></tr>\r\n<tr><td>NW</td><td></td><td>NE</td></tr>\r\n<tr><td>SW</td><td></td><td>SE</td></tr>\r\n<tr><td></td><td>S</td><td></td></tr>\r\n</table>\r\n'),('CMD_MOVE_MTN','DE','Berg versetzten'),('CMD_MOVE_MTN','EN','move mountain'),('CMD_MOVE_MTN_MSG','DE','soll versetzt werden nach'),('CMD_MOVE_MTN_MSG','EN','should be moved to'),('CMD_PLAGUE','DE','verseuchen'),('CMD_PLAGUE','EN','init plague'),('CMD_PLAGUE_MSG','DE','Wähle Seuche für'),('CMD_PLAGUE_MSG','EN','Choose plague for'),('CONQUERED_ARKS','DE','Eroberte Archen'),('CONQUERED_ARKS','EN','Conquered arks'),('DEAD_AVATARS','DE','Tote Avatare'),('DEAD_AVATARS','EN','dead avatars'),('DEAD_HEROS','DE','Gefallene Helden'),('DEAD_HEROS','EN','Dead heros'),('DEAD_PRIESTS','DE','Gefallene Priester'),('DEAD_PRIESTS','EN','Dead priests'),('DEAD_WARRIORS','DE','Gefallene Krieger'),('DEAD_WARRIORS','EN','Dead warriors'),('END_OF_GAME','DE','Das Spiel ist aus! Die Gewinner entnehmt ihr bitte der Statistik.'),('END_OF_GAME','EN','The game is over! For winners look in the statistic section.'),('ERROR_NO_LOGIN','DE','Um diese Aymargeddon-Seite anzusehen, müssen Sie sich erst <a href=\"login.epl\">einloggen</a>, da der Inhalt für jeden Spieler verschieden ist.'),('ERROR_NO_LOGIN','EN','To view this aymargeddon page you first need to <a href=\"login.epl\">login</a>, because it\'s content is different for each player.'),('EVENT_ARK_APPROACHING','DE','Von %1 kommt eine Arche.'),('EVENT_ARK_APPROACHING','EN','An ark comes from %1.'),('EVENT_BUILD_ARK','DE','Spieler %1 baut eine Arche.'),('EVENT_BUILD_ARK','EN','Player %1 builds an ark.'),('EVENT_BUILD_TEMPLE','DE','Ein Tempel für den Gott %2 der Größe %3 wird fertig.'),('EVENT_BUILD_TEMPLE','EN','A temple for god %2 with size %3 will be finished.'),('EVENT_FIGHT_GOD','DE','Hier findet ein Avatarkampf zwischen %2 und %3 statt.'),('EVENT_FIGHT_GOD','EN','Here is an avatar fight between %2 and %3.'),('EVENT_FLOOD','DE','Der Gott %1 hat die Sintflut herbeigerufen! '),('EVENT_FLOOD','EN','The god %1 will flood this aerea!'),('EVENT_MOBILE_APPROACHING','DE','Aus %2 kommen %3 %4 von Spieler %1 hier an.'),('EVENT_MOBILE_APPROACHING','EN','From field %2 will come %3 %4 from player %1.'),('EVENT_PRODUCE_PRIEST','DE','Ein Priester beendet seine Ausbildung.'),('EVENT_PRODUCE_PRIEST','EN','A priest finish his training.'),('EVENT_PRODUCE_WARRIOR','DE','Ein Krieger beendet seine Ausbildung.'),('EVENT_PRODUCE_WARRIOR','EN','A warrior finish his training.'),('FIELD_AYMARGEDDON','DE','Aymargeddon'),('FIELD_AYMARGEDDON','EN','Aymargeddon'),('FIELD_CITY','DE','Die Stadt'),('FIELD_CITY','EN','The city'),('FIELD_ISLE','DE','Die Insel'),('FIELD_ISLE','EN','The island'),('FIELD_MOUNTAIN','DE','Der Berg'),('FIELD_MOUNTAIN','EN','The mountain'),('FIELD_PLAIN','DE','Die Ebene'),('FIELD_PLAIN','EN','The plain'),('FIELD_POLE','DE','Der Manapol'),('FIELD_POLE','EN','The mana pole'),('FIELD_WATER','DE','Das Wasserfeld'),('FIELD_WATER','EN','The water field'),('FIGHTING_STRENGTH','DE','Kampfstärke'),('FIGHTING_STRENGTH','EN','Fighting strength'),('FIGHT_AVATAR','DE','Avatarkampf'),('FIGHT_AVATAR','EN','avatar fight'),('FIGHT_EARTHLING','DE','%1 versucht dieses Feld zu erobern.'),('FIGHT_EARTHLING','EN','%1 trys to conquer this field.'),('FLANKING','DE','Flankierungsbonus'),('FLANKING','EN','Flanking'),('FORM_BACK_BUTTON','DE','zurück'),('FORM_BACK_BUTTON','EN','back'),('FORM_OK_BUTTON','DE','senden'),('FORM_OK_BUTTON','EN','submit'),('GEN_FEMALE','DE','Frau'),('GEN_FEMALE','EN','Woman'),('GEN_MALE','DE','Mann'),('GEN_MALE','EN','Man'),('GEN_PLURAL','DE','Gruppe'),('GEN_PLURAL','EN','Group'),('GLOBAL','DE','allen Feldern'),('GLOBAL','EN','all places'),('GOD','DE','Gott'),('GOD','EN','god'),('GODS_HELP','DE','Göttlicher Unterstützung'),('GODS_HELP','EN','Help of gods'),('HOMECITY','DE','Es ist die Heimatstadt'),('HOMECITY','EN','It\'s the home town'),('HOMEHOLY','DE','Es ist ein heiliger Berg'),('HOMEHOLY','EN','It\'s a holy mountain'),('INCARNATE','DE','Avatar erschaffen'),('INCARNATE','EN','create avatar'),('LANG_ENGLISH','DE','Englisch'),('LANG_ENGLISH','EN','English'),('LANG_GERMAN','DE','Deutsch'),('LANG_GERMAN','EN','German'),('LANG_WELCOME','DE','Wählen Sie ihre bevorzugte Sprache'),('LANG_WELCOME','EN','Choose your favorite language'),('LAST_BATTLE_HEADING','DE','Derzeitige Kampfstärken der Götter in der letzten Schlacht:'),('LAST_BATTLE_HEADING','EN','Actual fighting power of gods for the last battle:'),('LAST_BATTLE_LINE','DE','%1 kämpft mit Stärke %2.'),('LAST_BATTLE_LINE','EN','%1 fights with strength %2.'),('LOGIN_EMAIL','DE','e-Mail Adresse'),('LOGIN_EMAIL','EN','email'),('LOGIN_FAILED','DE','Login fehlgeschlagen. Falsches Passwort oder unbekannter Benutzername.'),('LOGIN_FAILED','EN','Login failed. Wrong password or unknown username.'),('LOGIN_PASSWORD','DE','Passwort'),('LOGIN_PASSWORD','EN','password'),('LOGIN_REALNAME','DE','richtiger Name'),('LOGIN_REALNAME','EN','real name'),('LOGIN_REG_ERROR','DE','Die Anmeldung ist fehlgeschlagen. Vielleicht ist der Benutzername schon vergeben. Nicht vergessen: Jeder Benutzer darf nur <strong>einen</strong> Account bei uns haben!!'),('LOGIN_REG_ERROR','EN','We couldn\'t register you. Maybe the login name is already in use. Always remember: any user is only allowed <strong>one</strong> account on this server!!'),('LOGIN_REG_FORM_HEAD','DE','Suchen sie sich einen Benutzernamen aus:'),('LOGIN_REG_FORM_HEAD','EN','Choose your login name:'),('LOGIN_REG_LINK','DE','anmelden'),('LOGIN_REG_LINK','EN','register'),('LOGIN_REG_MSG','DE','Wenn Du noch keinen Aymargeddon-Account hast, solltest Du dich'),('LOGIN_REG_MSG','EN','If you don\'t have an aymargeddon account, you should'),('LOGIN_REG_OK_HEAD','DE','Die Anmeldung hat geklappt.'),('LOGIN_REG_OK_HEAD','EN','You are now registered.'),('LOGIN_REG_OK_TAIL','DE','Das Passwort für den Account wird an die angegebene Adresse geschickt.'),('LOGIN_REG_OK_TAIL','EN','The password for your account will be sent to your email adress.'),('LOGIN_REG_RETURN','DE','zurück zum Eingang'),('LOGIN_REG_RETURN','EN','back to the login'),('LOGIN_USERNAME','DE','Benutzername'),('LOGIN_USERNAME','EN','Username'),('LOGIN_WELCOME','DE','Der Eingang zu <strong>Aymargeddon</strong>!'),('LOGIN_WELCOME','EN','The Entrance to <strong>Aymargeddon</strong>!'),('LUCK','DE','Gewürfelt'),('LUCK','EN','Dice roll'),('MOBILE_ARK','DE','Arche'),('MOBILE_ARK','EN','ark'),('MOBILE_ARK_PL','DE','Archen'),('MOBILE_ARK_PL','EN','arks'),('MOBILE_AVATAR','DE','Avatar'),('MOBILE_AVATAR','EN','avatar'),('MOBILE_AVATAR_PL','DE','Avatare'),('MOBILE_AVATAR_PL','EN','avatars'),('MOBILE_BLOCK','DE','blockieren'),('MOBILE_BLOCK','EN','block'),('MOBILE_HELP','DE','helfen'),('MOBILE_HELP','EN','help'),('MOBILE_HERO','DE','Held'),('MOBILE_HERO','EN','hero'),('MOBILE_HERO_PL','DE','Helden'),('MOBILE_HERO_PL','EN','heros'),('MOBILE_IGNORE','DE','ignorieren'),('MOBILE_IGNORE','EN','ignore'),('MOBILE_PRIEST','DE','Priester'),('MOBILE_PRIEST','EN','priest'),('MOBILE_PRIEST_PL','DE','Priester'),('MOBILE_PRIEST_PL','EN','priests'),('MOBILE_PROPHET','DE','Prophet'),('MOBILE_PROPHET','EN','prophet'),('MOBILE_PROPHET_PL','DE','Propheten'),('MOBILE_PROPHET_PL','EN','prophets'),('MOBILE_WARRIOR','DE','Krieger'),('MOBILE_WARRIOR','EN','warrior'),('MOBILE_WARRIOR_PL','DE','Krieger'),('MOBILE_WARRIOR_PL','EN','warriors'),('MOVE','DE','bewegen'),('MOVE','EN','move'),('MSG_AVATAR_DEAD','DE','In %1 starb ein Avatar von %2 im Kampf. Er kämpft jetzt in der letzten Schlacht für seinen Gott.'),('MSG_AVATAR_DEAD','EN','In %1 died an avatar of %2. He fights now in the last battle for his god.'),('MSG_BLESS_HERO','DE','Der Gott %1 hat in %3 einen Krieger gesegnet, so dass dieser fortan heroische Kräfte entfalten kann.'),('MSG_BLESS_HERO','EN','The god %1 has blessed a warrior from %2 in %3. He is from now on called \'HERO\'!'),('MSG_BLESS_PRIEST','DE','%1 hat einen Krieger von %2 in %3 zum Priester geweiht.'),('MSG_BLESS_PRIEST','EN','%1 blessed a warrior from %2 in %3. It is now a priest.'),('MSG_BUILD_ARK','DE','%1 hat in %2 eine Arche gebaut.'),('MSG_BUILD_ARK','EN','%1 has build an ark in %2.'),('MSG_BUILD_TEMPLE','DE','%1 hat in %3 einen Tempel zu Ehren von %2 errichtet. Es ist der größte Tempel weit und breit!'),('MSG_BUILD_TEMPLE','EN','%1 has build a temple to pray to %3 in %2. It is the largest temple in the world!'),('MSG_CANT_ATTACK_ALLIE','DE','Fehler bei Verarbeitung von Befehl %1: Du kannst Deinen Verbündeten %2 nicht angreifen in Feld %3.'),('MSG_CANT_ATTACK_ALLIE','EN','Error during process of command %1: You cant yttack your allie %2 in field %3.'),('MSG_CANT_BUILD_HERE','DE','Fehler bei Verarbeitung von Befehl %1: Das kann man auf Feld %2 nicht bauen.'),('MSG_CANT_BUILD_HERE','EN','Error during process of command %1: You cant build this in field %2.'),('MSG_CANT_DESTROY_DEFENDED','DE','Du kannst den Tempel in %1 nicht zerstören, weil er von Priestern eines anderen Gottes beschützt wird.'),('MSG_CANT_DESTROY_DEFENDED','EN','You cant destroy the temple in %1. The temple is defended by unorthodox priests.'),('MSG_CANT_DESTROY_MOUNTAIN','DE','Du kannst den Tempel auf dem Berg %1 nicht zerstören.'),('MSG_CANT_DESTROY_MOUNTAIN','EN','You cant destroy the temple on mountain %1.'),('MSG_CANT_DESTROY_OWN','DE','Du kannst den Tempel in %1 nicht zerstören da er Dir selbst gehört.'),('MSG_CANT_DESTROY_OWN','EN','You cant destroy your very own temple in %1.'),('MSG_CANT_FLOOD_TERRAIN','DE','Du kannst %1 nicht überfluten: Falsches Terrain %2.'),('MSG_CANT_FLOOD_TERRAIN','EN','You cant flood %1: Wrong terrain %2.'),('MSG_CANT_LEAVE_AYMARGEDDO','DE','Fehler bei Verarbeitung von Befehl %1: Du kannst die Aymargeddon in Feld %2 nicht verlassen!'),('MSG_CANT_LEAVE_AYMARGEDDO','EN','Error during process of command %1: You cant leave Aymargeddon in field %2.'),('MSG_CANT_MOVE_ATTACKED','DE','Du kannst keine %2 aus %1 bewegen, so lange dort gekämpft wird.'),('MSG_CANT_MOVE_ATTACKED','EN','You cant move %2 from %1 during fight.'),('MSG_CANT_MOVE_PLAGUE','DE','%2 können sich in %1 nicht bewegen, weil sie von der %3 betroffen sind.'),('MSG_CANT_MOVE_PLAGUE','EN','%2 cant move in %1 because of %3.'),('MSG_CANT_MOVE_TO_POLE','DE','Fehler bei Verarbeitung von Befehl %1: Du kannst Dich nicht auf den Pol %2 bewegen.'),('MSG_CANT_MOVE_TO_POLE','EN','Error during process of command %1: You cant move to pole %2.'),('MSG_CANT_RESCUE_WORLD','DE','Du kannst den Tempel in %2 nicht mehr zerstören, weil nur noch %1 Tempelbauplätze unbesetzt sind. Das Ende der Welt ist unaufhaltsam!'),('MSG_CANT_RESCUE_WORLD','EN','You cant destroy the temple in %2. There are only %1 unbuild temples left. The end of the world is irresistible.'),('MSG_CANT_SWIM','DE','Fehler bei Verarbeitung von Befehl %1: %3 können nicht schwimmen in %2.'),('MSG_CANT_SWIM','EN','Error during process of command %1: %3 cant swim in %2.'),('MSG_CHANGE_FORTUNE','DE','%1 hat den Glücksfaktor von %2 auf %3 geändert.'),('MSG_CHANGE_FORTUNE','EN','%1 changed the fortune from %2 to %3.'),('MSG_CH_ACTION','DE','Die Avatare in %2 haben jetzt den Status %1.'),('MSG_CH_ACTION','EN','The avatars in %2 now have the status %1.'),('MSG_CH_STATUS','DE','Dein neuer Status gegenüber %1 ist jetzt %2.'),('MSG_CH_STATUS','EN','Your new status regarding %1 is now %2.'),('MSG_DESTROY_NEED_AVATAR','DE','Du brauchst einen Avatar um den Tempel in %1 zerstören zu können.'),('MSG_DESTROY_NEED_AVATAR','EN','You need an avatar to destroy the temple in %1.'),('MSG_DIE_ORDER','DE','Du hast Deine Sterbereihenfolge geändert. Sie lautet jetzt: %1.'),('MSG_DIE_ORDER','EN','You changed your die order to %1.'),('MSG_DONT_MOVE_WITH','DE','Nicht mehr mitbewegen.'),('MSG_DONT_MOVE_WITH','EN','Don\'t move with any mobile.'),('MSG_EARTHLING_CANT_MOVE_T','DE','Fehler bei Verarbeitung von Befehl %1: Du als Erdling kannst keine %2 bewegen.'),('MSG_EARTHLING_CANT_MOVE_T','EN','Error during process of command %1: Earthlings cant move %2.'),('MSG_FIGHT_DIE','DE','Ein %2 von %1 in %3 stirbt.'),('MSG_FIGHT_DIE','EN','A %2 from %1 in %3 dies.'),('MSG_FIGHT_END','DE','Die Horden von %1 griffen %2 in %4 an. %3 gewann.'),('MSG_FIGHT_END','EN','The army of %1 attacked %2 in %4. %3 won the battle.'),('MSG_FIGHT_RETREAT','DE','%4 %2 von %1 ziehen sich aus %3 zurück.'),('MSG_FIGHT_RETREAT','EN','%4 %2 from %1 retreats from %3.'),('MSG_FIGHT_RETREAT_DIE','DE','%4 %2 von %1 sterben in %3 weil sie keine Rückzugsmöglichkeit haben.'),('MSG_FIGHT_RETREAT_DIE','EN','%4 %2 from %1 die in %3: No way to retreat.'),('MSG_FLOOD','DE','%1 hat das Feld %2 überflutet. Aus %3 wurde %4.'),('MSG_FLOOD','EN','%1 has flooded %2. The old terrain %3 is now %4.'),('MSG_FLOOD_NEED_AVATAR','DE','Zum überfluten von %1 braucht man einen Avatar.'),('MSG_FLOOD_NEED_AVATAR','EN','You need an avatar in %1 to flood this field.'),('MSG_GOD_CANT_MOVE_TYPE','DE','Fehler bei Verarbeitung von Befehl %1: Als Gott kannst Du keine %2 bewegen.'),('MSG_GOD_CANT_MOVE_TYPE','EN','Error during process of command %1: Gods cant move type %2.'),('MSG_INCARNATE','DE','%1 inkarnierte einen Avatar in %2.'),('MSG_INCARNATE','EN','%1 incarnates an avatar in %2.'),('MSG_MOBILE_ARRIVES','DE','%1 %2 von %3 sind in %4 angekommen.'),('MSG_MOBILE_ARRIVES','EN','%1 %2 from %3 arrived in %4.'),('MSG_MOBILE_DRAWN','DE','%1 %2 von %3 sind in %4 jämmerlich ersoffen.'),('MSG_MOBILE_DRAWN','EN','%1 %2 from %3 drawn in %4.'),('MSG_MOVE_NO_TARGET','DE','Fehler bei Verarbeitung von Befehl %1: Von Feld %2 gibt es kein Feld in Richtung %3.'),('MSG_MOVE_NO_TARGET','EN','Error during process of command %1: There is no field in direction %3 from field %2.'),('MSG_MOVE_WITH','DE','Bewegt sich mit'),('MSG_MOVE_WITH','EN','Moves with'),('MSG_NOT_ENOUGH_MANA','DE','Dir fehlt Mana um den Befehl \"%1\" in %2 auszuführen.'),('MSG_NOT_ENOUGH_MANA','EN','You lack mana to execute the command \"%1\" in %2.'),('MSG_NOT_ENOUGH_MOBILES','DE','Fehler bei Verarbeitung von Befehl %1: %2 sind zu wenige in Feld %3.'),('MSG_NOT_ENOUGH_MOBILES','EN','Error during process of command %1: %2 is not enough in field %3.'),('MSG_NO_SUCH_MOBILE','DE','Fehler: Eine Einheit mit der ID %1 konnte nicht gefunden werden.'),('MSG_NO_SUCH_MOBILE','EN','Error: Cant find mobile with ID %1.'),('MSG_NO_SUCH_ROLE','DE','Fehler bei Verarbeitung des Befehls %1: Du kannst Deinen Status gegenüber jemandem, den es nicht gibt, wohl kaum ändern.'),('MSG_NO_SUCH_ROLE','EN','Error during process of command %1: You cant change your status to unknown players.'),('MSG_NO_TEMPLE_TO_DESTROY','DE','Du kannst in %1 keinen Tempel zerstören: Es ist keiner da.'),('MSG_NO_TEMPLE_TO_DESTROY','EN','You cant destroy an non existent temple in %1.'),('MSG_STATUS_INVALID','DE','Fehler bei Verarbeitung von Befehl %1: Unbekannter Status \"%2\"'),('MSG_STATUS_INVALID','EN','Error during process of command %1: Unknown status \"%2\"'),('MSG_TEMPLE_DESTROYD','DE','%3 hat in %1 einen Tempel, der %2 geweiht war, zerstört.'),('MSG_TEMPLE_DESTROYD','EN','%3 destroyd the temple of god %2 in %1.'),('MSG_TRANSPORTS','DE','reist zusammen mit'),('MSG_TRANSPORTS','EN','travels with'),('MSG_WRONG_TYPE','DE','Fehler bei Verarbeitung von Befehl %1: Falscher Typ %2 in Feld %3.'),('MSG_WRONG_TYPE','EN','Error during process of command %1: Wrong Type %2 in field %3.'),('NEW_HEROS','DE','Neue Helden'),('NEW_HEROS','EN','new heros'),('NOBODY','DE','niemand'),('NOBODY','EN','nobody'),('NOM_CHARNAME','DE','Charaktername'),('NOM_CHARNAME','EN','Character name'),('NOM_DESCRIPTION','DE','Beschreibung'),('NOM_DESCRIPTION','EN','Description'),('NOM_GENDER','DE','Geschlecht'),('NOM_GENDER','EN','Gender'),('NOM_ROLE','DE','Rolle'),('NOM_ROLE','EN','Role'),('NOT_OCCUPIED','DE','unbesetzt'),('NOT_OCCUPIED','EN','not occupied'),('OCCUPIED','DE','besetzt von'),('OCCUPIED','EN','occupied by'),('OWN_MANA','DE','Du hast %1 Mana zur Verfügung.<p>'),('OWN_MANA','EN','You have %1 mana.<p>'),('PAGE_LANGUAGE','DE','Sprache'),('PAGE_LANGUAGE','EN','Language'),('PAGE_LOGIN','DE','Einloggen'),('PAGE_LOGIN','EN','Login'),('PAGE_LOGOUT','DE','Ausloggen'),('PAGE_LOGOUT','EN','Logout'),('PAGE_MAP','DE','Karte'),('PAGE_MAP','EN','Map'),('PAGE_PLAYER','DE','Spieler'),('PAGE_PLAYER','EN','Player'),('PAGE_REFERENCE','DE','Kurzreferenz'),('PAGE_REFERENCE','EN','short reference'),('PAGE_RULES','DE','Regeln'),('PAGE_RULES','EN','Rules'),('PAGE_START','DE','Start'),('PAGE_START','EN','Start'),('PEOPLE_OR_ARK','DE','Leute (oder Archen)'),('PEOPLE_OR_ARK','EN','people (or arks)'),('PLAGUE_IN_FIELD','DE','Hier grassiert die %1.'),('PLAGUE_IN_FIELD','EN','Here rampant %1.'),('PLAYER_CHOOSE_GAME','DE','Du musst erst ein Spiel wählen, bevor es mehr zu sehen gibt.'),('PLAYER_CHOOSE_GAME','EN','You must choose a game if you want to see more.'),('PLAYER_CREATE_CHAR','DE','Erschaffe deinen Charakter für'),('PLAYER_CREATE_CHAR','EN','Create your character for'),('PLAYER_DELETE_MESSAGES','DE','Alle nachrichten löschen.'),('PLAYER_DELETE_MESSAGES','EN','Delete all messages.'),('PLAYER_EVENTS','DE','Ereignisse'),('PLAYER_EVENTS','EN','Events'),('PLAYER_GAMES_NONE','DE','keine'),('PLAYER_GAMES_NONE','EN','none'),('PLAYER_MESSAGES','DE','Folgende Nachrichten sind für dich eingetroffen:'),('PLAYER_MESSAGES','EN','You got the following new messages:'),('PLAYER_MESSAGES_HEADING','DE','Nachrichten'),('PLAYER_MESSAGES_HEADING','EN','Messages'),('PLAYER_NO_EVENTS','DE','Keine bekannten Ereignisse für Dich.'),('PLAYER_NO_EVENTS','EN','No known events'),('PLAYER_NO_MESSAGE','DE','Es gibt keine neuen Nachrichten für dich.'),('PLAYER_NO_MESSAGE','EN','There are no new messages for you.'),('PLAYER_OPENGAMES','DE','<strong>offene Spiele</strong>'),('PLAYER_OPENGAMES','EN','<strong>open games</strong>'),('PLAYER_OWN_GAMES','DE','<strong>eigene Spiele</strong>'),('PLAYER_OWN_GAMES','EN','<strong>own games</strong>'),('PLAYER_STATISTIC','DE','Statistik'),('PLAYER_STATISTIC','EN','Statistics'),('PLAYER_TO_MAP','DE','Zur Karte'),('PLAYER_TO_MAP','EN','To the map'),('PLAYER_WELCOME','DE','Willkommen bei'),('PLAYER_WELCOME','EN','Welcome to'),('PPRO_DAT3_PL','DE','euch'),('PPRO_DAT3_PL','EN','you'),('PPRO_DAT3_SG','DE','dir'),('PPRO_DAT3_SG','EN','you'),('PPRO_DAT_F','DE','ihr'),('PPRO_DAT_F','EN','her'),('PPRO_DAT_M','DE','ihm'),('PPRO_DAT_M','EN','him'),('PPRO_DAT_PL','DE','ihnen'),('PPRO_DAT_PL','EN','them'),('PPRO_GEN_F','DE','ihr'),('PPRO_GEN_F','EN','her'),('PPRO_GEN_M','DE','sein'),('PPRO_GEN_M','EN','his'),('PPRO_GEN_PL','DE','ihr'),('PPRO_GEN_PL','EN','their'),('PREP_IS_PL','DE','sind'),('PREP_IS_PL','EN','are'),('PREP_IS_SG','DE','ist'),('PREP_IS_SG','EN','is'),('PREP_OWN_PL','DE','deiner'),('PREP_OWN_PL','EN','of your'),('PREP_OWN_SG','DE','von'),('PREP_OWN_SG','EN','of'),('REGISTER_MAIL_SUBJECT','DE','Willkommen bei Aymargeddon!'),('REGISTER_MAIL_SUBJECT','EN','Welcome to Aymargeddon!'),('REGISTER_MAIL_TEXT','DE','Hallo %1,\r\n\r\nHerzlich willkommen bei Aymargeddon. Dein Login lautet %2 und Dein Paswort lautet %3.\r\n\r\nBitte trage Dich auch auf die Mailingliste ein: \r\nhttp://aymargeddon.de/cgi-bin/mailman/listinfo/aymargeddon\r\n\r\nViel Spaß wünscht das Aymargeddon Development Team'),('REGISTER_MAIL_TEXT','EN','Hello %1,\r\n\r\nWelcome to Aymargeddon. Your login is %2 and your password is %3.\r\n\r\nYou should also subscribe to the mailing list:\r\n\r\nhttp://aymargeddon.de/cgi-bin/mailman/listinfo/aymargeddon\r\n\r\nHave fun!\r\n\r\nThe Aymargeddon Development Team'),('ROLE_EARTHLING','DE','Erdling'),('ROLE_EARTHLING','EN','earthling'),('ROLE_GOD','DE','Gott'),('ROLE_GOD','EN','god'),('ROLE_OBSERVER','DE','Beobachter'),('ROLE_OBSERVER','EN','observer'),('SEND_MESSAGE','DE','kontaktieren'),('SEND_MESSAGE','EN','contact'),('SEND_MESSAGE_TO','DE','Nachricht an %1:'),('SEND_MESSAGE_TO','EN','Message to %1:'),('STATISTIC_EARTHLING_CITY','DE','%1 hat %2 Städte.'),('STATISTIC_EARTHLING_CITY','EN','%1 has %2 citys.'),('STATISTIC_FORTUNE','DE','Der Glücksfaktor ist %1.<p>'),('STATISTIC_FORTUNE','EN','Fortune is %1.<p>'),('STATISTIC_NEW_TEMPLES','DE','Es sind zur Zeit %1 Tempel in Bau'),('STATISTIC_NEW_TEMPLES','EN','%1 temples will be build.'),('STATISTIC_SPEED','DE','Spielgeschwindigkeit: Eine Zeiteinheit dauert %1.<p>'),('STATISTIC_SPEED','EN','Game speed: One time intervall is %1.<p>'),('STATISTIC_UNBUILD','DE','%1 Tempel sind noch nicht gebaut.'),('STATISTIC_UNBUILD','EN','%1 temples are unbuild.'),('STAT_ALLIED','DE','Alliiert'),('STAT_ALLIED','EN','allied'),('STAT_BETRAY','DE','Verrat'),('STAT_BETRAY','EN','betray'),('STAT_FOE','DE','Feind'),('STAT_FOE','EN','enemy'),('STAT_FRIEND','DE','Freund'),('STAT_FRIEND','EN','friend'),('STAT_NEUTRAL','DE','Neutral'),('STAT_NEUTRAL','EN','neutral'),('SUM_OF_STRENGTH','DE','Gesamtstärke'),('SUM_OF_STRENGTH','EN','Total strength'),('SUNKEN_ARKS','DE','Gesunkene Archen'),('SUNKEN_ARKS','EN','Sunken arks'),('TEMPLE','DE','Hier steht ein Tempel'),('TEMPLE','EN','Here is a temple'),('TEST_TAG','DE','ich %1, dass %2! Prozent: %% hier nochmal: %2 %1'),('TIME_WITH_DAYS','DE','In %1 Tagen, %2 Stunden, %3 Minuten und %4 Sekunden'),('TIME_WITH_DAYS','EN','In %1 days, %2 hours, %3 minutes and %4 seconds'),('TIME_WITH_HOURS','DE','In %1 Stunden, %2 Minuten und %3 Sekunden'),('TIME_WITH_HOURS','EN','In %1 hours, %2 minutes and %3 seconds'),('TIME_WITH_MINUTES','DE','In %1 Minuten und %2 Sekunden'),('TIME_WITH_MINUTES','EN','In %1 minutes and %2 seconds'),('TIME_WITH_SECONDS','DE','In %1 Sekunden'),('TIME_WITH_SECONDS','EN','In %1 seconds'),('UNASSIGNED','DE','nicht vergebene Position'),('UNASSIGNED','EN','unassigned position'),('UNAVAILABLE_UNITS','DE','beschäftigte Einheiten'),('UNAVAILABLE_UNITS','EN','unavailable units'),('WINNER_IS','DE','Sieger ist'),('WINNER_IS','EN','Winner is');
/*!40000 ALTER TABLE `LOCALIZE` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-05-17 18:14:55
