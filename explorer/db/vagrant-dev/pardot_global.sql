-- MySQL dump 10.13  Distrib 5.5.47-37.7, for Linux (x86_64)
--
-- Host: localhost    Database: pardot_global
-- ------------------------------------------------------
-- Server version	5.5.47-37.7-log

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
-- Current Database: `pardot_global`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `pardot_global` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;

USE `pardot_global`;

--
-- Table structure for table `account_deletion_audit`
--

DROP TABLE IF EXISTS `account_deletion_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_deletion_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `company` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `type` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `metadata` text COLLATE utf8_unicode_ci,
  `shard_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_deletion_audit_FI_1` (`user_id`),
  CONSTRAINT `account_deletion_audit_FK_1` FOREIGN KEY (`user_id`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_deletion_audit`
--

LOCK TABLES `account_deletion_audit` WRITE;
/*!40000 ALTER TABLE `account_deletion_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_deletion_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_key`
--

DROP TABLE IF EXISTS `api_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_key` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `application_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `api_key` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `ip_address` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `api_key` (`api_key`),
  KEY `api_key_FI_1` (`account_id`),
  KEY `api_key_FI_2` (`user_id`),
  KEY `api_key_FI_3` (`created_by`),
  CONSTRAINT `api_key_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`),
  CONSTRAINT `api_key_FK_2` FOREIGN KEY (`user_id`) REFERENCES `global_user` (`id`),
  CONSTRAINT `api_key_FK_3` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_key`
--

LOCK TABLES `api_key` WRITE;
/*!40000 ALTER TABLE `api_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `app_metric`
--

DROP TABLE IF EXISTS `app_metric`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `app_metric` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `shard_id` int(11) DEFAULT NULL,
  `module` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hostname` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `referer` text COLLATE utf8_unicode_ci,
  `request_uri` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `request_params` text COLLATE utf8_unicode_ci,
  `cookies` text COLLATE utf8_unicode_ci,
  `user_id` int(11) DEFAULT NULL,
  `user_details` text COLLATE utf8_unicode_ci,
  `visitor_details` text COLLATE utf8_unicode_ci,
  `visitor_id` int(11) DEFAULT NULL,
  `execution_time` float DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_metric`
--

LOCK TABLES `app_metric` WRITE;
/*!40000 ALTER TABLE `app_metric` DISABLE KEYS */;
/*!40000 ALTER TABLE `app_metric` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `db_migration`
--

DROP TABLE IF EXISTS `db_migration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `db_migration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL,
  `file` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `applied` int(11) NOT NULL DEFAULT '0',
  `applied_at` datetime DEFAULT NULL,
  `is_approved` int(11) NOT NULL DEFAULT '0',
  `is_denied` int(11) NOT NULL DEFAULT '0',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `db_migration_FI_1` (`approved_by`),
  CONSTRAINT `db_migration_FK_1` FOREIGN KEY (`approved_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `db_migration`
--

LOCK TABLES `db_migration` WRITE;
/*!40000 ALTER TABLE `db_migration` DISABLE KEYS */;
/*!40000 ALTER TABLE `db_migration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `db_overage_report`
--

DROP TABLE IF EXISTS `db_overage_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `db_overage_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `company` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `db_limit` int(11) DEFAULT NULL,
  `total_overage` int(11) DEFAULT NULL,
  `overage_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `db_overage_report_lookup` (`account_id`,`overage_date`),
  CONSTRAINT `db_overage_report_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `db_overage_report`
--

LOCK TABLES `db_overage_report` WRITE;
/*!40000 ALTER TABLE `db_overage_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `db_overage_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `demo_group`
--

DROP TABLE IF EXISTS `demo_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `demo_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `account_name_prefix` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `user_name_prefix` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `expiration_date` datetime NOT NULL,
  `is_ready` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_account_prefix` (`account_name_prefix`),
  UNIQUE KEY `ix_user_prefix` (`user_name_prefix`),
  KEY `demo_group_FI_1` (`created_by`),
  KEY `demo_group_FI_2` (`updated_by`),
  CONSTRAINT `demo_group_FK_1` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`),
  CONSTRAINT `demo_group_FK_2` FOREIGN KEY (`updated_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `demo_group`
--

LOCK TABLES `demo_group` WRITE;
/*!40000 ALTER TABLE `demo_group` DISABLE KEYS */;
INSERT INTO `demo_group` VALUES (1,'Test Group 1','g1_','usr1_','2014-10-13 00:00:00',1,0,'2014-09-13 12:00:00',2,'2014-09-13 12:00:00',2),(2,'Test Group 2','g2_','usr2_','2014-10-14 00:00:00',0,0,'2014-09-14 13:00:00',8,'2014-09-14 13:00:00',8);
/*!40000 ALTER TABLE `demo_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `demo_group_account`
--

DROP TABLE IF EXISTS `demo_group_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `demo_group_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `demo_group_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `demo_group_account_FI_1` (`account_id`),
  KEY `demo_group_account_FI_2` (`demo_group_id`),
  CONSTRAINT `demo_group_account_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`),
  CONSTRAINT `demo_group_account_FK_2` FOREIGN KEY (`demo_group_id`) REFERENCES `demo_group` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `demo_group_account`
--

LOCK TABLES `demo_group_account` WRITE;
/*!40000 ALTER TABLE `demo_group_account` DISABLE KEYS */;
INSERT INTO `demo_group_account` VALUES (1,1,1,'2014-09-13 12:00:00'),(2,2,1,'2014-09-13 12:00:00'),(3,1,2,'2014-09-14 13:00:00'),(4,2,2,'2014-09-14 13:00:00');
/*!40000 ALTER TABLE `demo_group_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_domain`
--

DROP TABLE IF EXISTS `email_domain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_domain` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_isp` tinyint(1) NOT NULL DEFAULT '0',
  `is_popular` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2983 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_domain`
--

LOCK TABLES `email_domain` WRITE;
/*!40000 ALTER TABLE `email_domain` DISABLE KEYS */;
INSERT INTO `email_domain` VALUES (1,'gmail.com',0,0),(2,'hotmail.com',0,0),(3,'yahoo.com',0,0),(4,'aol.com',0,0),(5,'test.com',0,0),(6,'asdf.com',0,0),(7,'whois.com',0,0),(8,'msn.com',0,0),(9,'123.com',0,0),(10,'123box.net',0,0),(11,'123india.com',0,0),(12,'123mail.cl',0,0),(13,'123qwe.co.uk',0,0),(14,'150ml.com',0,0),(15,'15meg4free.com',0,0),(16,'163.com',0,0),(17,'1coolplace.com',0,0),(18,'1freeemail.com',0,0),(19,'1funplace.com',0,0),(20,'1internetdrive.com',0,0),(21,'1mail.net',0,0),(22,'1me.net',0,0),(23,'1mum.com',0,0),(24,'1musicrow.com',0,0),(25,'1netdrive.com',0,0),(26,'1nsyncfan.com',0,0),(27,'1under.com',0,0),(28,'1webave.com',0,0),(29,'1webhighway.com',0,0),(30,'212.com',0,0),(31,'24horas.com',0,0),(32,'2911.net',0,0),(33,'2d2i.com',0,0),(34,'2die4.com',0,0),(35,'3000.it',0,0),(36,'37.com',0,0),(37,'3ammagazine.com',0,0),(38,'3email.com',0,0),(39,'3xl.net',0,0),(40,'444.net',0,0),(41,'4email.com',0,0),(42,'4email.net',0,0),(43,'4mg.com',0,0),(44,'4newyork.com',0,0),(45,'4x4man.com',0,0),(46,'5iron.com',0,0),(47,'88.am',0,0),(48,'8848.net',0,0),(49,'aaronkwok.net',0,0),(50,'abbeyroadlondon.co.uk',0,0),(51,'abdulnour.com',0,0),(52,'aberystwyth.com',0,0),(53,'about.com',0,0),(54,'academycougars.com',0,0),(55,'acceso.or.cr',0,0),(56,'access4less.net',0,0),(57,'accessgcc.com',0,0),(58,'ace-of-base.com',0,0),(59,'acmemail.net',0,0),(60,'acninc.net',0,0),(61,'adexec.com',0,0),(62,'adios.net',0,0),(63,'ados.fr',0,0),(64,'advalvas.be',0,0),(65,'aeiou.pt',0,0),(66,'aemail4u.com',0,0),(67,'aeneasmail.com',0,0),(68,'afreeinternet.com',0,0),(69,'africamail.com',0,0),(70,'agoodmail.com',0,0),(71,'ahaa.dk',0,0),(72,'aichi.com',0,0),(73,'airpost.net',0,0),(74,'ajacied.com',0,0),(75,'ak47.hu',0,0),(76,'aknet.kg',0,0),(77,'albawaba.com',0,0),(78,'alex4all.com',0,0),(79,'alexandria.cc',0,0),(80,'algeria.com',0,0),(81,'alhilal.net',0,0),(82,'alibaba.com',0,0),(83,'alive.cz',0,0),(84,'allmail.net',0,0),(85,'alloymail.com',0,0),(86,'allsaintsfan.com',0,0),(87,'alskens.dk',0,0),(88,'altavista.com',0,0),(89,'altavista.se',0,0),(90,'alternativagratis.com',0,0),(91,'alumnidirector.com',0,0),(92,'alvilag.hu',0,0),(93,'amele.com',0,0),(94,'america.hm',0,0),(95,'amnetsal.com',0,0),(96,'amrer.net',0,0),(97,'amuro.net',0,0),(98,'amuromail.com',0,0),(99,'ananzi.co.za',0,0),(100,'andylau.net',0,0),(101,'anfmail.com',0,0),(102,'angelfire.com',0,0),(103,'animalwoman.net',0,0),(104,'anjungcafe.com',0,0),(105,'another.com',0,0),(106,'antisocial.com',0,0),(107,'antongijsen.com',0,0),(108,'antwerpen.com',0,0),(109,'anymoment.com',0,0),(110,'anytimenow.com',0,0),(111,'apexmail.com',0,0),(112,'apollo.lv',0,0),(113,'approvers.net',0,0),(114,'arabia.com',0,0),(115,'arabtop.net',0,0),(116,'archaeologist.com',0,0),(117,'arcor.de',0,0),(118,'arcotronics.bg',0,0),(119,'argentina.com',0,0),(120,'arnet.com.ar',0,0),(121,'artlover.com',0,0),(122,'artlover.com.au',0,0),(123,'as-if.com',0,0),(124,'asean-mail.com',0,0),(125,'asheville.com',0,0),(126,'asia-links.com',0,0),(127,'asia.com',0,0),(128,'asianavenue.com',0,0),(129,'asiancityweb.com',0,0),(130,'asianwired.net',0,0),(131,'assala.com',0,0),(132,'assamesemail.com',0,0),(133,'astroboymail.com',0,0),(134,'astrolover.com',0,0),(135,'asurfer.com',0,0),(136,'athenachu.net',0,0),(137,'atina.cl',0,0),(138,'atl.lv',0,0),(139,'atlaswebmail.com',0,0),(140,'atozasia.com',0,0),(141,'au.ru',0,0),(142,'ausi.com',0,0),(143,'australia.edu',0,0),(144,'australiamail.com',0,0),(145,'austrosearch.net',0,0),(146,'autoescuelanerja.com',0,0),(147,'avh.hu',0,0),(148,'ayna.com',0,0),(149,'azimiweb.com',0,0),(150,'bachelorboy.com',0,0),(151,'bachelorgal.com',0,0),(152,'backstreet-boys.com',0,0),(153,'backstreetboysclub.com',0,0),(154,'bagherpour.com',0,0),(155,'baptistmail.com',0,0),(156,'baptized.com',0,0),(157,'barcelona.com',0,0),(158,'batuta.net',0,0),(159,'baudoinconsulting.com',0,0),(160,'bcvibes.com',0,0),(161,'beeebank.com',0,0),(162,'beenhad.com',0,0),(163,'beep.ru',0,0),(164,'beer.com',0,0),(165,'beethoven.com',0,0),(166,'belice.com',0,0),(167,'belizehome.com',0,0),(168,'berlin.com',0,0),(169,'berlin.de',0,0),(170,'berlinexpo.de',0,0),(171,'bestmail.us',0,0),(172,'bharatmail.com',0,0),(173,'bigblue.net.au',0,0),(174,'bigboab.com',0,0),(175,'bigfoot.com',0,0),(176,'bigfoot.de',0,0),(177,'bigger.com',0,0),(178,'bigmailbox.com',0,0),(179,'bigramp.com',0,0),(180,'bikemechanics.com',0,0),(181,'bikeracers.net',0,0),(182,'bikerider.com',0,0),(183,'bimla.net',0,0),(184,'birdowner.net',0,0),(185,'bitpage.net',0,0),(186,'bizhosting.com',0,0),(187,'blackburnmail.com',0,0),(188,'blackplanet.com',0,0),(189,'blazemail.com',0,0),(190,'bluehyppo.com',0,0),(191,'bluemail.ch',0,0),(192,'bluemail.dk',0,0),(193,'blushmail.com',0,0),(194,'bmlsports.net',0,0),(195,'boardermail.com',0,0),(196,'bol.com.br',0,0),(197,'bolando.com',0,0),(198,'bollywoodz.com',0,0),(199,'bolt.com',0,0),(200,'boltonfans.com',0,0),(201,'bonbon.net',0,0),(202,'boom.com',0,0),(203,'bootmail.com',0,0),(204,'bornnaked.com',0,0),(205,'bostonoffice.com',0,0),(206,'bounce.net',0,0),(207,'box.az',0,0),(208,'boxbg.com',0,0),(209,'boxemail.com',0,0),(210,'boxfrog.com',0,0),(211,'boyzoneclub.com',0,0),(212,'bradfordfans.com',0,0),(213,'brasilia.net',0,0),(214,'brazilmail.com.br',0,0),(215,'breathe.com',0,0),(216,'brfree.com.br',0,0),(217,'britneyclub.com',0,0),(218,'brittonsign.com',0,0),(219,'btopenworld.co.uk',0,0),(220,'bullsfan.com',0,0),(221,'bullsgame.com',0,0),(222,'bumerang.ro',0,0),(223,'buryfans.com',0,0),(224,'business-man.com',0,0),(225,'businessman.net',0,0),(226,'bvimailbox.com',0,0),(227,'c2i.net',0,0),(228,'c3.hu',0,0),(229,'c4.com',0,0),(230,'caere.it',0,0),(231,'cairomail.com',0,0),(232,'callnetuk.com',0,0),(233,'caltanet.it',0,0),(234,'camidge.com',0,0),(235,'canada-11.com',0,0),(236,'canada.com',0,0),(237,'canoemail.com',0,0),(238,'canwetalk.com',0,0),(239,'caramail.com',0,0),(240,'care2.com',0,0),(241,'carioca.net',0,0),(242,'cartestraina.ro',0,0),(243,'catcha.com',0,0),(244,'catlover.com',0,0),(245,'cd2.com',0,0),(246,'celineclub.com',0,0),(247,'centoper.it',0,0),(248,'centralpets.com',0,0),(249,'centrum.cz',0,0),(250,'centrum.sk',0,0),(251,'cgac.es',0,0),(252,'chaiyomail.com',0,0),(253,'chance2mail.com',0,0),(254,'chandrasekar.net',0,0),(255,'chat.ru',0,0),(256,'chattown.com',0,0),(257,'chauhanweb.com',0,0),(258,'check1check.com',0,0),(259,'cheerful.com',0,0),(260,'chemist.com',0,0),(261,'chequemail.com',0,0),(262,'chickmail.com',0,0),(263,'china.net.vg',0,0),(264,'chirk.com',0,0),(265,'chocaholic.com.au',0,0),(266,'cia-agent.com',0,0),(267,'cia.hu',0,0),(268,'ciaoweb.it',0,0),(269,'cicciociccio.com',0,0),(270,'city-of-bath.org',0,0),(271,'city-of-birmingham.com',0,0),(272,'city-of-brighton.org',0,0),(273,'city-of-cambridge.com',0,0),(274,'city-of-coventry.com',0,0),(275,'city-of-edinburgh.com',0,0),(276,'city-of-lichfield.com',0,0),(277,'city-of-lincoln.com',0,0),(278,'city-of-liverpool.com',0,0),(279,'city-of-manchester.com',0,0),(280,'city-of-nottingham.com',0,0),(281,'city-of-oxford.com',0,0),(282,'city-of-swansea.com',0,0),(283,'city-of-westminster.com',0,0),(284,'city-of-westminster.net',0,0),(285,'city-of-york.net',0,0),(286,'cityofcardiff.net',0,0),(287,'cityoflondon.org',0,0),(288,'claramail.com',0,0),(289,'classicmail.co.za',0,0),(290,'clerk.com',0,0),(291,'cliffhanger.com',0,0),(292,'close2you.net',0,0),(293,'club4x4.net',0,0),(294,'clubalfa.com',0,0),(295,'clubbers.net',0,0),(296,'clubducati.com',0,0),(297,'clubhonda.net',0,0),(298,'cluemail.com',0,0),(299,'coder.hu',0,0),(300,'coid.biz',0,0),(301,'columnist.com',0,0),(302,'comic.com',0,0),(303,'compuserve.com',0,0),(304,'computer-freak.com',0,0),(305,'computermail.net',0,0),(306,'conexcol.com',0,0),(307,'connect4free.net',0,0),(308,'connectbox.com',0,0),(309,'consultant.com',0,0),(310,'cookiemonster.com',0,0),(311,'cool.br',0,0),(312,'coolgoose.ca',0,0),(313,'coolgoose.com',0,0),(314,'coolkiwi.com',0,0),(315,'coollist.com',0,0),(316,'coolmail.com',0,0),(317,'coolmail.net',0,0),(318,'coolsend.com',0,0),(319,'cooooool.com',0,0),(320,'cooperation.net',0,0),(321,'cooperationtogo.net',0,0),(322,'copacabana.com',0,0),(323,'cornerpub.com',0,0),(324,'corporatedirtbag.com',0,0),(325,'correo.terra.com.gt',0,0),(326,'cortinet.com',0,0),(327,'cotas.net',0,0),(328,'counsellor.com',0,0),(329,'countrylover.com',0,0),(330,'cracker.hu',0,0),(331,'crazedanddazed.com',0,0),(332,'crazysexycool.com',0,0),(333,'critterpost.com',0,0),(334,'croeso.com',0,0),(335,'crosswinds.net',0,0),(336,'cry4helponline.com',0,0),(337,'cs.com',0,0),(338,'csinibaba.hu',0,0),(339,'curio-city.com',0,0),(340,'cute-girl.com',0,0),(341,'cuteandcuddly.com',0,0),(342,'cutey.com',0,0),(343,'cww.de',0,0),(344,'cyberbabies.com',0,0),(345,'cyberforeplay.net',0,0),(346,'cyberinbox.com',0,0),(347,'cyberleports.com',0,0),(348,'cybernet.it',0,0),(349,'dabsol.net',0,0),(350,'dadacasa.com',0,0),(351,'dailypioneer.com',0,0),(352,'dangerous-minds.com',0,0),(353,'dansegulvet.com',0,0),(354,'data54.com',0,0),(355,'davegracey.com',0,0),(356,'dazedandconfused.com',0,0),(357,'dbzmail.com',0,0),(358,'dcemail.com',0,0),(359,'deadlymob.org',0,0),(360,'deal-maker.com',0,0),(361,'dearriba.com',0,0),(362,'death-star.com',0,0),(363,'deliveryman.com',0,0),(364,'desertmail.com',0,0),(365,'desilota.com',0,0),(366,'deskpilot.com',0,0),(367,'detik.com',0,0),(368,'devotedcouples.com',0,0),(369,'dfwatson.com',0,0),(370,'di-ve.com',0,0),(371,'diplomats.com',0,0),(372,'disinfo.net',0,0),(373,'dmailman.com',0,0),(374,'dnsmadeeasy.com',0,0),(375,'doctor.com',0,0),(376,'doglover.com',0,0),(377,'dogmail.co.uk',0,0),(378,'dogsnob.net',0,0),(379,'doityourself.com',0,0),(380,'doneasy.com',0,0),(381,'donjuan.com',0,0),(382,'dontgotmail.com',0,0),(383,'dontmesswithtexas.com',0,0),(384,'doramail.com',0,0),(385,'dostmail.com',0,0),(386,'dotcom.fr',0,0),(387,'dott.it',0,0),(388,'dplanet.ch',0,0),(389,'dr.com',0,0),(390,'dragoncon.net',0,0),(391,'dropzone.com',0,0),(392,'dubaimail.com',0,0),(393,'dublin.com',0,0),(394,'dublin.ie',0,0),(395,'dygo.com',0,0),(396,'dynamitemail.com',0,0),(397,'e-apollo.lv',0,0),(398,'e-mail.dk',0,0),(399,'e-mail.ru',0,0),(400,'e-mailanywhere.com',0,0),(401,'e-mails.ru',0,0),(402,'e-tapaal.com',0,0),(403,'earthalliance.com',0,0),(404,'earthdome.com',0,0),(405,'eastcoast.co.za',0,0),(406,'eastmail.com',0,0),(407,'ecbsolutions.net',0,0),(408,'echina.com',0,0),(409,'ednatx.com',0,0),(410,'educacao.te.pt',0,0),(411,'eircom.net',0,0),(412,'elsitio.com',0,0),(413,'elvis.com',0,0),(414,'email-london.co.uk',0,0),(415,'email.com',0,0),(416,'email.cz',0,0),(417,'email.ee',0,0),(418,'email.it',0,0),(419,'email.nu',0,0),(420,'email.ro',0,0),(421,'email.ru',0,0),(422,'email.si',0,0),(423,'email2me.net',0,0),(424,'emailacc.com',0,0),(425,'emailaccount.com',0,0),(426,'emailchoice.com',0,0),(427,'emailcorner.net',0,0),(428,'emailengine.net',0,0),(429,'emailforyou.net',0,0),(430,'emailgroups.net',0,0),(431,'emailpinoy.com',0,0),(432,'emailplanet.com',0,0),(433,'emails.ru',0,0),(434,'emailuser.net',0,0),(435,'emailx.net',0,0),(436,'ematic.com',0,0),(437,'end-war.com',0,0),(438,'enel.net',0,0),(439,'engineer.com',0,0),(440,'england.com',0,0),(441,'england.edu',0,0),(442,'epatra.com',0,0),(443,'epost.de',0,0),(444,'eposta.hu',0,0),(445,'eqqu.com',0,0),(446,'eramail.co.za',0,0),(447,'eresmas.com',0,0),(448,'eriga.lv',0,0),(449,'estranet.it',0,0),(450,'etoast.com',0,0),(451,'eudoramail.com',0,0),(452,'europe.com',0,0),(453,'euroseek.com',0,0),(454,'every1.net',0,0),(455,'everyday.com.kh',0,0),(456,'everyone.net',0,0),(457,'examnotes.net',0,0),(458,'excite.co.jp',0,0),(459,'excite.com',0,0),(460,'excite.it',0,0),(461,'execs.com',0,0),(462,'expressasia.com',0,0),(463,'extended.com',0,0),(464,'eyou.com',0,0),(465,'ezcybersearch.com',0,0),(466,'ezmail.egine.com',0,0),(467,'ezmail.ru',0,0),(468,'ezrs.com',0,0),(469,'f1fans.net',0,0),(470,'fakeinbox.com',0,0),(471,'fantasticmail.com',0,0),(472,'faroweb.com',0,0),(473,'fastem.com',0,0),(474,'fastemail.us',0,0),(475,'fastemailer.com',0,0),(476,'fastermail.com',0,0),(477,'fastimap.com',0,0),(478,'fastmail.fm',0,0),(479,'fastmailbox.net',0,0),(480,'fastmessaging.com',0,0),(481,'fatcock.net',0,0),(482,'fathersrightsne.org',0,0),(483,'fbi-agent.com',0,0),(484,'fbi.hu',0,0),(485,'federalcontractors.com',0,0),(486,'femenino.com',0,0),(487,'feyenoorder.com',0,0),(488,'ffanet.com',0,0),(489,'fiberia.com',0,0),(490,'filipinolinks.com',0,0),(491,'financemail.net',0,0),(492,'financier.com',0,0),(493,'findmail.com',0,0),(494,'finebody.com',0,0),(495,'fire-brigade.com',0,0),(496,'fishburne.org',0,0),(497,'flashmail.com',0,0),(498,'flipcode.com',0,0),(499,'fmail.co.uk',0,0),(500,'fmailbox.com',0,0),(501,'fmgirl.com',0,0),(502,'fmguy.com',0,0),(503,'fnbmail.co.za',0,0),(504,'fnmail.com',0,0),(505,'for-president.com',0,0),(506,'forfree.at',0,0),(507,'forpresident.com',0,0),(508,'fortuncity.com',0,0),(509,'forum.dk',0,0),(510,'free.com.pe',0,0),(511,'free.fr',0,0),(512,'freeaccess.nl',0,0),(513,'freeandsingle.com',0,0),(514,'freedomlover.com',0,0),(515,'freegates.be',0,0),(516,'freeghana.com',0,0),(517,'freeler.nl',0,0),(518,'freemail.com.au',0,0),(519,'freemail.com.pk',0,0),(520,'freemail.de',0,0),(521,'freemail.et',0,0),(522,'freemail.gr',0,0),(523,'freemail.hu',0,0),(524,'freemail.it',0,0),(525,'freemail.lt',0,0),(526,'freemail.nl',0,0),(527,'freemail.org.mk',0,0),(528,'freenet.de',0,0),(529,'freenet.kg',0,0),(530,'freeola.com',0,0),(531,'freeola.net',0,0),(532,'freeserve.co.uk',0,0),(533,'freestart.hu',0,0),(534,'freesurf.fr',0,0),(535,'freesurf.nl',0,0),(536,'freeuk.com',0,0),(537,'freeuk.net',0,0),(538,'freeukis_isp.co.uk',0,0),(539,'freeweb.org',0,0),(540,'freewebemail.com',0,0),(541,'freeyellow.com',0,0),(542,'freezone.co.uk',0,0),(543,'fresnomail.com',0,0),(544,'friendsfan.com',0,0),(545,'from-africa.com',0,0),(546,'from-america.com',0,0),(547,'from-argentina.com',0,0),(548,'from-asia.com',0,0),(549,'from-australia.com',0,0),(550,'from-belgium.com',0,0),(551,'from-brazil.com',0,0),(552,'from-canada.com',0,0),(553,'from-china.net',0,0),(554,'from-england.com',0,0),(555,'from-europe.com',0,0),(556,'from-france.net',0,0),(557,'from-germany.net',0,0),(558,'from-holland.com',0,0),(559,'from-israel.com',0,0),(560,'from-italy.net',0,0),(561,'from-japan.net',0,0),(562,'from-korea.com',0,0),(563,'from-mexico.com',0,0),(564,'from-outerspace.com',0,0),(565,'from-russia.com',0,0),(566,'from-spain.net',0,0),(567,'fromalabama.com',0,0),(568,'fromalaska.com',0,0),(569,'fromarizona.com',0,0),(570,'fromarkansas.com',0,0),(571,'fromcalifornia.com',0,0),(572,'fromcolorado.com',0,0),(573,'fromconnecticut.com',0,0),(574,'fromdelaware.com',0,0),(575,'fromflorida.net',0,0),(576,'fromgeorgia.com',0,0),(577,'fromhawaii.net',0,0),(578,'fromidaho.com',0,0),(579,'fromillinois.com',0,0),(580,'fromindiana.com',0,0),(581,'fromiowa.com',0,0),(582,'fromjupiter.com',0,0),(583,'fromkansas.com',0,0),(584,'fromkentucky.com',0,0),(585,'fromlouisiana.com',0,0),(586,'frommaine.net',0,0),(587,'frommaryland.com',0,0),(588,'frommassachusetts.com',0,0),(589,'frommiami.com',0,0),(590,'frommichigan.com',0,0),(591,'fromminnesota.com',0,0),(592,'frommississippi.com',0,0),(593,'frommissouri.com',0,0),(594,'frommontana.com',0,0),(595,'fromnebraska.com',0,0),(596,'fromnevada.com',0,0),(597,'fromnewhampshire.com',0,0),(598,'fromnewjersey.com',0,0),(599,'fromnewmexico.com',0,0),(600,'fromnewyork.net',0,0),(601,'fromnorthcarolina.com',0,0),(602,'fromnorthdakota.com',0,0),(603,'fromohio.com',0,0),(604,'fromoklahoma.com',0,0),(605,'fromoregon.net',0,0),(606,'frompennsylvania.com',0,0),(607,'fromrhodeisland.com',0,0),(608,'fromru.com',0,0),(609,'fromsouthcarolina.com',0,0),(610,'fromsouthdakota.com',0,0),(611,'fromtennessee.com',0,0),(612,'fromtexas.com',0,0),(613,'fromthestates.com',0,0),(614,'fromutah.com',0,0),(615,'fromvermont.com',0,0),(616,'fromvirginia.com',0,0),(617,'fromwashington.com',0,0),(618,'fromwashingtondc.com',0,0),(619,'fromwestvirginia.com',0,0),(620,'fromwisconsin.com',0,0),(621,'fromwyoming.com',0,0),(622,'front.ru',0,0),(623,'frostbyte.uk.net',0,0),(624,'fsmail.net',0,0),(625,'ftml.net',0,0),(626,'fuorissimo.com',0,0),(627,'furnitureprovider.com',0,0),(628,'fut.es',0,0),(629,'fxsmails.com',0,0),(630,'galaxy5.com',0,0),(631,'gamebox.net',0,0),(632,'gardener.com',0,0),(633,'gawab.com',0,0),(634,'gaza.net',0,0),(635,'gazeta.pl',0,0),(636,'gazibooks.com',0,0),(637,'geek.hu',0,0),(638,'geeklife.com',0,0),(639,'general-hospital.com',0,0),(640,'geologist.com',0,0),(641,'geopia.com',0,0),(642,'giga4u.de',0,0),(643,'givepeaceachance.com',0,0),(644,'glay.org',0,0),(645,'glendale.net',0,0),(646,'globalfree.it',0,0),(647,'globalpagan.com',0,0),(648,'globalsite.com.br',0,0),(649,'gmx.at',0,0),(650,'gmx.de',0,0),(651,'gmx.li',0,0),(652,'gmx.net',0,0),(653,'go.com',0,0),(654,'go.ro',0,0),(655,'go.ru',0,0),(656,'go2net.com',0,0),(657,'gofree.co.uk',0,0),(658,'goldenmail.ru',0,0),(659,'goldmail.ru',0,0),(660,'golfemail.com',0,0),(661,'golfmail.be',0,0),(662,'goplay.com',0,0),(663,'gorontalo.net',0,0),(664,'gothere.uk.com',0,0),(665,'gotmail.com',0,0),(666,'gotomy.com',0,0),(667,'gportal.hu',0,0),(668,'graffiti.net',0,0),(669,'gratisweb.com',0,0),(670,'grungecafe.com',0,0),(671,'gua.net',0,0),(672,'guessmail.com',0,0),(673,'guju.net',0,0),(674,'guy.com',0,0),(675,'guy2.com',0,0),(676,'guyanafriends.com',0,0),(677,'gyorsposta.com',0,0),(678,'gyorsposta.hu',0,0),(679,'hackermail.net',0,0),(680,'hailmail.net',0,0),(681,'hairdresser.net',0,0),(682,'hamptonroads.com',0,0),(683,'handbag.com',0,0),(684,'hang-ten.com',0,0),(685,'happemail.com',0,0),(686,'happycounsel.com',0,0),(687,'hardcorefreak.com',0,0),(688,'heartthrob.com',0,0),(689,'heerschap.com',0,0),(690,'heesun.net',0,0),(691,'hehe.com',0,0),(692,'hello.hu',0,0),(693,'helter-skelter.com',0,0),(694,'herediano.com',0,0),(695,'herono1.com',0,0),(696,'highmilton.com',0,0),(697,'highquality.com',0,0),(698,'highveldmail.co.za',0,0),(699,'his_ispavista.com',0,0),(700,'hkstarphoto.com',0,0),(701,'hollywoodkids.com',0,0),(702,'home.no.net',0,0),(703,'home.ro',0,0),(704,'home.se',0,0),(705,'homelocator.com',0,0),(706,'homestead.com',0,0),(707,'hongkong.com',0,0),(708,'hookup.net',0,0),(709,'horrormail.com',0,0),(710,'hot-shot.com',0,0),(711,'hot.ee',0,0),(712,'hotbot.com',0,0),(713,'hotbrev.com',0,0),(714,'hotfire.net',0,0),(715,'hotletter.com',0,0),(716,'hotmail.co.il',0,0),(717,'hotmail.fr',0,0),(718,'hotmail.kg',0,0),(719,'hotmail.kz',0,0),(720,'hotmail.ru',0,0),(721,'hotpop.com',0,0),(722,'hotpop3.com',0,0),(723,'hotvoice.com',0,0),(724,'hsuchi.net',0,0),(725,'hunsa.com',0,0),(726,'hushmail.com',0,0),(727,'i-france.com',0,0),(728,'i-mail.com.au',0,0),(729,'i-p.com',0,0),(730,'i12.com',0,0),(731,'iamawoman.com',0,0),(732,'iamwaiting.com',0,0),(733,'iamwasted.com',0,0),(734,'iamyours.com',0,0),(735,'icestorm.com',0,0),(736,'icmsconsultants.com',0,0),(737,'icq.com',0,0),(738,'icqmail.com',0,0),(739,'icrazy.com',0,0),(740,'ididitmyway.com',0,0),(741,'idirect.com',0,0),(742,'iespana.es',0,0),(743,'ignazio.it',0,0),(744,'ignmail.com',0,0),(745,'ijustdontcare.com',0,0),(746,'ilovechocolate.com',0,0),(747,'ilovetocollect.net',0,0),(748,'ilse.nl',0,0),(749,'imail.ru',0,0),(750,'imailbox.com',0,0),(751,'imel.org',0,0),(752,'imneverwrong.com',0,0),(753,'imposter.co.uk',0,0),(754,'imstressed.com',0,0),(755,'imtoosexy.com',0,0),(756,'in-box.net',0,0),(757,'iname.com',0,0),(758,'inbox.net',0,0),(759,'inbox.ru',0,0),(760,'incamail.com',0,0),(761,'incredimail.com',0,0),(762,'indexa.fr',0,0),(763,'india.com',0,0),(764,'indiatimes.com',0,0),(765,'infohq.com',0,0),(766,'infomail.es',0,0),(767,'infomart.or.jp',0,0),(768,'infovia.com.ar',0,0),(769,'inicia.es',0,0),(770,'inmail.sk',0,0),(771,'inorbit.com',0,0),(772,'insurer.com',0,0),(773,'interfree.it',0,0),(774,'interia.pl',0,0),(775,'interlap.com.ar',0,0),(776,'intermail.co.il',0,0),(777,'internet-police.com',0,0),(778,'internetbiz.com',0,0),(779,'internetdrive.com',0,0),(780,'internetegypt.com',0,0),(781,'internetemails.net',0,0),(782,'internetmailing.net',0,0),(783,'inwind.it',0,0),(784,'iobox.com',0,0),(785,'iobox.fi',0,0),(786,'iol.it',0,0),(787,'ip3.com',0,0),(788,'iqemail.com',0,0),(789,'irangate.net',0,0),(790,'iraqmail.com',0,0),(791,'irj.hu',0,0),(792,'isellcars.com',0,0),(793,'islamonline.net',0,0),(794,'ismart.net',0,0),(795,'isonfire.com',0,0),(796,'is_isp9.net',0,0),(797,'itloox.com',0,0),(798,'itmom.com',0,0),(799,'ivebeenframed.com',0,0),(800,'ivillage.com',0,0),(801,'iwan-fals.com',0,0),(802,'iwon.com',0,0),(803,'izadpanah.com',0,0),(804,'jakuza.hu',0,0),(805,'japan.com',0,0),(806,'jaydemail.com',0,0),(807,'jazzandjava.com',0,0),(808,'jazzgame.com',0,0),(809,'jetemail.net',0,0),(810,'jippii.fi',0,0),(811,'jmail.co.za',0,0),(812,'joinme.com',0,0),(813,'jordanmail.com',0,0),(814,'journalist.com',0,0),(815,'jovem.te.pt',0,0),(816,'joymail.com',0,0),(817,'jpopmail.com',0,0),(818,'jubiimail.dk',0,0),(819,'jumpy.it',0,0),(820,'juno.com',0,0),(821,'justemail.net',0,0),(822,'kaazoo.com',0,0),(823,'kaixo.com',0,0),(824,'kalpoint.com',0,0),(825,'kapoorweb.com',0,0),(826,'karachian.com',0,0),(827,'karachioye.com',0,0),(828,'karbasi.com',0,0),(829,'katamail.com',0,0),(830,'kayafmmail.co.za',0,0),(831,'keg-party.com',0,0),(832,'keko.com.ar',0,0),(833,'kellychen.com',0,0),(834,'keromail.com',0,0),(835,'kgb.hu',0,0),(836,'khosropour.com',0,0),(837,'kickassmail.com',0,0),(838,'killermail.com',0,0),(839,'kimo.com',0,0),(840,'kinki-kids.com',0,0),(841,'kittymail.com',0,0),(842,'kiwibox.com',0,0),(843,'kiwitown.com',0,0),(844,'krunis.com',0,0),(845,'kukamail.com',0,0),(846,'kumarweb.com',0,0),(847,'kuwait-mail.com',0,0),(848,'ladymail.cz',0,0),(849,'lagerlouts.com',0,0),(850,'lahoreoye.com',0,0),(851,'lakmail.com',0,0),(852,'lamer.hu',0,0),(853,'land.ru',0,0),(854,'lankamail.com',0,0),(855,'laposte.net',0,0),(856,'latinmail.com',0,0),(857,'lawyer.com',0,0),(858,'leehom.net',0,0),(859,'legalactions.com',0,0),(860,'legislator.com',0,0),(861,'leonlai.net',0,0),(862,'levele.com',0,0),(863,'levele.hu',0,0),(864,'lex.bg',0,0),(865,'liberomail.com',0,0),(866,'linkmaster.com',0,0),(867,'linuxfreemail.com',0,0),(868,'linuxmail.org',0,0),(869,'lionsfan.com.au',0,0),(870,'liontrucks.com',0,0),(871,'list.ru',0,0),(872,'liverpoolfans.com',0,0),(873,'llandudno.com',0,0),(874,'llangollen.com',0,0),(875,'lmxmail.sk',0,0),(876,'lobbyist.com',0,0),(877,'localbar.com',0,0),(878,'london.com',0,0),(879,'looksmart.co.uk',0,0),(880,'looksmart.com',0,0),(881,'looksmart.com.au',0,0),(882,'lopezclub.com',0,0),(883,'louiskoo.com',0,0),(884,'love.cz',0,0),(885,'loveable.com',0,0),(886,'lovelygirl.net',0,0),(887,'lovemail.com',0,0),(888,'lover-boy.com',0,0),(889,'lovergirl.com',0,0),(890,'lovingjesus.com',0,0),(891,'luso.pt',0,0),(892,'luukku.com',0,0),(893,'lycos.co.uk',0,0),(894,'lycos.com',0,0),(895,'lycos.es',0,0),(896,'lycos.it',0,0),(897,'lycos.ne.jp',0,0),(898,'lycosmail.com',0,0),(899,'m-a-i-l.com',0,0),(900,'mac.com',0,0),(901,'machinecandy.com',0,0),(902,'macmail.com',0,0),(903,'madrid.com',0,0),(904,'maffia.hu',0,0),(905,'magicmail.co.za',0,0),(906,'mahmoodweb.com',0,0),(907,'mail-awu.de',0,0),(908,'mail-box.cz',0,0),(909,'mail-center.com',0,0),(910,'mail-central.com',0,0),(911,'mail-page.com',0,0),(912,'mail.austria.com',0,0),(913,'mail.az',0,0),(914,'mail.be',0,0),(915,'mail.bulgaria.com',0,0),(916,'mail.co.za',0,0),(917,'mail.com',0,0),(918,'mail.ee',0,0),(919,'mail.gr',0,0),(920,'mail.md',0,0),(921,'mail.nu',0,0),(922,'mail.pf',0,0),(923,'mail.pt',0,0),(924,'mail.r-o-o-t.com',0,0),(925,'mail.ru',0,0),(926,'mail.sisna.com',0,0),(927,'mail.vasarhely.hu',0,0),(928,'mail15.com',0,0),(929,'mail2007.com',0,0),(930,'mail2aaron.com',0,0),(931,'mail2abby.com',0,0),(932,'mail2abc.com',0,0),(933,'mail2actor.com',0,0),(934,'mail2admiral.com',0,0),(935,'mail2adorable.com',0,0),(936,'mail2adoration.com',0,0),(937,'mail2adore.com',0,0),(938,'mail2adventure.com',0,0),(939,'mail2aeolus.com',0,0),(940,'mail2aether.com',0,0),(941,'mail2affection.com',0,0),(942,'mail2afghanistan.com',0,0),(943,'mail2africa.com',0,0),(944,'mail2agent.com',0,0),(945,'mail2aha.com',0,0),(946,'mail2ahoy.com',0,0),(947,'mail2aim.com',0,0),(948,'mail2air.com',0,0),(949,'mail2airbag.com',0,0),(950,'mail2airforce.com',0,0),(951,'mail2airport.com',0,0),(952,'mail2alabama.com',0,0),(953,'mail2alan.com',0,0),(954,'mail2alaska.com',0,0),(955,'mail2albania.com',0,0),(956,'mail2alcoholic.com',0,0),(957,'mail2alec.com',0,0),(958,'mail2alexa.com',0,0),(959,'mail2algeria.com',0,0),(960,'mail2alicia.com',0,0),(961,'mail2alien.com',0,0),(962,'mail2allan.com',0,0),(963,'mail2allen.com',0,0),(964,'mail2allison.com',0,0),(965,'mail2alpha.com',0,0),(966,'mail2alyssa.com',0,0),(967,'mail2amanda.com',0,0),(968,'mail2amazing.com',0,0),(969,'mail2amber.com',0,0),(970,'mail2america.com',0,0),(971,'mail2american.com',0,0),(972,'mail2andorra.com',0,0),(973,'mail2andrea.com',0,0),(974,'mail2andy.com',0,0),(975,'mail2anesthesiologist.com',0,0),(976,'mail2angela.com',0,0),(977,'mail2angola.com',0,0),(978,'mail2ann.com',0,0),(979,'mail2anna.com',0,0),(980,'mail2anne.com',0,0),(981,'mail2anthony.com',0,0),(982,'mail2anything.com',0,0),(983,'mail2aphrodite.com',0,0),(984,'mail2apollo.com',0,0),(985,'mail2april.com',0,0),(986,'mail2aquarius.com',0,0),(987,'mail2arabia.com',0,0),(988,'mail2arabic.com',0,0),(989,'mail2architect.com',0,0),(990,'mail2ares.com',0,0),(991,'mail2argentina.com',0,0),(992,'mail2aries.com',0,0),(993,'mail2arizona.com',0,0),(994,'mail2arkansas.com',0,0),(995,'mail2armenia.com',0,0),(996,'mail2army.com',0,0),(997,'mail2arnold.com',0,0),(998,'mail2art.com',0,0),(999,'mail2artemus.com',0,0),(1000,'mail2arthur.com',0,0),(1001,'mail2artist.com',0,0),(1002,'mail2ashley.com',0,0),(1003,'mail2ask.com',0,0),(1004,'mail2astronomer.com',0,0),(1005,'mail2athena.com',0,0),(1006,'mail2athlete.com',0,0),(1007,'mail2atlas.com',0,0),(1008,'mail2atom.com',0,0),(1009,'mail2attitude.com',0,0),(1010,'mail2auction.com',0,0),(1011,'mail2aunt.com',0,0),(1012,'mail2australia.com',0,0),(1013,'mail2austria.com',0,0),(1014,'mail2azerbaijan.com',0,0),(1015,'mail2baby.com',0,0),(1016,'mail2bahamas.com',0,0),(1017,'mail2bahrain.com',0,0),(1018,'mail2ballerina.com',0,0),(1019,'mail2ballplayer.com',0,0),(1020,'mail2band.com',0,0),(1021,'mail2bangladesh.com',0,0),(1022,'mail2bank.com',0,0),(1023,'mail2banker.com',0,0),(1024,'mail2bankrupt.com',0,0),(1025,'mail2baptist.com',0,0),(1026,'mail2bar.com',0,0),(1027,'mail2barbados.com',0,0),(1028,'mail2barbara.com',0,0),(1029,'mail2barter.com',0,0),(1030,'mail2basketball.com',0,0),(1031,'mail2batter.com',0,0),(1032,'mail2beach.com',0,0),(1033,'mail2beast.com',0,0),(1034,'mail2beatles.com',0,0),(1035,'mail2beauty.com',0,0),(1036,'mail2becky.com',0,0),(1037,'mail2beijing.com',0,0),(1038,'mail2belgium.com',0,0),(1039,'mail2belize.com',0,0),(1040,'mail2ben.com',0,0),(1041,'mail2bernard.com',0,0),(1042,'mail2beth.com',0,0),(1043,'mail2betty.com',0,0),(1044,'mail2beverly.com',0,0),(1045,'mail2beyond.com',0,0),(1046,'mail2biker.com',0,0),(1047,'mail2bill.com',0,0),(1048,'mail2billionaire.com',0,0),(1049,'mail2billy.com',0,0),(1050,'mail2bio.com',0,0),(1051,'mail2biologist.com',0,0),(1052,'mail2black.com',0,0),(1053,'mail2blackbelt.com',0,0),(1054,'mail2blake.com',0,0),(1055,'mail2blind.com',0,0),(1056,'mail2blonde.com',0,0),(1057,'mail2blues.com',0,0),(1058,'mail2bob.com',0,0),(1059,'mail2bobby.com',0,0),(1060,'mail2bolivia.com',0,0),(1061,'mail2bombay.com',0,0),(1062,'mail2bonn.com',0,0),(1063,'mail2bookmark.com',0,0),(1064,'mail2boreas.com',0,0),(1065,'mail2bosnia.com',0,0),(1066,'mail2boston.com',0,0),(1067,'mail2botswana.com',0,0),(1068,'mail2bradley.com',0,0),(1069,'mail2brazil.com',0,0),(1070,'mail2breakfast.com',0,0),(1071,'mail2brian.com',0,0),(1072,'mail2bride.com',0,0),(1073,'mail2brittany.com',0,0),(1074,'mail2broker.com',0,0),(1075,'mail2brook.com',0,0),(1076,'mail2bruce.com',0,0),(1077,'mail2brunei.com',0,0),(1078,'mail2brunette.com',0,0),(1079,'mail2brussels.com',0,0),(1080,'mail2bryan.com',0,0),(1081,'mail2bug.com',0,0),(1082,'mail2bulgaria.com',0,0),(1083,'mail2business.com',0,0),(1084,'mail2buy.com',0,0),(1085,'mail2ca.com',0,0),(1086,'mail2california.com',0,0),(1087,'mail2calvin.com',0,0),(1088,'mail2cambodia.com',0,0),(1089,'mail2cameroon.com',0,0),(1090,'mail2canada.com',0,0),(1091,'mail2cancer.com',0,0),(1092,'mail2capeverde.com',0,0),(1093,'mail2capricorn.com',0,0),(1094,'mail2cardinal.com',0,0),(1095,'mail2cardiologist.com',0,0),(1096,'mail2care.com',0,0),(1097,'mail2caroline.com',0,0),(1098,'mail2carolyn.com',0,0),(1099,'mail2casey.com',0,0),(1100,'mail2cat.com',0,0),(1101,'mail2caterer.com',0,0),(1102,'mail2cathy.com',0,0),(1103,'mail2catlover.com',0,0),(1104,'mail2catwalk.com',0,0),(1105,'mail2cell.com',0,0),(1106,'mail2chad.com',0,0),(1107,'mail2champaign.com',0,0),(1108,'mail2charles.com',0,0),(1109,'mail2chef.com',0,0),(1110,'mail2chemist.com',0,0),(1111,'mail2cherry.com',0,0),(1112,'mail2chicago.com',0,0),(1113,'mail2chile.com',0,0),(1114,'mail2china.com',0,0),(1115,'mail2chinese.com',0,0),(1116,'mail2chocolate.com',0,0),(1117,'mail2christian.com',0,0),(1118,'mail2christie.com',0,0),(1119,'mail2christmas.com',0,0),(1120,'mail2christy.com',0,0),(1121,'mail2chuck.com',0,0),(1122,'mail2cindy.com',0,0),(1123,'mail2clark.com',0,0),(1124,'mail2classifieds.com',0,0),(1125,'mail2claude.com',0,0),(1126,'mail2cliff.com',0,0),(1127,'mail2clinic.com',0,0),(1128,'mail2clint.com',0,0),(1129,'mail2close.com',0,0),(1130,'mail2club.com',0,0),(1131,'mail2coach.com',0,0),(1132,'mail2coastguard.com',0,0),(1133,'mail2colin.com',0,0),(1134,'mail2college.com',0,0),(1135,'mail2colombia.com',0,0),(1136,'mail2color.com',0,0),(1137,'mail2colorado.com',0,0),(1138,'mail2columbia.com',0,0),(1139,'mail2comedian.com',0,0),(1140,'mail2composer.com',0,0),(1141,'mail2computer.com',0,0),(1142,'mail2computers.com',0,0),(1143,'mail2concert.com',0,0),(1144,'mail2congo.com',0,0),(1145,'mail2connect.com',0,0),(1146,'mail2connecticut.com',0,0),(1147,'mail2consultant.com',0,0),(1148,'mail2convict.com',0,0),(1149,'mail2cook.com',0,0),(1150,'mail2cool.com',0,0),(1151,'mail2cory.com',0,0),(1152,'mail2costarica.com',0,0),(1153,'mail2country.com',0,0),(1154,'mail2courtney.com',0,0),(1155,'mail2cowboy.com',0,0),(1156,'mail2cowgirl.com',0,0),(1157,'mail2craig.com',0,0),(1158,'mail2crave.com',0,0),(1159,'mail2crazy.com',0,0),(1160,'mail2create.com',0,0),(1161,'mail2croatia.com',0,0),(1162,'mail2cry.com',0,0),(1163,'mail2crystal.com',0,0),(1164,'mail2cuba.com',0,0),(1165,'mail2culture.com',0,0),(1166,'mail2curt.com',0,0),(1167,'mail2customs.com',0,0),(1168,'mail2cute.com',0,0),(1169,'mail2cutey.com',0,0),(1170,'mail2cynthia.com',0,0),(1171,'mail2cyprus.com',0,0),(1172,'mail2czechrepublic.com',0,0),(1173,'mail2dad.com',0,0),(1174,'mail2dale.com',0,0),(1175,'mail2dallas.com',0,0),(1176,'mail2dan.com',0,0),(1177,'mail2dana.com',0,0),(1178,'mail2dance.com',0,0),(1179,'mail2dancer.com',0,0),(1180,'mail2danielle.com',0,0),(1181,'mail2danny.com',0,0),(1182,'mail2darlene.com',0,0),(1183,'mail2darling.com',0,0),(1184,'mail2darren.com',0,0),(1185,'mail2daughter.com',0,0),(1186,'mail2dave.com',0,0),(1187,'mail2dawn.com',0,0),(1188,'mail2dc.com',0,0),(1189,'mail2dealer.com',0,0),(1190,'mail2deanna.com',0,0),(1191,'mail2dearest.com',0,0),(1192,'mail2debbie.com',0,0),(1193,'mail2debby.com',0,0),(1194,'mail2deer.com',0,0),(1195,'mail2delaware.com',0,0),(1196,'mail2delicious.com',0,0),(1197,'mail2demeter.com',0,0),(1198,'mail2democrat.com',0,0),(1199,'mail2denise.com',0,0),(1200,'mail2denmark.com',0,0),(1201,'mail2dennis.com',0,0),(1202,'mail2dentist.com',0,0),(1203,'mail2derek.com',0,0),(1204,'mail2desert.com',0,0),(1205,'mail2devoted.com',0,0),(1206,'mail2devotion.com',0,0),(1207,'mail2diamond.com',0,0),(1208,'mail2diana.com',0,0),(1209,'mail2diane.com',0,0),(1210,'mail2diehard.com',0,0),(1211,'mail2dilemma.com',0,0),(1212,'mail2dillon.com',0,0),(1213,'mail2dinner.com',0,0),(1214,'mail2dinosaur.com',0,0),(1215,'mail2dionysos.com',0,0),(1216,'mail2diplomat.com',0,0),(1217,'mail2director.com',0,0),(1218,'mail2dirk.com',0,0),(1219,'mail2disco.com',0,0),(1220,'mail2dive.com',0,0),(1221,'mail2diver.com',0,0),(1222,'mail2divorced.com',0,0),(1223,'mail2djibouti.com',0,0),(1224,'mail2doctor.com',0,0),(1225,'mail2doglover.com',0,0),(1226,'mail2dominic.com',0,0),(1227,'mail2dominica.com',0,0),(1228,'mail2dominicanrepublic.com',0,0),(1229,'mail2don.com',0,0),(1230,'mail2donald.com',0,0),(1231,'mail2donna.com',0,0),(1232,'mail2doris.com',0,0),(1233,'mail2dorothy.com',0,0),(1234,'mail2doug.com',0,0),(1235,'mail2dough.com',0,0),(1236,'mail2douglas.com',0,0),(1237,'mail2dow.com',0,0),(1238,'mail2downtown.com',0,0),(1239,'mail2dream.com',0,0),(1240,'mail2dreamer.com',0,0),(1241,'mail2dude.com',0,0),(1242,'mail2dustin.com',0,0),(1243,'mail2dyke.com',0,0),(1244,'mail2dylan.com',0,0),(1245,'mail2earl.com',0,0),(1246,'mail2earth.com',0,0),(1247,'mail2eastend.com',0,0),(1248,'mail2eat.com',0,0),(1249,'mail2economist.com',0,0),(1250,'mail2ecuador.com',0,0),(1251,'mail2eddie.com',0,0),(1252,'mail2edgar.com',0,0),(1253,'mail2edwin.com',0,0),(1254,'mail2egypt.com',0,0),(1255,'mail2electron.com',0,0),(1256,'mail2eli.com',0,0),(1257,'mail2elizabeth.com',0,0),(1258,'mail2ellen.com',0,0),(1259,'mail2elliot.com',0,0),(1260,'mail2elsalvador.com',0,0),(1261,'mail2elvis.com',0,0),(1262,'mail2emergency.com',0,0),(1263,'mail2emily.com',0,0),(1264,'mail2engineer.com',0,0),(1265,'mail2english.com',0,0),(1266,'mail2environmentalist.com',0,0),(1267,'mail2eos.com',0,0),(1268,'mail2eric.com',0,0),(1269,'mail2erica.com',0,0),(1270,'mail2erin.com',0,0),(1271,'mail2erinyes.com',0,0),(1272,'mail2eris.com',0,0),(1273,'mail2eritrea.com',0,0),(1274,'mail2ernie.com',0,0),(1275,'mail2eros.com',0,0),(1276,'mail2estonia.com',0,0),(1277,'mail2ethan.com',0,0),(1278,'mail2ethiopia.com',0,0),(1279,'mail2eu.com',0,0),(1280,'mail2europe.com',0,0),(1281,'mail2eurus.com',0,0),(1282,'mail2eva.com',0,0),(1283,'mail2evan.com',0,0),(1284,'mail2evelyn.com',0,0),(1285,'mail2everything.com',0,0),(1286,'mail2exciting.com',0,0),(1287,'mail2expert.com',0,0),(1288,'mail2fairy.com',0,0),(1289,'mail2faith.com',0,0),(1290,'mail2fanatic.com',0,0),(1291,'mail2fancy.com',0,0),(1292,'mail2fantasy.com',0,0),(1293,'mail2farm.com',0,0),(1294,'mail2farmer.com',0,0),(1295,'mail2fashion.com',0,0),(1296,'mail2fat.com',0,0),(1297,'mail2feeling.com',0,0),(1298,'mail2female.com',0,0),(1299,'mail2fever.com',0,0),(1300,'mail2fighter.com',0,0),(1301,'mail2fiji.com',0,0),(1302,'mail2filmfestival.com',0,0),(1303,'mail2films.com',0,0),(1304,'mail2finance.com',0,0),(1305,'mail2finland.com',0,0),(1306,'mail2fireman.com',0,0),(1307,'mail2firm.com',0,0),(1308,'mail2fisherman.com',0,0),(1309,'mail2flexible.com',0,0),(1310,'mail2florence.com',0,0),(1311,'mail2florida.com',0,0),(1312,'mail2floyd.com',0,0),(1313,'mail2fly.com',0,0),(1314,'mail2fond.com',0,0),(1315,'mail2fondness.com',0,0),(1316,'mail2football.com',0,0),(1317,'mail2footballfan.com',0,0),(1318,'mail2found.com',0,0),(1319,'mail2france.com',0,0),(1320,'mail2frank.com',0,0),(1321,'mail2frankfurt.com',0,0),(1322,'mail2franklin.com',0,0),(1323,'mail2fred.com',0,0),(1324,'mail2freddie.com',0,0),(1325,'mail2free.com',0,0),(1326,'mail2freedom.com',0,0),(1327,'mail2french.com',0,0),(1328,'mail2freudian.com',0,0),(1329,'mail2friendship.com',0,0),(1330,'mail2from.com',0,0),(1331,'mail2fun.com',0,0),(1332,'mail2gabon.com',0,0),(1333,'mail2gabriel.com',0,0),(1334,'mail2gail.com',0,0),(1335,'mail2galaxy.com',0,0),(1336,'mail2gambia.com',0,0),(1337,'mail2games.com',0,0),(1338,'mail2gary.com',0,0),(1339,'mail2gavin.com',0,0),(1340,'mail2gemini.com',0,0),(1341,'mail2gene.com',0,0),(1342,'mail2genes.com',0,0),(1343,'mail2geneva.com',0,0),(1344,'mail2george.com',0,0),(1345,'mail2georgia.com',0,0),(1346,'mail2gerald.com',0,0),(1347,'mail2german.com',0,0),(1348,'mail2germany.com',0,0),(1349,'mail2ghana.com',0,0),(1350,'mail2gilbert.com',0,0),(1351,'mail2gina.com',0,0),(1352,'mail2girl.com',0,0),(1353,'mail2glen.com',0,0),(1354,'mail2gloria.com',0,0),(1355,'mail2goddess.com',0,0),(1356,'mail2gold.com',0,0),(1357,'mail2golfclub.com',0,0),(1358,'mail2golfer.com',0,0),(1359,'mail2gordon.com',0,0),(1360,'mail2government.com',0,0),(1361,'mail2grab.com',0,0),(1362,'mail2grace.com',0,0),(1363,'mail2graham.com',0,0),(1364,'mail2grandma.com',0,0),(1365,'mail2grandpa.com',0,0),(1366,'mail2grant.com',0,0),(1367,'mail2greece.com',0,0),(1368,'mail2green.com',0,0),(1369,'mail2greg.com',0,0),(1370,'mail2grenada.com',0,0),(1371,'mail2gsm.com',0,0),(1372,'mail2guard.com',0,0),(1373,'mail2guatemala.com',0,0),(1374,'mail2guy.com',0,0),(1375,'mail2hades.com',0,0),(1376,'mail2haiti.com',0,0),(1377,'mail2hal.com',0,0),(1378,'mail2handhelds.com',0,0),(1379,'mail2hank.com',0,0),(1380,'mail2hannah.com',0,0),(1381,'mail2harold.com',0,0),(1382,'mail2harry.com',0,0),(1383,'mail2hawaii.com',0,0),(1384,'mail2headhunter.com',0,0),(1385,'mail2heal.com',0,0),(1386,'mail2heather.com',0,0),(1387,'mail2heaven.com',0,0),(1388,'mail2hebe.com',0,0),(1389,'mail2hecate.com',0,0),(1390,'mail2heidi.com',0,0),(1391,'mail2helen.com',0,0),(1392,'mail2hell.com',0,0),(1393,'mail2help.com',0,0),(1394,'mail2helpdesk.com',0,0),(1395,'mail2henry.com',0,0),(1396,'mail2hephaestus.com',0,0),(1397,'mail2hera.com',0,0),(1398,'mail2hercules.com',0,0),(1399,'mail2herman.com',0,0),(1400,'mail2hermes.com',0,0),(1401,'mail2hespera.com',0,0),(1402,'mail2hestia.com',0,0),(1403,'mail2highschool.com',0,0),(1404,'mail2hindu.com',0,0),(1405,'mail2hip.com',0,0),(1406,'mail2hiphop.com',0,0),(1407,'mail2holland.com',0,0),(1408,'mail2holly.com',0,0),(1409,'mail2hollywood.com',0,0),(1410,'mail2homer.com',0,0),(1411,'mail2honduras.com',0,0),(1412,'mail2honey.com',0,0),(1413,'mail2hongkong.com',0,0),(1414,'mail2hope.com',0,0),(1415,'mail2horse.com',0,0),(1416,'mail2hot.com',0,0),(1417,'mail2hotel.com',0,0),(1418,'mail2houston.com',0,0),(1419,'mail2howard.com',0,0),(1420,'mail2hugh.com',0,0),(1421,'mail2human.com',0,0),(1422,'mail2hungary.com',0,0),(1423,'mail2hungry.com',0,0),(1424,'mail2hygeia.com',0,0),(1425,'mail2hyperspace.com',0,0),(1426,'mail2hypnos.com',0,0),(1427,'mail2ian.com',0,0),(1428,'mail2ice-cream.com',0,0),(1429,'mail2iceland.com',0,0),(1430,'mail2idaho.com',0,0),(1431,'mail2idontknow.com',0,0),(1432,'mail2illinois.com',0,0),(1433,'mail2imam.com',0,0),(1434,'mail2in.com',0,0),(1435,'mail2india.com',0,0),(1436,'mail2indian.com',0,0),(1437,'mail2indiana.com',0,0),(1438,'mail2indonesia.com',0,0),(1439,'mail2infinity.com',0,0),(1440,'mail2intense.com',0,0),(1441,'mail2iowa.com',0,0),(1442,'mail2iran.com',0,0),(1443,'mail2iraq.com',0,0),(1444,'mail2ireland.com',0,0),(1445,'mail2irene.com',0,0),(1446,'mail2iris.com',0,0),(1447,'mail2irresistible.com',0,0),(1448,'mail2irving.com',0,0),(1449,'mail2irwin.com',0,0),(1450,'mail2isaac.com',0,0),(1451,'mail2israel.com',0,0),(1452,'mail2italian.com',0,0),(1453,'mail2italy.com',0,0),(1454,'mail2jackie.com',0,0),(1455,'mail2jacob.com',0,0),(1456,'mail2jail.com',0,0),(1457,'mail2jaime.com',0,0),(1458,'mail2jake.com',0,0),(1459,'mail2jamaica.com',0,0),(1460,'mail2james.com',0,0),(1461,'mail2jamie.com',0,0),(1462,'mail2jan.com',0,0),(1463,'mail2jane.com',0,0),(1464,'mail2janet.com',0,0),(1465,'mail2janice.com',0,0),(1466,'mail2japan.com',0,0),(1467,'mail2japanese.com',0,0),(1468,'mail2jasmine.com',0,0),(1469,'mail2jason.com',0,0),(1470,'mail2java.com',0,0),(1471,'mail2jay.com',0,0),(1472,'mail2jazz.com',0,0),(1473,'mail2jed.com',0,0),(1474,'mail2jeffrey.com',0,0),(1475,'mail2jennifer.com',0,0),(1476,'mail2jenny.com',0,0),(1477,'mail2jeremy.com',0,0),(1478,'mail2jerry.com',0,0),(1479,'mail2jessica.com',0,0),(1480,'mail2jessie.com',0,0),(1481,'mail2jesus.com',0,0),(1482,'mail2jew.com',0,0),(1483,'mail2jeweler.com',0,0),(1484,'mail2jim.com',0,0),(1485,'mail2jimmy.com',0,0),(1486,'mail2joan.com',0,0),(1487,'mail2joann.com',0,0),(1488,'mail2joanna.com',0,0),(1489,'mail2jody.com',0,0),(1490,'mail2joe.com',0,0),(1491,'mail2joel.com',0,0),(1492,'mail2joey.com',0,0),(1493,'mail2john.com',0,0),(1494,'mail2join.com',0,0),(1495,'mail2jon.com',0,0),(1496,'mail2jonathan.com',0,0),(1497,'mail2jones.com',0,0),(1498,'mail2jordan.com',0,0),(1499,'mail2joseph.com',0,0),(1500,'mail2josh.com',0,0),(1501,'mail2joy.com',0,0),(1502,'mail2juan.com',0,0),(1503,'mail2judge.com',0,0),(1504,'mail2judy.com',0,0),(1505,'mail2juggler.com',0,0),(1506,'mail2julian.com',0,0),(1507,'mail2julie.com',0,0),(1508,'mail2jumbo.com',0,0),(1509,'mail2junk.com',0,0),(1510,'mail2justin.com',0,0),(1511,'mail2justme.com',0,0),(1512,'mail2kansas.com',0,0),(1513,'mail2karate.com',0,0),(1514,'mail2karen.com',0,0),(1515,'mail2karl.com',0,0),(1516,'mail2karma.com',0,0),(1517,'mail2kathleen.com',0,0),(1518,'mail2kathy.com',0,0),(1519,'mail2katie.com',0,0),(1520,'mail2kay.com',0,0),(1521,'mail2kazakhstan.com',0,0),(1522,'mail2keen.com',0,0),(1523,'mail2keith.com',0,0),(1524,'mail2kelly.com',0,0),(1525,'mail2kelsey.com',0,0),(1526,'mail2ken.com',0,0),(1527,'mail2kendall.com',0,0),(1528,'mail2kennedy.com',0,0),(1529,'mail2kenneth.com',0,0),(1530,'mail2kenny.com',0,0),(1531,'mail2kentucky.com',0,0),(1532,'mail2kenya.com',0,0),(1533,'mail2kerry.com',0,0),(1534,'mail2kevin.com',0,0),(1535,'mail2kim.com',0,0),(1536,'mail2kimberly.com',0,0),(1537,'mail2king.com',0,0),(1538,'mail2kirk.com',0,0),(1539,'mail2kiss.com',0,0),(1540,'mail2kosher.com',0,0),(1541,'mail2kristin.com',0,0),(1542,'mail2kurt.com',0,0),(1543,'mail2kuwait.com',0,0),(1544,'mail2kyle.com',0,0),(1545,'mail2kyrgyzstan.com',0,0),(1546,'mail2la.com',0,0),(1547,'mail2lacrosse.com',0,0),(1548,'mail2lance.com',0,0),(1549,'mail2lao.com',0,0),(1550,'mail2larry.com',0,0),(1551,'mail2latvia.com',0,0),(1552,'mail2laugh.com',0,0),(1553,'mail2laura.com',0,0),(1554,'mail2lauren.com',0,0),(1555,'mail2laurie.com',0,0),(1556,'mail2lawrence.com',0,0),(1557,'mail2lawyer.com',0,0),(1558,'mail2lebanon.com',0,0),(1559,'mail2lee.com',0,0),(1560,'mail2leo.com',0,0),(1561,'mail2leon.com',0,0),(1562,'mail2leonard.com',0,0),(1563,'mail2leone.com',0,0),(1564,'mail2leslie.com',0,0),(1565,'mail2letter.com',0,0),(1566,'mail2liberia.com',0,0),(1567,'mail2libertarian.com',0,0),(1568,'mail2libra.com',0,0),(1569,'mail2libya.com',0,0),(1570,'mail2liechtenstein.com',0,0),(1571,'mail2life.com',0,0),(1572,'mail2linda.com',0,0),(1573,'mail2linux.com',0,0),(1574,'mail2lionel.com',0,0),(1575,'mail2lipstick.com',0,0),(1576,'mail2liquid.com',0,0),(1577,'mail2lisa.com',0,0),(1578,'mail2lithuania.com',0,0),(1579,'mail2litigator.com',0,0),(1580,'mail2liz.com',0,0),(1581,'mail2lloyd.com',0,0),(1582,'mail2lois.com',0,0),(1583,'mail2lola.com',0,0),(1584,'mail2london.com',0,0),(1585,'mail2looking.com',0,0),(1586,'mail2lori.com',0,0),(1587,'mail2lost.com',0,0),(1588,'mail2lou.com',0,0),(1589,'mail2louis.com',0,0),(1590,'mail2louisiana.com',0,0),(1591,'mail2lovable.com',0,0),(1592,'mail2love.com',0,0),(1593,'mail2lucky.com',0,0),(1594,'mail2lucy.com',0,0),(1595,'mail2lunch.com',0,0),(1596,'mail2lust.com',0,0),(1597,'mail2luxembourg.com',0,0),(1598,'mail2luxury.com',0,0),(1599,'mail2lyle.com',0,0),(1600,'mail2lynn.com',0,0),(1601,'mail2madagascar.com',0,0),(1602,'mail2madison.com',0,0),(1603,'mail2madrid.com',0,0),(1604,'mail2maggie.com',0,0),(1605,'mail2mail4.com',0,0),(1606,'mail2maine.com',0,0),(1607,'mail2malawi.com',0,0),(1608,'mail2malaysia.com',0,0),(1609,'mail2maldives.com',0,0),(1610,'mail2mali.com',0,0),(1611,'mail2malta.com',0,0),(1612,'mail2mambo.com',0,0),(1613,'mail2man.com',0,0),(1614,'mail2mandy.com',0,0),(1615,'mail2manhunter.com',0,0),(1616,'mail2mankind.com',0,0),(1617,'mail2many.com',0,0),(1618,'mail2marc.com',0,0),(1619,'mail2marcia.com',0,0),(1620,'mail2margaret.com',0,0),(1621,'mail2margie.com',0,0),(1622,'mail2marhaba.com',0,0),(1623,'mail2maria.com',0,0),(1624,'mail2marilyn.com',0,0),(1625,'mail2marines.com',0,0),(1626,'mail2mark.com',0,0),(1627,'mail2marriage.com',0,0),(1628,'mail2married.com',0,0),(1629,'mail2marries.com',0,0),(1630,'mail2mars.com',0,0),(1631,'mail2marsha.com',0,0),(1632,'mail2marshallislands.com',0,0),(1633,'mail2martha.com',0,0),(1634,'mail2martin.com',0,0),(1635,'mail2marty.com',0,0),(1636,'mail2marvin.com',0,0),(1637,'mail2mary.com',0,0),(1638,'mail2maryland.com',0,0),(1639,'mail2mason.com',0,0),(1640,'mail2massachusetts.com',0,0),(1641,'mail2matt.com',0,0),(1642,'mail2matthew.com',0,0),(1643,'mail2maurice.com',0,0),(1644,'mail2mauritania.com',0,0),(1645,'mail2mauritius.com',0,0),(1646,'mail2max.com',0,0),(1647,'mail2maxwell.com',0,0),(1648,'mail2maybe.com',0,0),(1649,'mail2mba.com',0,0),(1650,'mail2me4u.com',0,0),(1651,'mail2mechanic.com',0,0),(1652,'mail2medieval.com',0,0),(1653,'mail2megan.com',0,0),(1654,'mail2mel.com',0,0),(1655,'mail2melanie.com',0,0),(1656,'mail2melissa.com',0,0),(1657,'mail2melody.com',0,0),(1658,'mail2member.com',0,0),(1659,'mail2memphis.com',0,0),(1660,'mail2methodist.com',0,0),(1661,'mail2mexican.com',0,0),(1662,'mail2mexico.com',0,0),(1663,'mail2mgz.com',0,0),(1664,'mail2miami.com',0,0),(1665,'mail2michael.com',0,0),(1666,'mail2michelle.com',0,0),(1667,'mail2michigan.com',0,0),(1668,'mail2mike.com',0,0),(1669,'mail2milan.com',0,0),(1670,'mail2milano.com',0,0),(1671,'mail2mildred.com',0,0),(1672,'mail2milkyway.com',0,0),(1673,'mail2millennium.com',0,0),(1674,'mail2millionaire.com',0,0),(1675,'mail2milton.com',0,0),(1676,'mail2mime.com',0,0),(1677,'mail2mindreader.com',0,0),(1678,'mail2mini.com',0,0),(1679,'mail2minister.com',0,0),(1680,'mail2minneapolis.com',0,0),(1681,'mail2minnesota.com',0,0),(1682,'mail2miracle.com',0,0),(1683,'mail2missionary.com',0,0),(1684,'mail2mississippi.com',0,0),(1685,'mail2missouri.com',0,0),(1686,'mail2mitch.com',0,0),(1687,'mail2model.com',0,0),(1688,'mail2moldova.com',0,0),(1689,'mail2molly.com',0,0),(1690,'mail2mom.com',0,0),(1691,'mail2monaco.com',0,0),(1692,'mail2money.com',0,0),(1693,'mail2mongolia.com',0,0),(1694,'mail2monica.com',0,0),(1695,'mail2montana.com',0,0),(1696,'mail2monty.com',0,0),(1697,'mail2moon.com',0,0),(1698,'mail2morocco.com',0,0),(1699,'mail2morpheus.com',0,0),(1700,'mail2mors.com',0,0),(1701,'mail2moscow.com',0,0),(1702,'mail2moslem.com',0,0),(1703,'mail2mouseketeer.com',0,0),(1704,'mail2movies.com',0,0),(1705,'mail2mozambique.com',0,0),(1706,'mail2mp3.com',0,0),(1707,'mail2mrright.com',0,0),(1708,'mail2msright.com',0,0),(1709,'mail2museum.com',0,0),(1710,'mail2music.com',0,0),(1711,'mail2musician.com',0,0),(1712,'mail2muslim.com',0,0),(1713,'mail2my.com',0,0),(1714,'mail2myboat.com',0,0),(1715,'mail2mycar.com',0,0),(1716,'mail2mycell.com',0,0),(1717,'mail2mygsm.com',0,0),(1718,'mail2mylaptop.com',0,0),(1719,'mail2mymac.com',0,0),(1720,'mail2mypager.com',0,0),(1721,'mail2mypalm.com',0,0),(1722,'mail2mypc.com',0,0),(1723,'mail2myphone.com',0,0),(1724,'mail2myplane.com',0,0),(1725,'mail2namibia.com',0,0),(1726,'mail2nancy.com',0,0),(1727,'mail2nasdaq.com',0,0),(1728,'mail2nathan.com',0,0),(1729,'mail2nauru.com',0,0),(1730,'mail2navy.com',0,0),(1731,'mail2neal.com',0,0),(1732,'mail2nebraska.com',0,0),(1733,'mail2ned.com',0,0),(1734,'mail2neil.com',0,0),(1735,'mail2nelson.com',0,0),(1736,'mail2nemesis.com',0,0),(1737,'mail2nepal.com',0,0),(1738,'mail2netherlands.com',0,0),(1739,'mail2network.com',0,0),(1740,'mail2nevada.com',0,0),(1741,'mail2newhampshire.com',0,0),(1742,'mail2newjersey.com',0,0),(1743,'mail2newmexico.com',0,0),(1744,'mail2newyork.com',0,0),(1745,'mail2newzealand.com',0,0),(1746,'mail2nicaragua.com',0,0),(1747,'mail2nick.com',0,0),(1748,'mail2nicole.com',0,0),(1749,'mail2niger.com',0,0),(1750,'mail2nigeria.com',0,0),(1751,'mail2nike.com',0,0),(1752,'mail2no.com',0,0),(1753,'mail2noah.com',0,0),(1754,'mail2noel.com',0,0),(1755,'mail2noelle.com',0,0),(1756,'mail2normal.com',0,0),(1757,'mail2norman.com',0,0),(1758,'mail2northamerica.com',0,0),(1759,'mail2northcarolina.com',0,0),(1760,'mail2northdakota.com',0,0),(1761,'mail2northpole.com',0,0),(1762,'mail2norway.com',0,0),(1763,'mail2notus.com',0,0),(1764,'mail2noway.com',0,0),(1765,'mail2nowhere.com',0,0),(1766,'mail2nuclear.com',0,0),(1767,'mail2nun.com',0,0),(1768,'mail2ny.com',0,0),(1769,'mail2oasis.com',0,0),(1770,'mail2oceanographer.com',0,0),(1771,'mail2ohio.com',0,0),(1772,'mail2ok.com',0,0),(1773,'mail2oklahoma.com',0,0),(1774,'mail2oliver.com',0,0),(1775,'mail2oman.com',0,0),(1776,'mail2one.com',0,0),(1777,'mail2onfire.com',0,0),(1778,'mail2online.com',0,0),(1779,'mail2oops.com',0,0),(1780,'mail2open.com',0,0),(1781,'mail2ophthalmologist.com',0,0),(1782,'mail2optometrist.com',0,0),(1783,'mail2oregon.com',0,0),(1784,'mail2oscars.com',0,0),(1785,'mail2oslo.com',0,0),(1786,'mail2painter.com',0,0),(1787,'mail2pakistan.com',0,0),(1788,'mail2palau.com',0,0),(1789,'mail2pan.com',0,0),(1790,'mail2panama.com',0,0),(1791,'mail2paraguay.com',0,0),(1792,'mail2paralegal.com',0,0),(1793,'mail2paris.com',0,0),(1794,'mail2park.com',0,0),(1795,'mail2parker.com',0,0),(1796,'mail2party.com',0,0),(1797,'mail2passion.com',0,0),(1798,'mail2pat.com',0,0),(1799,'mail2patricia.com',0,0),(1800,'mail2patrick.com',0,0),(1801,'mail2patty.com',0,0),(1802,'mail2paul.com',0,0),(1803,'mail2paula.com',0,0),(1804,'mail2pay.com',0,0),(1805,'mail2peace.com',0,0),(1806,'mail2pediatrician.com',0,0),(1807,'mail2peggy.com',0,0),(1808,'mail2pennsylvania.com',0,0),(1809,'mail2perry.com',0,0),(1810,'mail2persephone.com',0,0),(1811,'mail2persian.com',0,0),(1812,'mail2peru.com',0,0),(1813,'mail2pete.com',0,0),(1814,'mail2peter.com',0,0),(1815,'mail2pharmacist.com',0,0),(1816,'mail2phil.com',0,0),(1817,'mail2philippines.com',0,0),(1818,'mail2phoenix.com',0,0),(1819,'mail2phonecall.com',0,0),(1820,'mail2phyllis.com',0,0),(1821,'mail2pickup.com',0,0),(1822,'mail2pilot.com',0,0),(1823,'mail2pisces.com',0,0),(1824,'mail2planet.com',0,0),(1825,'mail2platinum.com',0,0),(1826,'mail2plato.com',0,0),(1827,'mail2pluto.com',0,0),(1828,'mail2pm.com',0,0),(1829,'mail2podiatrist.com',0,0),(1830,'mail2poet.com',0,0),(1831,'mail2poland.com',0,0),(1832,'mail2policeman.com',0,0),(1833,'mail2policewoman.com',0,0),(1834,'mail2politician.com',0,0),(1835,'mail2pop.com',0,0),(1836,'mail2pope.com',0,0),(1837,'mail2popular.com',0,0),(1838,'mail2portugal.com',0,0),(1839,'mail2poseidon.com',0,0),(1840,'mail2potatohead.com',0,0),(1841,'mail2power.com',0,0),(1842,'mail2presbyterian.com',0,0),(1843,'mail2president.com',0,0),(1844,'mail2priest.com',0,0),(1845,'mail2prince.com',0,0),(1846,'mail2princess.com',0,0),(1847,'mail2producer.com',0,0),(1848,'mail2professor.com',0,0),(1849,'mail2protect.com',0,0),(1850,'mail2psychiatrist.com',0,0),(1851,'mail2psycho.com',0,0),(1852,'mail2psychologist.com',0,0),(1853,'mail2qatar.com',0,0),(1854,'mail2queen.com',0,0),(1855,'mail2rabbi.com',0,0),(1856,'mail2race.com',0,0),(1857,'mail2racer.com',0,0),(1858,'mail2rachel.com',0,0),(1859,'mail2rage.com',0,0),(1860,'mail2rainmaker.com',0,0),(1861,'mail2ralph.com',0,0),(1862,'mail2randy.com',0,0),(1863,'mail2rap.com',0,0),(1864,'mail2rare.com',0,0),(1865,'mail2rave.com',0,0),(1866,'mail2ray.com',0,0),(1867,'mail2raymond.com',0,0),(1868,'mail2realtor.com',0,0),(1869,'mail2rebecca.com',0,0),(1870,'mail2recruiter.com',0,0),(1871,'mail2recycle.com',0,0),(1872,'mail2redhead.com',0,0),(1873,'mail2reed.com',0,0),(1874,'mail2reggie.com',0,0),(1875,'mail2register.com',0,0),(1876,'mail2rent.com',0,0),(1877,'mail2republican.com',0,0),(1878,'mail2resort.com',0,0),(1879,'mail2rex.com',0,0),(1880,'mail2rhodeisland.com',0,0),(1881,'mail2rich.com',0,0),(1882,'mail2richard.com',0,0),(1883,'mail2ricky.com',0,0),(1884,'mail2ride.com',0,0),(1885,'mail2riley.com',0,0),(1886,'mail2rita.com',0,0),(1887,'mail2rob.com',0,0),(1888,'mail2robert.com',0,0),(1889,'mail2roberta.com',0,0),(1890,'mail2robin.com',0,0),(1891,'mail2rock.com',0,0),(1892,'mail2rocker.com',0,0),(1893,'mail2rod.com',0,0),(1894,'mail2rodney.com',0,0),(1895,'mail2romania.com',0,0),(1896,'mail2rome.com',0,0),(1897,'mail2ron.com',0,0),(1898,'mail2ronald.com',0,0),(1899,'mail2ronnie.com',0,0),(1900,'mail2rose.com',0,0),(1901,'mail2rosie.com',0,0),(1902,'mail2roy.com',0,0),(1903,'mail2rudy.com',0,0),(1904,'mail2rugby.com',0,0),(1905,'mail2runner.com',0,0),(1906,'mail2russell.com',0,0),(1907,'mail2russia.com',0,0),(1908,'mail2russian.com',0,0),(1909,'mail2rusty.com',0,0),(1910,'mail2ruth.com',0,0),(1911,'mail2rwanda.com',0,0),(1912,'mail2ryan.com',0,0),(1913,'mail2sa.com',0,0),(1914,'mail2sabrina.com',0,0),(1915,'mail2safe.com',0,0),(1916,'mail2sagittarius.com',0,0),(1917,'mail2sail.com',0,0),(1918,'mail2sailor.com',0,0),(1919,'mail2sal.com',0,0),(1920,'mail2salaam.com',0,0),(1921,'mail2sam.com',0,0),(1922,'mail2samantha.com',0,0),(1923,'mail2samoa.com',0,0),(1924,'mail2samurai.com',0,0),(1925,'mail2sandra.com',0,0),(1926,'mail2sandy.com',0,0),(1927,'mail2sanfrancisco.com',0,0),(1928,'mail2sanmarino.com',0,0),(1929,'mail2santa.com',0,0),(1930,'mail2sara.com',0,0),(1931,'mail2sarah.com',0,0),(1932,'mail2sat.com',0,0),(1933,'mail2saturn.com',0,0),(1934,'mail2saudi.com',0,0),(1935,'mail2saudiarabia.com',0,0),(1936,'mail2save.com',0,0),(1937,'mail2savings.com',0,0),(1938,'mail2school.com',0,0),(1939,'mail2scientist.com',0,0),(1940,'mail2scorpio.com',0,0),(1941,'mail2scott.com',0,0),(1942,'mail2sean.com',0,0),(1943,'mail2search.com',0,0),(1944,'mail2seattle.com',0,0),(1945,'mail2secretagent.com',0,0),(1946,'mail2senate.com',0,0),(1947,'mail2senegal.com',0,0),(1948,'mail2sensual.com',0,0),(1949,'mail2seth.com',0,0),(1950,'mail2sevenseas.com',0,0),(1951,'mail2sexy.com',0,0),(1952,'mail2seychelles.com',0,0),(1953,'mail2shane.com',0,0),(1954,'mail2sharon.com',0,0),(1955,'mail2shawn.com',0,0),(1956,'mail2ship.com',0,0),(1957,'mail2shirley.com',0,0),(1958,'mail2shoot.com',0,0),(1959,'mail2shuttle.com',0,0),(1960,'mail2sierraleone.com',0,0),(1961,'mail2simon.com',0,0),(1962,'mail2singapore.com',0,0),(1963,'mail2single.com',0,0),(1964,'mail2site.com',0,0),(1965,'mail2skater.com',0,0),(1966,'mail2skier.com',0,0),(1967,'mail2sky.com',0,0),(1968,'mail2sleek.com',0,0),(1969,'mail2slim.com',0,0),(1970,'mail2slovakia.com',0,0),(1971,'mail2slovenia.com',0,0),(1972,'mail2smile.com',0,0),(1973,'mail2smith.com',0,0),(1974,'mail2smooth.com',0,0),(1975,'mail2soccer.com',0,0),(1976,'mail2soccerfan.com',0,0),(1977,'mail2socialist.com',0,0),(1978,'mail2soldier.com',0,0),(1979,'mail2somalia.com',0,0),(1980,'mail2son.com',0,0),(1981,'mail2song.com',0,0),(1982,'mail2sos.com',0,0),(1983,'mail2sound.com',0,0),(1984,'mail2southafrica.com',0,0),(1985,'mail2southamerica.com',0,0),(1986,'mail2southcarolina.com',0,0),(1987,'mail2southdakota.com',0,0),(1988,'mail2southkorea.com',0,0),(1989,'mail2southpole.com',0,0),(1990,'mail2spain.com',0,0),(1991,'mail2spanish.com',0,0),(1992,'mail2spare.com',0,0),(1993,'mail2spectrum.com',0,0),(1994,'mail2splash.com',0,0),(1995,'mail2sponsor.com',0,0),(1996,'mail2sports.com',0,0),(1997,'mail2srilanka.com',0,0),(1998,'mail2stacy.com',0,0),(1999,'mail2stan.com',0,0),(2000,'mail2stanley.com',0,0),(2001,'mail2star.com',0,0),(2002,'mail2state.com',0,0),(2003,'mail2stephanie.com',0,0),(2004,'mail2steve.com',0,0),(2005,'mail2steven.com',0,0),(2006,'mail2stewart.com',0,0),(2007,'mail2stlouis.com',0,0),(2008,'mail2stock.com',0,0),(2009,'mail2stockholm.com',0,0),(2010,'mail2stockmarket.com',0,0),(2011,'mail2storage.com',0,0),(2012,'mail2store.com',0,0),(2013,'mail2strong.com',0,0),(2014,'mail2student.com',0,0),(2015,'mail2studio.com',0,0),(2016,'mail2studio54.com',0,0),(2017,'mail2stuntman.com',0,0),(2018,'mail2subscribe.com',0,0),(2019,'mail2sudan.com',0,0),(2020,'mail2superstar.com',0,0),(2021,'mail2surfer.com',0,0),(2022,'mail2suriname.com',0,0),(2023,'mail2susan.com',0,0),(2024,'mail2suzie.com',0,0),(2025,'mail2swaziland.com',0,0),(2026,'mail2sweden.com',0,0),(2027,'mail2sweetheart.com',0,0),(2028,'mail2swim.com',0,0),(2029,'mail2swimmer.com',0,0),(2030,'mail2swiss.com',0,0),(2031,'mail2switzerland.com',0,0),(2032,'mail2sydney.com',0,0),(2033,'mail2sylvia.com',0,0),(2034,'mail2syria.com',0,0),(2035,'mail2taboo.com',0,0),(2036,'mail2taiwan.com',0,0),(2037,'mail2tajikistan.com',0,0),(2038,'mail2tammy.com',0,0),(2039,'mail2tango.com',0,0),(2040,'mail2tanya.com',0,0),(2041,'mail2tanzania.com',0,0),(2042,'mail2tara.com',0,0),(2043,'mail2taurus.com',0,0),(2044,'mail2taxi.com',0,0),(2045,'mail2taxidermist.com',0,0),(2046,'mail2taylor.com',0,0),(2047,'mail2taz.com',0,0),(2048,'mail2teacher.com',0,0),(2049,'mail2technician.com',0,0),(2050,'mail2ted.com',0,0),(2051,'mail2telephone.com',0,0),(2052,'mail2teletubbie.com',0,0),(2053,'mail2tenderness.com',0,0),(2054,'mail2tennessee.com',0,0),(2055,'mail2tennis.com',0,0),(2056,'mail2tennisfan.com',0,0),(2057,'mail2terri.com',0,0),(2058,'mail2terry.com',0,0),(2059,'mail2test.com',0,0),(2060,'mail2texas.com',0,0),(2061,'mail2thailand.com',0,0),(2062,'mail2therapy.com',0,0),(2063,'mail2think.com',0,0),(2064,'mail2tickets.com',0,0),(2065,'mail2tiffany.com',0,0),(2066,'mail2tim.com',0,0),(2067,'mail2time.com',0,0),(2068,'mail2timothy.com',0,0),(2069,'mail2tina.com',0,0),(2070,'mail2titanic.com',0,0),(2071,'mail2toby.com',0,0),(2072,'mail2todd.com',0,0),(2073,'mail2togo.com',0,0),(2074,'mail2tom.com',0,0),(2075,'mail2tommy.com',0,0),(2076,'mail2tonga.com',0,0),(2077,'mail2tony.com',0,0),(2078,'mail2touch.com',0,0),(2079,'mail2tourist.com',0,0),(2080,'mail2tracey.com',0,0),(2081,'mail2tracy.com',0,0),(2082,'mail2tramp.com',0,0),(2083,'mail2travel.com',0,0),(2084,'mail2traveler.com',0,0),(2085,'mail2travis.com',0,0),(2086,'mail2trekkie.com',0,0),(2087,'mail2trex.com',0,0),(2088,'mail2triallawyer.com',0,0),(2089,'mail2trick.com',0,0),(2090,'mail2trillionaire.com',0,0),(2091,'mail2troy.com',0,0),(2092,'mail2truck.com',0,0),(2093,'mail2trump.com',0,0),(2094,'mail2try.com',0,0),(2095,'mail2tunisia.com',0,0),(2096,'mail2turbo.com',0,0),(2097,'mail2turkey.com',0,0),(2098,'mail2turkmenistan.com',0,0),(2099,'mail2tv.com',0,0),(2100,'mail2tycoon.com',0,0),(2101,'mail2tyler.com',0,0),(2102,'mail2u4me.com',0,0),(2103,'mail2uae.com',0,0),(2104,'mail2uganda.com',0,0),(2105,'mail2uk.com',0,0),(2106,'mail2ukraine.com',0,0),(2107,'mail2uncle.com',0,0),(2108,'mail2unsubscribe.com',0,0),(2109,'mail2uptown.com',0,0),(2110,'mail2uruguay.com',0,0),(2111,'mail2usa.com',0,0),(2112,'mail2utah.com',0,0),(2113,'mail2uzbekistan.com',0,0),(2114,'mail2v.com',0,0),(2115,'mail2vacation.com',0,0),(2116,'mail2valentines.com',0,0),(2117,'mail2valerie.com',0,0),(2118,'mail2valley.com',0,0),(2119,'mail2vamoose.com',0,0),(2120,'mail2vanessa.com',0,0),(2121,'mail2vanuatu.com',0,0),(2122,'mail2venezuela.com',0,0),(2123,'mail2venous.com',0,0),(2124,'mail2venus.com',0,0),(2125,'mail2vermont.com',0,0),(2126,'mail2vickie.com',0,0),(2127,'mail2victor.com',0,0),(2128,'mail2victoria.com',0,0),(2129,'mail2vienna.com',0,0),(2130,'mail2vietnam.com',0,0),(2131,'mail2vince.com',0,0),(2132,'mail2virginia.com',0,0),(2133,'mail2virgo.com',0,0),(2134,'mail2visionary.com',0,0),(2135,'mail2vodka.com',0,0),(2136,'mail2volleyball.com',0,0),(2137,'mail2waiter.com',0,0),(2138,'mail2wallstreet.com',0,0),(2139,'mail2wally.com',0,0),(2140,'mail2walter.com',0,0),(2141,'mail2warren.com',0,0),(2142,'mail2washington.com',0,0),(2143,'mail2wave.com',0,0),(2144,'mail2way.com',0,0),(2145,'mail2waycool.com',0,0),(2146,'mail2wayne.com',0,0),(2147,'mail2webmaster.com',0,0),(2148,'mail2webtop.com',0,0),(2149,'mail2webtv.com',0,0),(2150,'mail2weird.com',0,0),(2151,'mail2wendell.com',0,0),(2152,'mail2wendy.com',0,0),(2153,'mail2westend.com',0,0),(2154,'mail2westvirginia.com',0,0),(2155,'mail2whether.com',0,0),(2156,'mail2whip.com',0,0),(2157,'mail2white.com',0,0),(2158,'mail2whitehouse.com',0,0),(2159,'mail2whitney.com',0,0),(2160,'mail2why.com',0,0),(2161,'mail2wilbur.com',0,0),(2162,'mail2wild.com',0,0),(2163,'mail2willard.com',0,0),(2164,'mail2willie.com',0,0),(2165,'mail2wine.com',0,0),(2166,'mail2winner.com',0,0),(2167,'mail2wired.com',0,0),(2168,'mail2wisconsin.com',0,0),(2169,'mail2woman.com',0,0),(2170,'mail2wonder.com',0,0),(2171,'mail2world.com',0,0),(2172,'mail2worship.com',0,0),(2173,'mail2wow.com',0,0),(2174,'mail2www.com',0,0),(2175,'mail2wyoming.com',0,0),(2176,'mail2xfiles.com',0,0),(2177,'mail2xox.com',0,0),(2178,'mail2yachtclub.com',0,0),(2179,'mail2yahalla.com',0,0),(2180,'mail2yemen.com',0,0),(2181,'mail2yes.com',0,0),(2182,'mail2yugoslavia.com',0,0),(2183,'mail2zack.com',0,0),(2184,'mail2zambia.com',0,0),(2185,'mail2zenith.com',0,0),(2186,'mail2zephir.com',0,0),(2187,'mail2zeus.com',0,0),(2188,'mail2zipper.com',0,0),(2189,'mail2zoo.com',0,0),(2190,'mail2zoologist.com',0,0),(2191,'mail2zurich.com',0,0),(2192,'mail3000.com',0,0),(2193,'mail333.com',0,0),(2194,'mailandftp.com',0,0),(2195,'mailandnews.com',0,0),(2196,'mailas.com',0,0),(2197,'mailasia.com',0,0),(2198,'mailbolt.com',0,0),(2199,'mailbomb.net',0,0),(2200,'mailbox.as',0,0),(2201,'mailbox.co.za',0,0),(2202,'mailbox.gr',0,0),(2203,'mailbox.hu',0,0),(2204,'mailbr.com.br',0,0),(2205,'mailc.net',0,0),(2206,'mailcan.com',0,0),(2207,'mailchoose.co',0,0),(2208,'mailcity.com',0,0),(2209,'mailclub.fr',0,0),(2210,'mailclub.net',0,0),(2211,'mailexcite.com',0,0),(2212,'mailforce.net',0,0),(2213,'mailftp.com',0,0),(2214,'mailgenie.net',0,0),(2215,'mailhaven.com',0,0),(2216,'mailhood.com',0,0),(2217,'mailingweb.com',0,0),(2218,'mailisent.com',0,0),(2219,'mailite.com',0,0),(2220,'mailme.dk',0,0),(2221,'mailmight.com',0,0),(2222,'mailmij.nl',0,0),(2223,'mailnew.com',0,0),(2224,'mailops.com',0,0),(2225,'mailoye.com',0,0),(2226,'mailpanda.com',0,0),(2227,'mailpride.com',0,0),(2228,'mailpuppy.com',0,0),(2229,'mailroom.com',0,0),(2230,'mailru.com',0,0),(2231,'mailsent.net',0,0),(2232,'mailsurf.com',0,0),(2233,'mailup.net',0,0),(2234,'maktoob.com',0,0),(2235,'malayalamtelevision.net',0,0),(2236,'manager.de',0,0),(2237,'mantrafreenet.com',0,0),(2238,'mantramail.com',0,0),(2239,'mantraonline.com',0,0),(2240,'marchmail.com',0,0),(2241,'marijuana.nl',0,0),(2242,'married-not.com',0,0),(2243,'marsattack.com',0,0),(2244,'masrawy.com',0,0),(2245,'mauimail.com',0,0),(2246,'maxleft.com',0,0),(2247,'mbox.com.au',0,0),(2248,'me-mail.hu',0,0),(2249,'meetingmall.com',0,0),(2250,'megago.com',0,0),(2251,'megamail.pt',0,0),(2252,'mehrani.com',0,0),(2253,'mehtaweb.com',0,0),(2254,'melodymail.com',0,0),(2255,'meloo.com',0,0),(2256,'message.hu',0,0),(2257,'metacrawler.com',0,0),(2258,'metta.lk',0,0),(2259,'miesto.sk',0,0),(2260,'mighty.co.za',0,0),(2261,'miho-nakayama.com',0,0),(2262,'millionaireintraining.com',0,0),(2263,'milmail.com',0,0),(2264,'misery.net',0,0),(2265,'mittalweb.com',0,0),(2266,'mixmail.com',0,0),(2267,'ml1.net',0,0),(2268,'mobilbatam.com',0,0),(2269,'mohammed.com',0,0),(2270,'moldova.cc',0,0),(2271,'moldova.com',0,0),(2272,'moldovacc.com',0,0),(2273,'montevideo.com.uy',0,0),(2274,'moonman.com',0,0),(2275,'moose-mail.com',0,0),(2276,'mortaza.com',0,0),(2277,'mosaicfx.com',0,0),(2278,'most-wanted.com',0,0),(2279,'mostlysunny.com',0,0),(2280,'motormania.com',0,0),(2281,'movemail.com',0,0),(2282,'mp4.it',0,0),(2283,'mr-potatohead.com',0,0),(2284,'mscold.com',0,0),(2285,'msgbox.com',0,0),(2286,'mundomail.net',0,0),(2287,'munich.com',0,0),(2288,'musician.org',0,0),(2289,'musicscene.org',0,0),(2290,'mybox.it',0,0),(2291,'mycabin.com',0,0),(2292,'mycity.com',0,0),(2293,'mycool.com',0,0),(2294,'mydomain.com',0,0),(2295,'mydotcomaddress.com',0,0),(2296,'myfamily.com',0,0),(2297,'myiris.com',0,0),(2298,'mynamedot.com',0,0),(2299,'mynetaddress.com',0,0),(2300,'myownemail.com',0,0),(2301,'myownfriends.com',0,0),(2302,'mypersonalemail.com',0,0),(2303,'myplace.com',0,0),(2304,'myrealbox.com',0,0),(2305,'myself.com',0,0),(2306,'mystupidjob.com',0,0),(2307,'myway.com',0,0),(2308,'myworldmail.com',0,0),(2309,'n2.com',0,0),(2310,'n2business.com',0,0),(2311,'n2mail.com',0,0),(2312,'n2software.com',0,0),(2313,'nabc.biz',0,0),(2314,'nagpal.net',0,0),(2315,'nakedgreens.com',0,0),(2316,'name.com',0,0),(2317,'nameplanet.com',0,0),(2318,'nandomail.com',0,0),(2319,'naseej.com',0,0),(2320,'nativestar.net',0,0),(2321,'nativeweb.net',0,0),(2322,'navigator.lv',0,0),(2323,'neeva.net',0,0),(2324,'nemra1.com',0,0),(2325,'nenter.com',0,0),(2326,'nervhq.org',0,0),(2327,'net4b.pt',0,0),(2328,'net4you.at',0,0),(2329,'netbounce.com',0,0),(2330,'netbroadcaster.com',0,0),(2331,'netcenter-vn.net',0,0),(2332,'netcourrier.com',0,0),(2333,'netexecutive.com',0,0),(2334,'netexpressway.com',0,0),(2335,'netian.com',0,0),(2336,'netizen.com.ar',0,0),(2337,'netlane.com',0,0),(2338,'netlimit.com',0,0),(2339,'netmongol.com',0,0),(2340,'netpiper.com',0,0),(2341,'netposta.net',0,0),(2342,'netralink.com',0,0),(2343,'netscape.net',0,0),(2344,'netscapeonline.co.uk',0,0),(2345,'netspeedway.com',0,0),(2346,'netsquare.com',0,0),(2347,'netster.com',0,0),(2348,'nettaxi.com',0,0),(2349,'netzero.com',0,0),(2350,'netzero.net',0,0),(2351,'newmail.com',0,0),(2352,'newmail.net',0,0),(2353,'newmail.ru',0,0),(2354,'newyork.com',0,0),(2355,'nfmail.com',0,0),(2356,'nicegal.com',0,0),(2357,'nicholastse.net',0,0),(2358,'nicolastse.com',0,0),(2359,'nightmail.com',0,0),(2360,'nikopage.com',0,0),(2361,'nirvanafan.com',0,0),(2362,'noavar.com',0,0),(2363,'norika-fujiwara.com',0,0),(2364,'norikomail.com',0,0),(2365,'northgates.net',0,0),(2366,'nospammail.net',0,0),(2367,'ny.com',0,0),(2368,'nyc.com',0,0),(2369,'nycmail.com',0,0),(2370,'nzoomail.com',0,0),(2371,'o-tay.com',0,0),(2372,'o2.co.uk',0,0),(2373,'oceanfree.net',0,0),(2374,'oddpost.com',0,0),(2375,'odmail.com',0,0),(2376,'oicexchange.com',0,0),(2377,'okbank.com',0,0),(2378,'okhuman.com',0,0),(2379,'okmad.com',0,0),(2380,'okmagic.com',0,0),(2381,'okname.net',0,0),(2382,'okuk.com',0,0),(2383,'ole.com',0,0),(2384,'olemail.com',0,0),(2385,'olympist.net',0,0),(2386,'omaninfo.com',0,0),(2387,'onebox.com',0,0),(2388,'onenet.com.ar',0,0),(2389,'onet.pl',0,0),(2390,'oninet.pt',0,0),(2391,'online.ie',0,0),(2392,'onlinewiz.com',0,0),(2393,'onmilwaukee.com',0,0),(2394,'onobox.com',0,0),(2395,'operamail.com',0,0),(2396,'optician.com',0,0),(2397,'orbitel.bg',0,0),(2398,'orgmail.net',0,0),(2399,'osite.com.br',0,0),(2400,'oso.com',0,0),(2401,'otakumail.com',0,0),(2402,'our-computer.com',0,0),(2403,'our-office.com',0,0),(2404,'ourbrisbane.com',0,0),(2405,'ournet.md',0,0),(2406,'outgun.com',0,0),(2407,'over-the-rainbow.com',0,0),(2408,'ownmail.net',0,0),(2409,'packersfan.com',0,0),(2410,'pakistanoye.com',0,0),(2411,'palestinemail.com',0,0),(2412,'parkjiyoon.com',0,0),(2413,'parrot.com',0,0),(2414,'partlycloudy.com',0,0),(2415,'partynight.at',0,0),(2416,'parvazi.com',0,0),(2417,'pcpostal.com',0,0),(2418,'pediatrician.com',0,0),(2419,'penpen.com',0,0),(2420,'peopleweb.com',0,0),(2421,'perfectmail.com',0,0),(2422,'personal.ro',0,0),(2423,'personales.com',0,0),(2424,'petml.com',0,0),(2425,'pettypool.com',0,0),(2426,'pezeshkpour.com',0,0),(2427,'phayze.com',0,0),(2428,'phreaker.net',0,0),(2429,'picusnet.com',0,0),(2430,'pigpig.net',0,0),(2431,'pinoymail.com',0,0),(2432,'piracha.net',0,0),(2433,'pisem.net',0,0),(2434,'planetaccess.com',0,0),(2435,'planetout.com',0,0),(2436,'plasa.com',0,0),(2437,'playersodds.com',0,0),(2438,'playful.com',0,0),(2439,'plusmail.com.br',0,0),(2440,'pmail.net',0,0),(2441,'pobox.hu',0,0),(2442,'pobox.sk',0,0),(2443,'pochta.ru',0,0),(2444,'poczta.fm',0,0),(2445,'poetic.com',0,0),(2446,'polbox.com',0,0),(2447,'policeoffice.com',0,0),(2448,'pool-sharks.com',0,0),(2449,'poond.com',0,0),(2450,'popmail.com',0,0),(2451,'popsmail.com',0,0),(2452,'popstar.com',0,0),(2453,'portugalmail.com',0,0),(2454,'portugalmail.pt',0,0),(2455,'portugalnet.com',0,0),(2456,'positive-thinking.com',0,0),(2457,'post.com',0,0),(2458,'post.cz',0,0),(2459,'post.sk',0,0),(2460,'postaccesslite.com',0,0),(2461,'postafree.com',0,0),(2462,'postaweb.com',0,0),(2463,'postinbox.com',0,0),(2464,'postino.ch',0,0),(2465,'postmaster.co.uk',0,0),(2466,'postpro.net',0,0),(2467,'powerfan.com',0,0),(2468,'praize.com',0,0),(2469,'premiumservice.com',0,0),(2470,'presidency.com',0,0),(2471,'press.co.jp',0,0),(2472,'priest.com',0,0),(2473,'primposta.com',0,0),(2474,'primposta.hu',0,0),(2475,'pro.hu',0,0),(2476,'progetplus.it',0,0),(2477,'programmer.net',0,0),(2478,'programozo.hu',0,0),(2479,'proinbox.com',0,0),(2480,'project2k.com',0,0),(2481,'promessage.com',0,0),(2482,'prontomail.com',0,0),(2483,'psv-supporter.com',0,0),(2484,'publicist.com',0,0),(2485,'pulp-fiction.com',0,0),(2486,'punkass.com',0,0),(2487,'qatarmail.com',0,0),(2488,'qprfans.com',0,0),(2489,'qrio.com',0,0),(2490,'quackquack.com',0,0),(2491,'qudsmail.com',0,0),(2492,'quepasa.com',0,0),(2493,'quickwebmail.com',0,0),(2494,'r-o-o-t.com',0,0),(2495,'raakim.com',0,0),(2496,'racingfan.com.au',0,0),(2497,'radicalz.com',0,0),(2498,'ragingbull.com',0,0),(2499,'ranmamail.com',0,0),(2500,'rastogi.net',0,0),(2501,'rattle-snake.com',0,0),(2502,'ravearena.com',0,0),(2503,'razormail.com',0,0),(2504,'rccgmail.org',0,0),(2505,'realemail.net',0,0),(2506,'reallyfast.biz',0,0),(2507,'rediffmail.com',0,0),(2508,'rediffmailpro.com',0,0),(2509,'rednecks.com',0,0),(2510,'redseven.de',0,0),(2511,'redsfans.com',0,0),(2512,'registerednurses.com',0,0),(2513,'repairman.com',0,0),(2514,'reply.hu',0,0),(2515,'representative.com',0,0),(2516,'rescueteam.com',0,0),(2517,'rezai.com',0,0),(2518,'rickymail.com',0,0),(2519,'rin.ru',0,0),(2520,'rn.com',0,0),(2521,'rock.com',0,0),(2522,'rocketmail.com',0,0),(2523,'rodrun.com',0,0),(2524,'rome.com',0,0),(2525,'roughnet.com',0,0),(2526,'rubyridge.com',0,0),(2527,'runbox.com',0,0),(2528,'rushpost.com',0,0),(2529,'ruttolibero.com',0,0),(2530,'s-mail.com',0,0),(2531,'sabreshockey.com',0,0),(2532,'sacbeemail.com',0,0),(2533,'safe-mail.net',0,0),(2534,'sailormoon.com',0,0),(2535,'saintly.com',0,0),(2536,'sale-sale-sale.com',0,0),(2537,'salehi.net',0,0),(2538,'samerica.com',0,0),(2539,'samilan.net',0,0),(2540,'sammimail.com',0,0),(2541,'sanfranmail.com',0,0),(2542,'sanook.com',0,0),(2543,'sapo.pt',0,0),(2544,'saudia.com',0,0),(2545,'sayhi.net',0,0),(2546,'scandalmail.com',0,0),(2547,'schweiz.org',0,0),(2548,'sci.fi',0,0),(2549,'scientist.com',0,0),(2550,'scifianime.com',0,0),(2551,'scottishmail.co.uk',0,0),(2552,'scubadiving.com',0,0),(2553,'searchwales.com',0,0),(2554,'sebil.com',0,0),(2555,'secret-police.com',0,0),(2556,'secretservices.net',0,0),(2557,'seductive.com',0,0),(2558,'seekstoyboy.com',0,0),(2559,'send.hu',0,0),(2560,'sendme.cz',0,0),(2561,'sent.com',0,0),(2562,'serga.com.ar',0,0),(2563,'servemymail.com',0,0),(2564,'sesmail.com',0,0),(2565,'sexmagnet.com',0,0),(2566,'seznam.cz',0,0),(2567,'shahweb.net',0,0),(2568,'shaniastuff.com',0,0),(2569,'sharmaweb.com',0,0),(2570,'she.com',0,0),(2571,'shootmail.com',0,0),(2572,'shotgun.hu',0,0),(2573,'shuf.com',0,0),(2574,'sialkotcity.com',0,0),(2575,'sialkotian.com',0,0),(2576,'sialkotoye.com',0,0),(2577,'sify.com',0,0),(2578,'sinamail.com',0,0),(2579,'singapore.com',0,0),(2580,'singmail.com',0,0),(2581,'singnet.com.sg',0,0),(2582,'skim.com',0,0),(2583,'skizo.hu',0,0),(2584,'slamdunkfan.com',0,0),(2585,'slingshot.com',0,0),(2586,'slo.net',0,0),(2587,'slotter.com',0,0),(2588,'smapxsmap.net',0,0),(2589,'smileyface.com',0,0),(2590,'smithemail.net',0,0),(2591,'smoothmail.com',0,0),(2592,'snail-mail.net',0,0),(2593,'snakemail.com',0,0),(2594,'sndt.net',0,0),(2595,'sneakemail.com',0,0),(2596,'sniper.hu',0,0),(2597,'snoopymail.com',0,0),(2598,'snowboarding.com',0,0),(2599,'snowdonia.net',0,0),(2600,'socamail.com',0,0),(2601,'sociologist.com',0,0),(2602,'softhome.net',0,0),(2603,'sol.dk',0,0),(2604,'soldier.hu',0,0),(2605,'soon.com',0,0),(2606,'soulfoodcookbook.com',0,0),(2607,'sp.nl',0,0),(2608,'space.com',0,0),(2609,'spacetowns.com',0,0),(2610,'spamex.com',0,0),(2611,'spartapiet.com',0,0),(2612,'spazmail.com',0,0),(2613,'speedpost.net',0,0),(2614,'spils.com',0,0),(2615,'spinfinder.com',0,0),(2616,'sportemail.com',0,0),(2617,'spray.no',0,0),(2618,'spray.se',0,0),(2619,'spymac.com',0,0),(2620,'srilankan.net',0,0),(2621,'st-davids.net',0,0),(2622,'stade.fr',0,0),(2623,'stargateradio.com',0,0),(2624,'starmail.com',0,0),(2625,'starmail.org',0,0),(2626,'starmedia.com',0,0),(2627,'starplace.com',0,0),(2628,'starspath.com',0,0),(2629,'start.com.au',0,0),(2630,'stopdropandroll.com',0,0),(2631,'stribmail.com',0,0),(2632,'strompost.com',0,0),(2633,'strongguy.com',0,0),(2634,'subram.com',0,0),(2635,'sudanmail.net',0,0),(2636,'suhabi.com',0,0),(2637,'suisse.org',0,0),(2638,'sunpoint.net',0,0),(2639,'sunrise-sunset.com',0,0),(2640,'sunsgame.com',0,0),(2641,'sunumail.sn',0,0),(2642,'superdada.com',0,0),(2643,'supereva.it',0,0),(2644,'supermail.ru',0,0),(2645,'surf3.net',0,0),(2646,'surfy.net',0,0),(2647,'surimail.com',0,0),(2648,'survivormail.com',0,0),(2649,'sweb.cz',0,0),(2650,'swiftdesk.com',0,0),(2651,'swirve.com',0,0),(2652,'swissinfo.org',0,0),(2653,'swissmail.net',0,0),(2654,'switchboardmail.com',0,0),(2655,'switzerland.org',0,0),(2656,'sx172.com',0,0),(2657,'syom.com',0,0),(2658,'syriamail.com',0,0),(2659,'t2mail.com',0,0),(2660,'takuyakimura.com',0,0),(2661,'talk21.com',0,0),(2662,'talkcity.com',0,0),(2663,'tamil.com',0,0),(2664,'tatanova.com',0,0),(2665,'tech4peace.org',0,0),(2666,'techemail.com',0,0),(2667,'techie.com',0,0),(2668,'technisamail.co.za',0,0),(2669,'technologist.com',0,0),(2670,'teenagedirtbag.com',0,0),(2671,'telebot.com',0,0),(2672,'teleline.es',0,0),(2673,'telinco.net',0,0),(2674,'telkom.net',0,0),(2675,'telpage.net',0,0),(2676,'tenchiclub.com',0,0),(2677,'tenderkiss.com',0,0),(2678,'terra.cl',0,0),(2679,'terra.com',0,0),(2680,'terra.com.ar',0,0),(2681,'terra.com.br',0,0),(2682,'terra.es',0,0),(2683,'tfanus.com.er',0,0),(2684,'tfz.net',0,0),(2685,'thai.com',0,0),(2686,'thaimail.com',0,0),(2687,'thaimail.net',0,0),(2688,'the-african.com',0,0),(2689,'the-airforce.com',0,0),(2690,'the-aliens.com',0,0),(2691,'the-american.com',0,0),(2692,'the-animal.com',0,0),(2693,'the-army.com',0,0),(2694,'the-astronaut.com',0,0),(2695,'the-beauty.com',0,0),(2696,'the-big-apple.com',0,0),(2697,'the-biker.com',0,0),(2698,'the-boss.com',0,0),(2699,'the-brazilian.com',0,0),(2700,'the-canadian.com',0,0),(2701,'the-canuck.com',0,0),(2702,'the-captain.com',0,0),(2703,'the-chinese.com',0,0),(2704,'the-country.com',0,0),(2705,'the-cowboy.com',0,0),(2706,'the-davis-home.com',0,0),(2707,'the-dutchman.com',0,0),(2708,'the-eagles.com',0,0),(2709,'the-englishman.com',0,0),(2710,'the-fastest.net',0,0),(2711,'the-fool.com',0,0),(2712,'the-frenchman.com',0,0),(2713,'the-galaxy.net',0,0),(2714,'the-genius.com',0,0),(2715,'the-gentleman.com',0,0),(2716,'the-german.com',0,0),(2717,'the-gremlin.com',0,0),(2718,'the-hooligan.com',0,0),(2719,'the-italian.com',0,0),(2720,'the-japanese.com',0,0),(2721,'the-lair.com',0,0),(2722,'the-madman.com',0,0),(2723,'the-mailinglist.com',0,0),(2724,'the-marine.com',0,0),(2725,'the-master.com',0,0),(2726,'the-mexican.com',0,0),(2727,'the-ministry.com',0,0),(2728,'the-monkey.com',0,0),(2729,'the-newsletter.net',0,0),(2730,'the-pentagon.com',0,0),(2731,'the-police.com',0,0),(2732,'the-prayer.com',0,0),(2733,'the-professional.com',0,0),(2734,'the-quickest.com',0,0),(2735,'the-russian.com',0,0),(2736,'the-snake.com',0,0),(2737,'the-spaceman.com',0,0),(2738,'the-stock-market.com',0,0),(2739,'the-student.net',0,0),(2740,'the-whitehouse.net',0,0),(2741,'the-wild-west.com',0,0),(2742,'the18th.com',0,0),(2743,'thecoolguy.com',0,0),(2744,'thecriminals.com',0,0),(2745,'thedoghousemail.com',0,0),(2746,'theend.hu',0,0),(2747,'thegolfcourse.com',0,0),(2748,'thegooner.com',0,0),(2749,'theheadoffice.com',0,0),(2750,'thelanddownunder.com',0,0),(2751,'theoffice.net',0,0),(2752,'thepokerface.com',0,0),(2753,'thepostmaster.net',0,0),(2754,'theraces.com',0,0),(2755,'theracetrack.com',0,0),(2756,'thestreetfighter.com',0,0),(2757,'theteebox.com',0,0),(2758,'thewatercooler.com',0,0),(2759,'thewebpros.co.uk',0,0),(2760,'thewizzard.com',0,0),(2761,'thewizzkid.com',0,0),(2762,'thezhangs.net',0,0),(2763,'thirdage.com',0,0),(2764,'thundermail.com',0,0),(2765,'tidni.com',0,0),(2766,'timein.net',0,0),(2767,'tiscali.at',0,0),(2768,'tiscali.be',0,0),(2769,'tiscali.co.uk',0,0),(2770,'tiscali.lu',0,0),(2771,'tiscali.se',0,0),(2772,'tkcity.com',0,0),(2773,'topchat.com',0,0),(2774,'topgamers.co.uk',0,0),(2775,'topletter.com',0,0),(2776,'topmail.com.ar',0,0),(2777,'topsurf.com',0,0),(2778,'torchmail.com',0,0),(2779,'travel.li',0,0),(2780,'trialbytrivia.com',0,0),(2781,'trmailbox.com',0,0),(2782,'tropicalstorm.com',0,0),(2783,'trust-me.com',0,0),(2784,'tsamail.co.za',0,0),(2785,'ttml.co.in',0,0),(2786,'tunisiamail.com',0,0),(2787,'turkey.com',0,0),(2788,'twinstarsmail.com',0,0),(2789,'tycoonmail.com',0,0),(2790,'typemail.com',0,0),(2791,'u2club.com',0,0),(2792,'uae.ac',0,0),(2793,'uaemail.com',0,0),(2794,'ubbi.com',0,0),(2795,'ubbi.com.br',0,0),(2796,'uboot.com',0,0),(2797,'uk2k.com',0,0),(2798,'uk2net.com',0,0),(2799,'uk7.net',0,0),(2800,'uk8.net',0,0),(2801,'ukbuilder.com',0,0),(2802,'ukcool.com',0,0),(2803,'ukdreamcast.com',0,0),(2804,'ukr.net',0,0),(2805,'uku.co.uk',0,0),(2806,'ultapulta.com',0,0),(2807,'ultrapostman.com',0,0),(2808,'ummah.org',0,0),(2809,'umpire.com',0,0),(2810,'unbounded.com',0,0),(2811,'unican.es',0,0),(2812,'unihome.com',0,0),(2813,'universal.pt',0,0),(2814,'uno.ee',0,0),(2815,'uno.it',0,0),(2816,'unofree.it',0,0),(2817,'uol.com.ar',0,0),(2818,'uol.com.br',0,0),(2819,'uol.com.co',0,0),(2820,'uol.com.mx',0,0),(2821,'uol.com.ve',0,0),(2822,'uole.com',0,0),(2823,'uole.com.ve',0,0),(2824,'uolmail.com',0,0),(2825,'uomail.com',0,0),(2826,'ureach.com',0,0),(2827,'urgentmail.biz',0,0),(2828,'usa.com',0,0),(2829,'usanetmail.com',0,0),(2830,'uymail.com',0,0),(2831,'uyuyuy.com',0,0),(2832,'v-sexi.com',0,0),(2833,'velnet.co.uk',0,0),(2834,'velocall.com',0,0),(2835,'verizonmail.com',0,0),(2836,'veryfast.biz',0,0),(2837,'veryspeedy.net',0,0),(2838,'violinmakers.co.uk',0,0),(2839,'vip.gr',0,0),(2840,'vipmail.ru',0,0),(2841,'virgilio.it',0,0),(2842,'virgin.net',0,0),(2843,'virtualmail.com',0,0),(2844,'visitmail.com',0,0),(2845,'visto.com',0,0),(2846,'vivianhsu.net',0,0),(2847,'vjtimail.com',0,0),(2848,'vnn.vn',0,0),(2849,'volcanomail.com',0,0),(2850,'vote-democrats.com',0,0),(2851,'vote-hillary.com',0,0),(2852,'vote-republicans.com',0,0),(2853,'wahoye.com',0,0),(2854,'wales2000.net',0,0),(2855,'wam.co.za',0,0),(2856,'wanadoo.es',0,0),(2857,'warmmail.com',0,0),(2858,'warpmail.net',0,0),(2859,'warrior.hu',0,0),(2860,'waumail.com',0,0),(2861,'wearab.net',0,0),(2862,'web-mail.com.ar',0,0),(2863,'web-police.com',0,0),(2864,'web.de',0,0),(2865,'webave.com',0,0),(2866,'webcity.ca',0,0),(2867,'webdream.com',0,0),(2868,'webindia123.com',0,0),(2869,'webjump.com',0,0),(2870,'webmail.co.yu',0,0),(2871,'webmail.co.za',0,0),(2872,'webmail.hu',0,0),(2873,'webmails.com',0,0),(2874,'webprogramming.com',0,0),(2875,'webstation.com',0,0),(2876,'websurfer.co.za',0,0),(2877,'webtopmail.com',0,0),(2878,'weedmail.com',0,0),(2879,'weekonline.com',0,0),(2880,'wehshee.com',0,0),(2881,'welsh-lady.com',0,0),(2882,'whartontx.com',0,0),(2883,'wheelweb.com',0,0),(2884,'whipmail.com',0,0),(2885,'whoever.com',0,0),(2886,'whoopymail.com',0,0),(2887,'wildmail.com',0,0),(2888,'winmail.com.au',0,0),(2889,'winning.com',0,0),(2890,'witty.com',0,0),(2891,'wolf-web.com',0,0),(2892,'wombles.com',0,0),(2893,'wongfaye.com',0,0),(2894,'wooow.it',0,0),(2895,'workmail.com',0,0),(2896,'worldemail.com',0,0),(2897,'wosaddict.com',0,0),(2898,'wouldilie.com',0,0),(2899,'wowmail.com',0,0),(2900,'wp.pl',0,0),(2901,'wrexham.net',0,0),(2902,'writeme.com',0,0),(2903,'writemeback.com',0,0),(2904,'wrongmail.com',0,0),(2905,'www.com',0,0),(2906,'wx88.net',0,0),(2907,'wxs.net',0,0),(2908,'x-mail.net',0,0),(2909,'x5g.com',0,0),(2910,'xmsg.com',0,0),(2911,'xoom.com',0,0),(2912,'xsmail.com',0,0),(2913,'xuno.com',0,0),(2914,'xzapmail.com',0,0),(2915,'yada-yada.com',0,0),(2916,'yaho.com',0,0),(2917,'yahoo.ca',0,0),(2918,'yahoo.co.in',0,0),(2919,'yahoo.co.jp',0,0),(2920,'yahoo.co.kr',0,0),(2921,'yahoo.co.nz',0,0),(2922,'yahoo.co.uk',0,0),(2923,'yahoo.com.ar',0,0),(2924,'yahoo.com.au',0,0),(2925,'yahoo.com.br',0,0),(2926,'yahoo.com.cn',0,0),(2927,'yahoo.com.hk',0,0),(2928,'yahoo.com.is',0,0),(2929,'yahoo.com.mx',0,0),(2930,'yahoo.com.ru',0,0),(2931,'yahoo.com.sg',0,0),(2932,'yahoo.de',0,0),(2933,'yahoo.dk',0,0),(2934,'yahoo.es',0,0),(2935,'yahoo.fr',0,0),(2936,'yahoo.ie',0,0),(2937,'yahoo.it',0,0),(2938,'yahoo.jp',0,0),(2939,'yahoo.ru',0,0),(2940,'yahoo.se',0,0),(2941,'yahoofs.com',0,0),(2942,'yalla.com',0,0),(2943,'yalla.com.lb',0,0),(2944,'yalook.com',0,0),(2945,'yam.com',0,0),(2946,'yandex.ru',0,0),(2947,'yapost.com',0,0),(2948,'yebox.com',0,0),(2949,'yehey.com',0,0),(2950,'yemenmail.com',0,0),(2951,'yepmail.net',0,0),(2952,'yifan.net',0,0),(2953,'yopolis.com',0,0),(2954,'youareadork.com',0,0),(2955,'your-house.com',0,0),(2956,'yourinbox.com',0,0),(2957,'yourlover.net',0,0),(2958,'yournightmare.com',0,0),(2959,'yours.com',0,0),(2960,'yourssincerely.com',0,0),(2961,'yourteacher.net',0,0),(2962,'yourwap.com',0,0),(2963,'yuuhuu.net',0,0),(2964,'yyhmail.com',0,0),(2965,'zahadum.com',0,0),(2966,'zeepost.nl',0,0),(2967,'zhaowei.net',0,0),(2968,'zip.net',0,0),(2969,'zipido.com',0,0),(2970,'ziplip.com',0,0),(2971,'zipmail.com',0,0),(2972,'zipmail.com.br',0,0),(2973,'zipmax.com',0,0),(2974,'zmail.ru',0,0),(2975,'zonnet.nl',0,0),(2976,'zubee.com',0,0),(2977,'zuvio.com',0,0),(2978,'zwallet.com',0,0),(2979,'zybermail.com',0,0),(2980,'zzn.com',0,0),(2981,'zzom.co.uk',0,0),(2982,'yahoo.com.vn',0,0);
/*!40000 ALTER TABLE `email_domain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_ip`
--

DROP TABLE IF EXISTS `email_ip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_ip` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip_address` int(11) NOT NULL,
  `hostname` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `server_id` int(11) DEFAULT '0',
  `is_active` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_hostname` (`hostname`),
  UNIQUE KEY `ix_ip_address` (`ip_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_ip`
--

LOCK TABLES `email_ip` WRITE;
/*!40000 ALTER TABLE `email_ip` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_ip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_sending_ip`
--

DROP TABLE IF EXISTS `email_sending_ip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_sending_ip` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `ip_address` int(11) unsigned NOT NULL,
  `is_dedicated` int(11) DEFAULT '0',
  `virtual_mta` int(11) DEFAULT '0',
  `ip_type` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_sending_ip` (`account_id`,`ip_address`),
  CONSTRAINT `email_sending_ip_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_sending_ip`
--

LOCK TABLES `email_sending_ip` WRITE;
/*!40000 ALTER TABLE `email_sending_ip` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_sending_ip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `engineer_whitelist`
--

DROP TABLE IF EXISTS `engineer_whitelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `engineer_whitelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `expires` datetime DEFAULT NULL,
  `status_jumpbox` int(11) DEFAULT '0',
  `status_test` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `engineer_whitelist_FI_1` (`created_by`),
  CONSTRAINT `engineer_whitelist_FK_1` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `engineer_whitelist`
--

LOCK TABLES `engineer_whitelist` WRITE;
/*!40000 ALTER TABLE `engineer_whitelist` DISABLE KEYS */;
/*!40000 ALTER TABLE `engineer_whitelist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_account`
--

DROP TABLE IF EXISTS `global_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sfdc_org_id` int(11) DEFAULT NULL,
  `sfdc_connector_username` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_ip_id` int(11) DEFAULT NULL,
  `company` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tracker_domain` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `timezone` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `encryption_key` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `new_encryption_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shard_id` int(11) DEFAULT '1',
  `type` int(11) DEFAULT NULL,
  `training_type` int(11) DEFAULT '0',
  `advocate_user_id` int(11) DEFAULT NULL,
  `is_billing_overdue` int(11) DEFAULT '0',
  `is_disabled` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `archived_at` datetime DEFAULT NULL,
  `prevent_deletion` int(11) DEFAULT '0',
  `scheduled_to_be_deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `global_account_sfdc_connector_username_unique` (`sfdc_connector_username`),
  KEY `global_account_FI_1` (`sfdc_org_id`),
  KEY `global_account_FI_2` (`email_ip_id`),
  KEY `global_account_FI_3` (`created_by`),
  KEY `global_account_FI_4` (`updated_by`),
  CONSTRAINT `global_account_FK_1` FOREIGN KEY (`sfdc_org_id`) REFERENCES `sfdc_org` (`id`),
  CONSTRAINT `global_account_FK_2` FOREIGN KEY (`email_ip_id`) REFERENCES `email_ip` (`id`),
  CONSTRAINT `global_account_FK_3` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`),
  CONSTRAINT `global_account_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_account`
--

LOCK TABLES `global_account` WRITE;
/*!40000 ALTER TABLE `global_account` DISABLE KEYS */;
INSERT INTO `global_account` VALUES (1,NULL,NULL,NULL,'Solaris Panels','http://www.solaris-panels.com/','http://go.localhost.com','America/New_York','821b5bcbd5247e9f2e1c458a259474fa','$1:0KkXcZfyznPf1/bMejwzzXjOZWWFVS9LRP6D2W+rnOc=:t3MK4elrXoit7tTCWzP+WF0UDkiIredIZxhu5hU/zP0=',1,5,0,NULL,0,0,0,NULL,NULL,'2007-08-15 09:42:51','2007-08-15 09:42:51',NULL,0,NULL),(2,NULL,NULL,NULL,'Eastern Cloud Software','http://www.ecsoftware.com/','http://go.localhost.com','America/New_York','a26d949fa140f486140bd76c7c2b2075','$1:obNEVAXo/pdIs/FltcN4g5pFuMqJ2/wtFmYLswsU0O8=:5Uvvpw792R4Izr7/8mHGdovnZOLUBkkyThg9Y4v5tuA=',2,5,0,NULL,0,0,0,NULL,NULL,'2016-03-24 16:07:13','2016-03-24 16:07:14',NULL,0,NULL);
/*!40000 ALTER TABLE `global_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_account_access`
--

DROP TABLE IF EXISTS `global_account_access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_account_access` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `role` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_role_expires_at` (`role`,`expires_at`),
  KEY `global_account_access_FI_1` (`account_id`),
  KEY `global_account_access_FI_2` (`created_by`),
  CONSTRAINT `global_account_access_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`),
  CONSTRAINT `global_account_access_FK_2` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_account_access`
--

LOCK TABLES `global_account_access` WRITE;
/*!40000 ALTER TABLE `global_account_access` DISABLE KEYS */;
INSERT INTO `global_account_access` VALUES (1,1,7,1,'2007-08-15 09:42:51',NULL),(2,2,7,1,'2007-08-15 09:42:51',NULL);
/*!40000 ALTER TABLE `global_account_access` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_account_benchmark_stats`
--

DROP TABLE IF EXISTS `global_account_benchmark_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_account_benchmark_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `stats_date` date NOT NULL,
  `logins` int(11) DEFAULT '0',
  `admin_logins` int(11) DEFAULT '0',
  `sales_logins` int(11) DEFAULT '0',
  `emails_sent` int(11) DEFAULT '0',
  `list_emails_sent` int(11) DEFAULT '0',
  `plugin_emails_sent` int(11) DEFAULT '0',
  `prospects_created` int(11) DEFAULT '0',
  `prospects_never_active` int(11) DEFAULT '0',
  `visitors_created` int(11) DEFAULT '0',
  `visitors_to_delete` int(11) DEFAULT '0',
  `content_updated` int(11) DEFAULT '0',
  `content_created` int(11) DEFAULT '0',
  `score` int(11) DEFAULT '0',
  `percentile` int(11) DEFAULT '0',
  `api_calls` int(11) DEFAULT '0',
  `active_prospects` int(11) DEFAULT '0',
  `active_prospects_score` int(11) DEFAULT '0',
  `prospects_from_conversions` int(11) DEFAULT '0',
  `prospect_page_views` int(11) DEFAULT '0',
  `webinars` int(11) DEFAULT '0',
  `webinar_signups` int(11) DEFAULT '0',
  `webinar_attendees` int(11) DEFAULT '0',
  `landing_page_views` int(11) DEFAULT '0',
  `landing_page_errors` int(11) DEFAULT '0',
  `landing_page_successes` int(11) DEFAULT '0',
  `social_posts` int(11) DEFAULT '0',
  `social_post_clicks` int(11) DEFAULT '0',
  `email_opens` int(11) DEFAULT '0',
  `email_clicks` int(11) DEFAULT '0',
  `email_soft_bounces` int(11) DEFAULT '0',
  `email_hard_bounces` int(11) DEFAULT '0',
  `email_abuse_complaints` int(11) DEFAULT '0',
  `email_unsubscribes` int(11) DEFAULT '0',
  `opportunities_created` int(11) DEFAULT '0',
  `prospect_days_to_opportunity` int(11) DEFAULT '0',
  `prospect_days_to_close` int(11) DEFAULT '0',
  `index_visitors` int(11) DEFAULT '0',
  `index_visits` int(11) DEFAULT '0',
  `index_visitor_activities` int(11) DEFAULT '0',
  `index_visitor_page_views` int(11) DEFAULT '0',
  `index_visitor_referrers` int(11) DEFAULT '0',
  `index_prospects` int(11) DEFAULT '0',
  `job_drip_program_runs` int(11) DEFAULT '0',
  `job_drip_program_time` int(11) DEFAULT '0',
  `job_segmentation_runs` int(11) DEFAULT '0',
  `job_segmentation_time` int(11) DEFAULT '0',
  `job_automation_runs` int(11) DEFAULT '0',
  `job_automation_time` int(11) DEFAULT '0',
  `job_dynamic_list_runs` int(11) DEFAULT '0',
  `job_dynamic_list_time` int(11) DEFAULT '0',
  `job_import_runs` int(11) DEFAULT '0',
  `job_import_time` int(11) DEFAULT '0',
  `job_export_runs` int(11) DEFAULT '0',
  `job_export_time` int(11) DEFAULT '0',
  `job_crm_sync_runs` int(11) DEFAULT '0',
  `job_crm_sync_time` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `global_account_benchmark_stats_lookup` (`account_id`,`stats_date`),
  CONSTRAINT `global_account_benchmark_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_account_benchmark_stats`
--

LOCK TABLES `global_account_benchmark_stats` WRITE;
/*!40000 ALTER TABLE `global_account_benchmark_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_account_benchmark_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_account_domain`
--

DROP TABLE IF EXISTS `global_account_domain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_account_domain` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `domain_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `spf_verified` int(11) DEFAULT '0',
  `dk1_verified` int(11) DEFAULT '0',
  `dk2_verified` int(11) DEFAULT '0',
  `dkim_enabled_on` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `global_account_domain` (`account_id`,`domain_name`),
  KEY `ix_account_id_dkim_enabled_on` (`account_id`,`dkim_enabled_on`),
  CONSTRAINT `global_account_domain_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_account_domain`
--

LOCK TABLES `global_account_domain` WRITE;
/*!40000 ALTER TABLE `global_account_domain` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_account_domain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_account_domainkey`
--

DROP TABLE IF EXISTS `global_account_domainkey`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_account_domainkey` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `key_name` varchar(50) COLLATE utf8_unicode_ci DEFAULT 'pardot',
  `private_key` text COLLATE utf8_unicode_ci,
  `public_key` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `global_account_domainkey_account_id` (`account_id`),
  CONSTRAINT `global_account_domainkey_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_account_domainkey`
--

LOCK TABLES `global_account_domainkey` WRITE;
/*!40000 ALTER TABLE `global_account_domainkey` DISABLE KEYS */;
INSERT INTO `global_account_domainkey` VALUES (1,1,'pardot','-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCsyhcFs0APSmi5\nEXDK6EbS44rt1Hbvon+TY9v0m3OGYgNuNIpeq4BB5kAs4awnpNa1To9XFMrt0Ajp\nHXl8kR+IhQltAd/pLHhcQ0PqgyB24nyARSU/gMLKPDNWWhYittc5LlcEir4+rIuS\noYk+KvhUZNse9mlrZWyDWWYPd4IAaJABm6s7Kx5xzbOKwgLy4Kd6OeC5D/YmFc9l\nYsJqB1S95CUGVRWPeb2XPd8rCyQJ3t69nq7HG3+OSm/pEmHfvvE8ESZEzgQFYRrd\n2nJDJ2mkqg8zIKsy4x52btmrKaasgSv76ajhY28E/9Amu+76n2mfWwNwnwas5dpR\nvrROFNHtAgMBAAECggEBAKCfNAuOd8w/BV6Ugd99UOkVsL4pNW7KBgIDYCLgpuGT\nF1FI8h/TGWUpHxsZpaksqJLeNo1ivMmZC894IMjVNxT3Zq24gmcFedV6ihXkUzdw\njv/GRzvi/DB3CdoJ4G3gve1f0HBecT9dsllaZHQwCayaHL+JnLHDFL59SkyycVzi\nTwjkYYkyv5S7AyI7eh998Ca6uf5hVrB+FMGZ/fJWklI3JJAodYQ2qVH9M6RccGnd\nDuHqWjEMmVvXcnQ6Ue7E8+3ApPZEtrtBwMznH4MV8UsYsb+vdr8CwDlRpO3jtkUq\n8x/1Xc3Gd4yj26gOhOs25xbtwVH4HXVeD2FiM4oiblkCgYEA3ReZg7L5oRVZF5+F\n3erll6qIvJJ0sFWzEr7iwSEoO22val6Ix6Id7CaYlGudUTrthcJE12o59WVwnBJT\nlj2wfVsKLwG6XcfDbWAkcZhdZTgZm9te97Oaqg5A8grj0hjujCBU8Nf/FwEsXwJr\n29mJ2dUBCbcM1SkzsF547aYj4MMCgYEAyBIfwrVuj0XNwLt/H+I8u8zbJpVXyn3c\nmc7WRHuwfrCSFoZLb5mVwApl6uQ0lEv3OA78gP7X3WBBnjRl+IyBH/f33nLyyOh4\nlvtcv5WP/Bl9KM3wjX3QfPZNmI+45DaENcSRdYVpVJCIB6lGVIX6Lfdk9W53F6G3\nvbk1tAw4V48CgYAEhv0vwzR1ZfiDEVMubibxah6OrfkRu0+FbL878S/ft6lF5lWq\nsNkoAspRD7sS9L/0YzwBpT02lzMtHvrzMqQwjPKyb7ifPv3zeWqFoPcYoYN0u5NA\nQz9BiDUwP6TWoogP+oGCxQmGMRH1iBkpUVUPTttMlaD/pG5YiDa1txc4/QKBgQCz\nqCLBE27+VO5YHYYgOWXUNjasxPqaqL7JlwStZmystx3YACwJQN9KHYw7i0Tzzetn\neX2g0DdDYUZLLD5NHM5uyJraNFpzst1mpr04hLNQ7AqJ87QJOmtXa01uq9CZjaLX\nLXZ5E53sBAVC6+xtxglL8ZXFFrb2j4+RXJku3rJRXQKBgQC45BndQIRWDZLaG1Gd\nu4iDuoF9B8/tGJsvRaRow6/9R//juatBgp0JPFAnvyzVlN44yl2KyvWxx6JCZLqw\npXg6yQRX37r93qCXNFEk/BwTl29JVSk/5MxBXE4MG0urYBlD9jttJSjxJ4n/d08T\nFqgZ73RejfniDiy7XeIyliynKA==\n-----END PRIVATE KEY-----\n','-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArMoXBbNAD0pouRFwyuhG\n0uOK7dR276J/k2Pb9JtzhmIDbjSKXquAQeZALOGsJ6TWtU6PVxTK7dAI6R15fJEf\niIUJbQHf6Sx4XEND6oMgduJ8gEUlP4DCyjwzVloWIrbXOS5XBIq+PqyLkqGJPir4\nVGTbHvZpa2Vsg1lmD3eCAGiQAZurOysecc2zisIC8uCnejnguQ/2JhXPZWLCagdU\nveQlBlUVj3m9lz3fKwskCd7evZ6uxxt/jkpv6RJh377xPBEmRM4EBWEa3dpyQydp\npKoPMyCrMuMedm7ZqymmrIEr++mo4WNvBP/QJrvu+p9pn1sDcJ8GrOXaUb60ThTR\n7QIDAQAB\n-----END PUBLIC KEY-----\n'),(2,2,'pardot','-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCvS8WCmgxPbWVM\nIo89mxLOdi3e8c1huRe2DTdw2g4b7kOw0ti2ap98mFJy4gq7jllUi7BCdcSgJjqV\nhdLfuWEiXBnT6OEy/CA7DX+9M3QSvvC+3UCvBZ9M8qb0MP07b9GWdGK4qE9l5Cjl\nHCub2XMsxifKlmRgOCRM25BMHgSXyxSGS4Ijy6iSP0s6lgTdmVqJaM8LAXh4Czut\n9K4J/hh2VkaL7OrSUw3FIarc0yrrVzk5hxk45ZKH1gecKJkIFK6w+0oYcVmMp1SL\nBfUNbJnL2bo4gI/uziEGVqf72ORgxW5MAZ+cXRmgDmFhMbgJhw/3vk/TdupuNqzS\nbWweDtIbAgMBAAECggEAJ9v830OUBQOFAxjgpUt7rUKmD4m//7aMs7KxppGOn78/\n2Rc4e9Imzbf9F25armch3N2eiJ4qxZervpAdcQ3ADoYOwWa0vlkiIwtgvm7St+h+\n6Yd5y9JldKPAXso86qT0bVetkvuCglKtEduj9t4tGEM+jQxBareZWXibiRNSTAlb\nHEn+4GjzfRXG9iGxxdehfAucoe+Zeo1u9lokUW9Vi2lEx5XD2eKxA1SCfXIBiHI2\nxjGh7zuYGaK5qWJDgBYcChmnA84U+K9SOMEnlNPRxsxJLcFCHFSSZ5S6mxs+nOiE\n0KB4BtriFEnZJk1cggk8Fr95sHWaullg43yDu4vGsQKBgQDVEhiFz6CWGm2EqTaM\n0PKNODVAipHxq19fKnX0wBzjCaAWiDz2pdwwXt/3fWf71qiMqcClrcEKiPpfIIBr\nR29FpGgkf8m3GUxSXUG5rYYA6avBIa73LYd9cB8f2BvarqVgF3LU9Vxt0ZCri02l\nuhpf/IYL/ecYeDA60RnLkfEzLQKBgQDSnU5zrkqu3TjQXIT0d4yHpSctGueDmgMj\nd1kFkffnAeEY4H7dvnnFEuDiKzh9RXmJM0+1ZH+Od9FUGTBS0Y6PbFXVWIY5twBB\nBJUNiqb0x7BK5PVDLUAzk+U93GE9F6rdo1by7mq3tWk+IV3AwVM55NNzoIaF7ZJC\npTB1SjEHZwKBgEpx4iOOobsQTMeXH7ofnz98Lg7423kmuVHU0hXLscwZptd4jmRX\nGxHDdFlSdaxmGcnb3bWFefcmWOQ3xOa2tMgOY1ytUVsp+aKldrtbR4C2JA58qFcw\njzBipl1H8qN7dciXKMYDXGH6YKOvLlgDKAf1gRhbhAzmoWNLf8nCmhWZAoGBAJEf\nf31KbX+MQ6ee+KYS8ixNam80CK6votX/WMHz0KPGsboYhpJ4uyNGXNq6+VOoWZRm\nXNgahaI/gWe3a4rFhrvg5Ev7kZGXPX+Pjr0j+uLT7e/NUAqX1ZM0p1M21XHpKv1J\nnZILIlGvmPMMvrMhAx3zRJh51ffWuV9ev8Mx+hKlAoGBANJwULiqz/EcdUF6GLYA\n/0dfjsMYtPRxHKUHu8/R6jnOsyZbXDKinIykk4LzY/iNkmbdxV8n9GjhgST2pBbd\navrRwAA93oETCEHXo4f15CMyHgGdQEgXhzjQcA9bCxZpqI1o1IOiKeh9oKhSCaUT\nMD88QW5YRnAVEetNrFwe73d9\n-----END PRIVATE KEY-----\n','-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAr0vFgpoMT21lTCKPPZsS\nznYt3vHNYbkXtg03cNoOG+5DsNLYtmqffJhScuIKu45ZVIuwQnXEoCY6lYXS37lh\nIlwZ0+jhMvwgOw1/vTN0Er7wvt1ArwWfTPKm9DD9O2/RlnRiuKhPZeQo5Rwrm9lz\nLMYnypZkYDgkTNuQTB4El8sUhkuCI8uokj9LOpYE3ZlaiWjPCwF4eAs7rfSuCf4Y\ndlZGi+zq0lMNxSGq3NMq61c5OYcZOOWSh9YHnCiZCBSusPtKGHFZjKdUiwX1DWyZ\ny9m6OICP7s4hBlan+9jkYMVuTAGfnF0ZoA5hYTG4CYcP975P03bqbjas0m1sHg7S\nGwIDAQAB\n-----END PUBLIC KEY-----\n');
/*!40000 ALTER TABLE `global_account_domainkey` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_account_stats`
--

DROP TABLE IF EXISTS `global_account_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_account_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `stats_date` date NOT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `logins` int(11) DEFAULT '0',
  `admin_logins` int(11) DEFAULT '0',
  `sales_logins` int(11) DEFAULT '0',
  `emails_sent` int(11) DEFAULT '0',
  `list_emails_sent` int(11) DEFAULT '0',
  `plugin_emails_sent` int(11) DEFAULT '0',
  `prospects_created` int(11) DEFAULT '0',
  `prospects_never_active` int(11) DEFAULT '0',
  `visitors_created` int(11) DEFAULT '0',
  `visitor_activities` int(11) DEFAULT '0',
  `visitor_page_views` int(11) DEFAULT '0',
  `prospect_activities` int(11) DEFAULT '0',
  `prospect_visitors` int(11) DEFAULT '0',
  `visitors_to_delete` int(11) DEFAULT '0',
  `content_updated` int(11) DEFAULT '0',
  `content_created` int(11) DEFAULT '0',
  `total_users` int(11) DEFAULT '0',
  `user_feedback_score` int(11) DEFAULT '0',
  `user_feedback_entries` int(11) DEFAULT '0',
  `user_feedback_promoters` int(11) DEFAULT '0',
  `user_feedback_detractors` int(11) DEFAULT '0',
  `crm_connector` int(11) DEFAULT '0',
  `active_connectors` int(11) DEFAULT '0',
  `score` int(11) DEFAULT '0',
  `percentile` float DEFAULT '0',
  `api_calls` int(11) DEFAULT '0',
  `active_prospects` int(11) DEFAULT '0',
  `active_prospects_score` int(11) DEFAULT '0',
  `prospects_from_conversions` int(11) DEFAULT '0',
  `prospect_page_views` int(11) DEFAULT '0',
  `webinars` int(11) DEFAULT '0',
  `webinar_signups` int(11) DEFAULT '0',
  `webinar_attendees` int(11) DEFAULT '0',
  `landing_page_views` int(11) DEFAULT '0',
  `landing_page_errors` int(11) DEFAULT '0',
  `landing_page_successes` int(11) DEFAULT '0',
  `social_posts` int(11) DEFAULT '0',
  `social_post_clicks` int(11) DEFAULT '0',
  `email_opens` int(11) DEFAULT '0',
  `email_clicks` int(11) DEFAULT '0',
  `email_soft_bounces` int(11) DEFAULT '0',
  `email_hard_bounces` int(11) DEFAULT '0',
  `email_abuse_complaints` int(11) DEFAULT '0',
  `email_unsubscribes` int(11) DEFAULT '0',
  `opportunities_created` int(11) DEFAULT '0',
  `prospect_days_to_opportunity` int(11) DEFAULT '0',
  `prospect_days_to_close` int(11) DEFAULT '0',
  `job_drip_program_runs` int(11) DEFAULT '0',
  `job_drip_program_time` int(11) DEFAULT '0',
  `job_segmentation_runs` int(11) DEFAULT '0',
  `job_segmentation_time` int(11) DEFAULT '0',
  `job_automation_runs` int(11) DEFAULT '0',
  `job_automation_time` int(11) DEFAULT '0',
  `job_realtime_automation_runs` int(11) DEFAULT '0',
  `job_realtime_automation_time` int(11) DEFAULT '0',
  `job_dynamic_list_runs` int(11) DEFAULT '0',
  `job_dynamic_list_time` int(11) DEFAULT '0',
  `job_import_runs` int(11) DEFAULT '0',
  `job_import_time` int(11) DEFAULT '0',
  `job_export_runs` int(11) DEFAULT '0',
  `job_export_time` int(11) DEFAULT '0',
  `job_crm_sync_runs` int(11) DEFAULT '0',
  `job_crm_sync_time` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `global_account_stats_lookup` (`account_id`,`stats_date`),
  KEY `ix_last_login_at` (`last_login_at`),
  CONSTRAINT `global_account_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_account_stats`
--

LOCK TABLES `global_account_stats` WRITE;
/*!40000 ALTER TABLE `global_account_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_account_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_agency`
--

DROP TABLE IF EXISTS `global_agency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_agency` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `global_agency_account_id_unique` (`account_id`),
  KEY `global_agency_FI_2` (`created_by`),
  KEY `global_agency_FI_3` (`updated_by`),
  CONSTRAINT `global_agency_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`),
  CONSTRAINT `global_agency_FK_2` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`),
  CONSTRAINT `global_agency_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_agency`
--

LOCK TABLES `global_agency` WRITE;
/*!40000 ALTER TABLE `global_agency` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_agency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_agency_account`
--

DROP TABLE IF EXISTS `global_agency_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_agency_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `global_agency_id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `global_agency_account_account_id_unique` (`account_id`),
  KEY `global_agency_account_FI_1` (`global_agency_id`),
  KEY `global_agency_account_FI_3` (`created_by`),
  KEY `global_agency_account_FI_4` (`updated_by`),
  CONSTRAINT `global_agency_account_FK_1` FOREIGN KEY (`global_agency_id`) REFERENCES `global_agency` (`id`),
  CONSTRAINT `global_agency_account_FK_2` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`),
  CONSTRAINT `global_agency_account_FK_3` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`),
  CONSTRAINT `global_agency_account_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_agency_account`
--

LOCK TABLES `global_agency_account` WRITE;
/*!40000 ALTER TABLE `global_agency_account` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_agency_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_agency_agency`
--

DROP TABLE IF EXISTS `global_agency_agency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_agency_agency` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `global_agency_id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `global_agency_agency_child_id_unique` (`child_id`),
  KEY `global_agency_agency_FI_1` (`global_agency_id`),
  KEY `global_agency_agency_FI_3` (`created_by`),
  KEY `global_agency_agency_FI_4` (`updated_by`),
  CONSTRAINT `global_agency_agency_FK_1` FOREIGN KEY (`global_agency_id`) REFERENCES `global_agency` (`id`),
  CONSTRAINT `global_agency_agency_FK_2` FOREIGN KEY (`child_id`) REFERENCES `global_agency` (`id`),
  CONSTRAINT `global_agency_agency_FK_3` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`),
  CONSTRAINT `global_agency_agency_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_agency_agency`
--

LOCK TABLES `global_agency_agency` WRITE;
/*!40000 ALTER TABLE `global_agency_agency` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_agency_agency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_email_layout`
--

DROP TABLE IF EXISTS `global_email_layout`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_email_layout` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `html_message` text COLLATE utf8_unicode_ci,
  `global_thumbnail_id` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `is_hidden` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `global_email_layout_FI_1` (`global_thumbnail_id`),
  KEY `global_email_layout_FI_2` (`created_by`),
  KEY `global_email_layout_FI_3` (`updated_by`),
  CONSTRAINT `global_email_layout_FK_1` FOREIGN KEY (`global_thumbnail_id`) REFERENCES `global_thumbnail` (`id`),
  CONSTRAINT `global_email_layout_FK_2` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`),
  CONSTRAINT `global_email_layout_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_email_layout`
--

LOCK TABLES `global_email_layout` WRITE;
/*!40000 ALTER TABLE `global_email_layout` DISABLE KEYS */;
INSERT INTO `global_email_layout` VALUES (1,'Two Column','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html;\" />\n    <title>\n      Email Newsletter\n    </title>\n  </head>\n  <body bgcolor=\"#CCCCCC\">\n<table style=\"width: 620px; color: #333333; font-family: arial,verdana,sans-serif;\" align=\"center\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n<tbody>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td>\n<p><br /> <span style=\"color: #508f07; font-size: 13px;\"><b>Value Statement - Include a compelling sentence here to get the audience to read more!</b></span></p>\n<p><span style=\"font-size: 13px;\"><span style=\"color: #000000;\">If you are having trouble reading Example.com\'s newsletter view the <a href=\"%%view_online%%\" style=\"text-decoration: none\"><span style=\"color: #508f07;\">Web Version.</span></a></span></span></p>\n</td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" bgcolor=\"#ebebeb\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td><a href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-03/DJY0S/21494_Email9Logo.png\" alt=\"Example.com Logo and Possible Tag Line Description or Newsletter Title\" style=\"border: none;\" /></a></td>\n<td>\n<h1><span style=\"font-size: 18px;\"><span style=\"font-family: Times,Palatino;\">Your Monthly Newsletter Title Here</span></span></h1>\n</td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td width=\"70%\"><a href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-03/DJY2G/21504_Email9Banner.png\" alt=\"Multi-Column Banner Description goes here!\" style=\"border: none;\" /></a></td>\n<td valign=\"top\">\n<h2><span style=\"font-size: 18px;\"><span style=\"font-family: Times,Palatino;\">In This Issue:</span></span></h2>\n<span style=\"font-size: 13px;\"><b><a href=\"#Section1\" style=\"text-decoration: none\"><span style=\"color: #508F07;\">Section 1:</span></a></b> This is a brief description of the first section\'s contents.<br /> <br /> <b><a href=\"#Section2\" style=\"text-decoration: none\"><span style=\"color: #508F07\">Section 2:</span></a></b> This is a brief description of the second section\'s contents.<br /> <br /> <b><a href=\"#Section3\" style=\"text-decoration: none\"><span style=\"color: #508F07\">Section 3:</span></a></b> This is a brief description of the third section\'s contents.</span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td valign=\"top\" width=\"55%\">\n<h3><span style=\"font-size: 18px;\"><span style=\"font-family: times,serif;\"><a name=\"Section1\" id=\"Section1\">Section 1</a></span></span></h3>\n<span style=\"font-size: 13px;\">This is the first section of your newsletter. Here, you can begin drawing in the prospect\'s interest with the key selling points for your product:</span> <ol>\n<li> <span style=\"font-size: 13px;\">Here you talk about your latest features.</span> </li>\n<li> <span style=\"font-size: 13px;\">Here you talk about client testimonials.<br /></span> </li>\n<li> <span style=\"font-size: 13px;\">Here you talk about customer support.</span> </li>\n</ol><span style=\"font-size: 13px;\"><a href=\"#\" style=\"text-decoration: none\"><span style=\"color: #508F07\">Read Full Article</span></a></span></td>\n<td><a href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-03/DJY2Q/21514_Email9Image0.png\" alt=\"We\'re here to help.\" title=\"Describe the image contents here!\" border=\"0\" /></a></td>\n</tr>\n<tr>\n<td valign=\"top\"><a href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-03/DJY3K/21524_Email9Image1.png\" alt=\"Sign up Today!\" title=\"Describe the image contents here!\" border=\"0\" /></a></td>\n<td>\n<h3><span style=\"font-size: 18px;\"><span style=\"font-family: times,serif;\"><a name=\"Section2\" id=\"Section2\">Section 2</a></span></span></h3>\n<span style=\"font-size: 13px;\">This is the second section of your newsletter. Here, you focus on the newest features in your product. Make prospects understand that you are continually upgrading your product for clients, and make existing clients feel better about having their ongoing relationship with you.<br /> <br /> <a href=\"#\" style=\"text-decoration: none\"><span style=\"color: #508F07\">Read Full Article</span></a></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" bgcolor=\"#aad46f\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td colspan=\"2\">\n<h2><span style=\"font-family: times,serif;\"><span style=\"font-size: 18px;\"><a name=\"Section3\" id=\"Section3\">Section 3</a></span></span></h2>\n</td>\n</tr>\n<tr>\n<td style=\"width: 65%;\"><br /> <span style=\"font-size: 13px;\">This is the third section of your newsletter. Here, you can begin talking about the bottom line--pricing. Show your prospects that you really do have a superior product, at a lower price, than the competition.<br /> <br /> Encourage them to talk to a representative from your company, if they have any questions or concerns.</span><br /> <br /></td>\n<td><a href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-03/DJY3U/21534_Email9Image2.png\" alt=\"We\'re here to help.\" title=\"Describe the image contents here!\" border=\"0\" /></a><br /> <br /></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td>\n<h3><span style=\"font-size: 14px\">Email Admin Center</span></h3>\n<span style=\"font-size: 12px\">This newsletter is a service of example.com. Should you no longer wish to receive these messages please go <a href=\"%%unsubscribe%%\" style=\"text-decoration: none\"><span style=\"color: #508F07\">here</span></a> to unsubscribe or send an email to: <a href=\"mailto:unsubscribe@company.com\" style=\"text-decoration: none;\"><span style=\"color: #508f07;\">unsubscribe@company.com</span></a><br /> <br /> To ensure delivery of this newsletter to your inbox and to enable images to load in future mailings, please add admincenter@example.com to your e-mail address book or safe senders list.<br /> <br /> %%account_address%%<br /> <br /> To view our Privacy Policy click <a href=\"#\" style=\"text-decoration: none\"><span style=\"color: #508F07\">here.</span></a></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n</tbody>\n</table>\n</body>\n</html>\n',NULL,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(2,'Three Column','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html;\" />\n    <title>\n      Email Newsletter\n    </title>\n  </head>\n  <body bgcolor=\"#FFFFFF\">\n<table style=\"width: 620px; font-family: arial,verdana,sans-serif; color: #333333;\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n<tbody>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td><span style=\"font-size: 13px;\"><span style=\"color: #91268f;\">Value Statement - Include a compelling sentence here to get your audience to read more!</span><br /> If you are having trouble reading Example.com\'s newsletter view the <a style=\"text-decoration: none;\" href=\"%%view_online%%\"><span style=\"color: #0066cc;\">Web Version.</span></a></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"5\" cellspacing=\"0\">\n<tbody>\n<tr>\n<td><a href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-03/DJZYI/21544_Email8Logo.png\" alt=\"Example.com Template Banner\" title=\"Example.com Banner Title goes here with banner copy, including Title of Newsletter\" border=\"0\" /></a></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"0\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td colspan=\"2\" align=\"center\"><span style=\"font-size: 13px;\"><b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Subscribe</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Back Issues</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Article Archive</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Resource Center</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Request Demo</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">yoursite.com</span></a></b></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"10\" cellspacing=\"5\">\n<tbody>\n<tr>\n<td valign=\"top\" width=\"33%\"><a href=\"#\"><img style=\"border: 0pt none;\" title=\"Latest News\" src=\"http://www2.pardot.com/l/1/2009-06-03/DJZYS/21554_Email8Image0.png\" alt=\"Latest News Icon\" /></a>\n<h2><span style=\"font-size: 13px;\">Latest News</span></h2>\n<p><span style=\"font-size: 13px;\">This is where the latest news from your company goes. Insert a loose summary here, and then include links to the full article for them to read online. All links are re-written as tracked links, so you will know which news entries your prospects care about most.</span></p>\n<p><span style=\"font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Click Here to Read More!</span></a><br /></span></p>\n</td>\n<td valign=\"top\" width=\"33%\"><a href=\"#\"><img style=\"border: 0pt none;\" title=\"Featured Product\" src=\"http://www2.pardot.com/l/1/2009-06-03/DJZZ2/21564_Email8Image1.png\" alt=\"Featured Product Icon\" /></a>\n<h2><span style=\"font-size: 13px;\">Featured Product</span></h2>\n<p><span style=\"font-size: 13px;\">This is where the feature product information goes. Your featured product is at the center of the stage, to grab the attention of your audience. If you want to know how interested your prospects are, you should have them</span></p>\n<p><span style=\"font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Check out the Sale Price!</span></a></span></p>\n</td>\n<td valign=\"top\"><a href=\"#\"><img style=\"border: 0pt none;\" title=\"New Features\" src=\"http://www2.pardot.com/l/1/2009-06-03/DJZZC/21574_Email8Image2.png\" alt=\"New Features Icon\" /></a>\n<h2 style=\"font-size: 13px;\">New Features</h2>\n<p><span style=\"font-size: 13px;\">This is where you can describe new features for your existing product. Make prospects understand that you are continually upgrading your product for clients, and make existing clients feel better about having their ongoing relationship with you.</span></p>\n<p><span style=\"font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Click Here To Read More!</span></a></span></p>\n</td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"10\" cellspacing=\"5\">\n<tbody>\n<tr>\n<td colspan=\"2\">\n<h1><span style=\"font-size: 15px;\">Testimonial</span></h1>\n<p><br /> <span style=\"font-size: 13px;\">This is where you can have a client testimonial for your product. By having a testimonial or case study, you directly show your prospects what your product can do for them. In addition, the company whose testimonial you use now feels like more a contributor for your company. Make prospects understand that you are continually upgrading your product for clients, and make existing clients feel better about having their ongoing relationship with you.</span></p>\n<p><span style=\"font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Read Full Article</span></a> | <a style=\"text-decoration: none;\" href=\"mailto:address@email.com\"><span style=\"color: #0066cc\">Email Feedback</span></a></span></p>\n</td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 650px;\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"5\" cellspacing=\"5\">\n<tbody>\n<tr>\n<td colspan=\"2\">\n<h1><span style=\"font-size: 14px;\">Email Admin Center</span></h1>\n<span style=\"font-size: 12px;\">This newsletter is a service of Example.com. Should you no longer wish to receive these messages please go <a style=\"text-decoration: none;\" href=\"%%unsubscribe%%\"><span style=\"color: #0066cc\">here</span></a> to unsubscribe or send an email to: <a style=\"text-decoration: none;\" href=\"mailto:unsubscribe@company.com\"><span style=\"color: #0066cc\">unsubscribe@company.com</span></a><br /> <br /> To ensure delivery of this newsletter to your inbox and to enable images to load in future mailings, please add admincenter@example.com to your e-mail address book or safe senders list.<br /> <br /> %%account_address%%<br /></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n</tbody>\n</table>\n</body>\n</html>\n',NULL,0,0,NULL,NULL,'2007-08-29 10:42:51','2007-08-29 10:42:51'),(3,'Left Sidebar','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html;\" />\n    <title>\n      Email Newsletter\n    </title>\n  </head>\n  <body bgcolor=\"#EBF1FC\">\n<table style=\"width: 620px; font-family: arial,verdana,sans-serif; color: #333333;\" align=\"center\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n<tbody>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td><span style=\"font-size: 13px;\">Value Statement - Include a compelling sentence here to get your audience to read more!<br /> If you are having trouble reading Example.com\'s newsletter view the <a style=\"color: #0066cc\" href=\"%%view_online%%\">Web Version.</a></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellpadding=\"5\">\n<tbody>\n<tr>\n<td align=\"center\"><a style=\"color: #0066cc\" href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-08/DZL4G/22524_Email5Logo.png\" alt=\"Example.com Template Banner\" title=\"Title of Newsletter\" border=\"0\" /></a></td>\n</tr>\n<tr>\n<td align=\"center\" bgcolor=\"#f0f0f0\"><span style=\"font-size: 13px;\"><a style=\"color: #0066cc\" href=\"#\">Back Issues</a> | <a style=\"color: #0066cc\" href=\"#\">Article Archive</a> | <a style=\"color: #0066cc\" href=\"#\">Resource Center</a> | <a style=\"color: #0066cc\" href=\"#\">Request Demo</a> | <a style=\"color: #0066cc\" href=\"#\">yoursite.com</a></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellpadding=\"20\" cellspacing=\"5\">\n<tbody>\n<tr>\n<td bgcolor=\"#f0f0f0\" valign=\"top\">\n<h2><span style=\"font-size: 17px; color: #2051ab;\">In This Issue:</span></h2>\n<span style=\"font-size: 13px;\"><a style=\"color: #0066cc;\" href=\"#Section1\">Section 1:</a></span> <span style=\"font-size: 13px;\">This is a brief description of the first section\'s contents</span><span style=\"font-size: 13px;\">.</span><br /> <span style=\"font-size: 13px;\"><br /> <a style=\"color: #0066cc;\" href=\"#Section2\">Section 2:</a></span> <span style=\"font-size: 13px;\">This is a brief description of the second section\'s contents</span><span style=\"font-size: 13px;\">.</span><br /> <span style=\"font-size: 13px;\"><br /> <a style=\"color: #0066cc;\" href=\"#Section3\">Section 3:</a></span> <span style=\"font-size: 13px;\">This is a brief description of the third section\'s contents</span><span style=\"font-size: 13px;\">.</span><br /> <span style=\"font-size: 13px;\"><br /></span></td>\n<td width=\"65%\">\n<h1><a style=\"color: #0066cc\" name=\"Latest\" id=\"Latest\"></a><a name=\"Section1\" id=\"Section1\"></a>Section 1</h1>\n<span style=\"font-size: 13px;\">This is your first section. Use it to grab your prospects\' attention, to ensure that they will read the rest of the email. Here is where you talk about your extensive product feature list:</span> \n<ul>\n<li> <span style=\"font-size: 13px;\">Here is your first feature. This is a long</span> <span style=\" font-size: 13px;\">description</span> <span style=\"font-size: 13px;\">for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your second feature. This is a long</span> <span style=\" font-size: 13px;\">description</span> <span style=\"font-size: 13px;\">for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your third feature. This is a long</span> <span style=\" font-size: 13px;\">description</span> <span style=\"font-size: 13px;\">for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your fourth feature. This is a long</span> <span style=\" font-size: 13px;\">description</span> <span style=\"font-size: 13px;\">for this feature, so that your prospects will fully understands its implications</span> </li>\n</ul>\n<span style=\"font-size: 13px;\"><a style=\"color: #0066cc\" href=\"#\">Read Full Article</a></span><br /></td>\n</tr>\n<tr>\n<td>\n<h2><span style=\"font-size: 17px; color: #2051ab;\">Get our Newsletter!</span></h2>\n<span style=\"font-size: 13px;\">Sign up for more newsletters today!<br /> <br /> <a style=\"color: #0066cc;\" href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-08/DZL4Q/22534_Email5Button.png\" alt=\"Subscribe Today!\" title=\"Click here to subscribe!\" border=\"0\" /></a></span><br /> <br /></td>\n<td>\n<h1><a style=\"color: #0066cc\" name=\"Latest\" id=\"Latest\"></a><a name=\"Section2\" id=\"Section2\"></a>Section 2</h1>\n<span style=\"font-size: 13px;\">This is where the latest news from your company goes. Use this section to keep your prospects\' interest high, so that they continue reading the email, instead of skimming over it. Use a loose summary or overview of any recent major events here, and then include a link to a full article online. Links are re-written as tracked links inside of emails, so you will know which news entries your prospects care about most. With this information, you can begin providing them with emails that are customized towards their interests.<br /> <br /> <a style=\"color: #0066cc;\" href=\"#\">Read Full Article</a></span> <span style=\"font-size: 13px;\">| <a style=\"color: #0066cc;\" href=\"mailto:address@email.com\">Email Feedback</a></span><span style=\"font-size: 13px;\"><a style=\"color: #0066cc\" href=\"#\"></a></span></td>\n</tr>\n<tr>\n<td bgcolor=\"#ebf1fc\" valign=\"top\">\n<h1><span style=\"font-size: 17px; color: #2051ab;\">New Features</span></h1>\n<p><span style=\"font-size: 13px;\">This is where you can describe new features for your existing product. Make prospects understand that you are continually upgrading your product for clients, and make existing clients feel better about having their ongoing relationship with you.</span></p>\n<p><span style=\"font-size: 13px;\"><a style=\"color: #0066cc;\" href=\"#\">Click Here To Read More</a></span></p>\n</td>\n<td>\n<h1><a style=\"color: #0066cc\" name=\"Latest\" id=\"Latest\"></a><a name=\"Section3\" id=\"Section3\"></a>Section 3</h1>\n<p><span style=\"font-size: 13px;\">This is where you can have a client testimonial for your product. By having a testimonial or case study, you directly show your prospects what your product can do for them. In addition, the company whose testimonial you use now feels like more a contributor for your company. Make prospects understand that you are continually upgrading your product for clients, and make existing clients feel better about having their ongoing relationship with you.</span></p>\n<p><span style=\"font-size: 13px;\"><a style=\"color: #0066cc;\" href=\"#\">Read Full Article</a> | <a style=\"color: #0066cc;\" href=\"mailto:address@email.com\">Email Feedback</a></span><span style=\"font-size: 13px;\"><br /> <a style=\"color: #0066cc\" href=\"#\"></a></span></p>\n</td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td>\n<hr style=\"font-size: 15px;\" noshade=\"noshade\" />\n<h1><span style=\"font-size: 14px;\">Email Admin Center</span></h1>\n<span style=\"font-size: 12px;\">This newsletter is a service of example.com. Should you no longer wish to receive these messages please go <a style=\"color: #0066cc\" href=\"%%unsubscribe%%\">here</a> to unsubscribe or send an email to: <a style=\"color: #0066cc;\" href=\"mailto:unsubscribe@company.com\">unsubscribe@company.com</a><br /> <br /> To ensure delivery of this newsletter to your inbox and to enable images to load in future mailings, please add admincenter@example.com to your e-mail address book or safe senders list.<br /> <br /> You are receiving this email at yourname@example.com.<br /> <br /> <a style=\"color: #0066cc;\" href=\"#\">Update Your Profile</a> | <a style=\"color: #0066cc\" href=\"%%view_online%%\">Web Version</a> | <a style=\"color: #0066cc;\" href=\"#\">Subscribe to Newsletter Name</a><br /> <br /> %%account_address%%</span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n</tbody>\n</table>\n</body>\n</html>\n',NULL,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(4,'Blog Updates','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html;\" />\n    <title>\n      Email Newsletter\n    </title>\n  </head>\n  <body style=\"background-color: rgb(235, 235, 235);\">\n<table style=\"width: 620px; font-family: arial,verdana,sans-serif; color: #333333;\" align=\"center\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n<tbody>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellpadding=\"10\">\n<tbody>\n<tr>\n<td width=\"75%\">\n<h1><span style=\"font-family: Arial,Helvetica,sans-serif;\"><span style=\"color: #0071bc;\"><span style=\"font-size: 16px;\">In This Issue:</span></span></span></h1>\n<ul>\n<li> <span style=\"font-size: 13px;\"><a href=\"#Section1\" style=\"text-decoration: none\"><span style=\"color: #0066cc;\">Section 1:</span></a>This is a brief description of the first section\'s contents.</span> </li>\n<li> <span style=\"font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#Section2\"><span style=\"color: #0066cc\">Section 2:</span></a>This is a brief description of the second section\'s contents.</span> </li>\n<li> <span style=\"font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#Section3\"><span style=\"color: #0066cc\">Section 3:</span></a>This is a brief description of the third section\'s contents.</span> </li>\n</ul>\n</td>\n<td valign=\"top\"><a href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-02/DJGT2/21394_Email3Logo.png\" alt=\"Example.com Logo \" title=\"Example.com Logo Description\" style=\"border-style: none\" /></a></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td><span style=\"font-size: 13px;\"><a style=\"text-decoration: none\" href=\"%%view_online%%\"><span style=\"color: #0066cc\">Web Version</span></a> | <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Update Your Profile</span></a> | <a style=\"text-decoration: none;\" href=\"%%unsubscribe%%\"><span style=\"color: #0066cc\">Unsubscribe</span></a></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellpadding=\"10\">\n<tbody>\n<tr>\n<td>\n<hr size=\"5\" width=\"100%\" />\n<a href=\"#\"><img title=\"Example.com Banner Description\" src=\"http://www2.pardot.com/l/1/2009-06-02/DJGTC/21404_Email3Banner.png\" alt=\"Example.com Banner\" style=\"border-style: none\" /></a></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellpadding=\"10\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td bgcolor=\"#c4e08c\" valign=\"top\"><span style=\"font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Subscribe</span></a> | <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Back Issues</span></a> | <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Article Archive</span></a> | <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Resource Center</span></a> | <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Request Demo</span></a> | <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">yoursite.com</span></a></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellpadding=\"8\">\n<tbody>\n<tr>\n<td>\n<h1><span style=\"font-size: 18px;\"><span style=\"font-family: Arial,Helvetica,sans-serif;\"><span style=\"color: #0071bc;\"><a name=\"Section1\" id=\"Section1\"></a>Section 1</span></span></span></h1>\n<span style=\"font-size: 13px;\">This is your first section. Use it to grab your prospects\' attention, to ensure that they will read the rest of the email. Here is where you talk about your extensive product feature list:<br /> <br /></span> \n<ul>\n<li> <span style=\"font-size: 13px;\">Here is your first feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your second feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your third feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your fourth feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n</ul>\n<span style=\"font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Read Full Article</span></a> | <a style=\"text-decoration: none;\" href=\"mailto:address@email.com\"><span style=\"color: #0066cc\">Email Feedback</span></a><br /> <br /></span> \n<hr style=\"font-size: 15px;\" width=\"100%\" />\n</td>\n</tr>\n<tr>\n<td>\n<h1><span style=\"font-size: 18px;\"><span style=\"font-family: Arial,Helvetica,sans-serif;\"><span style=\"color: #0071bc;\"><a name=\"Section2\" id=\"Section2\"></a>Section 2</span></span></span></h1>\n<span style=\"font-size: 13px;\">This is the second section of your newsletter. Here, you focus on the newest features in your product. Make prospects understand that you are continually upgrading your product for clients, and make existing clients feel better about having their ongoing relationship with you.<br /> <br /> <a href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-02/DJGTM/21414_Email3Button.png\" alt=\"Sign up for a demo!\" title=\"Click here to sign up for a demo!\" style=\"border-style: none\" /></a><br /> <br /> <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Read Full Article</span></a> |<a style=\"text-decoration: none;\" href=\"mailto:address@company.com\"><span style=\"color: #0066cc\">Email Feedback</span></a></span><br /> <br /> \n<hr style=\"font-size: 15px;\" width=\"100%\" />\n</td>\n</tr>\n<tr>\n<td>\n<h1><span style=\"font-size: 18px;\"><span style=\"font-family: Arial,Helvetica,sans-serif;\"><span style=\"color: #0071bc;\"><a name=\"Section3\" id=\"Section3\"></a>Section 3</span></span></span></h1>\n<span style=\"font-size: 13px;\">This is the third section of your newsletter. Here, you can begin talking about the bottom line--pricing. Show your prospects that you really do have a superior product, at a lower price, than the competition.<br /> <br /> Encourage them to talk to a representative from your company, if they have any questions or concerns.<br /> <br /> <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Read Full Article</span></a> | <a style=\"text-decoration: none;\" href=\"mailto:address@email.com\"><span style=\"color: #0066cc\">Email Feedback</span></a></span><br /> <br /> \n<hr size=\"5\" width=\"100%\" />\n</td>\n</tr>\n<tr>\n<td>\n<h1><span style=\"font-size: 14px;\">Email Admin Center</span></h1>\n<span style=\"font-size: 12px;\">This newsletter is a service of Example.com. Should you no longer wish to receive these messages please go <a style=\"text-decoration: none;\" href=\"%%unsubscribe%%\"><span style=\"color: #0066cc\">here</span></a> to unsubscribe or send an email to: <a style=\"text-decoration: none;\" href=\"mailto:unsubscribe@company.com\"><span style=\"color: #0066cc\">unsubscribe@company.com</span></a><br /> <br /> To ensure delivery of this newsletter to your inbox and to enable images to load in future mailings, please add admincenter@example.com to your e-mail address book or safe senders list.<br /> <br /> %%account_address%%<br /></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n</tbody>\n</table>\n</body>\n</html>\n',NULL,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(5,'Product Email','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html;\" />\n    <title>\n      Email Newsletter\n    </title>\n  </head>\n  <body bgcolor=\"#FAF6D8\">\n<table style=\"width: 620px; font-family: arial,verdana,sans-serif; color: #333333;\" align=\"center\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n<tbody>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"0\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td colspan=\"2\"><span style=\"font-size: 13px;\"><span style=\"color: #df5437;\"><b>Value Statement - Include a compelling sentence here to get the audience to read more!</b></span><br /> If you are having trouble reading Example.com\'s newsletter view the <a style=\"text-decoration: none;\" href=\"%%view_online%%\"><span style=\"color: #0066cc;\">Web Version.</span></a></span></td>\n</tr>\n<tr>\n<td><a href=\"#\"><img style=\"border: 0pt none;\" title=\"Example.com Logo Description\" src=\"http://www2.pardot.com/l/1/2009-06-04/DK5J2/21774_Email1Logo.png\" alt=\"Example.com Logo\" /></a></td>\n</tr>\n<tr>\n<td colspan=\"2\" align=\"center\"><span style=\"font-size: 13px;\"><b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Subscribe</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Back Issues</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Article Archive</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Resource Center</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Request Demo</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">yoursite.com</span></a></b></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellpadding=\"10\">\n<tbody>\n<tr>\n<td>\n<h2><span style=\"font-size: 18px;\"><span style=\"font-family: times,serif;\"><span style=\"color: #df5437;\">In This Issue:</span></span></span></h2>\n<span style=\"font-size: 13px;\"><b><a style=\"text-decoration: none;\" href=\"Section1\"><span style=\"color: #0066cc\">Section 1:</span></a></b><br /> This is a brief description of the first section\'s contents.<br /> <br /> <b><a style=\"text-decoration: none;\" href=\"Section2\"><span style=\"color: #0066cc\">Section 2:</span></a></b><br /> This is a brief description of the second section\'s contents.<br /> <br /> <b><a style=\"text-decoration: none;\" href=\"Section3\"><span style=\"color: #0066cc\">Section 3:</span></a></b><br /> This is a brief description of the third section\'s contents.</span><br /></td>\n<td rowspan=\"2\" valign=\"top\"><a href=\"#\"><img style=\"border: 0pt none;\" title=\"Multi-Column Banner Description\" src=\"http://www2.pardot.com/l/1/2009-06-04/DK5IS/21764_Email1Banner.png\" alt=\"Multi-Column Banner\" /></a></td>\n</tr>\n<tr>\n<td>\n<h3><span style=\"font-size: 18px;\"><span style=\"font-family: times,serif;\"><span style=\"color: #df5437;\"><a name=\"Section1\" id=\"Section1\"></a>Section 1</span></span></span></h3>\n<span style=\"font-size: 13px;\">This is your first section. Use it to grab your prospects\' attention, to ensure that they will read the rest of the email. Here is where you talk about your extensive product feature list:</span> <ol>\n<li> <span style=\"font-size: 13px;\">Here is your first feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your second feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your third feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your fourth feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n</ol><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\"><span style=\"font-size: 13px;\">Read Full Article</span></span></a></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td>\n<h2><span style=\"font-size: 18px;\"><span style=\"font-family: times,serif;\"><span style=\"color: #df5437;\"><a name=\"Section2\" id=\"Section2\"></a>Featured Product</span></span></span></h2>\n<span style=\"font-size: 13px;\">This is where the latest news from your company goes. Use this section to keep your prospects\' interest high, so that they continue reading the email, instead of skimming over it. Use a loose summary or overview of any recent major events here, and then include a link to a full article online. Links are re-written as tracked links inside of emails, so you will know which news entries your prospects care about most. With this information, you can begin providing them with emails that are customized towards their interests.<br /> <br /> <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Read Full Article</span></a>| <a style=\"text-decoration: none;\" href=\"mailto:address@company.com\"><span style=\"color: #0066cc\">Email Feedback</span></a></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td valign=\"top\"><img src=\"http://www2.pardot.com/l/1/2009-06-04/DK5II/21754_Email1Icon.png\" alt=\"Description of image goes here!\" /></td>\n<td valign=\"top\"><span style=\"font-size: 13px;\"><a name=\"Section3\" id=\"Section3\"></a>This is where you can have a client testimonial for your product. By having a testimonial or case study, you directly show your prospects what your product can do for them. In addition, the company whose testimonial you use now feels like more a contributor for your company. Make prospects understand that you are continually upgrading your product for clients, and make existing clients feel better about having their ongoing relationship with you.<a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Read Full Article</span></a> | <a style=\"text-decoration: none;\" href=\"mailto:address@company.com\"><span style=\"color: #0066cc\">Email Feedback</span></a></span><br /> <br /></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" cellpadding=\"10\">\n<tbody>\n<tr>\n<td>\n<h1><span style=\"font-size: 14px;\">Email Admin Center</span></h1>\n<span style=\"font-size: 12px;\">This newsletter is a service of Example.com. Should you no longer wish to receive these messages please go <a style=\"text-decoration: none;\" href=\"%%unsubscribe%%\"><span style=\"color: #0066cc\">here</span></a> to unsubscribe or send an email to: <a style=\"text-decoration: none;\" href=\"mailto:unsubscribe@company.com\"><span style=\"color: #0066cc\">unsubscribe@company.com</span></a><br /> <br /> To ensure delivery of this newsletter to your inbox and to enable images to load in future mailings, please add admincenter@example.com to your e-mail address book or safe senders list.<br /> <br /> %%account_address%%<br /></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n</tbody>\n</table>\n</body>\n</html>\n',NULL,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(6,'Right Sidebar','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html;\" />\n    <title>\n      Email Newsletter\n    </title>\n  </head>\n  <body bgcolor=\"#000000\">\n<table style=\"width: 620px; font-family: arial,verdana,sans-serif; color: #333333; background-color: #ffffff;\" align=\"center\" border=\"0\">\n<tbody>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td><span style=\"color: #0066cc; font-size: 13px;\"><b>Value Statement - Include a compelling sentence here to get your audience to read more!</b><br /> If you are having trouble reading Example.com\'s newsletter view the <a style=\"text-decoration: none;\" href=\"%%view_online%%\"><span style=\"color: #0066cc\">Web Version.</span></a></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td><a style=\"color: #0066cc\" href=\"#\"><img style=\"border: 0pt none;\" src=\"http://www2.pardot.com/l/1/2009-06-03/DK0GK/21604_Email7Logo.png\" alt=\"Example.com Template Banner\" title=\"Example.com Banner Title Goes Here\" /></a></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td width=\"65%\">\n<h1><span style=\"font-size: 18px;\"><a name=\"Section1\" id=\"Section1\"></a>Section 1</span></h1>\n<span style=\" font-size: 13px;\">This is your first section. Use it to grab your prospects\' attention, to ensure that they will read the rest of the email. Here is where you talk about your extensive product feature list:</span> \n<ul>\n<li> <span style=\" font-size: 13px;\">Here is your first feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\" font-size: 13px;\">Here is your second feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\" font-size: 13px;\">Here is your third feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\" font-size: 13px;\">Here is your fourth feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\" font-size: 13px;\">Here is your fifth feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n</ul>\n<span style=\" font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Learn More</span></a></span></td>\n<td bgcolor=\"#e9f3d9\" valign=\"top\">\n<h2><span style=\"font-size: 16px;\">In This Issue:</span></h2>\n<span style=\"font-size: 13px;\"><b><a style=\"text-decoration: none;\" href=\"#Section1\"><span style=\"color: #0066cc\">Section 1:</span></a></b>This is a brief description of the first section\'s contents.<br /> <br /> <b><a style=\"text-decoration: none;\" href=\"#Section2\"><span style=\"color: #0066cc\">Section 2:</span></a></b>This is a brief description of the second section\'s contents.<br /> <br /> <b><a style=\"text-decoration: none;\" href=\"#Section3\"><span style=\"color: #0066cc\">Section 3:</span></a></b>This is a brief description of the third section\'s contents.</span></td>\n</tr>\n<tr>\n<td>\n<h1><span style=\"font-size: 18px;\"><a name=\"Section2\" id=\"Section2\"></a>Section 2</span></h1>\n<span style=\"font-size: 13px;\">This is where the latest news from your company goes. Use this section to keep your prospects\' interest high, so that they continue reading the email, instead of skimming over it. Use a loose summary or overview of any recent major events here, and then include a link to a full article online. Links are re-written as tracked links inside of emails, so you will know which news entries your prospects care about most. With this information, you can begin providing them with emails that are customized towards their interests.<br /> <br /> <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Read Full Article</span></a></span></td>\n<td bgcolor=\"#ffffff\" valign=\"top\">\n<h2><span style=\"font-size: 16px;\">Product Demo</span></h2>\n<span style=\"width: 100%;\">This is where you entice prospects to try a demo. Securing a demo is one of the most important steps in a successful deal.<br /> <br /> <a style=\"text-decoration: none;\" href=\"#\"><img style=\"border: 0pt none;\" src=\"http://www2.pardot.com/l/1/2009-06-03/DK0GU/21614_Email7Button.png\" alt=\"Sign Up Today!\" title=\"Click here to sign up!\" /></a></span></td>\n</tr>\n<tr>\n<td>\n<h1><span style=\"font-size: 18px;\"><a name=\"Section3\" id=\"Section3\"></a>Section 3</span></h1>\n<p><span style=\"font-size: 13px;\">This is where you can have a client testimonial for your product. By having a testimonial or case study, you directly show your prospects what your product can do for them. In addition, the company whose testimonial you use now feels like more a contributor for your company. Make prospects understand that you are continually upgrading your product for clients, and make existing clients feel better about having their ongoing relationship with you.</span></p>\n<p><span style=\"font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Click Here To Read More</span></a><br /></span></p>\n<p><span style=\"font-size: 13px;\">Here, you can write more about your own company\'s take on the testimonial. Draw attention to the parts of it that are most relevant to your prospects\' interests.<br /> <br /> <a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Read Full Article</span></a></span></p>\n</td>\n<td bgcolor=\"#e9f3d9\" valign=\"top\">\n<h2><span style=\"font-size: 16px;\">New Features</span></h2>\n<p><span style=\"font-size: 13px;\">This is where you can describe new features for your existing product. Make prospects understand that you are continually upgrading your product for clients, and make existing clients feel better about having their ongoing relationship with you.</span></p>\n<p><span style=\"font-size: 13px;\"><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Click Here To Read More</span></a></span></p>\n</td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"center\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"0\" cellspacing=\"20\">\n<tbody>\n<tr>\n<td>\n<h1><span style=\"font-size: 14px;\">Email Admin Center</span></h1>\n<span style=\"font-size: 12px;\">This newsletter is a service of Example.com. Should you no longer wish to receive these messages please go <a style=\"text-decoration: none;\" href=\"%%unsubscribe%%\"><span style=\"color: #0066cc\">here</span></a> to unsubscribe or send an email to: <a style=\"text-decoration: none;\" href=\"mailto:unsubscribe@company.com\"><span style=\"color: #0066cc\">unsubscribe@company.com</span></a><br /> <br /> To ensure delivery of this newsletter to your inbox and to enable images to load in future mailings, please add admincenter@example.com to your e-mail address book or safe senders list.<br /> <br /> %%account_address%%<br /></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\"></td>\n</tr>\n</tbody>\n</table>\n</body>\n</html>\n',NULL,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(7,'Single Column','<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html;\" />\n    <title>\n      Email Newsletter\n    </title>\n  </head>\n  <body bgcolor=\"#FFFFFF\">\n<table style=\"width: 620px; font-family: arial,verdana,sans-serif; color: #333333;\" align=\"center\" bgcolor=\"#ffffff\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n<tbody>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"left\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td><span style=\"font-size: 13px;\">Summary of your newsletter to entice recipients to read it.<br /> <br /> If you are having trouble reading Example Company\'s newsletter view the <a style=\"text-decoration: none;\" href=\"%%view_online%%\"><span style=\"color: #0066cc;\">Web Version.</span></a></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"left\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td><a href=\"#\"><img style=\"border: 0pt none;\" src=\"http://www2.pardot.com/l/1/2009-06-03/DK588/21684_Email0Logo.png\" alt=\"Example.com Logo\" title=\"Example.com Logo Description\" /></a></td>\n<td valign=\"middle\"><span style=\"font-size: 13px;\">Monthly Newsletter Title Here</span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"left\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td><a href=\"#\"><img style=\"border: 0pt none;\" src=\"http://www2.pardot.com/l/1/2009-06-03/DK58I/21694_Email0Banner.png\" alt=\"Example.com Template Banner\" title=\"Example.com Template Banner Description\" /></a></td>\n</tr>\n<tr>\n<td><span style=\"font-size: 13px;\"><b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Subscribe</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Back Issues</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Article Archive</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Resource Center</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">Request Demo</span></a></b> | <b><a style=\"text-decoration: none;\" href=\"#\"><span style=\"color: #0066cc\">yoursite.com</span></a></b></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"left\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td width=\"100\"><a href=\"#\"><img src=\"http://www2.pardot.com/l/1/2009-06-03/DK58S/21704_Email0Icon.png\" alt=\"New bubble Icon\" title=\"New Bubble - New product description here\" border=\"0\" /></a></td>\n<td><a name=\"Features\" id=\"Latest\"><span style=\"font-size: 17px;\"><span style=\"font-family: times,serif;\">Latest News</span></span></a><br /> <span style=\"font-size: 14px;\"><span style=\"color: #0066CC;\"><b>This is a brief teaser about the latest news from your company.</b></span></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 560px;\" align=\"left\" cellpadding=\"20\">\n<tbody>\n<tr>\n<td><span style=\"font-size: 13px;\">This is your first section. Use it to grab your prospects\' attention, to ensure that they will read the rest of the email. Here is where you talk about your extensive product feature list:</span> \n<ul>\n<li> <span style=\"font-size: 13px;\">Here is your first feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your second feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your third feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n<li> <span style=\"font-size: 13px;\">Here is your fourth feature. This is a long description for this feature, so that your prospects will fully understands its implications</span> </li>\n</ul>\n<center> <span style=\"font-size: 13px;\"><a href=\"#\"><img style=\"border: 0pt none;\" src=\"http://www2.pardot.com/l/1/2009-06-03/DK592/21714_Email0Spacer.png\" alt=\"New product icon\" title=\"New product description\" /></a></span> </center></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<tr>\n<td align=\"left\">\n<table style=\"width: 100%;\" align=\"left\" cellspacing=\"10\">\n<tbody>\n<tr>\n<td>\n<h1><span style=\"font-size: 14px;\">Email Admin Center</span></h1>\n<span style=\"font-size: 12px;\">This newsletter is a service of Example.com. Should you no longer wish to receive these messages please go <a style=\"text-decoration: none;\" href=\"%%unsubscribe%%\"><span style=\"color: #0066cc\">here</span></a> to unsubscribe or send an email to: <a style=\"text-decoration: none;\" href=\"mailto:unsubscribe@company.com\"><span style=\"color: #0066cc\">unsubscribe@company.com</span></a><br /> <br /> To ensure delivery of this newsletter to your inbox and to enable images to load in future mailings, please add admincenter@example.com to your e-mail address book or safe senders list.<br /> <br /> %%account_address%%<br /></span></td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n</tbody>\n</table>\n</body>\n</html>\n',NULL,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51');
/*!40000 ALTER TABLE `global_email_layout` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_memcached_invalidate`
--

DROP TABLE IF EXISTS `global_memcached_invalidate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_memcached_invalidate` (
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_memcached_invalidate`
--

LOCK TABLES `global_memcached_invalidate` WRITE;
/*!40000 ALTER TABLE `global_memcached_invalidate` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_memcached_invalidate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_message`
--

DROP TABLE IF EXISTS `global_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text COLLATE utf8_unicode_ci,
  `message_type` int(11) NOT NULL,
  `title_type` int(11) NOT NULL,
  `system_message_type` int(11) DEFAULT NULL,
  `roles` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shards` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `categories` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_account_specific` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `global_message_FI_1` (`created_by`),
  KEY `global_message_FI_2` (`updated_by`),
  CONSTRAINT `global_message_FK_1` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`),
  CONSTRAINT `global_message_FK_2` FOREIGN KEY (`updated_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_message`
--

LOCK TABLES `global_message` WRITE;
/*!40000 ALTER TABLE `global_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_message_global_account`
--

DROP TABLE IF EXISTS `global_message_global_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_message_global_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `global_message_id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `global_message_global_account_FI_1` (`global_message_id`),
  KEY `global_message_global_account_FI_2` (`account_id`),
  CONSTRAINT `global_message_global_account_FK_1` FOREIGN KEY (`global_message_id`) REFERENCES `global_message` (`id`),
  CONSTRAINT `global_message_global_account_FK_2` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_message_global_account`
--

LOCK TABLES `global_message_global_account` WRITE;
/*!40000 ALTER TABLE `global_message_global_account` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_message_global_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_setting`
--

DROP TABLE IF EXISTS `global_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_setting` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `setting_value` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_setting`
--

LOCK TABLES `global_setting` WRITE;
/*!40000 ALTER TABLE `global_setting` DISABLE KEYS */;
INSERT INTO `global_setting` VALUES (1,'Shard1-NewAccountLimit','99999'),(2,'Shard2-NewAccountLimit','99999'),(3,'sfdc-consumer-key','3MVG9A2kN3Bn17htnkqFCn2LVy26T7HULdqPCkKHG9NhDAuN7cvmstmBzTdKZjRlajC7lx3lMwV5teFxU3cD7'),(4,'sfdc-consumer-key-connector','3MVG9A2kN3Bn17htJ8IFFcgtLRFEW4cOB_uIGSsOyzjwvPERJ3sYJIYtTigKuW8hDPBdsEPo_dmN1J.3r95uB'),(5,'sfdc-consumer-secret','$1:VMePFIhFze5E5GeSJiwVesfc/fmShpqOXyHOEGPMOlo=:5J2x8qfFFEVpU7ajcQU8FhuipRDn0kUUOmXZHETWwGI='),(6,'sfdc-consumer-secret-connector','$1:yTI4BHxeGwJKPLp+T8cNIzH8lY+HIy7nrhB/IR4Aznc=:6yvOU6sDmVWdCV9TzpoPrqCQsHiL233yj26uIG7/CtQ='),(7,'sfdc-oauth-token-url','https://login.salesforce.com/services/oauth2/token'),(8,'sfdc-redirect-uri','https://pi.localhost.com/sso/login/source/salesforce'),(9,'sfdc-redirect-uri-connector','https://pi.localhost.com/sso/loginConnector/source/salesforce'),(10,'sfdc-oauth-authorize-url','https://login.salesforce.com/services/oauth2/authorize'),(11,'sfdc-oauth-token-url-sandbox','https://test.salesforce.com/services/oauth2/token'),(12,'sfdc-oauth-authorize-url-sandbox','https://test.salesforce.com/services/oauth2/authorize'),(13,'ld-consumer-key','3MVG9iTxZANhwHQv5vrXmRPisGBxV06PgrOG5H6QOEtt4jcYOI_BbGrzJZ.87._uvxweEEQY8b6tMTuNYfkX5'),(14,'ld-consumer-secret','$1:joo3TG41tnOUn0F8BqnGO+CY2CCcG5zV9kTMLYJYLhA=:jtdrbyOFcp+/sz+dO+QbY4ayqQCa73H1iuEdJVJrR9c='),(15,'disable_signalhandlerworkflowindevenvironment','0');
/*!40000 ALTER TABLE `global_setting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_thumbnail`
--

DROP TABLE IF EXISTS `global_thumbnail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_thumbnail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `s3_key` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `uri` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `global_thumbnail_FI_1` (`created_by`),
  KEY `global_thumbnail_FI_2` (`updated_by`),
  CONSTRAINT `global_thumbnail_FK_1` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`),
  CONSTRAINT `global_thumbnail_FK_2` FOREIGN KEY (`updated_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_thumbnail`
--

LOCK TABLES `global_thumbnail` WRITE;
/*!40000 ALTER TABLE `global_thumbnail` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_thumbnail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_user`
--

DROP TABLE IF EXISTS `global_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `username` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `role` int(11) NOT NULL,
  `rss_key` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_user_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_crm_synced` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `is_crm_username_verified` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `global_user_username_unique` (`username`),
  KEY `global_user_email_rss_key_index` (`email`,`rss_key`),
  KEY `global_user_FI_1` (`account_id`),
  KEY `global_user_FI_2` (`created_by`),
  KEY `global_user_FI_3` (`updated_by`),
  CONSTRAINT `global_user_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`),
  CONSTRAINT `global_user_FK_2` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`),
  CONSTRAINT `global_user_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=315 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_user`
--

LOCK TABLES `global_user` WRITE;
/*!40000 ALTER TABLE `global_user` DISABLE KEYS */;
INSERT INTO `global_user` VALUES (1,1,'marketing@pardot.com','marketing@pardot.com','$2a$12$l3r7tOg1MKOrJ2d5hR5a4ey4hg2NFo.uNmVQCGG0N6kFgAUWjavK.',2,'ec8ffc764e7ced04ec2012d1a90b33f8','eval@prospect_insight.demo',NULL,0,0,1,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(2,1,'coordinator@pardot.com','coordinator@pardot.com','$2a$12$muBHsTPPhO0Y0vDXzby8kuUKaC.zVSdjGAxRaBVVH9znnOTSL1Hbu',3,'ec8ffc764e7ced04ec2012d1a90b33f8','marketing.coordinator',NULL,0,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(3,1,'sales@pardot.com','sales@pardot.com','$2a$12$5.I/CPFsB9/iDOO4GK4Squh7F.zKOoYZp1wo3mLU0nJYZdqAi7iYK',4,'c25397c97cf6f4dbd6cbff034eab0009','sales.rep',NULL,0,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(4,1,'sales2@pardot.com','sales2@pardot.com','$2a$12$5.I/CPFsB9/iDOO4GK4Squh7F.zKOoYZp1wo3mLU0nJYZdqAi7iYK',4,'e3e0d1290d4c48e2a227f5bf0f951002','sales.repb',NULL,0,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(5,1,'salesmanager@pardot.com','salesmanager@pardot.com','$2a$12$M/YC4DaOymefqIwYOJEosuZEpFvmgU29BWCm3b1uoZxVP8cTMhMIy',5,'6b2df159e946a59b31eefd5edf519751','sales.manager',NULL,0,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(6,1,'root@pardot.com','root@pardot.com','$2a$08$AhwmE4U8ZwXIuzhc/5NLMeDq4y6MdSf/fle4Vr4V2ES5BdRxC390K',10,'0e7170d437c2e716528dad1eb66b6bea','john.smith',NULL,0,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(7,1,'engineer@pardot.com','engineer@pardot.com','$2a$08$YODZj8.V7MSr7wesFsADXuq/EsP3KwBXVhdvedou0T4OXwe6WwhKS',7,'0e7170d437c2e716528dad1eb66b6bec','engi.neer',NULL,0,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(8,1,'coordinator2@pardot.com','coordinator2@pardot.com','$2a$12$c/vMBrP.TxMZoYB6BoM6zu2Au0OqHVPQ.tugSrLZE4lZakSzHRaf6',3,'ec8ffc764e7ced04ec2012d1a90b33f8','marketing.coordinatorb',NULL,0,0,0,NULL,NULL,'2007-07-29 10:43:51','2007-07-29 10:43:51'),(9,2,'marketing@ecsoftware.com','marketing@ecsoftware.com','$2a$12$QB7zOEM1QE8SdXvC3JevFunUewoRo7xEeammFOfi/u0phuQAcyI4e',2,'ec8ffc764e7ced04ec2012d1a90b33f8','eval@prospect_insight.demo',NULL,0,0,1,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(10,2,'coordinator@ecsoftware.com','coordinator@ecsoftware.com','$2a$12$c/vMBrP.TxMZoYB6BoM6zu2Au0OqHVPQ.tugSrLZE4lZakSzHRaf6',3,'ec8ffc764e7ced04ec2012d1a90b33f8','marketing.coordinator',NULL,0,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(11,2,'sales@ecsoftware.com','sales@ecsoftware.com','$2a$12$vOOGjCaLLy.ftO8lzQzs9eh3kEyMnnBF3rpOdHgGiVr96Mhffe5qi',4,'b36db4f64f5c1f35bf9b03d44a034396','sales.rep',NULL,0,0,0,NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(314,1,'agency',NULL,'nonvalidpassword',2,'rss_key',NULL,NULL,0,0,0,NULL,NULL,'2016-03-24 16:07:16','2016-03-24 16:07:16');
/*!40000 ALTER TABLE `global_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_user_feedback`
--

DROP TABLE IF EXISTS `global_user_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_user_feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `time_period` int(11) NOT NULL,
  `response` int(11) NOT NULL,
  `comments` text COLLATE utf8_unicode_ci,
  `is_responded` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `global_user_feedback_FI_1` (`account_id`),
  KEY `global_user_feedback_FI_2` (`user_id`),
  CONSTRAINT `global_user_feedback_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`),
  CONSTRAINT `global_user_feedback_FK_2` FOREIGN KEY (`user_id`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_user_feedback`
--

LOCK TABLES `global_user_feedback` WRITE;
/*!40000 ALTER TABLE `global_user_feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_user_feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_user_login`
--

DROP TABLE IF EXISTS `global_user_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_user_login` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `ip_address` varchar(15) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_successful` tinyint(1) NOT NULL DEFAULT '1',
  `is_persistent` int(11) NOT NULL DEFAULT '0',
  `remember_me_key` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `preview_key` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_remember_me_key` (`remember_me_key`),
  UNIQUE KEY `uniq_preview_key` (`preview_key`),
  KEY `global_user_login_FI_1` (`account_id`),
  KEY `global_user_login_FI_2` (`user_id`),
  KEY `remember_me_key_created_at` (`remember_me_key`,`created_at`),
  KEY `preview_key_created_at` (`preview_key`,`created_at`),
  CONSTRAINT `global_user_login_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`),
  CONSTRAINT `global_user_login_FK_2` FOREIGN KEY (`user_id`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_user_login`
--

LOCK TABLES `global_user_login` WRITE;
/*!40000 ALTER TABLE `global_user_login` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_user_login` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job`
--

DROP TABLE IF EXISTS `job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_group_id` int(11) DEFAULT NULL,
  `shard_id` int(11) DEFAULT '1',
  `status` int(11) DEFAULT '0',
  `requested_status` int(11) DEFAULT '0',
  `params` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `last_tried_at` datetime DEFAULT NULL,
  `runtime` float DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  `server_id` int(11) DEFAULT '0',
  `launcher_pid` int(11) DEFAULT NULL,
  `pid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_shard` (`job_group_id`,`shard_id`),
  KEY `ix_server_id` (`server_id`,`status`),
  CONSTRAINT `job_FK_1` FOREIGN KEY (`job_group_id`) REFERENCES `job_group` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job`
--

LOCK TABLES `job` WRITE;
/*!40000 ALTER TABLE `job` DISABLE KEYS */;
INSERT INTO `job` VALUES (1,8,1,0,0,NULL,'2016-03-24 16:06:04',NULL,NULL,NULL,0,NULL,NULL),(2,26,1,0,0,NULL,'2016-03-24 16:06:04',NULL,NULL,NULL,0,NULL,NULL),(3,10,1,0,0,NULL,'2016-03-24 16:06:04',NULL,NULL,NULL,0,NULL,NULL),(4,23,1,0,0,NULL,'2016-03-24 16:06:04',NULL,NULL,'2016-03-25 03:30:00',0,NULL,NULL),(5,22,1,0,0,NULL,'2016-03-24 16:06:04',NULL,NULL,'2016-03-25 02:20:00',0,NULL,NULL),(6,24,1,0,0,NULL,'2016-03-24 16:06:04',NULL,NULL,'2016-03-25 02:40:00',0,NULL,NULL),(7,30,1,0,0,NULL,'2016-03-24 16:06:04',NULL,NULL,NULL,0,NULL,NULL),(8,31,1,0,0,NULL,'2016-03-24 16:06:04',NULL,NULL,NULL,0,NULL,NULL),(9,12,1,0,0,NULL,'2016-03-24 16:06:04',NULL,NULL,NULL,0,NULL,NULL),(10,16,1,2,0,NULL,'2016-03-24 16:06:04',NULL,NULL,NULL,0,NULL,NULL),(11,17,1,2,0,NULL,'2016-03-24 16:06:04',NULL,NULL,NULL,0,NULL,NULL),(12,7,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(13,9,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(14,11,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(15,13,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(16,19,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(17,21,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(18,27,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(19,28,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(20,32,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,'2016-03-25 03:00:00',0,NULL,NULL),(21,34,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,'2016-03-25 01:20:00',0,NULL,NULL),(22,36,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(23,37,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,'2016-03-25 01:00:00',0,NULL,NULL),(24,38,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(25,39,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(26,40,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(27,42,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(28,43,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(29,44,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(30,45,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(31,46,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(32,50,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,'2016-03-25 01:20:00',0,NULL,NULL),(33,51,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(34,54,1,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(35,7,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(36,8,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(37,9,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(38,10,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(39,11,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(40,12,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(41,13,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(42,16,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(43,19,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(44,21,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(45,23,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,'2016-03-25 03:30:00',0,NULL,NULL),(46,24,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,'2016-03-25 02:40:00',0,NULL,NULL),(47,27,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(48,28,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(49,30,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(50,31,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(51,32,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,'2016-03-25 03:00:00',0,NULL,NULL),(52,34,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,'2016-03-25 01:20:00',0,NULL,NULL),(53,36,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(54,37,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,'2016-03-25 01:00:00',0,NULL,NULL),(55,38,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(56,39,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(57,40,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(58,42,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(59,43,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(60,44,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(61,45,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(62,46,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(63,50,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,'2016-03-25 01:20:00',0,NULL,NULL),(64,51,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL),(65,54,2,0,0,NULL,'2016-03-24 16:07:27',NULL,NULL,NULL,0,NULL,NULL);
/*!40000 ALTER TABLE `job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_category`
--

DROP TABLE IF EXISTS `job_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_category_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_category`
--

LOCK TABLES `job_category` WRITE;
/*!40000 ALTER TABLE `job_category` DISABLE KEYS */;
INSERT INTO `job_category` VALUES (1,'Automation'),(2,'Background'),(3,'CRM'),(4,'Daily Email'),(5,'Demo Accounts'),(6,'Email'),(16,'Engage'),(15,'Maintenance'),(8,'Paid Search'),(7,'Prospect'),(9,'Reporting'),(10,'Run Once'),(11,'Search'),(14,'Social Data'),(12,'Statistics'),(13,'Visitor');
/*!40000 ALTER TABLE `job_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_group`
--

DROP TABLE IF EXISTS `job_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_category_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `server_location` int(11) DEFAULT NULL,
  `retry_delay` int(11) DEFAULT '600',
  `max_runtime` int(11) DEFAULT '3600',
  `auto_kill` int(11) DEFAULT '0',
  `params` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `scheduled_time` time DEFAULT NULL,
  `unpause_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_group_name` (`name`),
  KEY `job_group_FI_1` (`job_category_id`),
  CONSTRAINT `job_group_FK_1` FOREIGN KEY (`job_category_id`) REFERENCES `job_category` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_group`
--

LOCK TABLES `job_group` WRITE;
/*!40000 ALTER TABLE `job_group` DISABLE KEYS */;
INSERT INTO `job_group` VALUES (1,8,'Adwords NewCampaignPull Initiation','AdwordsNewCampaignPullInitiation',1,300,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";s:1:\"1\";}','2016-03-24 16:06:04',NULL,NULL),(2,8,'Adwords NewCampaignPull','AdwordsNewCampaignPull',1,60,3600,0,'a:2:{s:21:\"max_number_of_buckets\";s:1:\"5\";s:27:\"include_unarchived_accounts\";s:1:\"1\";}','2016-03-24 16:06:04',NULL,NULL),(3,8,'Adwords NewCampaignSync Initiation','AdwordsNewCampaignSyncInitiation',1,300,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";s:1:\"1\";}','2016-03-24 16:06:04',NULL,NULL),(4,8,'Adwords NewCampaignSync','AdwordsNewCampaignSync',1,60,3600,0,'a:2:{s:21:\"max_number_of_buckets\";s:1:\"5\";s:27:\"include_unarchived_accounts\";s:1:\"1\";}','2016-03-24 16:06:04',NULL,NULL),(5,8,'Adwords IncrementalUpdate Initiation','AdwordsIncrementalUpdateInitiation',1,300,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";s:1:\"1\";}','2016-03-24 16:06:04',NULL,NULL),(6,8,'Adwords IncrementalUpdate','AdwordsIncrementalUpdate',1,60,3600,0,'a:2:{s:21:\"max_number_of_buckets\";s:1:\"5\";s:27:\"include_unarchived_accounts\";s:1:\"1\";}','2016-03-24 16:06:04',NULL,NULL),(7,1,'AutomationTime','AutomationTime',1,600,3600,0,'a:2:{s:21:\"max_number_of_buckets\";i:2;s:27:\"include_unarchived_accounts\";i:1;}  automationTime:','2016-03-24 16:06:04',NULL,NULL),(8,1,'DripProgram - Bucket 1','DripProgram',1,600,3600,0,'a:1:{s:9:\"bucket_id\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(9,2,'CleanBackgroundQueue','CleanBackgroundQueue',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(10,2,'Export','Export',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(11,2,'Filter','Filter',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(12,2,'SimpleExport','SimpleExport',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(13,2,'Thumbnail','Thumbnail',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(14,2,'ImportProspectsS3InitializeRedis','ImportProspectsS3InitializeRedis',1,300,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";s:1:\"1\";}','2016-03-24 16:06:04',NULL,NULL),(15,2,'ImportProspectsS3SelfScaling','ImportProspectsS3SelfScaling',1,300,3600,0,'a:2:{s:21:\"max_number_of_buckets\";s:1:\"2\";s:27:\"include_unarchived_accounts\";s:1:\"1\";}','2016-03-24 16:06:04',NULL,NULL),(16,2,'ImportErrors','ImportErrors',1,60,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(17,2,'ExportTable','ExportTable',1,600,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}    retry_delay: 300','2016-03-24 16:06:04',NULL,NULL),(18,3,'CrmEmailPushSalesforce - Bucket 1','CrmEmailPushSalesforce',1,600,3600,0,'a:2:{s:9:\"bucket_id\";i:1;s:27:\"include_unarchived_accounts\";s:1:\"1\";}','2016-03-24 16:06:04',NULL,NULL),(19,3,'CrmPushSalesforce - Bucket 1','CrmPushSalesforce',1,600,3600,0,'a:1:{s:9:\"bucket_id\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(20,3,'CrmSyncNetsuite - Bucket 1','CrmSyncNetsuite',1,600,3600,0,'a:1:{s:9:\"bucket_id\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(21,3,'CrmSyncSugar','CrmSyncSugar',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(22,4,'ProspectActivityEmail','ProspectActivityEmail',1,86400,3600,0,NULL,'2016-03-24 16:06:04','02:20:00',NULL),(23,4,'ProspectAssignmentEmail','ProspectAssignmentEmail',1,86400,3600,0,NULL,'2016-03-24 16:06:04','03:30:00',NULL),(24,4,'VisitorActivityEmail','VisitorActivityEmail',1,86400,3600,0,NULL,'2016-03-24 16:06:04','02:40:00',NULL),(25,6,'FastEmail','FastEmail',NULL,120,3600,0,'a:2:{s:21:\"max_number_of_buckets\";i:5;s:27:\"include_unarchived_accounts\";i:1;}    server_location: 3','2016-03-24 16:06:04',NULL,NULL),(26,6,'EmailQueue','EmailQueue',NULL,120,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}    server_location: 3','2016-03-24 16:06:04',NULL,NULL),(27,6,'EmailAlert','EmailAlert',3,120,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(28,6,'EmailBounce','EmailBounce',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(29,6,'SpamComplaint','SpamComplaint',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(30,7,'ProspectRescore','ProspectRescore',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(31,7,'ProspectMergeAndDelete','ProspectMergeAndDelete',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(32,9,'AccountUsageReport','AccountUsageReport',1,86400,3600,0,NULL,'2016-03-24 16:06:04','03:00:00',NULL),(33,9,'Report','Report',1,86400,3600,0,NULL,'2016-03-24 16:06:04','00:40:00',NULL),(34,11,'PaidSearch','PaidSearch',1,86400,3600,0,NULL,'2016-03-24 16:06:04','01:20:00',NULL),(35,11,'SiteSearch','SiteSearch',1,86400,3600,0,NULL,'2016-03-24 16:06:04','02:00:00',NULL),(36,12,'EmailStats','EmailStats',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(37,12,'ProspectSummaryCumulativeStats','ProspectSummaryCumulativeStats',1,86400,3600,0,NULL,'2016-03-24 16:06:04','01:00:00',NULL),(38,13,'CleanOldVisitorAudits','CleanOldVisitorAudits',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(39,13,'cleanScriptVisitors','cleanScriptVisitors',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(40,13,'VisitorGoogleClick','VisitorGoogleClick',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(41,13,'VisitorMerge','VisitorMerge',1,600,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";s:1:\"1\";}','2016-03-24 16:06:04',NULL,NULL),(42,13,'VisitorRemoveOld','VisitorRemoveOld',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(43,13,'VisitorWhois','VisitorWhois',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(44,14,'SocialDataNodeLookup','SocialDataNodeLookup',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(45,14,'SocialDataRefresh','SocialDataRefresh',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(46,14,'SocialDataConsumeApiResult','SocialDataConsumeApiResult',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(47,9,'OpportunityInfluenceSelfScaling','OpportunityInfluenceSelfScaling',1,600,3600,0,NULL,'2016-03-24 16:06:04',NULL,NULL),(48,15,'AutomaticAccountDropScheduler','AutomaticAccountDropScheduler',1,600,3600,0,'a:2:{s:11:\"not_dry_run\";i:1;s:18:\"ignore_day_of_week\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(49,15,'AutomaticAccountDrop','AutomaticAccountDrop',1,600,3600,0,'a:1:{s:8:\"live_run\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(50,11,'AdwordsFullSyncInitiation','AdwordsFullSyncInitiation',1,86400,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04','01:20:00',NULL),(51,11,'AdwordsCampaignSync','AdwordsCampaignSync',1,600,3600,0,'a:2:{s:21:\"max_number_of_buckets\";i:5;s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(52,3,'Verify SFDC Connectors','CrmVerifySalesforceConnector',1,60,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(53,3,'Pull Salesforce','CrmPullSalesforce',1,600,7200,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(54,3,'Pull Campaigns','CrmCampaignPull',1,600,3600,0,'a:1:{s:22:\"max_queues_per_account\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(55,3,'Full Sync','CrmFullSync',1,300,7200,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(56,3,'Pull Campaign Members From Salesforce','CrmPullSalesforceCampaignMembers',1,86400,3600,0,NULL,'2016-03-24 16:06:04','02:00:00',NULL),(57,3,'Pull Salesforce Changelogs','CrmPullSalesforceChangelogs',1,600,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(58,3,'Pull Salesforce Metadata','CrmPullSalesforceMetadata',1,14400,14400,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(59,3,'Sync Emails','CrmSyncEmail',1,120,3600,0,'a:3:{s:21:\"max_number_of_buckets\";i:4;s:10:\"batch_size\";i:200;s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(60,3,'Sync Salesforce Prospects','CrmSyncSalesforceProspects',1,60,3600,0,'a:3:{s:21:\"max_number_of_buckets\";i:100;s:25:\"include_archived_accounts\";i:1;s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(61,3,'Sync Salesforce Sso Users','CrmSyncSalesforceSsoUsers',1,600,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(62,3,'Pull Salesforce Custom Objects','CrmPullSalesforceCustomObjects',1,600,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(63,3,'Refresh Archived Salesforce Campaign Status','RefreshArchivedCrmCampaignStatuses',1,1800,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}','2016-03-24 16:06:04',NULL,NULL),(64,16,'EngageCache','EngageCache',NULL,120,3600,0,'a:1:{s:27:\"include_unarchived_accounts\";i:1;}    server_location: 3','2016-03-24 16:06:04',NULL,NULL),(65,5,'Demo Instance Background Queue Self Scaling','DemoInstanceBackgroundQueueSelfScaling',1,600,3600,0,'a:4:{s:21:\"max_number_of_buckets\";i:2;s:19:\"include_account_ids\";a:1:{i:0;i:1;}s:27:\"include_unarchived_accounts\";i:1;s:25:\"include_archived_accounts\";i:0;}    retry_delay: 300','2016-03-24 16:06:04',NULL,NULL),(66,5,'Demo Data Generator','DemoDataGenerator',1,600,3600,0,'a:2:{s:27:\"include_unarchived_accounts\";i:1;s:25:\"include_archived_accounts\";i:0;}    retry_delay: 300','2016-03-24 16:06:04',NULL,NULL),(67,5,'Demo Instance Advance Timestamps','DemoInstanceAdvanceTimestamps',1,600,3600,0,'a:2:{s:27:\"include_unarchived_accounts\";i:1;s:25:\"include_archived_accounts\";i:0;}    retry_delay: 600','2016-03-24 16:06:04',NULL,NULL),(68,5,'Demo Instance Drop Archived','DemoInstanceDropArchived',1,600,3600,0,'a:3:{s:30:\"max_accounts_to_delete_per_run\";i:0;s:27:\"include_unarchived_accounts\";i:1;s:25:\"include_archived_accounts\";i:0;}    retry_delay: 600','2016-03-24 16:06:04',NULL,NULL),(69,5,'Demo Instance Unprovisioned Self Scaling','DemoInstanceUnprovisionedSelfScaling',1,600,3600,0,'a:4:{s:21:\"max_number_of_buckets\";i:2;s:30:\"desired_unprovisioned_accounts\";i:0;s:27:\"include_unarchived_accounts\";i:1;s:25:\"include_archived_accounts\";i:0;}    retry_delay: 600','2016-03-24 16:06:04',NULL,NULL);
/*!40000 ALTER TABLE `job_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_host`
--

DROP TABLE IF EXISTS `job_host`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_host` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `server_name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `requested_status` int(11) DEFAULT '0',
  `manager_run_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_host_server_name` (`server_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_host`
--

LOCK TABLES `job_host` WRITE;
/*!40000 ALTER TABLE `job_host` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_host` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_server`
--

DROP TABLE IF EXISTS `job_server`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_server` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shard_id` int(11) DEFAULT '1',
  `server_name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `server_location` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_server` (`shard_id`,`server_location`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_server`
--

LOCK TABLES `job_server` WRITE;
/*!40000 ALTER TABLE `job_server` DISABLE KEYS */;
INSERT INTO `job_server` VALUES (1,1,'localhost',1),(2,1,'localhost',2),(3,1,'localhost',3),(4,2,'localhost',1),(5,2,'localhost',2),(6,2,'localhost',3);
/*!40000 ALTER TABLE `job_server` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `queries`
--

DROP TABLE IF EXISTS `queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `database` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `datacenter` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `sql` text COLLATE utf8_unicode_ci,
  `view` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_limited` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `queries`
--

LOCK TABLES `queries` WRITE;
/*!40000 ALTER TABLE `queries` DISABLE KEYS */;
/*!40000 ALTER TABLE `queries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recent_releases`
--

DROP TABLE IF EXISTS `recent_releases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recent_releases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `release_date` datetime DEFAULT NULL,
  `expiration_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `recent_releases_FI_1` (`user_id`),
  CONSTRAINT `recent_releases_FK_1` FOREIGN KEY (`user_id`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recent_releases`
--

LOCK TABLES `recent_releases` WRITE;
/*!40000 ALTER TABLE `recent_releases` DISABLE KEYS */;
/*!40000 ALTER TABLE `recent_releases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rss_feed`
--

DROP TABLE IF EXISTS `rss_feed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rss_feed` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feed_type` int(11) DEFAULT NULL,
  `feed_id` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `author` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_feed_type_id` (`feed_type`,`feed_id`),
  KEY `ix_feed_id` (`feed_id`),
  KEY `ix_type_created` (`feed_type`,`created`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rss_feed`
--

LOCK TABLES `rss_feed` WRITE;
/*!40000 ALTER TABLE `rss_feed` DISABLE KEYS */;
/*!40000 ALTER TABLE `rss_feed` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20140825172247');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sfdc_org`
--

DROP TABLE IF EXISTS `sfdc_org`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sfdc_org` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fid` varchar(18) COLLATE utf8_unicode_ci NOT NULL,
  `current_hmac_key` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `previous_hmac_key` varchar(100) COLLATE utf8_unicode_ci DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `org_id_unique` (`fid`),
  KEY `current_hmac_key` (`current_hmac_key`),
  KEY `previous_hmac_key` (`previous_hmac_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sfdc_org`
--

LOCK TABLES `sfdc_org` WRITE;
/*!40000 ALTER TABLE `sfdc_org` DISABLE KEYS */;
/*!40000 ALTER TABLE `sfdc_org` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `spam_ip`
--

DROP TABLE IF EXISTS `spam_ip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spam_ip` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `last_seen_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_ip` (`ip`),
  KEY `ix_last_seen_at` (`last_seen_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `spam_ip`
--

LOCK TABLES `spam_ip` WRITE;
/*!40000 ALTER TABLE `spam_ip` DISABLE KEYS */;
/*!40000 ALTER TABLE `spam_ip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sso_login`
--

DROP TABLE IF EXISTS `user_sso_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_sso_login` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `sso_type` int(11) DEFAULT NULL,
  `sso_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sso_id_endpoint_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sso_org_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sso_username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `access_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `refresh_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `instance_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ld_access_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ld_refresh_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ld_sso_id_endpoint_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ld_sso_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ld_instance_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sso_unique` (`sso_type`,`sso_id`),
  KEY `user_sso_login_FI_1` (`account_id`),
  KEY `user_sso_login_FI_2` (`user_id`),
  CONSTRAINT `user_sso_login_FK_1` FOREIGN KEY (`account_id`) REFERENCES `global_account` (`id`),
  CONSTRAINT `user_sso_login_FK_2` FOREIGN KEY (`user_id`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sso_login`
--

LOCK TABLES `user_sso_login` WRITE;
/*!40000 ALTER TABLE `user_sso_login` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_sso_login` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `virtual_server`
--

DROP TABLE IF EXISTS `virtual_server`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_server` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL,
  `status` int(11) DEFAULT '0',
  `ip_address` text COLLATE utf8_unicode_ci NOT NULL,
  `hostname` text COLLATE utf8_unicode_ci NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `virtual_server_FI_1` (`created_by`),
  CONSTRAINT `virtual_server_FK_1` FOREIGN KEY (`created_by`) REFERENCES `global_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `virtual_server`
--

LOCK TABLES `virtual_server` WRITE;
/*!40000 ALTER TABLE `virtual_server` DISABLE KEYS */;
/*!40000 ALTER TABLE `virtual_server` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-04-05 12:34:51
