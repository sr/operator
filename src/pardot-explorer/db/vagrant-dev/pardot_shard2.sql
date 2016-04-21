-- MySQL dump 10.13  Distrib 5.5.47-37.7, for Linux (x86_64)
--
-- Host: localhost    Database: pardot_shard2
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
-- Current Database: `pardot_shard2`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `pardot_shard2` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;

USE `pardot_shard2`;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email_ip_id` int(11) DEFAULT NULL,
  `company` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sfdc_org_id` varchar(18) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tracker_domain` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `country` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_one` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_two` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `territory` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fax` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `unsubscribe_page_id` int(11) DEFAULT NULL,
  `email_preference_page_id` int(11) DEFAULT NULL,
  `plugin_campaign_id` int(11) DEFAULT NULL,
  `adwords_campaign_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `training_type` int(11) DEFAULT '0',
  `discount` int(11) DEFAULT NULL,
  `timezone` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale` int(11) DEFAULT '0',
  `default_locale_code` varchar(40) COLLATE utf8_unicode_ci DEFAULT 'en_US',
  `default_language_code` varchar(40) COLLATE utf8_unicode_ci DEFAULT 'en_US',
  `currency_id` int(11) DEFAULT '0',
  `encryption_key` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `new_encryption_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `permanent_bcc` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `max_users` int(11) DEFAULT '5',
  `max_emails` int(11) DEFAULT NULL,
  `max_file_storage_size` int(11) DEFAULT NULL,
  `email_server_id` int(11) DEFAULT NULL,
  `expiration` datetime DEFAULT NULL,
  `billing_date` date DEFAULT NULL,
  `email_overage_rate` float DEFAULT NULL,
  `shard_id` int(11) DEFAULT '1',
  `advocate_user_id` int(11) DEFAULT NULL,
  `is_billing_overdue` int(11) DEFAULT '0',
  `is_disabled` int(11) DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `ld_email_send_limit` int(11) DEFAULT '100',
  `ld_send_limit_reset_duration` int(11) DEFAULT '1',
  `max_mcemails_reset_duration` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_FI_1` (`unsubscribe_page_id`),
  KEY `account_FI_2` (`email_preference_page_id`),
  KEY `account_FI_3` (`plugin_campaign_id`),
  KEY `account_FI_4` (`adwords_campaign_id`),
  CONSTRAINT `account_FK_1` FOREIGN KEY (`unsubscribe_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `account_FK_2` FOREIGN KEY (`email_preference_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `account_FK_3` FOREIGN KEY (`plugin_campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `account_FK_4` FOREIGN KEY (`adwords_campaign_id`) REFERENCES `campaign` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` VALUES (1,NULL,'Pardot',NULL,NULL,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,0,'en_US','en_US',0,NULL,NULL,NULL,5,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,0,0,0,NULL,NULL,100,1,1,NULL,NULL),(2,NULL,'Eastern Cloud Software','http://www.ecsoftware.com/',NULL,'http://go.pardot.com','United States','1564 River Street','Suite 3200','Stevenson','Alabama',NULL,'30426','555-555-5555',NULL,NULL,NULL,2,NULL,5,0,NULL,'America/New_York',0,'en_US','en_US',0,'a26d949fa140f486140bd76c7c2b2075','$1:obNEVAXo/pdIs/FltcN4g5pFuMqJ2/wtFmYLswsU0O8=:5Uvvpw792R4Izr7/8mHGdovnZOLUBkkyThg9Y4v5tuA=',NULL,10,NULL,NULL,NULL,'2020-07-17 00:00:00',NULL,NULL,2,NULL,0,0,0,NULL,NULL,100,1,1,'2007-07-29 10:42:51','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_access_log`
--

DROP TABLE IF EXISTS `account_access_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_access_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `module` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_access_log_FI_1` (`account_id`),
  CONSTRAINT `account_access_log_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_access_log`
--

LOCK TABLES `account_access_log` WRITE;
/*!40000 ALTER TABLE `account_access_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_access_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_extras`
--

DROP TABLE IF EXISTS `account_extras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_extras` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `is_ip_security_enabled` tinyint(4) DEFAULT '0',
  `crm_bucket_id` int(11) NOT NULL DEFAULT '1',
  `crm_last_run_at` datetime DEFAULT NULL,
  `crm_is_processing` int(11) DEFAULT '0',
  `drip_bucket_id` int(11) NOT NULL DEFAULT '1',
  `drip_is_processing` int(11) DEFAULT '0',
  `drip_last_run_at` int(11) DEFAULT NULL,
  `visitor_whois_last_run_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_checked_visit_id` int(11) DEFAULT NULL,
  `last_checked_visitor_page_view_id` int(11) DEFAULT NULL,
  `last_checked_visit_at` datetime DEFAULT NULL,
  `last_checked_visitor_page_view_at` datetime DEFAULT NULL,
  `last_scored_visitor_activity_id` int(11) DEFAULT NULL,
  `last_scored_visitor_page_view_id` int(11) DEFAULT NULL,
  `hide_email_counts` int(11) DEFAULT '0',
  `social_data_active_refresh_needed` int(11) DEFAULT '1',
  `social_data_inactive_refresh_needed` int(11) DEFAULT '1',
  `last_checked_active_social_data_prospect_id` int(11) DEFAULT '0',
  `last_checked_inactive_social_data_prospect_id` int(11) DEFAULT '0',
  `last_email_stats_check` datetime DEFAULT NULL,
  `email_stats_check_process_id` int(11) DEFAULT NULL,
  `autofill_location_data` int(11) DEFAULT '0',
  `last_db_threshold` datetime DEFAULT NULL,
  `last_db_overage` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_id` (`account_id`),
  CONSTRAINT `account_extras_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_extras`
--

LOCK TABLES `account_extras` WRITE;
/*!40000 ALTER TABLE `account_extras` DISABLE KEYS */;
INSERT INTO `account_extras` VALUES (1,2,0,1,NULL,0,1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14',NULL,NULL,NULL,NULL,NULL,NULL,0,1,1,0,0,NULL,NULL,0,NULL,NULL);
/*!40000 ALTER TABLE `account_extras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_ip_security`
--

DROP TABLE IF EXISTS `account_ip_security`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_ip_security` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_ip` int(11) unsigned NOT NULL,
  `end_ip` int(11) unsigned NOT NULL,
  `type` int(11) NOT NULL,
  `hash` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `account_ip_security_FI_1` (`account_id`),
  KEY `account_ip_security_FI_2` (`created_by`),
  KEY `account_ip_security_FI_3` (`updated_by`),
  CONSTRAINT `account_ip_security_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `account_ip_security_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `account_ip_security_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_ip_security`
--

LOCK TABLES `account_ip_security` WRITE;
/*!40000 ALTER TABLE `account_ip_security` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_ip_security` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_limit`
--

DROP TABLE IF EXISTS `account_limit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_limit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `max_api_requests` int(11) DEFAULT NULL,
  `max_automations` int(11) DEFAULT NULL,
  `max_blocks` int(11) DEFAULT NULL,
  `max_prospect_field_customs` int(11) DEFAULT NULL,
  `max_drip_programs` int(11) DEFAULT NULL,
  `max_emails` int(11) DEFAULT NULL,
  `max_db_size` int(11) DEFAULT NULL,
  `max_file_storage_size` int(11) DEFAULT NULL,
  `max_filters` int(11) DEFAULT NULL,
  `max_forms` int(11) DEFAULT NULL,
  `max_form_handlers` int(11) DEFAULT NULL,
  `max_keywords` int(11) DEFAULT NULL,
  `max_landing_pages` int(11) DEFAULT NULL,
  `max_lists` int(11) DEFAULT NULL,
  `max_page_actions` int(11) DEFAULT NULL,
  `max_personalizations` int(11) DEFAULT NULL,
  `max_profiles` int(11) DEFAULT NULL,
  `max_site_search_urls` int(11) DEFAULT NULL,
  `max_users` int(11) DEFAULT NULL,
  `max_dynamic_lists` int(11) DEFAULT NULL,
  `max_test_lists` int(11) DEFAULT NULL,
  `max_test_list_members` int(11) DEFAULT NULL,
  `max_competitors` int(11) DEFAULT NULL,
  `concurrent_api_requests` int(11) DEFAULT NULL,
  `max_mcemails` int(11) DEFAULT '200',
  `max_mcemails_limit` int(11) DEFAULT '500',
  `has_permanent_bcc` int(11) NOT NULL DEFAULT '0',
  `has_litmus_access` tinyint(1) NOT NULL DEFAULT '0',
  `has_phone_access` tinyint(1) NOT NULL DEFAULT '0',
  `has_social_access` tinyint(1) NOT NULL DEFAULT '0',
  `has_chat_support_access` tinyint(1) NOT NULL DEFAULT '0',
  `has_vanity_url_access` tinyint(1) NOT NULL DEFAULT '0',
  `has_email_blocked` tinyint(1) NOT NULL DEFAULT '0',
  `has_social_data` tinyint(1) NOT NULL DEFAULT '0',
  `has_paid_search` tinyint(1) NOT NULL DEFAULT '0',
  `has_dynamic_content` tinyint(1) NOT NULL DEFAULT '0',
  `has_multivariate_tests` tinyint(1) NOT NULL DEFAULT '0',
  `has_blocks` tinyint(1) NOT NULL DEFAULT '0',
  `has_custom_roles` tinyint(1) NOT NULL DEFAULT '0',
  `has_nonmarketing_email` int(11) NOT NULL DEFAULT '0',
  `max_custom_objects` int(11) DEFAULT NULL,
  `has_email_ab_testing` int(11) NOT NULL DEFAULT '0',
  `has_marketing_calendar` int(11) NOT NULL DEFAULT '0',
  `max_import_filesize_mb` int(11) DEFAULT '100',
  `has_email_opens_adjust_score_once` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `account_limit_FI_1` (`account_id`),
  CONSTRAINT `account_limit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_limit`
--

LOCK TABLES `account_limit` WRITE;
/*!40000 ALTER TABLE `account_limit` DISABLE KEYS */;
INSERT INTO `account_limit` VALUES (1,2,100000,2147483647,2147483647,2147483647,2147483647,500000,2147483647,5120,2147483647,2147483647,2147483647,1000,2147483647,2147483647,25,2147483647,2147483647,2000,2147483647,9999,2147483647,100,100,5,200,500,0,1,1,1,1,1,0,1,1,1,1,1,1,0,4,1,1,100,1);
/*!40000 ALTER TABLE `account_limit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_message`
--

DROP TABLE IF EXISTS `account_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `roles` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `categories` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_message_FI_1` (`account_id`),
  CONSTRAINT `account_message_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_message`
--

LOCK TABLES `account_message` WRITE;
/*!40000 ALTER TABLE `account_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_message_prefs`
--

DROP TABLE IF EXISTS `account_message_prefs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_message_prefs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `account_message_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `modified_at` datetime DEFAULT NULL,
  `is_dismissed` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `account_message_prefs_FI_1` (`account_id`),
  KEY `account_message_prefs_FI_2` (`user_id`),
  CONSTRAINT `account_message_prefs_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `account_message_prefs_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_message_prefs`
--

LOCK TABLES `account_message_prefs` WRITE;
/*!40000 ALTER TABLE `account_message_prefs` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_message_prefs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_report`
--

DROP TABLE IF EXISTS `account_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `api_requests` int(11) DEFAULT '0',
  `prospects` int(11) DEFAULT '0',
  `emails` int(11) DEFAULT '0',
  `page_views` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_report_FI_1` (`account_id`),
  CONSTRAINT `account_report_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_report`
--

LOCK TABLES `account_report` WRITE;
/*!40000 ALTER TABLE `account_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_scoring_model`
--

DROP TABLE IF EXISTS `account_scoring_model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_scoring_model` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `page_view_score` int(11) NOT NULL DEFAULT '1',
  `tracker_link_click_score` int(11) NOT NULL DEFAULT '3',
  `landing_page_success_score` int(11) NOT NULL DEFAULT '50',
  `landing_page_error_score` int(11) NOT NULL DEFAULT '-5',
  `form_submission_score` int(11) NOT NULL DEFAULT '50',
  `form_error_score` int(11) NOT NULL DEFAULT '-5',
  `form_handler_submission_score` int(11) NOT NULL DEFAULT '50',
  `form_handler_error_score` int(11) NOT NULL DEFAULT '-5',
  `site_search_query_score` int(11) NOT NULL DEFAULT '3',
  `email_open_score` int(11) NOT NULL DEFAULT '0',
  `opportunity_lost_score` int(11) NOT NULL DEFAULT '-100',
  `opportunity_won_score` int(11) NOT NULL DEFAULT '0',
  `opportunity_created_score` int(11) NOT NULL DEFAULT '50',
  `visitor_session_score` int(11) NOT NULL DEFAULT '3',
  `file_access_score` int(11) NOT NULL DEFAULT '3',
  `third_party_click_score` int(11) NOT NULL DEFAULT '3',
  `custom_url_click_score` int(11) NOT NULL DEFAULT '3',
  `olark_chat_score` int(11) NOT NULL DEFAULT '10',
  `webinar_invited_score` int(11) NOT NULL DEFAULT '0',
  `webinar_attended_score` int(11) NOT NULL DEFAULT '0',
  `webinar_registered_score` int(11) NOT NULL DEFAULT '0',
  `meeting_invited_score` int(11) NOT NULL DEFAULT '0',
  `meeting_attended_score` int(11) NOT NULL DEFAULT '0',
  `meeting_registered_score` int(11) NOT NULL DEFAULT '0',
  `social_message_link_click_score` int(11) NOT NULL DEFAULT '0',
  `video_play_score` int(11) NOT NULL DEFAULT '10',
  `event_registered_score` int(11) NOT NULL DEFAULT '0',
  `event_checked_in_score` int(11) NOT NULL DEFAULT '0',
  `uservoice_suggestion_score` int(11) NOT NULL DEFAULT '0',
  `uservoice_comment_score` int(11) NOT NULL DEFAULT '0',
  `uservoice_ticket_score` int(11) NOT NULL DEFAULT '0',
  `video_conversion_score` int(11) NOT NULL DEFAULT '50',
  `video_watched_threequarters_score` int(11) NOT NULL DEFAULT '25',
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_id` (`account_id`),
  KEY `account_scoring_model_FI_2` (`updated_by`),
  CONSTRAINT `account_scoring_model_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `account_scoring_model_FK_2` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_scoring_model`
--

LOCK TABLES `account_scoring_model` WRITE;
/*!40000 ALTER TABLE `account_scoring_model` DISABLE KEYS */;
INSERT INTO `account_scoring_model` VALUES (1,2,1,3,50,-5,50,-5,50,-5,3,0,-100,0,50,3,3,3,3,10,0,0,0,0,0,0,0,10,0,0,0,0,0,50,25,'2016-03-24 16:07:14',NULL);
/*!40000 ALTER TABLE `account_scoring_model` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_setting`
--

DROP TABLE IF EXISTS `account_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_setting` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `setting_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `setting_value` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`account_id`,`setting_key`),
  CONSTRAINT `account_setting_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_setting`
--

LOCK TABLES `account_setting` WRITE;
/*!40000 ALTER TABLE `account_setting` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_setting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_request`
--

DROP TABLE IF EXISTS `api_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_request` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `api_key_id` int(11) DEFAULT NULL,
  `api_version` int(11) DEFAULT NULL,
  `module_type` int(11) NOT NULL,
  `action_type` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `api_request_FI_1` (`account_id`),
  KEY `api_request_FI_2` (`user_id`),
  CONSTRAINT `api_request_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `api_request_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_request`
--

LOCK TABLES `api_request` WRITE;
/*!40000 ALTER TABLE `api_request` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `fid` int(11) DEFAULT NULL,
  `type` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `update_type` int(11) DEFAULT NULL,
  `audit` text COLLATE utf8_unicode_ci,
  `is_processed` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ix_is_processed` (`account_id`,`is_processed`),
  CONSTRAINT `audit_log_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auto_save`
--

DROP TABLE IF EXISTS `auto_save`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_save` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `which_editor` int(11) DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auto_save_FI_1` (`account_id`),
  KEY `auto_save_FI_2` (`user_id`),
  CONSTRAINT `auto_save_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `auto_save_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auto_save`
--

LOCK TABLES `auto_save` WRITE;
/*!40000 ALTER TABLE `auto_save` DISABLE KEYS */;
/*!40000 ALTER TABLE `auto_save` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation`
--

DROP TABLE IF EXISTS `automation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `match_type` int(11) DEFAULT '1',
  `last_run_at` datetime DEFAULT NULL,
  `runtime` float DEFAULT NULL,
  `metadata` text COLLATE utf8_unicode_ci,
  `last_processed_automation_history_id` int(11) DEFAULT NULL,
  `is_paused` int(11) DEFAULT '0',
  `is_being_processed` int(11) DEFAULT '0',
  `is_real_time` tinyint(1) DEFAULT '0',
  `is_archived` tinyint(1) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `automation_FI_1` (`account_id`),
  KEY `automation_FI_2` (`campaign_id`),
  KEY `automation_FI_3` (`last_processed_automation_history_id`),
  KEY `automation_FI_4` (`created_by`),
  KEY `automation_FI_5` (`updated_by`),
  CONSTRAINT `automation_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `automation_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `automation_FK_3` FOREIGN KEY (`last_processed_automation_history_id`) REFERENCES `automation_history` (`id`),
  CONSTRAINT `automation_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `automation_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation`
--

LOCK TABLES `automation` WRITE;
/*!40000 ALTER TABLE `automation` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_action`
--

DROP TABLE IF EXISTS `automation_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automation_action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `automation_id` int(11) DEFAULT NULL,
  `action` int(11) DEFAULT NULL,
  `target` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `queue_id` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `groupx_id` int(11) DEFAULT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `profile_criteria_id` int(11) DEFAULT NULL,
  `form_field_id` int(11) DEFAULT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `crm_task_template_id` int(11) DEFAULT NULL,
  `scoring_category_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `automation_action_FI_1` (`account_id`),
  KEY `automation_action_FI_2` (`automation_id`),
  KEY `automation_action_FI_3` (`user_id`),
  KEY `automation_action_FI_4` (`queue_id`),
  KEY `automation_action_FI_5` (`campaign_id`),
  KEY `automation_action_FI_6` (`groupx_id`),
  KEY `automation_action_FI_7` (`email_template_id`),
  KEY `automation_action_FI_8` (`listx_id`),
  KEY `automation_action_FI_9` (`profile_criteria_id`),
  KEY `automation_action_FI_10` (`form_field_id`),
  KEY `automation_action_FI_11` (`prospect_field_default_id`),
  KEY `automation_action_FI_12` (`prospect_field_custom_id`),
  KEY `automation_action_FI_13` (`crm_task_template_id`),
  KEY `automation_action_FI_14` (`scoring_category_id`),
  KEY `automation_action_FI_15` (`created_by`),
  KEY `automation_action_FI_16` (`updated_by`),
  CONSTRAINT `automation_action_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `automation_action_FK_10` FOREIGN KEY (`form_field_id`) REFERENCES `form_field` (`id`),
  CONSTRAINT `automation_action_FK_11` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `automation_action_FK_12` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`),
  CONSTRAINT `automation_action_FK_13` FOREIGN KEY (`crm_task_template_id`) REFERENCES `crm_task_template` (`id`),
  CONSTRAINT `automation_action_FK_14` FOREIGN KEY (`scoring_category_id`) REFERENCES `scoring_category` (`id`),
  CONSTRAINT `automation_action_FK_15` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `automation_action_FK_16` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `automation_action_FK_2` FOREIGN KEY (`automation_id`) REFERENCES `automation` (`id`),
  CONSTRAINT `automation_action_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `automation_action_FK_4` FOREIGN KEY (`queue_id`) REFERENCES `queue` (`id`),
  CONSTRAINT `automation_action_FK_5` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `automation_action_FK_6` FOREIGN KEY (`groupx_id`) REFERENCES `groupx` (`id`),
  CONSTRAINT `automation_action_FK_7` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`),
  CONSTRAINT `automation_action_FK_8` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `automation_action_FK_9` FOREIGN KEY (`profile_criteria_id`) REFERENCES `profile_criteria` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_action`
--

LOCK TABLES `automation_action` WRITE;
/*!40000 ALTER TABLE `automation_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_error`
--

DROP TABLE IF EXISTS `automation_error`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automation_error` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `type` tinyint(4) DEFAULT NULL,
  `auto_id` int(11) DEFAULT NULL,
  `rule_id` int(11) DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_type_auto_id` (`account_id`,`type`,`auto_id`),
  CONSTRAINT `automation_error_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_error`
--

LOCK TABLES `automation_error` WRITE;
/*!40000 ALTER TABLE `automation_error` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_error` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_history`
--

DROP TABLE IF EXISTS `automation_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automation_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `automation_id` int(11) NOT NULL,
  `revision_data` text COLLATE utf8_unicode_ci,
  `diff_data` text COLLATE utf8_unicode_ci,
  `change_type` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `is_paused` int(11) DEFAULT '0',
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `automation_history_FI_1` (`account_id`),
  KEY `automation_history_FI_2` (`automation_id`),
  KEY `automation_history_FI_3` (`updated_by`),
  CONSTRAINT `automation_history_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `automation_history_FK_2` FOREIGN KEY (`automation_id`) REFERENCES `automation` (`id`),
  CONSTRAINT `automation_history_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_history`
--

LOCK TABLES `automation_history` WRITE;
/*!40000 ALTER TABLE `automation_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_preview`
--

DROP TABLE IF EXISTS `automation_preview`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automation_preview` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `automation_id` int(11) DEFAULT NULL,
  `num_matched` int(11) DEFAULT '0',
  `is_finished` int(11) DEFAULT '0',
  `last_updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `notify_email` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auto_id` (`automation_id`),
  KEY `automation_preview_FI_1` (`account_id`),
  CONSTRAINT `automation_preview_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `automation_preview_FK_2` FOREIGN KEY (`automation_id`) REFERENCES `automation` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_preview`
--

LOCK TABLES `automation_preview` WRITE;
/*!40000 ALTER TABLE `automation_preview` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_preview` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_preview_prospect`
--

DROP TABLE IF EXISTS `automation_preview_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automation_preview_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `automation_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `automation_preview_prospect_FI_1` (`account_id`),
  KEY `automation_preview_prospect_FI_2` (`automation_id`),
  KEY `automation_preview_prospect_FI_3` (`prospect_id`),
  CONSTRAINT `automation_preview_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `automation_preview_prospect_FK_2` FOREIGN KEY (`automation_id`) REFERENCES `automation` (`id`),
  CONSTRAINT `automation_preview_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_preview_prospect`
--

LOCK TABLES `automation_preview_prospect` WRITE;
/*!40000 ALTER TABLE `automation_preview_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_preview_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_prospect`
--

DROP TABLE IF EXISTS `automation_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automation_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `automation_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `has_applied_actions` tinyint(4) NOT NULL DEFAULT '0',
  `process_id` int(11) DEFAULT '0',
  `actions_applied_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_entry` (`account_id`,`automation_id`,`prospect_id`),
  KEY `ix_haap` (`has_applied_actions`,`process_id`),
  KEY `automation_prospect_FI_2` (`automation_id`),
  KEY `automation_prospect_FI_3` (`prospect_id`),
  KEY `automation_prospect_FI_4` (`user_id`),
  CONSTRAINT `automation_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `automation_prospect_FK_2` FOREIGN KEY (`automation_id`) REFERENCES `automation` (`id`),
  CONSTRAINT `automation_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `automation_prospect_FK_4` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_prospect`
--

LOCK TABLES `automation_prospect` WRITE;
/*!40000 ALTER TABLE `automation_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `automation_rule`
--

DROP TABLE IF EXISTS `automation_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `automation_rule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `automation_id` int(11) DEFAULT NULL,
  `automation_rule_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `object_type` int(11) DEFAULT NULL,
  `compare` int(11) DEFAULT NULL,
  `operator` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `custom_url_id` int(11) DEFAULT NULL,
  `filex_id` int(11) DEFAULT NULL,
  `form_field_id` int(11) DEFAULT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `queue_id` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `form_handler_id` int(11) DEFAULT NULL,
  `landing_page_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `field_id` int(11) DEFAULT NULL,
  `webinar_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `crm_campaign_id` int(11) DEFAULT NULL,
  `crm_campaign_status_id` int(11) DEFAULT NULL,
  `scoring_category_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `automation_rule_FI_1` (`account_id`),
  KEY `automation_rule_FI_2` (`automation_id`),
  KEY `automation_rule_FI_3` (`automation_rule_id`),
  KEY `automation_rule_FI_4` (`custom_url_id`),
  KEY `automation_rule_FI_5` (`filex_id`),
  KEY `automation_rule_FI_6` (`form_field_id`),
  KEY `automation_rule_FI_7` (`prospect_field_default_id`),
  KEY `automation_rule_FI_8` (`prospect_field_custom_id`),
  KEY `automation_rule_FI_9` (`user_id`),
  KEY `automation_rule_FI_10` (`queue_id`),
  KEY `automation_rule_FI_11` (`form_id`),
  KEY `automation_rule_FI_12` (`form_handler_id`),
  KEY `automation_rule_FI_13` (`landing_page_id`),
  KEY `automation_rule_FI_14` (`listx_id`),
  KEY `automation_rule_FI_15` (`field_id`),
  KEY `automation_rule_FI_16` (`webinar_id`),
  KEY `automation_rule_FI_17` (`profile_id`),
  KEY `automation_rule_FI_18` (`crm_campaign_id`),
  KEY `automation_rule_FI_19` (`crm_campaign_status_id`),
  KEY `automation_rule_FI_20` (`scoring_category_id`),
  KEY `automation_rule_FI_21` (`created_by`),
  KEY `automation_rule_FI_22` (`updated_by`),
  CONSTRAINT `automation_rule_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `automation_rule_FK_10` FOREIGN KEY (`queue_id`) REFERENCES `queue` (`id`),
  CONSTRAINT `automation_rule_FK_11` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `automation_rule_FK_12` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`),
  CONSTRAINT `automation_rule_FK_13` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `automation_rule_FK_14` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `automation_rule_FK_15` FOREIGN KEY (`field_id`) REFERENCES `field` (`id`),
  CONSTRAINT `automation_rule_FK_16` FOREIGN KEY (`webinar_id`) REFERENCES `webinar` (`id`),
  CONSTRAINT `automation_rule_FK_17` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`),
  CONSTRAINT `automation_rule_FK_18` FOREIGN KEY (`crm_campaign_id`) REFERENCES `crm_campaign` (`id`),
  CONSTRAINT `automation_rule_FK_19` FOREIGN KEY (`crm_campaign_status_id`) REFERENCES `crm_campaign_status` (`id`),
  CONSTRAINT `automation_rule_FK_2` FOREIGN KEY (`automation_id`) REFERENCES `automation` (`id`),
  CONSTRAINT `automation_rule_FK_20` FOREIGN KEY (`scoring_category_id`) REFERENCES `scoring_category` (`id`),
  CONSTRAINT `automation_rule_FK_21` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `automation_rule_FK_22` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `automation_rule_FK_3` FOREIGN KEY (`automation_rule_id`) REFERENCES `automation_rule` (`id`),
  CONSTRAINT `automation_rule_FK_4` FOREIGN KEY (`custom_url_id`) REFERENCES `custom_url` (`id`),
  CONSTRAINT `automation_rule_FK_5` FOREIGN KEY (`filex_id`) REFERENCES `filex` (`id`),
  CONSTRAINT `automation_rule_FK_6` FOREIGN KEY (`form_field_id`) REFERENCES `form_field` (`id`),
  CONSTRAINT `automation_rule_FK_7` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `automation_rule_FK_8` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`),
  CONSTRAINT `automation_rule_FK_9` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `automation_rule`
--

LOCK TABLES `automation_rule` WRITE;
/*!40000 ALTER TABLE `automation_rule` DISABLE KEYS */;
/*!40000 ALTER TABLE `automation_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `background_queue`
--

DROP TABLE IF EXISTS `background_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `background_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `parameters` mediumtext COLLATE utf8_unicode_ci,
  `type` int(11) DEFAULT NULL,
  `is_ready` int(11) DEFAULT '1',
  `is_finished` int(11) DEFAULT '0',
  `is_cancelled` int(11) DEFAULT '0',
  `num_items` int(11) DEFAULT '0',
  `job_id` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `background_queue_FI_1` (`account_id`),
  KEY `background_queue_FI_2` (`user_id`),
  KEY `background_queue_FI_3` (`created_by`),
  KEY `background_queue_FI_4` (`updated_by`),
  CONSTRAINT `background_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `background_queue_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `background_queue_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `background_queue_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `background_queue`
--

LOCK TABLES `background_queue` WRITE;
/*!40000 ALTER TABLE `background_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `background_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `background_queue_job`
--

DROP TABLE IF EXISTS `background_queue_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `background_queue_job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `background_queue_id` int(11) DEFAULT NULL,
  `content` mediumtext COLLATE utf8_unicode_ci,
  `binary_content` longblob,
  `is_being_processed` int(11) DEFAULT '0',
  `is_finished` int(11) DEFAULT '0',
  `job_id` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_lock_for_queue` (`account_id`,`background_queue_id`,`is_finished`,`is_being_processed`,`job_id`),
  KEY `background_queue_job_FI_2` (`background_queue_id`),
  CONSTRAINT `background_queue_job_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `background_queue_job_FK_2` FOREIGN KEY (`background_queue_id`) REFERENCES `background_queue` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `background_queue_job`
--

LOCK TABLES `background_queue_job` WRITE;
/*!40000 ALTER TABLE `background_queue_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `background_queue_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bitly_url`
--

DROP TABLE IF EXISTS `bitly_url`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bitly_url` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `short_url` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `long_url` text COLLATE utf8_unicode_ci,
  `is_personalized` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bitly_url_FI_1` (`account_id`),
  CONSTRAINT `bitly_url_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bitly_url`
--

LOCK TABLES `bitly_url` WRITE;
/*!40000 ALTER TABLE `bitly_url` DISABLE KEYS */;
/*!40000 ALTER TABLE `bitly_url` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `block`
--

DROP TABLE IF EXISTS `block`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `block` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `display_content` text COLLATE utf8_unicode_ci,
  `is_archived` tinyint(1) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `block_FI_1` (`account_id`),
  KEY `block_FI_2` (`created_by`),
  KEY `block_FI_3` (`updated_by`),
  CONSTRAINT `block_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `block_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `block_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `block`
--

LOCK TABLES `block` WRITE;
/*!40000 ALTER TABLE `block` DISABLE KEYS */;
/*!40000 ALTER TABLE `block` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calendar_event`
--

DROP TABLE IF EXISTS `calendar_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calendar_event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `icon` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `color` varchar(6) COLLATE utf8_unicode_ci NOT NULL,
  `start` datetime NOT NULL,
  `end` datetime DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `all_day` int(11) NOT NULL DEFAULT '0',
  `is_archived` int(11) NOT NULL DEFAULT '0',
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `both_ts` (`account_id`,`is_archived`,`start`,`end`),
  KEY `end_ts` (`account_id`,`is_archived`,`end`),
  KEY `calendar_event_FI_2` (`created_by`),
  KEY `calendar_event_FI_3` (`updated_by`),
  CONSTRAINT `calendar_event_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `calendar_event_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `calendar_event_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calendar_event`
--

LOCK TABLES `calendar_event` WRITE;
/*!40000 ALTER TABLE `calendar_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `calendar_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign`
--

DROP TABLE IF EXISTS `campaign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) DEFAULT NULL,
  `crm_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_campaign_id` int(11) DEFAULT NULL,
  `name` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cost` float DEFAULT NULL,
  `is_active` int(11) DEFAULT '1',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `campaign_FI_1` (`account_id`),
  KEY `campaign_FI_2` (`connector_id`),
  KEY `campaign_FI_3` (`crm_campaign_id`),
  KEY `campaign_FI_4` (`created_by`),
  KEY `campaign_FI_5` (`updated_by`),
  CONSTRAINT `campaign_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `campaign_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `campaign_FK_3` FOREIGN KEY (`crm_campaign_id`) REFERENCES `crm_campaign` (`id`),
  CONSTRAINT `campaign_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `campaign_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign`
--

LOCK TABLES `campaign` WRITE;
/*!40000 ALTER TABLE `campaign` DISABLE KEYS */;
INSERT INTO `campaign` VALUES (1,2,NULL,NULL,NULL,'Website Tracking',NULL,1,NULL,NULL,NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,NULL,NULL,NULL,'Email Plug-in',NULL,1,NULL,NULL,NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `campaign` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_action`
--

DROP TABLE IF EXISTS `campaign_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `trigger_type` int(11) NOT NULL,
  `trigger_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `campaign_member_status_id` int(11) DEFAULT NULL,
  `execution_order` int(11) NOT NULL DEFAULT '1',
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_execution_order_per_trigger` (`account_id`,`trigger_id`,`trigger_type`,`execution_order`),
  KEY `campaign_action_FI_2` (`campaign_id`),
  KEY `campaign_action_FI_3` (`campaign_member_status_id`),
  KEY `campaign_action_FI_4` (`created_by`),
  KEY `campaign_action_FI_5` (`updated_by`),
  CONSTRAINT `campaign_action_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `campaign_action_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `campaign_action_FK_3` FOREIGN KEY (`campaign_member_status_id`) REFERENCES `campaign_member_status` (`id`),
  CONSTRAINT `campaign_action_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `campaign_action_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_action`
--

LOCK TABLES `campaign_action` WRITE;
/*!40000 ALTER TABLE `campaign_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_cohort_stats`
--

DROP TABLE IF EXISTS `campaign_cohort_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_cohort_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `stats_date` date NOT NULL,
  `prospects` int(11) DEFAULT '0',
  `assigned_prospects` int(11) DEFAULT '0',
  `opportunities` int(11) DEFAULT '0',
  `days_to_opp` int(11) DEFAULT '0',
  `opp_value` int(11) DEFAULT '0',
  `revenue` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campaign_cohort_stats_lookup` (`account_id`,`campaign_id`,`stats_date`),
  KEY `campaign_cohort_stats_FI_2` (`campaign_id`),
  CONSTRAINT `campaign_cohort_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `campaign_cohort_stats_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_cohort_stats`
--

LOCK TABLES `campaign_cohort_stats` WRITE;
/*!40000 ALTER TABLE `campaign_cohort_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_cohort_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_member_audit`
--

DROP TABLE IF EXISTS `campaign_member_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_member_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `type` int(11) NOT NULL,
  `trigger_type` int(11) NOT NULL,
  `trigger_id` int(11) NOT NULL,
  `campaign_member_status_id` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_prospect_audits` (`account_id`,`prospect_id`,`campaign_id`),
  KEY `ix_trigger_object_audits` (`account_id`,`trigger_id`,`trigger_type`),
  KEY `campaign_member_audit_FI_2` (`campaign_id`),
  KEY `campaign_member_audit_FI_3` (`prospect_id`),
  KEY `campaign_member_audit_FI_4` (`visitor_id`),
  KEY `campaign_member_audit_FI_5` (`campaign_member_status_id`),
  CONSTRAINT `campaign_member_audit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `campaign_member_audit_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `campaign_member_audit_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `campaign_member_audit_FK_4` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `campaign_member_audit_FK_5` FOREIGN KEY (`campaign_member_status_id`) REFERENCES `campaign_member_status` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_member_audit`
--

LOCK TABLES `campaign_member_audit` WRITE;
/*!40000 ALTER TABLE `campaign_member_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_member_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_member_audit_external_key`
--

DROP TABLE IF EXISTS `campaign_member_audit_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_member_audit_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_campaign_member_audit_id` FOREIGN KEY (`id`) REFERENCES `campaign_member_audit` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_member_audit_external_key`
--

LOCK TABLES `campaign_member_audit_external_key` WRITE;
/*!40000 ALTER TABLE `campaign_member_audit_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_member_audit_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_member_status`
--

DROP TABLE IF EXISTS `campaign_member_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_member_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `connector_id` int(11) DEFAULT NULL,
  `crm_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `priority` int(11) DEFAULT '0',
  `is_default` int(11) DEFAULT '0',
  `has_responded` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `crm_campaign_status_fid` (`campaign_id`,`crm_fid`),
  KEY `campaign_member_status_FI_1` (`account_id`),
  KEY `campaign_member_status_FI_3` (`connector_id`),
  KEY `campaign_member_status_FI_4` (`created_by`),
  KEY `campaign_member_status_FI_5` (`updated_by`),
  CONSTRAINT `campaign_member_status_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `campaign_member_status_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `campaign_member_status_FK_3` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `campaign_member_status_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `campaign_member_status_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_member_status`
--

LOCK TABLES `campaign_member_status` WRITE;
/*!40000 ALTER TABLE `campaign_member_status` DISABLE KEYS */;
INSERT INTO `campaign_member_status` VALUES (1,2,1,NULL,NULL,'Sent',0,1,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,1,NULL,NULL,'Responded',1,0,1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,2,2,NULL,NULL,'Sent',0,1,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(4,2,2,NULL,NULL,'Responded',1,0,1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `campaign_member_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_membership_audit`
--

DROP TABLE IF EXISTS `campaign_membership_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_membership_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `metadata` text COLLATE utf8_unicode_ci,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `campaign_membership_audit_FI_1` (`account_id`),
  KEY `campaign_membership_audit_FI_2` (`prospect_id`),
  KEY `campaign_membership_audit_FI_3` (`campaign_id`),
  KEY `campaign_membership_audit_FI_4` (`user_id`),
  CONSTRAINT `campaign_membership_audit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `campaign_membership_audit_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `campaign_membership_audit_FK_3` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `campaign_membership_audit_FK_4` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_membership_audit`
--

LOCK TABLES `campaign_membership_audit` WRITE;
/*!40000 ALTER TABLE `campaign_membership_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_membership_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_prospect`
--

DROP TABLE IF EXISTS `campaign_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `prospect_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_source` int(11) DEFAULT '0',
  `is_manual` int(11) DEFAULT '0',
  `campaign_member_status_id` int(11) NOT NULL,
  `crm_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_crm_synced` int(11) DEFAULT '0',
  `override_crm` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campaign_member` (`account_id`,`campaign_id`,`prospect_id`),
  KEY `ix_members_with_status` (`account_id`,`campaign_id`,`campaign_member_status_id`),
  KEY `campaign_prospect_FI_2` (`campaign_id`),
  KEY `campaign_prospect_FI_3` (`prospect_id`),
  KEY `campaign_prospect_FI_4` (`campaign_member_status_id`),
  CONSTRAINT `campaign_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `campaign_prospect_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `campaign_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `campaign_prospect_FK_4` FOREIGN KEY (`campaign_member_status_id`) REFERENCES `campaign_member_status` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_prospect`
--

LOCK TABLES `campaign_prospect` WRITE;
/*!40000 ALTER TABLE `campaign_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_source_stats`
--

DROP TABLE IF EXISTS `campaign_source_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_source_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `opportunity_id` int(11) DEFAULT NULL,
  `opportunity_value` float DEFAULT NULL,
  `opportunity_revenue` float DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `join_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campaign_member` (`account_id`,`prospect_id`,`visitor_id`,`opportunity_id`),
  KEY `ix_stats` (`account_id`,`campaign_id`,`is_archived`,`join_date`),
  KEY `campaign_source_stats_FI_2` (`campaign_id`),
  KEY `campaign_source_stats_FI_3` (`prospect_id`),
  KEY `campaign_source_stats_FI_4` (`visitor_id`),
  KEY `campaign_source_stats_FI_5` (`opportunity_id`),
  CONSTRAINT `campaign_source_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `campaign_source_stats_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `campaign_source_stats_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `campaign_source_stats_FK_4` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `campaign_source_stats_FK_5` FOREIGN KEY (`opportunity_id`) REFERENCES `opportunity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_source_stats`
--

LOCK TABLES `campaign_source_stats` WRITE;
/*!40000 ALTER TABLE `campaign_source_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_source_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_source_stats_external_key`
--

DROP TABLE IF EXISTS `campaign_source_stats_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_source_stats_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_campaign_source_stats_id` FOREIGN KEY (`id`) REFERENCES `campaign_source_stats` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_source_stats_external_key`
--

LOCK TABLES `campaign_source_stats_external_key` WRITE;
/*!40000 ALTER TABLE `campaign_source_stats_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_source_stats_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_stats`
--

DROP TABLE IF EXISTS `campaign_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `stats_date` date NOT NULL,
  `visitors` int(11) DEFAULT '0',
  `prospects` int(11) DEFAULT '0',
  `assigned_prospects` int(11) DEFAULT '0',
  `opportunities` int(11) DEFAULT '0',
  `opp_value` int(11) DEFAULT '0',
  `revenue` int(11) DEFAULT '0',
  `opp_days_to_create` int(11) DEFAULT '0',
  `opp_days_to_close` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `campaign_stats_lookup` (`account_id`,`campaign_id`,`stats_date`),
  KEY `campaign_stats_FI_2` (`campaign_id`),
  CONSTRAINT `campaign_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `campaign_stats_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_stats`
--

LOCK TABLES `campaign_stats` WRITE;
/*!40000 ALTER TABLE `campaign_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_touch`
--

DROP TABLE IF EXISTS `campaign_touch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_touch` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `type` int(11) NOT NULL,
  `trigger_type` int(11) DEFAULT NULL,
  `trigger_id` int(11) DEFAULT NULL,
  `campaign_member_status_id` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_prospect_audits` (`account_id`,`prospect_id`,`campaign_id`),
  KEY `ix_trigger_object_audits` (`account_id`,`trigger_id`,`trigger_type`),
  KEY `campaign_touch_FI_2` (`campaign_id`),
  KEY `campaign_touch_FI_3` (`prospect_id`),
  KEY `campaign_touch_FI_4` (`visitor_id`),
  KEY `campaign_touch_FI_5` (`campaign_member_status_id`),
  KEY `campaign_touch_FI_6` (`created_by`),
  CONSTRAINT `campaign_touch_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `campaign_touch_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `campaign_touch_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `campaign_touch_FK_4` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `campaign_touch_FK_5` FOREIGN KEY (`campaign_member_status_id`) REFERENCES `campaign_member_status` (`id`),
  CONSTRAINT `campaign_touch_FK_6` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_touch`
--

LOCK TABLES `campaign_touch` WRITE;
/*!40000 ALTER TABLE `campaign_touch` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_touch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_touch_external_key`
--

DROP TABLE IF EXISTS `campaign_touch_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaign_touch_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_campaign_touch_id` FOREIGN KEY (`id`) REFERENCES `campaign_touch` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_touch_external_key`
--

LOCK TABLES `campaign_touch_external_key` WRITE;
/*!40000 ALTER TABLE `campaign_touch_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_touch_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `competitor`
--

DROP TABLE IF EXISTS `competitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `competitor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `site` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `is_default` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `stats_checked_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `competitor_FI_1` (`account_id`),
  KEY `competitor_FI_2` (`created_by`),
  KEY `competitor_FI_3` (`updated_by`),
  CONSTRAINT `competitor_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `competitor_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `competitor_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `competitor`
--

LOCK TABLES `competitor` WRITE;
/*!40000 ALTER TABLE `competitor` DISABLE KEYS */;
/*!40000 ALTER TABLE `competitor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `competitor_stats`
--

DROP TABLE IF EXISTS `competitor_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `competitor_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `competitor_id` int(11) NOT NULL,
  `stats_date` date NOT NULL,
  `google_indexed_pages` int(11) DEFAULT NULL,
  `google_inbound_links` int(11) DEFAULT NULL,
  `google_pagerank` int(11) DEFAULT NULL,
  `alexa_rank` int(11) DEFAULT NULL,
  `is_current` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `competitor_stats_lookup` (`competitor_id`,`stats_date`),
  KEY `competitor_stats_FI_1` (`account_id`),
  CONSTRAINT `competitor_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `competitor_stats_FK_2` FOREIGN KEY (`competitor_id`) REFERENCES `competitor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `competitor_stats`
--

LOCK TABLES `competitor_stats` WRITE;
/*!40000 ALTER TABLE `competitor_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `competitor_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `completion_action`
--

DROP TABLE IF EXISTS `completion_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `completion_action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `type` int(11) NOT NULL DEFAULT '1',
  `trigger_type` int(11) NOT NULL DEFAULT '1',
  `trigger_id` int(11) NOT NULL,
  `completion_object_id` int(11) DEFAULT NULL,
  `completion_object_value` text COLLATE utf8_unicode_ci,
  `crm_task_template_id` int(11) DEFAULT NULL,
  `execution_order` int(11) NOT NULL DEFAULT '1',
  `is_archived` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `completion_action_unique_index2` (`trigger_type`,`trigger_id`,`execution_order`),
  UNIQUE KEY `completion_action_unique_index` (`trigger_type`,`trigger_id`,`type`,`completion_object_id`),
  KEY `completion_action_FI_1` (`account_id`),
  KEY `completion_action_FI_2` (`crm_task_template_id`),
  CONSTRAINT `completion_action_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `completion_action_FK_2` FOREIGN KEY (`crm_task_template_id`) REFERENCES `crm_task_template` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `completion_action`
--

LOCK TABLES `completion_action` WRITE;
/*!40000 ALTER TABLE `completion_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `completion_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `completion_rule`
--

DROP TABLE IF EXISTS `completion_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `completion_rule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `trigger_type` int(11) NOT NULL DEFAULT '1',
  `trigger_id` int(11) NOT NULL,
  `type` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `completion_rule_FI_1` (`account_id`),
  CONSTRAINT `completion_rule_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `completion_rule`
--

LOCK TABLES `completion_rule` WRITE;
/*!40000 ALTER TABLE `completion_rule` DISABLE KEYS */;
/*!40000 ALTER TABLE `completion_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `connector`
--

DROP TABLE IF EXISTS `connector`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connector` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_vendor_id` int(11) DEFAULT NULL,
  `connector_category_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `username` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `encrypted_password` text COLLATE utf8_unicode_ci,
  `encrypted_oauth_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` text COLLATE utf8_unicode_ci,
  `last_synced_at` datetime DEFAULT NULL,
  `last_synced_metadata_at` datetime DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `connector_FI_1` (`account_id`),
  KEY `connector_FI_2` (`created_by`),
  KEY `connector_FI_3` (`updated_by`),
  CONSTRAINT `connector_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `connector_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `connector_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connector`
--

LOCK TABLES `connector` WRITE;
/*!40000 ALTER TABLE `connector` DISABLE KEYS */;
INSERT INTO `connector` VALUES (1,2,12,5,'LinkedIn',NULL,NULL,NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,14,5,'Data.com',NULL,NULL,NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `connector` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `connector_activity`
--

DROP TABLE IF EXISTS `connector_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connector_activity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `type` int(11) DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `is_archived` int(11) DEFAULT '0',
  `object_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `connector_activity_FI_1` (`account_id`),
  CONSTRAINT `connector_activity_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connector_activity`
--

LOCK TABLES `connector_activity` WRITE;
/*!40000 ALTER TABLE `connector_activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `connector_activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `connector_error`
--

DROP TABLE IF EXISTS `connector_error`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connector_error` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `short_error` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `long_error` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `is_public` int(11) DEFAULT '0',
  `duration` int(11) DEFAULT '0',
  `severity` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `connector_error_FI_1` (`account_id`),
  KEY `connector_error_FI_2` (`connector_id`),
  CONSTRAINT `connector_error_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `connector_error_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connector_error`
--

LOCK TABLES `connector_error` WRITE;
/*!40000 ALTER TABLE `connector_error` DISABLE KEYS */;
/*!40000 ALTER TABLE `connector_error` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `connector_metadata`
--

DROP TABLE IF EXISTS `connector_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connector_metadata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `metadata_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `metadata_value` text COLLATE utf8_unicode_ci,
  `sort_order` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `connector_metadata_FI_1` (`account_id`),
  KEY `connector_metadata_FI_2` (`connector_id`),
  KEY `connector_metadata_FI_3` (`created_by`),
  KEY `connector_metadata_FI_4` (`updated_by`),
  CONSTRAINT `connector_metadata_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `connector_metadata_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `connector_metadata_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `connector_metadata_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connector_metadata`
--

LOCK TABLES `connector_metadata` WRITE;
/*!40000 ALTER TABLE `connector_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `connector_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `connector_metadata_listx`
--

DROP TABLE IF EXISTS `connector_metadata_listx`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connector_metadata_listx` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_metadata_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `connector_metadata_listx_FI_1` (`account_id`),
  KEY `connector_metadata_listx_FI_2` (`connector_metadata_id`),
  KEY `connector_metadata_listx_FI_3` (`listx_id`),
  CONSTRAINT `connector_metadata_listx_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `connector_metadata_listx_FK_2` FOREIGN KEY (`connector_metadata_id`) REFERENCES `connector_metadata` (`id`),
  CONSTRAINT `connector_metadata_listx_FK_3` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connector_metadata_listx`
--

LOCK TABLES `connector_metadata_listx` WRITE;
/*!40000 ALTER TABLE `connector_metadata_listx` DISABLE KEYS */;
/*!40000 ALTER TABLE `connector_metadata_listx` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `connector_session_metadata`
--

DROP TABLE IF EXISTS `connector_session_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connector_session_metadata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) DEFAULT NULL,
  `metadata_key` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `metadata_value` varchar(2000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `connector_session_metadata_FI_1` (`account_id`),
  KEY `connector_session_metadata_FI_2` (`connector_id`),
  KEY `connector_session_metadata_FI_3` (`created_by`),
  KEY `connector_session_metadata_FI_4` (`updated_by`),
  CONSTRAINT `connector_session_metadata_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `connector_session_metadata_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `connector_session_metadata_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `connector_session_metadata_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connector_session_metadata`
--

LOCK TABLES `connector_session_metadata` WRITE;
/*!40000 ALTER TABLE `connector_session_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `connector_session_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `connector_stats`
--

DROP TABLE IF EXISTS `connector_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connector_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `call_type` int(11) DEFAULT '0',
  `call_subtype` int(11) DEFAULT '0',
  `object_type` int(11) DEFAULT '0',
  `job_uses` int(11) DEFAULT '0',
  `total_uses` int(11) DEFAULT '0',
  `calls` int(11) DEFAULT '0',
  `stats_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `connector_stats_lookup` (`account_id`,`connector_id`,`call_type`,`call_subtype`,`object_type`,`stats_date`),
  KEY `connector_stats_FI_2` (`connector_id`),
  CONSTRAINT `connector_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `connector_stats_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connector_stats`
--

LOCK TABLES `connector_stats` WRITE;
/*!40000 ALTER TABLE `connector_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `connector_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_campaign`
--

DROP TABLE IF EXISTS `crm_campaign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_campaign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_fid` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `is_archived` int(11) DEFAULT '0',
  `is_active` int(11) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `crm_campaign_fid` (`account_id`,`connector_id`,`crm_fid`),
  KEY `crm_campaign_FI_2` (`connector_id`),
  CONSTRAINT `crm_campaign_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `crm_campaign_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_campaign`
--

LOCK TABLES `crm_campaign` WRITE;
/*!40000 ALTER TABLE `crm_campaign` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_campaign` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_campaign_prospect`
--

DROP TABLE IF EXISTS `crm_campaign_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_campaign_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `crm_campaign_id` int(11) NOT NULL,
  `crm_campaign_status_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `crm_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prospect_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_crm_synced` int(11) DEFAULT '0',
  `override_crm` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `crm_campaign_prospect` (`account_id`,`crm_campaign_id`,`prospect_id`),
  KEY `crm_campaign_prospect_FI_2` (`crm_campaign_id`),
  KEY `crm_campaign_prospect_FI_3` (`crm_campaign_status_id`),
  KEY `crm_campaign_prospect_FI_4` (`prospect_id`),
  CONSTRAINT `crm_campaign_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `crm_campaign_prospect_FK_2` FOREIGN KEY (`crm_campaign_id`) REFERENCES `crm_campaign` (`id`),
  CONSTRAINT `crm_campaign_prospect_FK_3` FOREIGN KEY (`crm_campaign_status_id`) REFERENCES `crm_campaign_status` (`id`),
  CONSTRAINT `crm_campaign_prospect_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_campaign_prospect`
--

LOCK TABLES `crm_campaign_prospect` WRITE;
/*!40000 ALTER TABLE `crm_campaign_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_campaign_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_campaign_status`
--

DROP TABLE IF EXISTS `crm_campaign_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_campaign_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `crm_campaign_id` int(11) NOT NULL,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sort_order` int(11) DEFAULT '-1',
  `crm_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `crm_campaign_status_fid` (`account_id`,`crm_campaign_id`,`crm_fid`),
  KEY `crm_campaign_status_FI_2` (`crm_campaign_id`),
  CONSTRAINT `crm_campaign_status_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `crm_campaign_status_FK_2` FOREIGN KEY (`crm_campaign_id`) REFERENCES `crm_campaign` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_campaign_status`
--

LOCK TABLES `crm_campaign_status` WRITE;
/*!40000 ALTER TABLE `crm_campaign_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_campaign_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_object`
--

DROP TABLE IF EXISTS `crm_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `plural_label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url_pattern` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `creatable` int(11) DEFAULT '0',
  `deletable` int(11) DEFAULT '0',
  `queryable` int(11) DEFAULT '0',
  `retrievable` int(11) DEFAULT '0',
  `searchable` int(11) DEFAULT '0',
  `updateable` int(11) DEFAULT '0',
  `replicateable` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `object_name` (`account_id`,`connector_id`,`name`),
  KEY `crm_object_FI_2` (`connector_id`),
  CONSTRAINT `crm_object_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `crm_object_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_object`
--

LOCK TABLES `crm_object` WRITE;
/*!40000 ALTER TABLE `crm_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_object_field`
--

DROP TABLE IF EXISTS `crm_object_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_object_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `crm_object_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `case_sensitive` int(11) DEFAULT '0',
  `name_field` int(11) DEFAULT '0',
  `createable` int(11) DEFAULT '0',
  `updateable` int(11) DEFAULT '0',
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `soap_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `accuracy` int(11) DEFAULT '0',
  `scale` int(11) DEFAULT '0',
  `length` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `field_name` (`account_id`,`crm_object_id`,`name`),
  KEY `crm_object_field_FI_2` (`crm_object_id`),
  CONSTRAINT `crm_object_field_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `crm_object_field_FK_2` FOREIGN KEY (`crm_object_id`) REFERENCES `crm_object` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_object_field`
--

LOCK TABLES `crm_object_field` WRITE;
/*!40000 ALTER TABLE `crm_object_field` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_object_field` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_object_field_option`
--

DROP TABLE IF EXISTS `crm_object_field_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_object_field_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `crm_object_field_id` int(11) NOT NULL,
  `is_default` int(11) DEFAULT '0',
  `sort_order` int(11) DEFAULT '0',
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `field_index` (`account_id`,`crm_object_field_id`,`value`),
  KEY `crm_object_field_option_FI_2` (`crm_object_field_id`),
  CONSTRAINT `crm_object_field_option_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `crm_object_field_option_FK_2` FOREIGN KEY (`crm_object_field_id`) REFERENCES `crm_object_field` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_object_field_option`
--

LOCK TABLES `crm_object_field_option` WRITE;
/*!40000 ALTER TABLE `crm_object_field_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_object_field_option` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_object_relationship`
--

DROP TABLE IF EXISTS `crm_object_relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_object_relationship` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `child_object_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_object_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `child_field_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `relationship_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `field_name` (`account_id`,`connector_id`,`child_object_name`,`child_field_name`,`parent_object_name`),
  KEY `crm_object_relationship_FI_2` (`connector_id`),
  CONSTRAINT `crm_object_relationship_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `crm_object_relationship_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_object_relationship`
--

LOCK TABLES `crm_object_relationship` WRITE;
/*!40000 ALTER TABLE `crm_object_relationship` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_object_relationship` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_task`
--

DROP TABLE IF EXISTS `crm_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_task` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `assigned_user_id` int(11) DEFAULT NULL,
  `crm_task_status_id` int(11) NOT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `priority` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `activity_date` date DEFAULT NULL,
  `reminder_date` datetime DEFAULT NULL,
  `crm_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `crm_task_fid` (`crm_fid`),
  KEY `crm_task_FI_1` (`account_id`),
  KEY `crm_task_FI_2` (`prospect_id`),
  KEY `crm_task_FI_3` (`connector_id`),
  KEY `crm_task_FI_4` (`assigned_user_id`),
  KEY `crm_task_FI_5` (`crm_task_status_id`),
  CONSTRAINT `crm_task_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `crm_task_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `crm_task_FK_3` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `crm_task_FK_4` FOREIGN KEY (`assigned_user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `crm_task_FK_5` FOREIGN KEY (`crm_task_status_id`) REFERENCES `crm_task_status` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_task`
--

LOCK TABLES `crm_task` WRITE;
/*!40000 ALTER TABLE `crm_task` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_task_status`
--

DROP TABLE IF EXISTS `crm_task_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_task_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `crm_fid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_default` int(11) DEFAULT '0',
  `is_closed` int(11) DEFAULT '0',
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `crm_task_status` (`account_id`,`connector_id`,`crm_fid`),
  KEY `crm_task_status_FI_2` (`connector_id`),
  CONSTRAINT `crm_task_status_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `crm_task_status_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_task_status`
--

LOCK TABLES `crm_task_status` WRITE;
/*!40000 ALTER TABLE `crm_task_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_task_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_task_template`
--

DROP TABLE IF EXISTS `crm_task_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_task_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `assigned_user_id` int(11) DEFAULT NULL,
  `crm_task_status_id` int(11) NOT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `priority` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `due_date_offset` int(11) DEFAULT NULL,
  `reminder_date_offset` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `crm_task_template_FI_1` (`account_id`),
  KEY `crm_task_template_FI_2` (`assigned_user_id`),
  KEY `crm_task_template_FI_3` (`crm_task_status_id`),
  CONSTRAINT `crm_task_template_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `crm_task_template_FK_2` FOREIGN KEY (`assigned_user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `crm_task_template_FK_3` FOREIGN KEY (`crm_task_status_id`) REFERENCES `crm_task_status` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_task_template`
--

LOCK TABLES `crm_task_template` WRITE;
/*!40000 ALTER TABLE `crm_task_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_task_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_object`
--

DROP TABLE IF EXISTS `custom_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `external_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `display_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `plural_display_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `display_info` text COLLATE utf8_unicode_ci,
  `display_field_id` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `crm_object` (`account_id`,`external_id`),
  KEY `custom_object_FI_2` (`display_field_id`),
  CONSTRAINT `custom_object_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `custom_object_FK_2` FOREIGN KEY (`display_field_id`) REFERENCES `field` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_object`
--

LOCK TABLES `custom_object` WRITE;
/*!40000 ALTER TABLE `custom_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_object_instance`
--

DROP TABLE IF EXISTS `custom_object_instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_object_instance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `custom_object_id` int(11) NOT NULL,
  `external_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `crm_object` (`account_id`,`custom_object_id`,`external_id`),
  KEY `custom_object_instance_FI_2` (`custom_object_id`),
  CONSTRAINT `custom_object_instance_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `custom_object_instance_FK_2` FOREIGN KEY (`custom_object_id`) REFERENCES `custom_object` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_object_instance`
--

LOCK TABLES `custom_object_instance` WRITE;
/*!40000 ALTER TABLE `custom_object_instance` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_object_instance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_role`
--

DROP TABLE IF EXISTS `custom_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `custom_role_FI_1` (`account_id`),
  KEY `custom_role_FI_2` (`created_by`),
  KEY `custom_role_FI_3` (`updated_by`),
  CONSTRAINT `custom_role_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `custom_role_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `custom_role_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_role`
--

LOCK TABLES `custom_role` WRITE;
/*!40000 ALTER TABLE `custom_role` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_role_ability`
--

DROP TABLE IF EXISTS `custom_role_ability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_role_ability` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `custom_role_id` int(11) DEFAULT NULL,
  `ability` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `custom_role_ability_FI_1` (`account_id`),
  KEY `custom_role_ability_FI_2` (`custom_role_id`),
  CONSTRAINT `custom_role_ability_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `custom_role_ability_FK_2` FOREIGN KEY (`custom_role_id`) REFERENCES `custom_role` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_role_ability`
--

LOCK TABLES `custom_role_ability` WRITE;
/*!40000 ALTER TABLE `custom_role_ability` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_role_ability` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_url`
--

DROP TABLE IF EXISTS `custom_url`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_url` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `dest_url` text COLLATE utf8_unicode_ci,
  `bitly_url_id` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `vanity_url_id` int(11) DEFAULT NULL,
  `ga_source` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ga_medium` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ga_term` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ga_content` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ga_campaign` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `custom_url_FI_1` (`account_id`),
  KEY `custom_url_FI_2` (`bitly_url_id`),
  KEY `custom_url_FI_3` (`campaign_id`),
  KEY `custom_url_FI_4` (`vanity_url_id`),
  KEY `custom_url_FI_5` (`created_by`),
  KEY `custom_url_FI_6` (`updated_by`),
  CONSTRAINT `custom_url_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `custom_url_FK_2` FOREIGN KEY (`bitly_url_id`) REFERENCES `bitly_url` (`id`),
  CONSTRAINT `custom_url_FK_3` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `custom_url_FK_4` FOREIGN KEY (`vanity_url_id`) REFERENCES `vanity_url` (`id`),
  CONSTRAINT `custom_url_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `custom_url_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_url`
--

LOCK TABLES `custom_url` WRITE;
/*!40000 ALTER TABLE `custom_url` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_url` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_url_stats`
--

DROP TABLE IF EXISTS `custom_url_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_url_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `custom_url_id` int(11) NOT NULL,
  `stats_date` date DEFAULT NULL,
  `unique_clicks` int(11) DEFAULT '0',
  `total_clicks` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_stats_lookup` (`custom_url_id`,`stats_date`),
  KEY `custom_url_stats_FI_1` (`account_id`),
  KEY `custom_url_stats_FI_2` (`campaign_id`),
  CONSTRAINT `custom_url_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `custom_url_stats_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `custom_url_stats_FK_3` FOREIGN KEY (`custom_url_id`) REFERENCES `custom_url` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_url_stats`
--

LOCK TABLES `custom_url_stats` WRITE;
/*!40000 ALTER TABLE `custom_url_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_url_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deleted_object`
--

DROP TABLE IF EXISTS `deleted_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deleted_object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `object_id` int(11) NOT NULL,
  `object_type` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deleted_object`
--

LOCK TABLES `deleted_object` WRITE;
/*!40000 ALTER TABLE `deleted_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `deleted_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `demo_account_tracker`
--

DROP TABLE IF EXISTS `demo_account_tracker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `demo_account_tracker` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `site_asset_identifier` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `asset_type` int(11) NOT NULL,
  `asset_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `siteAssetIdentifier` (`account_id`,`site_asset_identifier`),
  CONSTRAINT `demo_account_tracker_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `demo_account_tracker`
--

LOCK TABLES `demo_account_tracker` WRITE;
/*!40000 ALTER TABLE `demo_account_tracker` DISABLE KEYS */;
/*!40000 ALTER TABLE `demo_account_tracker` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `domain_whitelist`
--

DROP TABLE IF EXISTS `domain_whitelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `domain_whitelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `domain` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `domain_whitelist_FI_1` (`account_id`),
  KEY `domain_whitelist_FI_2` (`created_by`),
  KEY `domain_whitelist_FI_3` (`updated_by`),
  CONSTRAINT `domain_whitelist_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `domain_whitelist_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `domain_whitelist_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `domain_whitelist`
--

LOCK TABLES `domain_whitelist` WRITE;
/*!40000 ALTER TABLE `domain_whitelist` DISABLE KEYS */;
/*!40000 ALTER TABLE `domain_whitelist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drip_program`
--

DROP TABLE IF EXISTS `drip_program`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drip_program` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `email_after_business_hours` int(11) NOT NULL DEFAULT '0',
  `email_blackout_timezone` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `last_run_at` datetime DEFAULT NULL,
  `runtime` float DEFAULT NULL,
  `is_paused` int(11) DEFAULT '0',
  `is_being_processed` int(11) DEFAULT '0',
  `is_archived` tinyint(1) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `drip_program_FI_1` (`account_id`),
  KEY `drip_program_FI_2` (`campaign_id`),
  KEY `drip_program_FI_3` (`listx_id`),
  KEY `drip_program_FI_4` (`created_by`),
  KEY `drip_program_FI_5` (`updated_by`),
  CONSTRAINT `drip_program_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `drip_program_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `drip_program_FK_3` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `drip_program_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `drip_program_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drip_program`
--

LOCK TABLES `drip_program` WRITE;
/*!40000 ALTER TABLE `drip_program` DISABLE KEYS */;
/*!40000 ALTER TABLE `drip_program` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drip_program_action`
--

DROP TABLE IF EXISTS `drip_program_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drip_program_action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `drip_program_id` int(11) DEFAULT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `email_message_id` int(11) DEFAULT NULL,
  `groupx_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `crm_campaign_status_id` int(11) DEFAULT NULL,
  `crm_task_template_id` int(11) DEFAULT NULL,
  `jump_to_step_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `days` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `campaign_member_status_id` int(11) DEFAULT NULL,
  `value` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) DEFAULT '1',
  `sort_order` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `drip_program_action_FI_1` (`account_id`),
  KEY `drip_program_action_FI_2` (`drip_program_id`),
  KEY `drip_program_action_FI_3` (`email_template_id`),
  KEY `drip_program_action_FI_4` (`email_message_id`),
  KEY `drip_program_action_FI_5` (`groupx_id`),
  KEY `drip_program_action_FI_6` (`listx_id`),
  KEY `drip_program_action_FI_7` (`crm_campaign_status_id`),
  KEY `drip_program_action_FI_8` (`crm_task_template_id`),
  KEY `drip_program_action_FI_9` (`jump_to_step_id`),
  KEY `drip_program_action_FI_10` (`parent_id`),
  KEY `drip_program_action_FI_11` (`user_id`),
  KEY `drip_program_action_FI_12` (`campaign_id`),
  KEY `drip_program_action_FI_13` (`campaign_member_status_id`),
  KEY `drip_program_action_FI_14` (`created_by`),
  KEY `drip_program_action_FI_15` (`updated_by`),
  CONSTRAINT `drip_program_action_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `drip_program_action_FK_10` FOREIGN KEY (`parent_id`) REFERENCES `drip_program_action` (`id`),
  CONSTRAINT `drip_program_action_FK_11` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `drip_program_action_FK_12` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `drip_program_action_FK_13` FOREIGN KEY (`campaign_member_status_id`) REFERENCES `campaign_member_status` (`id`),
  CONSTRAINT `drip_program_action_FK_14` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `drip_program_action_FK_15` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `drip_program_action_FK_2` FOREIGN KEY (`drip_program_id`) REFERENCES `drip_program` (`id`),
  CONSTRAINT `drip_program_action_FK_3` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`),
  CONSTRAINT `drip_program_action_FK_4` FOREIGN KEY (`email_message_id`) REFERENCES `email_message` (`id`),
  CONSTRAINT `drip_program_action_FK_5` FOREIGN KEY (`groupx_id`) REFERENCES `groupx` (`id`),
  CONSTRAINT `drip_program_action_FK_6` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `drip_program_action_FK_7` FOREIGN KEY (`crm_campaign_status_id`) REFERENCES `crm_campaign_status` (`id`),
  CONSTRAINT `drip_program_action_FK_8` FOREIGN KEY (`crm_task_template_id`) REFERENCES `crm_task_template` (`id`),
  CONSTRAINT `drip_program_action_FK_9` FOREIGN KEY (`jump_to_step_id`) REFERENCES `drip_program_action` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drip_program_action`
--

LOCK TABLES `drip_program_action` WRITE;
/*!40000 ALTER TABLE `drip_program_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `drip_program_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drip_program_action_prospect`
--

DROP TABLE IF EXISTS `drip_program_action_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drip_program_action_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `drip_program_action_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `drip_program_action_prospect_FI_1` (`account_id`),
  KEY `drip_program_action_prospect_FI_2` (`drip_program_action_id`),
  KEY `drip_program_action_prospect_FI_3` (`prospect_id`),
  CONSTRAINT `drip_program_action_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `drip_program_action_prospect_FK_2` FOREIGN KEY (`drip_program_action_id`) REFERENCES `drip_program_action` (`id`),
  CONSTRAINT `drip_program_action_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drip_program_action_prospect`
--

LOCK TABLES `drip_program_action_prospect` WRITE;
/*!40000 ALTER TABLE `drip_program_action_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `drip_program_action_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drip_program_action_stats`
--

DROP TABLE IF EXISTS `drip_program_action_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drip_program_action_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `drip_program_id` int(11) NOT NULL,
  `drip_program_action_id` int(11) NOT NULL,
  `prospects` int(11) DEFAULT '0',
  `sent` int(11) DEFAULT '0',
  `queued` int(11) DEFAULT '0',
  `delivered` int(11) DEFAULT '0',
  `soft_bounce` int(11) DEFAULT '0',
  `hard_bounce` int(11) DEFAULT '0',
  `opted_out` int(11) DEFAULT '0',
  `opens` int(11) DEFAULT '0',
  `unique_clicks` int(11) DEFAULT '0',
  `total_clicks` int(11) DEFAULT '0',
  `spam_complaints` int(11) DEFAULT '0',
  `stats_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `drip_program_stats_lookup` (`drip_program_action_id`,`stats_date`),
  KEY `drip_program_action_stats_FI_1` (`account_id`),
  KEY `drip_program_action_stats_FI_2` (`drip_program_id`),
  CONSTRAINT `drip_program_action_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `drip_program_action_stats_FK_2` FOREIGN KEY (`drip_program_id`) REFERENCES `drip_program` (`id`),
  CONSTRAINT `drip_program_action_stats_FK_3` FOREIGN KEY (`drip_program_action_id`) REFERENCES `drip_program_action` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drip_program_action_stats`
--

LOCK TABLES `drip_program_action_stats` WRITE;
/*!40000 ALTER TABLE `drip_program_action_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `drip_program_action_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drip_program_email_address`
--

DROP TABLE IF EXISTS `drip_program_email_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drip_program_email_address` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `drip_program_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `email_address` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_drip_email_address_idx` (`account_id`,`drip_program_id`,`email_address`),
  KEY `drip_program_email_address_FI_2` (`drip_program_id`),
  KEY `drip_program_email_address_FI_3` (`prospect_id`),
  CONSTRAINT `drip_program_email_address_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `drip_program_email_address_FK_2` FOREIGN KEY (`drip_program_id`) REFERENCES `drip_program` (`id`),
  CONSTRAINT `drip_program_email_address_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drip_program_email_address`
--

LOCK TABLES `drip_program_email_address` WRITE;
/*!40000 ALTER TABLE `drip_program_email_address` DISABLE KEYS */;
/*!40000 ALTER TABLE `drip_program_email_address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drip_program_listx`
--

DROP TABLE IF EXISTS `drip_program_listx`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drip_program_listx` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `drip_program_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `is_suppressed` int(11) DEFAULT '0',
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `drip_program_listx_FI_1` (`account_id`),
  KEY `drip_program_listx_FI_2` (`drip_program_id`),
  KEY `drip_program_listx_FI_3` (`listx_id`),
  KEY `drip_program_listx_FI_4` (`created_by`),
  CONSTRAINT `drip_program_listx_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `drip_program_listx_FK_2` FOREIGN KEY (`drip_program_id`) REFERENCES `drip_program` (`id`),
  CONSTRAINT `drip_program_listx_FK_3` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `drip_program_listx_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drip_program_listx`
--

LOCK TABLES `drip_program_listx` WRITE;
/*!40000 ALTER TABLE `drip_program_listx` DISABLE KEYS */;
/*!40000 ALTER TABLE `drip_program_listx` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_content`
--

DROP TABLE IF EXISTS `dynamic_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynamic_content` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `based_on` int(11) NOT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `base_content` text COLLATE utf8_unicode_ci,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dynamic_content_FI_1` (`account_id`),
  KEY `dynamic_content_FI_2` (`prospect_field_default_id`),
  KEY `dynamic_content_FI_3` (`prospect_field_custom_id`),
  CONSTRAINT `dynamic_content_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `dynamic_content_FK_2` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `dynamic_content_FK_3` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_content`
--

LOCK TABLES `dynamic_content` WRITE;
/*!40000 ALTER TABLE `dynamic_content` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamic_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_content_variation`
--

DROP TABLE IF EXISTS `dynamic_content_variation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynamic_content_variation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `dynamic_content_id` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `content` text COLLATE utf8_unicode_ci NOT NULL,
  `comparison_operator` int(11) NOT NULL,
  `comparison_value1` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `comparison_value2` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `dynamic_content_variation_FI_1` (`account_id`),
  KEY `dynamic_content_variation_FI_2` (`dynamic_content_id`),
  CONSTRAINT `dynamic_content_variation_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `dynamic_content_variation_FK_2` FOREIGN KEY (`dynamic_content_id`) REFERENCES `dynamic_content` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_content_variation`
--

LOCK TABLES `dynamic_content_variation` WRITE;
/*!40000 ALTER TABLE `dynamic_content_variation` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamic_content_variation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_list`
--

DROP TABLE IF EXISTS `dynamic_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynamic_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `match_type` int(11) DEFAULT '1',
  `last_run_at` datetime DEFAULT NULL,
  `runtime` float DEFAULT NULL,
  `metadata` text COLLATE utf8_unicode_ci,
  `is_paused` int(11) DEFAULT '0',
  `is_being_processed` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `total_prospects_matched` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dynamic_list_FI_1` (`account_id`),
  KEY `dynamic_list_FI_2` (`created_by`),
  KEY `dynamic_list_FI_3` (`updated_by`),
  CONSTRAINT `dynamic_list_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `dynamic_list_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `dynamic_list_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_list`
--

LOCK TABLES `dynamic_list` WRITE;
/*!40000 ALTER TABLE `dynamic_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamic_list` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_list_preview`
--

DROP TABLE IF EXISTS `dynamic_list_preview`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynamic_list_preview` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `dynamic_list_id` int(11) DEFAULT NULL,
  `preview_key` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `num_matched` int(11) DEFAULT '0',
  `is_finished` int(11) DEFAULT '0',
  `last_updated_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `notify_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_preview_key` (`account_id`,`preview_key`),
  UNIQUE KEY `ix_dynamic_list_id` (`account_id`,`dynamic_list_id`),
  KEY `dynamic_list_preview_FI_2` (`dynamic_list_id`),
  KEY `dynamic_list_preview_FI_3` (`created_by`),
  KEY `dynamic_list_preview_FI_4` (`updated_by`),
  CONSTRAINT `dynamic_list_preview_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `dynamic_list_preview_FK_2` FOREIGN KEY (`dynamic_list_id`) REFERENCES `dynamic_list` (`id`),
  CONSTRAINT `dynamic_list_preview_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `dynamic_list_preview_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_list_preview`
--

LOCK TABLES `dynamic_list_preview` WRITE;
/*!40000 ALTER TABLE `dynamic_list_preview` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamic_list_preview` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_list_preview_prospect`
--

DROP TABLE IF EXISTS `dynamic_list_preview_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynamic_list_preview_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `dynamic_list_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dynamic_list_preview` (`account_id`,`dynamic_list_id`,`prospect_id`),
  KEY `dynamic_list_preview_prospect_FI_2` (`dynamic_list_id`),
  KEY `dynamic_list_preview_prospect_FI_3` (`prospect_id`),
  CONSTRAINT `dynamic_list_preview_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `dynamic_list_preview_prospect_FK_2` FOREIGN KEY (`dynamic_list_id`) REFERENCES `dynamic_list` (`id`),
  CONSTRAINT `dynamic_list_preview_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_list_preview_prospect`
--

LOCK TABLES `dynamic_list_preview_prospect` WRITE;
/*!40000 ALTER TABLE `dynamic_list_preview_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamic_list_preview_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_list_prospect`
--

DROP TABLE IF EXISTS `dynamic_list_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynamic_list_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `dynamic_list_preview_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_main` (`account_id`,`dynamic_list_preview_id`),
  KEY `dynamic_list_prospect_FI_2` (`dynamic_list_preview_id`),
  KEY `dynamic_list_prospect_FI_3` (`prospect_id`),
  CONSTRAINT `dynamic_list_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `dynamic_list_prospect_FK_2` FOREIGN KEY (`dynamic_list_preview_id`) REFERENCES `dynamic_list_preview` (`id`),
  CONSTRAINT `dynamic_list_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_list_prospect`
--

LOCK TABLES `dynamic_list_prospect` WRITE;
/*!40000 ALTER TABLE `dynamic_list_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamic_list_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dynamic_list_rule`
--

DROP TABLE IF EXISTS `dynamic_list_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynamic_list_rule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `dynamic_list_id` int(11) DEFAULT NULL,
  `dynamic_list_rule_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `object_type` int(11) DEFAULT NULL,
  `compare` int(11) DEFAULT NULL,
  `operator` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `custom_url_id` int(11) DEFAULT NULL,
  `filex_id` int(11) DEFAULT NULL,
  `form_field_id` int(11) DEFAULT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `queue_id` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `form_handler_id` int(11) DEFAULT NULL,
  `landing_page_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `field_id` int(11) DEFAULT NULL,
  `webinar_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `crm_campaign_id` int(11) DEFAULT NULL,
  `crm_campaign_status_id` int(11) DEFAULT NULL,
  `scoring_category_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dynamic_list_rule_FI_1` (`account_id`),
  KEY `dynamic_list_rule_FI_2` (`dynamic_list_id`),
  KEY `dynamic_list_rule_FI_3` (`dynamic_list_rule_id`),
  KEY `dynamic_list_rule_FI_4` (`custom_url_id`),
  KEY `dynamic_list_rule_FI_5` (`filex_id`),
  KEY `dynamic_list_rule_FI_6` (`form_field_id`),
  KEY `dynamic_list_rule_FI_7` (`prospect_field_default_id`),
  KEY `dynamic_list_rule_FI_8` (`prospect_field_custom_id`),
  KEY `dynamic_list_rule_FI_9` (`user_id`),
  KEY `dynamic_list_rule_FI_10` (`queue_id`),
  KEY `dynamic_list_rule_FI_11` (`form_id`),
  KEY `dynamic_list_rule_FI_12` (`form_handler_id`),
  KEY `dynamic_list_rule_FI_13` (`landing_page_id`),
  KEY `dynamic_list_rule_FI_14` (`listx_id`),
  KEY `dynamic_list_rule_FI_15` (`field_id`),
  KEY `dynamic_list_rule_FI_16` (`webinar_id`),
  KEY `dynamic_list_rule_FI_17` (`profile_id`),
  KEY `dynamic_list_rule_FI_18` (`crm_campaign_id`),
  KEY `dynamic_list_rule_FI_19` (`crm_campaign_status_id`),
  KEY `dynamic_list_rule_FI_20` (`scoring_category_id`),
  KEY `dynamic_list_rule_FI_21` (`created_by`),
  KEY `dynamic_list_rule_FI_22` (`updated_by`),
  CONSTRAINT `dynamic_list_rule_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_10` FOREIGN KEY (`queue_id`) REFERENCES `queue` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_11` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_12` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_13` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_14` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_15` FOREIGN KEY (`field_id`) REFERENCES `field` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_16` FOREIGN KEY (`webinar_id`) REFERENCES `webinar` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_17` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_18` FOREIGN KEY (`crm_campaign_id`) REFERENCES `crm_campaign` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_19` FOREIGN KEY (`crm_campaign_status_id`) REFERENCES `crm_campaign_status` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_2` FOREIGN KEY (`dynamic_list_id`) REFERENCES `dynamic_list` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_20` FOREIGN KEY (`scoring_category_id`) REFERENCES `scoring_category` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_21` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_22` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_3` FOREIGN KEY (`dynamic_list_rule_id`) REFERENCES `dynamic_list_rule` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_4` FOREIGN KEY (`custom_url_id`) REFERENCES `custom_url` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_5` FOREIGN KEY (`filex_id`) REFERENCES `filex` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_6` FOREIGN KEY (`form_field_id`) REFERENCES `form_field` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_7` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_8` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`),
  CONSTRAINT `dynamic_list_rule_FK_9` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_list_rule`
--

LOCK TABLES `dynamic_list_rule` WRITE;
/*!40000 ALTER TABLE `dynamic_list_rule` DISABLE KEYS */;
/*!40000 ALTER TABLE `dynamic_list_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `editing_session`
--

DROP TABLE IF EXISTS `editing_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `editing_session` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `object_type` int(11) NOT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `is_archived` int(11) DEFAULT '0',
  `is_commit` int(11) DEFAULT '0',
  `ttl_seconds` int(11) DEFAULT NULL,
  `state` tinyint(4) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `object_sessions` (`account_id`,`object_id`,`object_type`),
  KEY `users_editing_session` (`account_id`,`object_id`,`object_type`,`created_by`),
  KEY `editing_session_FI_2` (`created_by`),
  CONSTRAINT `editing_session_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `editing_session_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `editing_session`
--

LOCK TABLES `editing_session` WRITE;
/*!40000 ALTER TABLE `editing_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `editing_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email`
--

DROP TABLE IF EXISTS `email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `list_email_id` int(11) DEFAULT NULL,
  `drip_program_id` int(11) DEFAULT NULL,
  `drip_program_action_id` int(11) DEFAULT NULL,
  `email_message_id` int(11) DEFAULT NULL,
  `server_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_paused` int(11) DEFAULT '0',
  `is_queued` tinyint(1) NOT NULL DEFAULT '0',
  `is_being_processed` tinyint(1) NOT NULL DEFAULT '0',
  `is_sent` tinyint(1) NOT NULL DEFAULT '0',
  `is_draft` tinyint(1) NOT NULL DEFAULT '0',
  `is_crm_synced` tinyint(1) NOT NULL DEFAULT '0',
  `is_hidden` int(11) DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `client_type` int(11) DEFAULT NULL,
  `bounce_severity` int(11) DEFAULT '1',
  `has_opted_out` int(11) DEFAULT '0',
  `clicks` int(11) DEFAULT '0',
  `opens` int(11) DEFAULT '0',
  `spam_complaints` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_updated_at` (`updated_at`),
  KEY `ix_account_server_sent` (`account_id`,`server_id`,`is_sent`),
  KEY `ix_datatable` (`account_id`,`is_archived`,`is_hidden`,`sent_at`),
  KEY `is_queued` (`is_queued`),
  KEY `email_FI_2` (`user_id`),
  KEY `email_FI_3` (`campaign_id`),
  KEY `email_FI_4` (`prospect_id`),
  KEY `email_FI_5` (`listx_id`),
  KEY `email_FI_6` (`list_email_id`),
  KEY `email_FI_7` (`drip_program_id`),
  KEY `email_FI_8` (`drip_program_action_id`),
  KEY `email_FI_9` (`email_message_id`),
  KEY `email_FI_10` (`created_by`),
  KEY `email_FI_11` (`updated_by`),
  CONSTRAINT `email_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_FK_10` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `email_FK_11` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `email_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `email_FK_3` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `email_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `email_FK_5` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `email_FK_6` FOREIGN KEY (`list_email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_FK_7` FOREIGN KEY (`drip_program_id`) REFERENCES `drip_program` (`id`),
  CONSTRAINT `email_FK_8` FOREIGN KEY (`drip_program_action_id`) REFERENCES `drip_program_action` (`id`),
  CONSTRAINT `email_FK_9` FOREIGN KEY (`email_message_id`) REFERENCES `email_message` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email`
--

LOCK TABLES `email` WRITE;
/*!40000 ALTER TABLE `email` DISABLE KEYS */;
/*!40000 ALTER TABLE `email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_ab_test`
--

DROP TABLE IF EXISTS `email_ab_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_ab_test` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_draft_id` int(11) DEFAULT NULL,
  `a_email_id` int(11) DEFAULT NULL,
  `b_email_id` int(11) DEFAULT NULL,
  `winner_email_id` int(11) DEFAULT NULL,
  `winning_version` int(11) DEFAULT NULL,
  `percent` int(11) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `duration_type` int(11) NOT NULL DEFAULT '3',
  `tiebreaker` int(11) NOT NULL DEFAULT '2',
  `test_ends_at` datetime DEFAULT NULL,
  `test_paused_at` datetime DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `is_being_processed` int(11) DEFAULT '0',
  `test_type` tinyint(4) NOT NULL DEFAULT '1',
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_ab_test_FI_1` (`account_id`),
  KEY `email_ab_test_FI_2` (`email_draft_id`),
  KEY `email_ab_test_FI_3` (`a_email_id`),
  KEY `email_ab_test_FI_4` (`b_email_id`),
  KEY `email_ab_test_FI_5` (`winner_email_id`),
  KEY `email_ab_test_FI_6` (`created_by`),
  CONSTRAINT `email_ab_test_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_ab_test_FK_2` FOREIGN KEY (`email_draft_id`) REFERENCES `email_draft` (`id`),
  CONSTRAINT `email_ab_test_FK_3` FOREIGN KEY (`a_email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_ab_test_FK_4` FOREIGN KEY (`b_email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_ab_test_FK_5` FOREIGN KEY (`winner_email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_ab_test_FK_6` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_ab_test`
--

LOCK TABLES `email_ab_test` WRITE;
/*!40000 ALTER TABLE `email_ab_test` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_ab_test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_bounce`
--

DROP TABLE IF EXISTS `email_bounce`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_bounce` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_id` int(11) DEFAULT NULL,
  `reason` text COLLATE utf8_unicode_ci,
  `type` tinyint(4) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_bounce_unique` (`account_id`,`email_id`),
  KEY `account_updatedAt` (`account_id`,`updated_at`),
  KEY `email_bounce_FI_2` (`email_id`),
  CONSTRAINT `email_bounce_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_bounce_FK_2` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_bounce`
--

LOCK TABLES `email_bounce` WRITE;
/*!40000 ALTER TABLE `email_bounce` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_bounce` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_click`
--

DROP TABLE IF EXISTS `email_click`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_click` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) NOT NULL,
  `email_id` int(11) NOT NULL,
  `list_email_id` int(11) DEFAULT NULL,
  `drip_program_action_id` int(11) DEFAULT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `is_filtered` int(11) DEFAULT '0',
  `tracker_redirect_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_click_acct_list_created` (`account_id`,`list_email_id`,`created_at`,`is_filtered`),
  KEY `email_click_acct_dripAction_created` (`account_id`,`drip_program_action_id`,`created_at`,`is_filtered`),
  KEY `email_click_acct_template_created` (`account_id`,`email_template_id`,`created_at`,`is_filtered`),
  KEY `email_click_acct_list_tracker_created` (`account_id`,`list_email_id`,`tracker_redirect_id`,`created_at`,`is_filtered`),
  KEY `email_click_acct_drip_template_tracker_created` (`account_id`,`drip_program_action_id`,`email_template_id`,`tracker_redirect_id`,`created_at`,`is_filtered`),
  KEY `email_click_created_at_email_id` (`account_id`,`created_at`,`email_id`,`is_filtered`),
  KEY `email_click_FI_2` (`visitor_id`),
  KEY `email_click_FI_3` (`prospect_id`),
  KEY `email_click_FI_4` (`email_id`),
  KEY `email_click_FI_5` (`list_email_id`),
  KEY `email_click_FI_6` (`drip_program_action_id`),
  KEY `email_click_FI_7` (`email_template_id`),
  KEY `email_click_FI_8` (`tracker_redirect_id`),
  CONSTRAINT `email_click_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_click_FK_2` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `email_click_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `email_click_FK_4` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_click_FK_5` FOREIGN KEY (`list_email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_click_FK_6` FOREIGN KEY (`drip_program_action_id`) REFERENCES `drip_program_action` (`id`),
  CONSTRAINT `email_click_FK_7` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`),
  CONSTRAINT `email_click_FK_8` FOREIGN KEY (`tracker_redirect_id`) REFERENCES `tracker_redirect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_click`
--

LOCK TABLES `email_click` WRITE;
/*!40000 ALTER TABLE `email_click` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_click` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_click_external_key`
--

DROP TABLE IF EXISTS `email_click_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_click_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_email_click_id` FOREIGN KEY (`id`) REFERENCES `email_click` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_click_external_key`
--

LOCK TABLES `email_click_external_key` WRITE;
/*!40000 ALTER TABLE `email_click_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_click_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_complaint`
--

DROP TABLE IF EXISTS `email_complaint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_complaint` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_id` int(11) DEFAULT NULL,
  `reason` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_complaint_unique` (`account_id`,`email_id`),
  KEY `email_complaint_FI_2` (`email_id`),
  CONSTRAINT `email_complaint_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_complaint_FK_2` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_complaint`
--

LOCK TABLES `email_complaint` WRITE;
/*!40000 ALTER TABLE `email_complaint` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_complaint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_compliance_account_audit`
--

DROP TABLE IF EXISTS `email_compliance_account_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_compliance_account_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `processed_at` datetime NOT NULL,
  `finished_at` datetime DEFAULT NULL,
  `fid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_compliance_account_audit_FI_1` (`account_id`),
  CONSTRAINT `email_compliance_account_audit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_compliance_account_audit`
--

LOCK TABLES `email_compliance_account_audit` WRITE;
/*!40000 ALTER TABLE `email_compliance_account_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_compliance_account_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_compliance_email_audit`
--

DROP TABLE IF EXISTS `email_compliance_email_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_compliance_email_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_id` int(11) NOT NULL,
  `email_compliance_account_audit_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `audited_at` datetime NOT NULL,
  `compliance_status` int(11) NOT NULL,
  `complaint_sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_compliance_email_audit_FI_1` (`account_id`),
  KEY `email_compliance_email_audit_FI_2` (`email_id`),
  KEY `email_compliance_email_audit_FI_3` (`email_compliance_account_audit_id`),
  CONSTRAINT `email_compliance_email_audit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_compliance_email_audit_FK_2` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_compliance_email_audit_FK_3` FOREIGN KEY (`email_compliance_account_audit_id`) REFERENCES `email_compliance_account_audit` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_compliance_email_audit`
--

LOCK TABLES `email_compliance_email_audit` WRITE;
/*!40000 ALTER TABLE `email_compliance_email_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_compliance_email_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_draft`
--

DROP TABLE IF EXISTS `email_draft`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_draft` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `email_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `from_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subject_a` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subject_b` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `text_message_a` text COLLATE utf8_unicode_ci,
  `text_message_b` text COLLATE utf8_unicode_ci,
  `html_message_a` text COLLATE utf8_unicode_ci,
  `html_message_b` text COLLATE utf8_unicode_ci,
  `completion_actions` text COLLATE utf8_unicode_ci,
  `email_listx` text COLLATE utf8_unicode_ci,
  `sender_a` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sender_b` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_template_id_a` int(11) DEFAULT NULL,
  `email_template_id_b` int(11) DEFAULT NULL,
  `reply_to_a` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reply_to_b` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `specific_click_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) DEFAULT '3',
  `is_bypass_optouts` int(11) NOT NULL DEFAULT '0',
  `ab_percent` int(11) DEFAULT NULL,
  `ab_duration` int(11) DEFAULT NULL,
  `ab_test_type` int(11) DEFAULT NULL,
  `ab_duration_type` int(11) NOT NULL DEFAULT '4',
  `ab_tiebreaker` int(11) DEFAULT NULL,
  `is_archived` int(11) NOT NULL DEFAULT '0',
  `is_hidden` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `email_draft_account_drafts` (`account_id`,`created_at`),
  KEY `email_draft_account_recent_drafts` (`account_id`,`updated_at`),
  KEY `email_draft_user_recent_draft` (`account_id`,`updated_at`,`updated_by`),
  KEY `email_draft_FI_2` (`campaign_id`),
  KEY `email_draft_FI_3` (`email_template_id`),
  KEY `email_draft_FI_4` (`email_id`),
  KEY `email_draft_FI_5` (`prospect_id`),
  KEY `email_draft_FI_6` (`email_template_id_a`),
  KEY `email_draft_FI_7` (`email_template_id_b`),
  KEY `email_draft_FI_8` (`created_by`),
  KEY `email_draft_FI_9` (`updated_by`),
  CONSTRAINT `email_draft_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_draft_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `email_draft_FK_3` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`),
  CONSTRAINT `email_draft_FK_4` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_draft_FK_5` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `email_draft_FK_6` FOREIGN KEY (`email_template_id_a`) REFERENCES `email_template` (`id`),
  CONSTRAINT `email_draft_FK_7` FOREIGN KEY (`email_template_id_b`) REFERENCES `email_template` (`id`),
  CONSTRAINT `email_draft_FK_8` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `email_draft_FK_9` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_draft`
--

LOCK TABLES `email_draft` WRITE;
/*!40000 ALTER TABLE `email_draft` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_draft` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_listx`
--

DROP TABLE IF EXISTS `email_listx`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_listx` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `is_suppressed` int(11) DEFAULT '0',
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_listx_FI_1` (`account_id`),
  KEY `email_listx_FI_2` (`email_id`),
  KEY `email_listx_FI_3` (`listx_id`),
  KEY `email_listx_FI_4` (`created_by`),
  CONSTRAINT `email_listx_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_listx_FK_2` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_listx_FK_3` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `email_listx_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_listx`
--

LOCK TABLES `email_listx` WRITE;
/*!40000 ALTER TABLE `email_listx` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_listx` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_log`
--

DROP TABLE IF EXISTS `email_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_id` int(11) DEFAULT NULL,
  `mta_id` int(11) NOT NULL,
  `mta_message_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message_raw` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mta_message_id` (`mta_message_id`,`mta_id`),
  KEY `created_at` (`created_at`),
  KEY `email_log_FI_1` (`account_id`),
  KEY `email_log_FI_2` (`email_id`),
  CONSTRAINT `email_log_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_log_FK_2` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_log`
--

LOCK TABLES `email_log` WRITE;
/*!40000 ALTER TABLE `email_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_message`
--

DROP TABLE IF EXISTS `email_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `from_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `text_message` mediumtext COLLATE utf8_unicode_ci,
  `html_message` mediumtext COLLATE utf8_unicode_ci,
  `is_from_assigned_user` int(11) DEFAULT '0',
  `email_type` int(11) DEFAULT '0',
  `type` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_message_FI_1` (`account_id`),
  KEY `email_message_FI_2` (`email_template_id`),
  KEY `email_message_FI_3` (`user_id`),
  CONSTRAINT `email_message_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_message_FK_2` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`),
  CONSTRAINT `email_message_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_message`
--

LOCK TABLES `email_message` WRITE;
/*!40000 ALTER TABLE `email_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_metric`
--

DROP TABLE IF EXISTS `email_metric`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_metric` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_id` int(11) DEFAULT NULL,
  `total_emails` int(11) DEFAULT NULL,
  `scheduled_time` datetime DEFAULT NULL,
  `queueing_start` datetime DEFAULT NULL,
  `queueing_end` datetime DEFAULT NULL,
  `sending_start` datetime DEFAULT NULL,
  `sending_end` datetime DEFAULT NULL,
  `pause_duration` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_email` (`account_id`,`email_id`),
  KEY `account_scheduled` (`account_id`,`scheduled_time`),
  KEY `email_metric_FI_2` (`email_id`),
  CONSTRAINT `email_metric_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_metric_FK_2` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_metric`
--

LOCK TABLES `email_metric` WRITE;
/*!40000 ALTER TABLE `email_metric` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_metric` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_open`
--

DROP TABLE IF EXISTS `email_open`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_open` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) NOT NULL,
  `email_id` int(11) NOT NULL,
  `list_email_id` int(11) DEFAULT NULL,
  `drip_program_action_id` int(11) DEFAULT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `is_filtered` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_open_acct_list_created` (`account_id`,`list_email_id`,`created_at`,`is_filtered`),
  KEY `email_open_acct_dripAction_created` (`account_id`,`drip_program_action_id`,`created_at`,`is_filtered`),
  KEY `email_open_acct_template_created` (`account_id`,`email_template_id`,`created_at`,`is_filtered`),
  KEY `email_open_created_at_email_id` (`account_id`,`created_at`,`email_id`,`is_filtered`),
  KEY `email_open_acct_list_email_prospect` (`account_id`,`list_email_id`,`prospect_id`),
  KEY `email_open_FI_2` (`visitor_id`),
  KEY `email_open_FI_3` (`prospect_id`),
  KEY `email_open_FI_4` (`email_id`),
  KEY `email_open_FI_5` (`list_email_id`),
  KEY `email_open_FI_6` (`drip_program_action_id`),
  KEY `email_open_FI_7` (`email_template_id`),
  CONSTRAINT `email_open_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_open_FK_2` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `email_open_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `email_open_FK_4` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_open_FK_5` FOREIGN KEY (`list_email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_open_FK_6` FOREIGN KEY (`drip_program_action_id`) REFERENCES `drip_program_action` (`id`),
  CONSTRAINT `email_open_FK_7` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_open`
--

LOCK TABLES `email_open` WRITE;
/*!40000 ALTER TABLE `email_open` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_open` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_open_external_key`
--

DROP TABLE IF EXISTS `email_open_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_open_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_email_open_id` FOREIGN KEY (`id`) REFERENCES `email_open` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_open_external_key`
--

LOCK TABLES `email_open_external_key` WRITE;
/*!40000 ALTER TABLE `email_open_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_open_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_preferences_list`
--

DROP TABLE IF EXISTS `email_preferences_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_preferences_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_preferences_page_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`account_id`,`email_preferences_page_id`,`listx_id`),
  KEY `email_preferences_list_FI_2` (`email_preferences_page_id`),
  KEY `email_preferences_list_FI_3` (`listx_id`),
  CONSTRAINT `email_preferences_list_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_preferences_list_FK_2` FOREIGN KEY (`email_preferences_page_id`) REFERENCES `email_preferences_page` (`id`),
  CONSTRAINT `email_preferences_list_FK_3` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_preferences_list`
--

LOCK TABLES `email_preferences_list` WRITE;
/*!40000 ALTER TABLE `email_preferences_list` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_preferences_list` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_preferences_page`
--

DROP TABLE IF EXISTS `email_preferences_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_preferences_page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `layout_template_id` int(11) DEFAULT NULL,
  `before_form_content` text COLLATE utf8_unicode_ci,
  `after_form_content` text COLLATE utf8_unicode_ci,
  `email_label` varchar(1000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_error` varchar(1000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `unsubscribe_link_text` varchar(1000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `unsubscribe_confirm` varchar(1000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `submit_button_text` varchar(1000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `thank_you_content` text COLLATE utf8_unicode_ci,
  `opted_out_message` varchar(1000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `opted_in_message` varchar(1000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vanity_url_id` int(11) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_preferences_page_FI_1` (`account_id`),
  KEY `email_preferences_page_FI_2` (`campaign_id`),
  KEY `email_preferences_page_FI_3` (`layout_template_id`),
  KEY `email_preferences_page_FI_4` (`vanity_url_id`),
  KEY `email_preferences_page_FI_5` (`created_by`),
  KEY `email_preferences_page_FI_6` (`updated_by`),
  CONSTRAINT `email_preferences_page_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_preferences_page_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `email_preferences_page_FK_3` FOREIGN KEY (`layout_template_id`) REFERENCES `layout_template` (`id`),
  CONSTRAINT `email_preferences_page_FK_4` FOREIGN KEY (`vanity_url_id`) REFERENCES `vanity_url` (`id`),
  CONSTRAINT `email_preferences_page_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `email_preferences_page_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_preferences_page`
--

LOCK TABLES `email_preferences_page` WRITE;
/*!40000 ALTER TABLE `email_preferences_page` DISABLE KEYS */;
INSERT INTO `email_preferences_page` VALUES (1,2,1,'Default Email Preferences Page','Email Preference Center',1,'Select which lists you would like to receive email communications from.','','Email Address','Please input a valid email address','Opt out from all email communications','Are you sure you want to opt out from all future email communications?','Save Preferences','Your email preferences have been saved.','Now opted out of','Now subscribed to',NULL,1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `email_preferences_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_send_options`
--

DROP TABLE IF EXISTS `email_send_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_send_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_id` int(11) DEFAULT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `email_draft_id` int(11) DEFAULT NULL,
  `is_bypass_optouts` int(11) DEFAULT '0',
  `send_from_account_owner` int(11) DEFAULT '0',
  `is_test` int(11) DEFAULT '0',
  `reply_to_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `send_from_data` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ab_version` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_send_options_FI_1` (`account_id`),
  KEY `email_send_options_FI_2` (`email_id`),
  KEY `email_send_options_FI_3` (`email_template_id`),
  KEY `email_send_options_FI_4` (`email_draft_id`),
  KEY `email_send_options_FI_5` (`created_by`),
  KEY `email_send_options_FI_6` (`updated_by`),
  CONSTRAINT `email_send_options_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_send_options_FK_2` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `email_send_options_FK_3` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`),
  CONSTRAINT `email_send_options_FK_4` FOREIGN KEY (`email_draft_id`) REFERENCES `email_draft` (`id`),
  CONSTRAINT `email_send_options_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `email_send_options_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_send_options`
--

LOCK TABLES `email_send_options` WRITE;
/*!40000 ALTER TABLE `email_send_options` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_send_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_stats`
--

DROP TABLE IF EXISTS `email_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `list_emails` int(11) DEFAULT '0',
  `automatic_emails` int(11) DEFAULT '0',
  `one_to_one_emails` int(11) DEFAULT '0',
  `drip_emails` int(11) DEFAULT '0',
  `engage_emails` int(11) DEFAULT '0',
  `stats_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_stats_lookup` (`account_id`,`stats_date`),
  CONSTRAINT `email_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_stats`
--

LOCK TABLES `email_stats` WRITE;
/*!40000 ALTER TABLE `email_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_sync_queue`
--

DROP TABLE IF EXISTS `email_sync_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_sync_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `email_sync_queue_FI_1` (`account_id`),
  KEY `email_sync_queue_FI_2` (`email_id`),
  CONSTRAINT `email_sync_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_sync_queue_FK_2` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_sync_queue`
--

LOCK TABLES `email_sync_queue` WRITE;
/*!40000 ALTER TABLE `email_sync_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_sync_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_template`
--

DROP TABLE IF EXISTS `email_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `email_layout_id` int(11) DEFAULT NULL,
  `thumbnail_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `text_message` mediumtext COLLATE utf8_unicode_ci,
  `html_message` mediumtext COLLATE utf8_unicode_ci,
  `tracked_text_message` mediumtext COLLATE utf8_unicode_ci,
  `tracked_html_message` mediumtext COLLATE utf8_unicode_ci,
  `type` int(11) DEFAULT '1',
  `is_from_assigned_user` tinyint(1) NOT NULL DEFAULT '0',
  `is_use_from_name` tinyint(1) NOT NULL DEFAULT '0',
  `email_type` int(11) DEFAULT '0',
  `is_one_to_one_email` int(11) DEFAULT '1',
  `is_autoresponder_email` int(11) DEFAULT '1',
  `is_drip_email` int(11) DEFAULT '1',
  `is_list_email` int(11) DEFAULT '1',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `last_stats_diff_at` datetime DEFAULT NULL,
  `last_stats_recalc_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_template_FI_1` (`account_id`),
  KEY `email_template_FI_2` (`campaign_id`),
  KEY `email_template_FI_3` (`thumbnail_id`),
  KEY `email_template_FI_4` (`user_id`),
  KEY `email_template_FI_5` (`created_by`),
  KEY `email_template_FI_6` (`updated_by`),
  CONSTRAINT `email_template_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_template_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `email_template_FK_3` FOREIGN KEY (`thumbnail_id`) REFERENCES `thumbnail` (`id`),
  CONSTRAINT `email_template_FK_4` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `email_template_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `email_template_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_template`
--

LOCK TABLES `email_template` WRITE;
/*!40000 ALTER TABLE `email_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_template_draft`
--

DROP TABLE IF EXISTS `email_template_draft`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_template_draft` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `email_layout_id` int(11) DEFAULT NULL,
  `thumbnail_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `text_message` text COLLATE utf8_unicode_ci,
  `html_message` text COLLATE utf8_unicode_ci,
  `send_from_data` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reply_to_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` smallint(6) DEFAULT '1',
  `email_type` smallint(6) DEFAULT '0',
  `is_one_to_one_email` tinyint(4) DEFAULT '1',
  `is_autoresponder_email` tinyint(4) DEFAULT '1',
  `is_drip_email` tinyint(4) DEFAULT '1',
  `is_list_email` tinyint(4) DEFAULT '1',
  `is_archived` tinyint(4) DEFAULT '0',
  `published_template_id` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_template_draft_FI_1` (`account_id`),
  KEY `email_template_draft_FI_2` (`created_by`),
  KEY `email_template_draft_FI_3` (`updated_by`),
  CONSTRAINT `email_template_draft_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_template_draft_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `email_template_draft_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_template_draft`
--

LOCK TABLES `email_template_draft` WRITE;
/*!40000 ALTER TABLE `email_template_draft` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_template_draft` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_template_stats`
--

DROP TABLE IF EXISTS `email_template_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_template_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_template_id` int(11) NOT NULL,
  `stats_date` date DEFAULT NULL,
  `sent` int(11) DEFAULT '0',
  `queued` int(11) DEFAULT '0',
  `delivered` int(11) DEFAULT '0',
  `soft_bounce` int(11) DEFAULT '0',
  `hard_bounce` int(11) DEFAULT '0',
  `opted_out` int(11) DEFAULT '0',
  `opens` int(11) DEFAULT '0',
  `unique_clicks` int(11) DEFAULT '0',
  `total_clicks` int(11) DEFAULT '0',
  `spam_complaints` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_template_stats_uniq` (`email_template_id`,`stats_date`),
  KEY `email_template_stats_FI_1` (`account_id`),
  CONSTRAINT `email_template_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `email_template_stats_FK_2` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_template_stats`
--

LOCK TABLES `email_template_stats` WRITE;
/*!40000 ALTER TABLE `email_template_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_template_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `engage_action`
--

DROP TABLE IF EXISTS `engage_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `engage_action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `uuid` varchar(36) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_engage_action_account_id_uuid` (`account_id`,`uuid`),
  KEY `idx_engage_filter_action_created_at` (`created_at`),
  CONSTRAINT `engage_action_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `engage_action`
--

LOCK TABLES `engage_action` WRITE;
/*!40000 ALTER TABLE `engage_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `engage_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `engage_filter`
--

DROP TABLE IF EXISTS `engage_filter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `engage_filter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `criteria_hash` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `criteria` text COLLATE utf8_unicode_ci,
  `users` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `engage_filter_FI_1` (`account_id`),
  CONSTRAINT `engage_filter_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `engage_filter`
--

LOCK TABLES `engage_filter` WRITE;
/*!40000 ALTER TABLE `engage_filter` DISABLE KEYS */;
INSERT INTO `engage_filter` VALUES (1,2,'2ca10852ab13d1f4e02b5a3f86e1a7565240904f','\"prospect!=null\"','-1','2016-03-24 16:07:15','2016-03-24 16:07:15',0),(2,2,'a64ecbb47bce0459bb1c28459169a103dbc29713','{\"a\":[\"prospect==null\",\"whois.company!=null\"]}','-1','2016-03-24 16:07:15','2016-03-24 16:07:15',0),(3,2,'7d8c1dfcbe6a06a5c85825cce3ea9993095c5efe','{\"a\":[\"prospect!=null\",{\"o\":[\"prospect.state==Georgia\",\"whois.state==Georgia\"]}]}','-1','2016-03-24 16:07:15','2016-03-24 16:07:15',0);
/*!40000 ALTER TABLE `engage_filter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `engage_filter_action`
--

DROP TABLE IF EXISTS `engage_filter_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `engage_filter_action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `engage_action_id` int(11) NOT NULL,
  `engage_filter_id` int(11) NOT NULL,
  `user` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_engage_filter_action_filter_id_action_id` (`engage_action_id`,`engage_filter_id`,`user`),
  KEY `idx_engage_filter_action_user` (`user`),
  KEY `engage_filter_action_FI_1` (`account_id`),
  KEY `engage_filter_action_FI_3` (`engage_filter_id`),
  CONSTRAINT `engage_filter_action_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `engage_filter_action_FK_2` FOREIGN KEY (`engage_action_id`) REFERENCES `engage_action` (`id`),
  CONSTRAINT `engage_filter_action_FK_3` FOREIGN KEY (`engage_filter_id`) REFERENCES `engage_filter` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `engage_filter_action`
--

LOCK TABLES `engage_filter_action` WRITE;
/*!40000 ALTER TABLE `engage_filter_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `engage_filter_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `fid` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `status` int(11) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `timezone` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `organizer_name` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `organizer_url` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `venue_name` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tickets_count` int(11) DEFAULT NULL,
  `tickets_sold` int(11) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `modified_at` datetime DEFAULT NULL,
  `is_private` int(11) DEFAULT NULL,
  `is_hidden` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`account_id`,`connector_id`,`fid`),
  KEY `event_FI_2` (`connector_id`),
  CONSTRAINT `event_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `event_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event`
--

LOCK TABLES `event` WRITE;
/*!40000 ALTER TABLE `event` DISABLE KEYS */;
/*!40000 ALTER TABLE `event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_attendee`
--

DROP TABLE IF EXISTS `event_attendee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event_attendee` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `registered_at` datetime DEFAULT NULL,
  `checked_in` int(11) NOT NULL DEFAULT '0',
  `checked_in_at` datetime DEFAULT NULL,
  `fid` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quantity` int(11) NOT NULL DEFAULT '1',
  `modified_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`account_id`,`event_id`,`fid`),
  KEY `event_attendee_FI_2` (`event_id`),
  KEY `event_attendee_FI_3` (`prospect_id`),
  CONSTRAINT `event_attendee_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `event_attendee_FK_2` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`),
  CONSTRAINT `event_attendee_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_attendee`
--

LOCK TABLES `event_attendee` WRITE;
/*!40000 ALTER TABLE `event_attendee` DISABLE KEYS */;
/*!40000 ALTER TABLE `event_attendee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field`
--

DROP TABLE IF EXISTS `field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `object_type` int(11) NOT NULL,
  `object_property` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) NOT NULL DEFAULT '1',
  `unique_id` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_record_multiple_responses` int(11) DEFAULT '0',
  `is_required` int(11) DEFAULT '0',
  `is_use_values` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `sync_crm_field_values` int(11) DEFAULT '0',
  `crm_field_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_object_type` (`account_id`,`object_type`),
  KEY `field_FI_2` (`created_by`),
  KEY `field_FI_3` (`updated_by`),
  CONSTRAINT `field_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `field_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `field_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field`
--

LOCK TABLES `field` WRITE;
/*!40000 ALTER TABLE `field` DISABLE KEYS */;
INSERT INTO `field` VALUES (1,2,1,'name',1,NULL,'Name',0,1,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,1,'number',1,NULL,'Number',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,2,1,'description',5,NULL,'Description',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(4,2,1,'phone',1,NULL,'Phone',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(5,2,1,'fax',1,NULL,'Fax',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(6,2,1,'website',1,NULL,'Website',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(7,2,1,'rating',4,NULL,'Rating',0,0,1,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(8,2,1,'site',1,NULL,'Site',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(9,2,1,'type',4,NULL,'Type',0,0,1,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(10,2,1,'annual_revenue',1,NULL,'Annual Revenue',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(11,2,1,'industry',4,NULL,'Industry',0,0,1,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(12,2,1,'sic',1,NULL,'SIC Code',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(13,2,1,'employees',1,NULL,'Number of Employees',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(14,2,1,'ownership',4,NULL,'Ownership',0,0,1,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(15,2,1,'ticker_symbol',1,NULL,'Ticker Symbol',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(16,2,1,'billing_address_one',1,NULL,'Billing Address One',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(17,2,1,'billing_address_two',1,NULL,'Billing Address Two',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(18,2,1,'billing_city',1,NULL,'Billing City',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(19,2,1,'billing_state',1,NULL,'Billing State',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(20,2,1,'billing_zip',1,NULL,'Billing Zip',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(21,2,1,'billing_country',1,NULL,'Billing Country',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(22,2,1,'shipping_address_one',1,NULL,'Shipping Address One',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(23,2,1,'shipping_address_two',1,NULL,'Shipping Address Two',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(24,2,1,'shipping_city',1,NULL,'Shipping City',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(25,2,1,'shipping_state',1,NULL,'Shipping State',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(26,2,1,'shipping_zip',1,NULL,'Shipping Zip',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(27,2,1,'shipping_country',1,NULL,'Shipping Country',0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `field` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_option`
--

DROP TABLE IF EXISTS `field_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `field_id` int(11) NOT NULL,
  `label` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_option_FI_1` (`account_id`),
  KEY `field_option_FI_2` (`field_id`),
  KEY `field_option_FI_3` (`created_by`),
  KEY `field_option_FI_4` (`updated_by`),
  CONSTRAINT `field_option_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `field_option_FK_2` FOREIGN KEY (`field_id`) REFERENCES `field` (`id`),
  CONSTRAINT `field_option_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `field_option_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_option`
--

LOCK TABLES `field_option` WRITE;
/*!40000 ALTER TABLE `field_option` DISABLE KEYS */;
INSERT INTO `field_option` VALUES (1,2,7,NULL,'Hot',0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,7,NULL,'Warm',1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,2,7,NULL,'Cold',2,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(4,2,9,NULL,'Prospect',0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(5,2,9,NULL,'Customer - Direct',1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(6,2,9,NULL,'Customer - Channel',2,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(7,2,9,NULL,'Channel Partner / Reseller',3,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(8,2,9,NULL,'Installation Partner',4,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(9,2,9,NULL,'Technology Partner',5,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(10,2,9,NULL,'Other',6,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(11,2,11,NULL,'Agriculture',0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(12,2,11,NULL,'Apparel',1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(13,2,11,NULL,'Banking',2,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(14,2,11,NULL,'Biotechnology',3,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(15,2,11,NULL,'Chemicals',4,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(16,2,11,NULL,'Communications',5,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(17,2,11,NULL,'Construction',6,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(18,2,11,NULL,'Consulting',7,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(19,2,11,NULL,'Education',8,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(20,2,11,NULL,'Electronic',9,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(21,2,11,NULL,'Energy',10,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(22,2,11,NULL,'Engineering',11,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(23,2,11,NULL,'Entertainment',12,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(24,2,11,NULL,'Environmental',13,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(25,2,11,NULL,'Finance',14,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(26,2,11,NULL,'Food & Beverage',15,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(27,2,11,NULL,'Government',16,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(28,2,11,NULL,'Healthcare',17,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(29,2,11,NULL,'Hospitality',18,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(30,2,11,NULL,'Insurance',19,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(31,2,11,NULL,'Machinery',20,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(32,2,11,NULL,'Manufacturing',21,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(33,2,11,NULL,'Media',22,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(34,2,11,NULL,'Not For Profit',23,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(35,2,11,NULL,'Recreation',24,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(36,2,11,NULL,'Retail',25,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(37,2,11,NULL,'Shipping',26,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(38,2,11,NULL,'Technology',27,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(39,2,11,NULL,'Telecommunications',28,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(40,2,11,NULL,'Transportation',29,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(41,2,11,NULL,'Utilities',30,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(42,2,11,NULL,'Other',31,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(43,2,14,NULL,'Public',0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(44,2,14,NULL,'Private',1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(45,2,14,NULL,'Subsidiary',2,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(46,2,14,NULL,'Other',3,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `field_option` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_relation`
--

DROP TABLE IF EXISTS `field_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_relation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `field_id` int(11) NOT NULL,
  `object_type` int(11) NOT NULL,
  `target_object_type` int(11) NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `field_relation_target` (`account_id`,`object_type`,`field_id`,`target_object_type`),
  UNIQUE KEY `field_relation_source` (`account_id`,`target_object_type`,`object_type`,`field_id`),
  KEY `field_relation_FI_2` (`field_id`),
  KEY `field_relation_FI_3` (`created_by`),
  KEY `field_relation_FI_4` (`updated_by`),
  CONSTRAINT `field_relation_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `field_relation_FK_2` FOREIGN KEY (`field_id`) REFERENCES `field` (`id`),
  CONSTRAINT `field_relation_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `field_relation_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_relation`
--

LOCK TABLES `field_relation` WRITE;
/*!40000 ALTER TABLE `field_relation` DISABLE KEYS */;
/*!40000 ALTER TABLE `field_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_relation_value`
--

DROP TABLE IF EXISTS `field_relation_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_relation_value` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `field_id` int(11) NOT NULL,
  `field_relation_id` int(11) NOT NULL,
  `object_type` int(11) NOT NULL,
  `target_object_type` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `target_object_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `frv_lookup_by_source` (`account_id`,`object_type`,`field_id`,`object_id`),
  KEY `frv_lookup_by_target` (`account_id`,`object_type`,`field_id`,`target_object_type`,`target_object_id`),
  KEY `field_relation_value_FI_2` (`field_id`),
  KEY `field_relation_value_FI_3` (`field_relation_id`),
  CONSTRAINT `field_relation_value_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `field_relation_value_FK_2` FOREIGN KEY (`field_id`) REFERENCES `field` (`id`),
  CONSTRAINT `field_relation_value_FK_3` FOREIGN KEY (`field_relation_id`) REFERENCES `field_relation` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_relation_value`
--

LOCK TABLES `field_relation_value` WRITE;
/*!40000 ALTER TABLE `field_relation_value` DISABLE KEYS */;
/*!40000 ALTER TABLE `field_relation_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `field_value`
--

DROP TABLE IF EXISTS `field_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_value` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `object_type` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `field_id` int(11) NOT NULL,
  `value` text COLLATE utf8_unicode_ci,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `field_value_object_lookup` (`account_id`,`object_type`,`object_id`),
  KEY `field_value_FI_2` (`field_id`),
  KEY `field_value_FI_3` (`created_by`),
  KEY `field_value_FI_4` (`updated_by`),
  CONSTRAINT `field_value_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `field_value_FK_2` FOREIGN KEY (`field_id`) REFERENCES `field` (`id`),
  CONSTRAINT `field_value_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `field_value_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `field_value`
--

LOCK TABLES `field_value` WRITE;
/*!40000 ALTER TABLE `field_value` DISABLE KEYS */;
/*!40000 ALTER TABLE `field_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_stats`
--

DROP TABLE IF EXISTS `file_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `file_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `file_id` int(11) NOT NULL,
  `stats_date` date DEFAULT NULL,
  `unique_views` int(11) DEFAULT '0',
  `total_views` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `file_stats_lookup` (`file_id`,`stats_date`),
  KEY `file_stats_FI_1` (`account_id`),
  CONSTRAINT `file_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `file_stats_FK_2` FOREIGN KEY (`file_id`) REFERENCES `filex` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_stats`
--

LOCK TABLES `file_stats` WRITE;
/*!40000 ALTER TABLE `file_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `file_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `filex`
--

DROP TABLE IF EXISTS `filex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `filex` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `s3_key` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` text COLLATE utf8_unicode_ci,
  `size` int(11) DEFAULT NULL,
  `bitly_url_id` int(11) DEFAULT NULL,
  `vanity_url_id` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT '0',
  `is_do_not_index` tinyint(1) NOT NULL DEFAULT '1',
  `thumbnail_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `filex_FI_1` (`account_id`),
  KEY `filex_FI_2` (`bitly_url_id`),
  KEY `filex_FI_3` (`vanity_url_id`),
  KEY `filex_FI_4` (`created_by`),
  KEY `filex_FI_5` (`updated_by`),
  CONSTRAINT `filex_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `filex_FK_2` FOREIGN KEY (`bitly_url_id`) REFERENCES `bitly_url` (`id`),
  CONSTRAINT `filex_FK_3` FOREIGN KEY (`vanity_url_id`) REFERENCES `vanity_url` (`id`),
  CONSTRAINT `filex_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `filex_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `filex`
--

LOCK TABLES `filex` WRITE;
/*!40000 ALTER TABLE `filex` DISABLE KEYS */;
/*!40000 ALTER TABLE `filex` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `filter`
--

DROP TABLE IF EXISTS `filter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `filter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `filter_FI_1` (`account_id`),
  KEY `filter_FI_2` (`created_by`),
  KEY `filter_FI_3` (`updated_by`),
  CONSTRAINT `filter_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `filter_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `filter_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `filter`
--

LOCK TABLES `filter` WRITE;
/*!40000 ALTER TABLE `filter` DISABLE KEYS */;
INSERT INTO `filter` VALUES (1,2,'MSN Keyword Spam Bots','65.55.109.*',1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,'MSN Keyword Spam Bots 2','65.55.110.*',1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,2,'MSN Keyword Spam Bots 3','65.55.232.*',1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `filter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folder`
--

DROP TABLE IF EXISTS `folder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folder` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `parent_folder_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path` varchar(1700) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path_ids` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_permissions` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_folder_children` (`account_id`,`parent_folder_id`,`is_archived`),
  KEY `folder_FI_2` (`parent_folder_id`),
  KEY `folder_FI_3` (`created_by`),
  KEY `folder_FI_4` (`updated_by`),
  CONSTRAINT `folder_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `folder_FK_2` FOREIGN KEY (`parent_folder_id`) REFERENCES `folder` (`id`),
  CONSTRAINT `folder_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `folder_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folder`
--

LOCK TABLES `folder` WRITE;
/*!40000 ALTER TABLE `folder` DISABLE KEYS */;
/*!40000 ALTER TABLE `folder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folder_object`
--

DROP TABLE IF EXISTS `folder_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folder_object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `folder_id` int(11) NOT NULL,
  `tag_object_type` tinyint(4) DEFAULT NULL,
  `object_type` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `object_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `folder_object_account_object` (`account_id`,`folder_id`,`object_type`,`object_id`),
  KEY `folder_object_FI_2` (`folder_id`),
  KEY `folder_object_FI_3` (`created_by`),
  KEY `folder_object_FI_4` (`updated_by`),
  CONSTRAINT `folder_object_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `folder_object_FK_2` FOREIGN KEY (`folder_id`) REFERENCES `folder` (`id`),
  CONSTRAINT `folder_object_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `folder_object_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folder_object`
--

LOCK TABLES `folder_object` WRITE;
/*!40000 ALTER TABLE `folder_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `folder_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folder_permission`
--

DROP TABLE IF EXISTS `folder_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folder_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `folder_id` int(11) NOT NULL,
  `group_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_folder_permission_account_folder_group` (`account_id`,`folder_id`,`group_id`),
  KEY `folder_permission_FI_2` (`folder_id`),
  KEY `folder_permission_FI_3` (`group_id`),
  KEY `folder_permission_FI_4` (`created_by`),
  CONSTRAINT `folder_permission_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `folder_permission_FK_2` FOREIGN KEY (`folder_id`) REFERENCES `folder` (`id`),
  CONSTRAINT `folder_permission_FK_3` FOREIGN KEY (`group_id`) REFERENCES `groupx` (`id`),
  CONSTRAINT `folder_permission_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folder_permission`
--

LOCK TABLES `folder_permission` WRITE;
/*!40000 ALTER TABLE `folder_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `folder_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form`
--

DROP TABLE IF EXISTS `form`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `layout_template_id` int(11) DEFAULT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `submit_button_text` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `redirect_location` text COLLATE utf8_unicode_ci,
  `thank_you_content` text COLLATE utf8_unicode_ci,
  `thank_you_code` text COLLATE utf8_unicode_ci,
  `before_form_content` text COLLATE utf8_unicode_ci,
  `after_form_content` text COLLATE utf8_unicode_ci,
  `font_size` tinyint(4) DEFAULT NULL,
  `font_family` tinyint(4) DEFAULT NULL,
  `font_color` int(11) DEFAULT NULL,
  `label_alignment` tinyint(4) DEFAULT NULL,
  `radio_alignment` tinyint(4) DEFAULT NULL,
  `checkbox_alignment` tinyint(4) DEFAULT NULL,
  `required_char` tinyint(4) DEFAULT NULL,
  `show_not_prospect` int(11) DEFAULT '0',
  `is_use_redirect_location` int(11) DEFAULT '0',
  `is_notify_users` tinyint(1) NOT NULL DEFAULT '0',
  `is_notify_assigned` int(11) DEFAULT '0',
  `is_always_display` int(11) DEFAULT '0',
  `is_captcha_enabled` int(11) DEFAULT '0',
  `is_cookieless` int(11) DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_FI_1` (`account_id`),
  KEY `form_FI_2` (`campaign_id`),
  KEY `form_FI_3` (`layout_template_id`),
  KEY `form_FI_4` (`email_template_id`),
  KEY `form_FI_5` (`created_by`),
  KEY `form_FI_6` (`updated_by`),
  CONSTRAINT `form_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `form_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `form_FK_3` FOREIGN KEY (`layout_template_id`) REFERENCES `layout_template` (`id`),
  CONSTRAINT `form_FK_4` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`),
  CONSTRAINT `form_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `form_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form`
--

LOCK TABLES `form` WRITE;
/*!40000 ALTER TABLE `form` DISABLE KEYS */;
INSERT INTO `form` VALUES (1,2,1,1,NULL,'Standard Form',NULL,'Submit',NULL,'<p>Thank you for filling out the form. We will get back to you shortly.</p>',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,0,0,0,0,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `form` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_field`
--

DROP TABLE IF EXISTS `form_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `form_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `error_message` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `regular_expression` text COLLATE utf8_unicode_ci,
  `default_value` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_mail_merge_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `css_classes` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) DEFAULT '1',
  `data_format` int(11) DEFAULT '1',
  `is_required` tinyint(1) NOT NULL DEFAULT '0',
  `is_always_display` tinyint(1) NOT NULL DEFAULT '0',
  `is_use_conditionals` tinyint(1) NOT NULL DEFAULT '0',
  `is_use_values` tinyint(1) NOT NULL DEFAULT '0',
  `is_maintain_initial_value` tinyint(1) NOT NULL DEFAULT '0',
  `is_do_not_prefill` int(11) DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_field_FI_1` (`account_id`),
  KEY `form_field_FI_2` (`form_id`),
  KEY `form_field_FI_3` (`prospect_field_default_id`),
  KEY `form_field_FI_4` (`prospect_field_custom_id`),
  KEY `form_field_FI_5` (`created_by`),
  KEY `form_field_FI_6` (`updated_by`),
  CONSTRAINT `form_field_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `form_field_FK_2` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `form_field_FK_3` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `form_field_FK_4` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`),
  CONSTRAINT `form_field_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `form_field_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_field`
--

LOCK TABLES `form_field` WRITE;
/*!40000 ALTER TABLE `form_field` DISABLE KEYS */;
INSERT INTO `form_field` VALUES (1,2,1,1,1,NULL,'First Name','First Name',NULL,'This field is required.',NULL,NULL,NULL,NULL,1,1,1,0,0,0,0,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,1,2,2,NULL,'Last Name','Last Name',NULL,'This field is required.',NULL,NULL,NULL,NULL,1,1,1,0,0,0,0,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,2,1,3,3,NULL,'Email','Email',NULL,'Please input a valid email address from a non-free provider.',NULL,NULL,NULL,NULL,1,3,1,1,0,0,0,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(4,2,1,4,4,NULL,'Company','Company',NULL,'This field is required.',NULL,NULL,NULL,NULL,1,1,1,0,0,0,0,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `form_field` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_field_conditional`
--

DROP TABLE IF EXISTS `form_field_conditional`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_field_conditional` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `form_field_id` int(11) DEFAULT NULL,
  `conditional_id` int(11) DEFAULT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_field_conditional_FI_1` (`account_id`),
  KEY `form_field_conditional_FI_2` (`form_field_id`),
  KEY `form_field_conditional_FI_3` (`conditional_id`),
  KEY `form_field_conditional_FI_4` (`prospect_field_default_id`),
  KEY `form_field_conditional_FI_5` (`prospect_field_custom_id`),
  KEY `form_field_conditional_FI_6` (`created_by`),
  CONSTRAINT `form_field_conditional_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `form_field_conditional_FK_2` FOREIGN KEY (`form_field_id`) REFERENCES `form_field` (`id`),
  CONSTRAINT `form_field_conditional_FK_3` FOREIGN KEY (`conditional_id`) REFERENCES `form_field` (`id`),
  CONSTRAINT `form_field_conditional_FK_4` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `form_field_conditional_FK_5` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`),
  CONSTRAINT `form_field_conditional_FK_6` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_field_conditional`
--

LOCK TABLES `form_field_conditional` WRITE;
/*!40000 ALTER TABLE `form_field_conditional` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_field_conditional` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_field_value`
--

DROP TABLE IF EXISTS `form_field_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_field_value` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `form_field_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_field_value_FI_1` (`account_id`),
  KEY `form_field_value_FI_2` (`form_field_id`),
  KEY `form_field_value_FI_3` (`listx_id`),
  KEY `form_field_value_FI_4` (`profile_id`),
  KEY `form_field_value_FI_5` (`created_by`),
  KEY `form_field_value_FI_6` (`updated_by`),
  CONSTRAINT `form_field_value_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `form_field_value_FK_2` FOREIGN KEY (`form_field_id`) REFERENCES `form_field` (`id`),
  CONSTRAINT `form_field_value_FK_3` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `form_field_value_FK_4` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`),
  CONSTRAINT `form_field_value_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `form_field_value_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_field_value`
--

LOCK TABLES `form_field_value` WRITE;
/*!40000 ALTER TABLE `form_field_value` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_field_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_handler`
--

DROP TABLE IF EXISTS `form_handler`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_handler` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `success_location` text COLLATE utf8_unicode_ci,
  `error_location` text COLLATE utf8_unicode_ci,
  `is_data_forwarded` tinyint(1) NOT NULL DEFAULT '0',
  `is_notify_users` tinyint(1) NOT NULL DEFAULT '0',
  `is_notify_assigned` int(11) DEFAULT '0',
  `is_always_email` int(11) DEFAULT '0',
  `is_cookieless` int(11) DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_handler_FI_1` (`account_id`),
  KEY `form_handler_FI_2` (`campaign_id`),
  KEY `form_handler_FI_3` (`email_template_id`),
  KEY `form_handler_FI_4` (`created_by`),
  KEY `form_handler_FI_5` (`updated_by`),
  CONSTRAINT `form_handler_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `form_handler_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `form_handler_FK_3` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`),
  CONSTRAINT `form_handler_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `form_handler_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_handler`
--

LOCK TABLES `form_handler` WRITE;
/*!40000 ALTER TABLE `form_handler` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_handler` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_handler_form_field`
--

DROP TABLE IF EXISTS `form_handler_form_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_handler_form_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `form_handler_id` int(11) DEFAULT NULL,
  `form_field_id` int(11) DEFAULT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `is_maintain_initial_value` int(11) DEFAULT '0',
  `is_required` int(11) DEFAULT '0',
  `data_format` int(11) DEFAULT '1',
  `error_message` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_handler_form_field_FI_1` (`account_id`),
  KEY `form_handler_form_field_FI_2` (`form_handler_id`),
  KEY `form_handler_form_field_FI_3` (`form_field_id`),
  KEY `form_handler_form_field_FI_4` (`prospect_field_default_id`),
  KEY `form_handler_form_field_FI_5` (`prospect_field_custom_id`),
  KEY `form_handler_form_field_FI_6` (`created_by`),
  CONSTRAINT `form_handler_form_field_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `form_handler_form_field_FK_2` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`),
  CONSTRAINT `form_handler_form_field_FK_3` FOREIGN KEY (`form_field_id`) REFERENCES `form_field` (`id`),
  CONSTRAINT `form_handler_form_field_FK_4` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `form_handler_form_field_FK_5` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`),
  CONSTRAINT `form_handler_form_field_FK_6` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_handler_form_field`
--

LOCK TABLES `form_handler_form_field` WRITE;
/*!40000 ALTER TABLE `form_handler_form_field` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_handler_form_field` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_handler_notification`
--

DROP TABLE IF EXISTS `form_handler_notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_handler_notification` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `form_handler_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_handler_notification_FI_1` (`account_id`),
  KEY `form_handler_notification_FI_2` (`form_handler_id`),
  KEY `form_handler_notification_FI_3` (`user_id`),
  KEY `form_handler_notification_FI_4` (`created_by`),
  KEY `form_handler_notification_FI_5` (`updated_by`),
  CONSTRAINT `form_handler_notification_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `form_handler_notification_FK_2` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`),
  CONSTRAINT `form_handler_notification_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `form_handler_notification_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `form_handler_notification_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_handler_notification`
--

LOCK TABLES `form_handler_notification` WRITE;
/*!40000 ALTER TABLE `form_handler_notification` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_handler_notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_handler_stats`
--

DROP TABLE IF EXISTS `form_handler_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_handler_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `form_handler_id` int(11) NOT NULL,
  `stats_date` date DEFAULT NULL,
  `conversions` int(11) DEFAULT '0',
  `unique_submissions` int(11) DEFAULT '0',
  `total_submissions` int(11) DEFAULT '0',
  `unique_errors` int(11) DEFAULT '0',
  `total_errors` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_handler_stats_uniq` (`form_handler_id`,`campaign_id`,`stats_date`),
  KEY `form_handler_stats_FI_1` (`account_id`),
  KEY `form_handler_stats_FI_2` (`campaign_id`),
  CONSTRAINT `form_handler_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `form_handler_stats_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `form_handler_stats_FK_3` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_handler_stats`
--

LOCK TABLES `form_handler_stats` WRITE;
/*!40000 ALTER TABLE `form_handler_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_handler_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_notification`
--

DROP TABLE IF EXISTS `form_notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_notification` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `form_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `form_notification_FI_1` (`account_id`),
  KEY `form_notification_FI_2` (`form_id`),
  KEY `form_notification_FI_3` (`user_id`),
  KEY `form_notification_FI_4` (`created_by`),
  KEY `form_notification_FI_5` (`updated_by`),
  CONSTRAINT `form_notification_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `form_notification_FK_2` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `form_notification_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `form_notification_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `form_notification_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_notification`
--

LOCK TABLES `form_notification` WRITE;
/*!40000 ALTER TABLE `form_notification` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_stats`
--

DROP TABLE IF EXISTS `form_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `form_id` int(11) NOT NULL,
  `stats_date` date DEFAULT NULL,
  `unique_views` int(11) DEFAULT '0',
  `total_views` int(11) DEFAULT '0',
  `conversions` int(11) DEFAULT '0',
  `unique_submissions` int(11) DEFAULT '0',
  `total_submissions` int(11) DEFAULT '0',
  `unique_errors` int(11) DEFAULT '0',
  `total_errors` int(11) DEFAULT '0',
  `unique_clicks` int(11) DEFAULT '0',
  `total_clicks` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `form_stats_lookup` (`form_id`,`stats_date`),
  KEY `form_stats_FI_1` (`account_id`),
  KEY `form_stats_FI_2` (`campaign_id`),
  CONSTRAINT `form_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `form_stats_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `form_stats_FK_3` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_stats`
--

LOCK TABLES `form_stats` WRITE;
/*!40000 ALTER TABLE `form_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_message_prefs`
--

DROP TABLE IF EXISTS `global_message_prefs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `global_message_prefs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `global_message_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `modified_at` datetime DEFAULT NULL,
  `is_dismissed` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `global_message_prefs_FI_1` (`account_id`),
  KEY `global_message_prefs_FI_2` (`user_id`),
  CONSTRAINT `global_message_prefs_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `global_message_prefs_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_message_prefs`
--

LOCK TABLES `global_message_prefs` WRITE;
/*!40000 ALTER TABLE `global_message_prefs` DISABLE KEYS */;
/*!40000 ALTER TABLE `global_message_prefs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groupx`
--

DROP TABLE IF EXISTS `groupx`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groupx` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `groupx_FI_1` (`account_id`),
  KEY `groupx_FI_2` (`created_by`),
  KEY `groupx_FI_3` (`updated_by`),
  CONSTRAINT `groupx_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `groupx_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `groupx_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groupx`
--

LOCK TABLES `groupx` WRITE;
/*!40000 ALTER TABLE `groupx` DISABLE KEYS */;
/*!40000 ALTER TABLE `groupx` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groupx_user`
--

DROP TABLE IF EXISTS `groupx_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groupx_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `groupx_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `last_assigned_prospect_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `groupx_user_FI_1` (`account_id`),
  KEY `groupx_user_FI_2` (`groupx_id`),
  KEY `groupx_user_FI_3` (`user_id`),
  CONSTRAINT `groupx_user_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `groupx_user_FK_2` FOREIGN KEY (`groupx_id`) REFERENCES `groupx` (`id`),
  CONSTRAINT `groupx_user_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groupx_user`
--

LOCK TABLES `groupx_user` WRITE;
/*!40000 ALTER TABLE `groupx_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `groupx_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `import`
--

DROP TABLE IF EXISTS `import`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `background_queue_id` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `s3_bucket` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `s3_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `num_created` int(11) DEFAULT NULL,
  `num_updated` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `import_FI_1` (`account_id`),
  KEY `import_FI_2` (`user_id`),
  KEY `import_FI_3` (`background_queue_id`),
  CONSTRAINT `import_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `import_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `import_FK_3` FOREIGN KEY (`background_queue_id`) REFERENCES `background_queue` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import`
--

LOCK TABLES `import` WRITE;
/*!40000 ALTER TABLE `import` DISABLE KEYS */;
/*!40000 ALTER TABLE `import` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `import_log`
--

DROP TABLE IF EXISTS `import_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `import_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `action` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `import_prospect` (`import_id`,`prospect_id`),
  KEY `import_log_FI_1` (`account_id`),
  KEY `import_log_FI_3` (`prospect_id`),
  CONSTRAINT `import_log_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `import_log_FK_2` FOREIGN KEY (`import_id`) REFERENCES `import` (`id`),
  CONSTRAINT `import_log_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import_log`
--

LOCK TABLES `import_log` WRITE;
/*!40000 ALTER TABLE `import_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `import_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyword`
--

DROP TABLE IF EXISTS `keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyword` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `competitor_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `site` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `stats_checked_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `keyword_FI_1` (`account_id`),
  KEY `keyword_FI_2` (`competitor_id`),
  KEY `keyword_FI_3` (`created_by`),
  KEY `keyword_FI_4` (`updated_by`),
  CONSTRAINT `keyword_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `keyword_FK_2` FOREIGN KEY (`competitor_id`) REFERENCES `competitor` (`id`),
  CONSTRAINT `keyword_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `keyword_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keyword`
--

LOCK TABLES `keyword` WRITE;
/*!40000 ALTER TABLE `keyword` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyword` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyword_position`
--

DROP TABLE IF EXISTS `keyword_position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyword_position` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `keyword_id` int(11) NOT NULL,
  `stats_date` date NOT NULL,
  `search_vendor` int(11) NOT NULL,
  `position1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position3` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position4` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position5` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position6` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position7` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position8` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position9` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position10` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position11` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position12` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position13` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position14` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position15` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position16` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position17` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position18` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position19` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position20` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_current` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `keyword_position_lookup` (`keyword_id`,`stats_date`,`search_vendor`),
  KEY `keyword_position_FI_1` (`account_id`),
  CONSTRAINT `keyword_position_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `keyword_position_FK_2` FOREIGN KEY (`keyword_id`) REFERENCES `keyword` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keyword_position`
--

LOCK TABLES `keyword_position` WRITE;
/*!40000 ALTER TABLE `keyword_position` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyword_position` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyword_position_competitor`
--

DROP TABLE IF EXISTS `keyword_position_competitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyword_position_competitor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `keyword_position_id` int(11) NOT NULL,
  `competitor_id` int(11) NOT NULL,
  `position` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `keyword_position_competitor_FI_1` (`account_id`),
  KEY `keyword_position_competitor_FI_2` (`keyword_position_id`),
  KEY `keyword_position_competitor_FI_3` (`competitor_id`),
  CONSTRAINT `keyword_position_competitor_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `keyword_position_competitor_FK_2` FOREIGN KEY (`keyword_position_id`) REFERENCES `keyword_position` (`id`),
  CONSTRAINT `keyword_position_competitor_FK_3` FOREIGN KEY (`competitor_id`) REFERENCES `competitor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keyword_position_competitor`
--

LOCK TABLES `keyword_position_competitor` WRITE;
/*!40000 ALTER TABLE `keyword_position_competitor` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyword_position_competitor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyword_prospect`
--

DROP TABLE IF EXISTS `keyword_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyword_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `keyword_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `keyword_prospect_lookup` (`account_id`,`keyword_id`,`prospect_id`),
  KEY `keyword_prospect_FI_2` (`keyword_id`),
  KEY `keyword_prospect_FI_3` (`prospect_id`),
  CONSTRAINT `keyword_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `keyword_prospect_FK_2` FOREIGN KEY (`keyword_id`) REFERENCES `keyword` (`id`),
  CONSTRAINT `keyword_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keyword_prospect`
--

LOCK TABLES `keyword_prospect` WRITE;
/*!40000 ALTER TABLE `keyword_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyword_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyword_stats`
--

DROP TABLE IF EXISTS `keyword_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyword_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `keyword_id` int(11) NOT NULL,
  `stats_date` date NOT NULL,
  `monthly_search_volume` int(11) DEFAULT NULL,
  `cost_per_click` float DEFAULT NULL,
  `ranking_difficulty` int(11) DEFAULT NULL,
  `google_rank` int(11) DEFAULT NULL,
  `bing_rank` int(11) DEFAULT NULL,
  `is_current` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `keyword_stats_lookup` (`keyword_id`,`stats_date`),
  KEY `keyword_stats_FI_1` (`account_id`),
  CONSTRAINT `keyword_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `keyword_stats_FK_2` FOREIGN KEY (`keyword_id`) REFERENCES `keyword` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keyword_stats`
--

LOCK TABLES `keyword_stats` WRITE;
/*!40000 ALTER TABLE `keyword_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyword_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyword_suggestion`
--

DROP TABLE IF EXISTS `keyword_suggestion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyword_suggestion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `keyword_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `monthly_search_volume` int(11) DEFAULT NULL,
  `cost_per_click` float DEFAULT NULL,
  `ranking_difficulty` int(11) DEFAULT NULL,
  `google_rank` int(11) DEFAULT NULL,
  `bing_rank` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `keyword_suggestion_lookup` (`keyword_id`,`name`),
  KEY `keyword_suggestion_FI_1` (`account_id`),
  CONSTRAINT `keyword_suggestion_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `keyword_suggestion_FK_2` FOREIGN KEY (`keyword_id`) REFERENCES `keyword` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keyword_suggestion`
--

LOCK TABLES `keyword_suggestion` WRITE;
/*!40000 ALTER TABLE `keyword_suggestion` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyword_suggestion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `landing_page`
--

DROP TABLE IF EXISTS `landing_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `landing_page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `layout_template_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_do_not_index` int(11) DEFAULT '0',
  `opening_general_content` text COLLATE utf8_unicode_ci,
  `content` text COLLATE utf8_unicode_ci,
  `content_desc` text COLLATE utf8_unicode_ci,
  `layout_type` int(11) DEFAULT '1',
  `static_layout_type` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `script_fragment` text COLLATE utf8_unicode_ci,
  `layout_css` text COLLATE utf8_unicode_ci,
  `layout_css_generated` text COLLATE utf8_unicode_ci,
  `layout_table_border` int(11) DEFAULT NULL,
  `layout_background_color` varchar(7) COLLATE utf8_unicode_ci DEFAULT NULL,
  `layout_table_background_color` varchar(7) COLLATE utf8_unicode_ci DEFAULT NULL,
  `redirect_location` text COLLATE utf8_unicode_ci,
  `vanity_url_id` int(11) DEFAULT NULL,
  `is_use_redirect_location` tinyint(1) NOT NULL DEFAULT '0',
  `bitly_url_id` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `landing_page_FI_1` (`account_id`),
  KEY `landing_page_FI_2` (`campaign_id`),
  KEY `landing_page_FI_3` (`form_id`),
  KEY `landing_page_FI_4` (`layout_template_id`),
  KEY `landing_page_FI_5` (`vanity_url_id`),
  KEY `landing_page_FI_6` (`bitly_url_id`),
  KEY `landing_page_FI_7` (`created_by`),
  KEY `landing_page_FI_8` (`updated_by`),
  CONSTRAINT `landing_page_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `landing_page_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `landing_page_FK_3` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `landing_page_FK_4` FOREIGN KEY (`layout_template_id`) REFERENCES `layout_template` (`id`),
  CONSTRAINT `landing_page_FK_5` FOREIGN KEY (`vanity_url_id`) REFERENCES `vanity_url` (`id`),
  CONSTRAINT `landing_page_FK_6` FOREIGN KEY (`bitly_url_id`) REFERENCES `bitly_url` (`id`),
  CONSTRAINT `landing_page_FK_7` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `landing_page_FK_8` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `landing_page`
--

LOCK TABLES `landing_page` WRITE;
/*!40000 ALTER TABLE `landing_page` DISABLE KEYS */;
/*!40000 ALTER TABLE `landing_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `landing_page_stats`
--

DROP TABLE IF EXISTS `landing_page_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `landing_page_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `landing_page_id` int(11) NOT NULL,
  `stats_date` date DEFAULT NULL,
  `unique_views` int(11) DEFAULT '0',
  `total_views` int(11) DEFAULT '0',
  `conversions` int(11) DEFAULT '0',
  `unique_submissions` int(11) DEFAULT '0',
  `total_submissions` int(11) DEFAULT '0',
  `unique_errors` int(11) DEFAULT '0',
  `total_errors` int(11) DEFAULT '0',
  `unique_clicks` int(11) DEFAULT '0',
  `total_clicks` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `landing_page_stats_lookup` (`landing_page_id`,`stats_date`),
  KEY `landing_page_stats_FI_1` (`account_id`),
  KEY `landing_page_stats_FI_2` (`campaign_id`),
  CONSTRAINT `landing_page_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `landing_page_stats_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `landing_page_stats_FK_3` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `landing_page_stats`
--

LOCK TABLES `landing_page_stats` WRITE;
/*!40000 ALTER TABLE `landing_page_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `landing_page_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `layout_template`
--

DROP TABLE IF EXISTS `layout_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `layout_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `layout_content` mediumtext COLLATE utf8_unicode_ci,
  `form_content` mediumtext COLLATE utf8_unicode_ci,
  `site_search_content` mediumtext COLLATE utf8_unicode_ci,
  `is_use_wysiwyg` int(11) DEFAULT '1',
  `is_include_default_css` tinyint(1) NOT NULL DEFAULT '1',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `thumbnail_id` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `layout_template_FI_1` (`account_id`),
  KEY `layout_template_FI_2` (`thumbnail_id`),
  KEY `layout_template_FI_3` (`created_by`),
  KEY `layout_template_FI_4` (`updated_by`),
  CONSTRAINT `layout_template_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `layout_template_FK_2` FOREIGN KEY (`thumbnail_id`) REFERENCES `thumbnail` (`id`),
  CONSTRAINT `layout_template_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `layout_template_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `layout_template`
--

LOCK TABLES `layout_template` WRITE;
/*!40000 ALTER TABLE `layout_template` DISABLE KEYS */;
INSERT INTO `layout_template` VALUES (1,2,'Standard',NULL,'\r\n<!DOCTYPE html>\r\n<html>\r\n	<head>\r\n		<base href=\"\" >\r\n		<meta charset=\"utf-8\"/>\r\n		<meta name=\"description\" content=\"%%description%%\"/>\r\n		<title>%%title%%</title>\r\n	</head>\r\n	<body>\r\n		%%content%%\r\n	</body>\r\n</html>\r\n','\r\n<form accept-charset=\"UTF-8\" method=\"post\" action=\"%%form-action-url%%\" class=\"form\" id=\"pardot-form\">\r\n%%form-opening-general-content%%\r\n\r\n%%form-if-thank-you%%\r\n	%%form-javascript-focus%%\r\n	%%form-thank-you-content%%\r\n	%%form-thank-you-code%%\r\n%%form-end-if-thank-you%%\r\n\r\n%%form-if-display-form%%\r\n\r\n	%%form-before-form-content%%\r\n		%%form-if-error%%\r\n			<p class=\"errors\">Please correct the errors below:</p>\r\n		%%form-end-if-error%%\r\n		\r\n		%%form-start-loop-fields%%\r\n			<p class=\"form-field %%form-field-css-classes%% %%form-field-class-type%% %%form-field-class-required%% %%form-field-class-hidden%% %%form-field-class-no-label%% %%form-field-class-error%% %%form-field-dependency-css%%\">\r\n				%%form-if-field-label%%\r\n					<label class=\"field-label\" for=\"%%form-field-id%%\">%%form-field-label%%</label>\r\n				%%form-end-if-field-label%%\r\n				\r\n				%%form-field-input%%\r\n				%%form-if-field-description%%\r\n					<span class=\"description\">%%form-field-description%%</span>\r\n				%%form-end-if-field-description%%\r\n			</p>\r\n			<div id=\"error_for_%%form-field-id%%\" style=\"display:none\"></div>\r\n			%%form-field-if-error%%\r\n				<p class=\"error no-label\">%%form-field-error-message%%</p>\r\n			%%form-field-end-if-error%%\r\n		%%form-end-loop-fields%%\r\n		\r\n		%%form-spam-trap-field%%\r\n		\r\n		<!-- forces IE5-8 to correctly submit UTF8 content  -->\r\n		<input name=\"_utf8\" type=\"hidden\" value=\"&#9731;\" />\r\n		\r\n		<p class=\"submit\">\r\n			<input type=\"submit\" accesskey=\"s\" value=\"%%form-submit-button-text%%\" %%form-submit-disabled%%/>\r\n		</p>\r\n	%%form-after-form-content%%\r\n	\r\n%%form-end-if-display-form%%\r\n\r\n%%form-javascript-link-target-top%%\r\n</form>\r\n','\r\n<form method=\"get\" action=\"%%search-action-url%%\" class=\"form\" id=\"pardot-form\">\r\n	<p class=\"full-width\">\r\n		<input type=\"text\" name=\"q\" value=\"%%search-query%%\" size=\"40\" /> \r\n		<input type=\"submit\" value=\"Search\" /> \r\n	</p>\r\n<h2>Search results for: %%search-query%%</h2>		\r\n\r\n%%search-if-results%%\r\n	<ol start=\"%%search-result-start-position%%\">\r\n		%%search-start-loop-results%% \r\n		<li>\r\n			<strong><a href=\"%%search-result-url%%\">%%search-result-title%%</a></strong><br/>\r\n			%%search-result-description%%<br/> \r\n			<em>%%search-result-url-abbreviation%%</em> %%search-result-file-size%% KB\r\n		</li> \r\n		%%search-end-loop-results%%\r\n	</ol>\r\n	\r\n	<p class=\"pager\">\r\n		<strong>\r\n		%%search-if-previous-page-available%%\r\n		<a href=\"%%search-previous-page-url%%\">\r\n			Previous (page %%search-previous-page-number%%)\r\n		</a>\r\n		%%search-else-previous-page-not-available%%\r\n			Previous \r\n		%%search-end-if-previous-page-available%% |\r\n	\r\n		Page %%search-this-page-number%% of %%search-total-pages-number%% | \r\n	\r\n		%%search-if-next-page-available%%\r\n			<a href=\"%%search-next-page-url%%\">\r\n			Next (page %%search-next-page-number%%)</a>\r\n		%%search-else-next-page-not-available%%\r\n			Next\r\n		%%search-end-if-next-page-available%%\r\n		</strong>\r\n	</p>\r\n%%search-else-no-results%%\r\n	%%search-no-results-content%%\r\n%%search-end-if-results%%\r\n</form>\r\n',1,1,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,'Unsubscribe Layout',NULL,NULL,NULL,NULL,1,1,0,NULL,9,9,'2007-07-29 10:42:51','2007-07-29 10:42:51');
/*!40000 ALTER TABLE `layout_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `layout_template_region`
--

DROP TABLE IF EXISTS `layout_template_region`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `layout_template_region` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `layout_template_id` int(11) NOT NULL,
  `landing_page_id` int(11) DEFAULT NULL,
  `region_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `region_element` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `region_content` text COLLATE utf8_unicode_ci,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `layout_template_region_FI_1` (`account_id`),
  KEY `layout_template_region_FI_2` (`layout_template_id`),
  KEY `layout_template_region_FI_3` (`landing_page_id`),
  KEY `layout_template_region_FI_4` (`created_by`),
  KEY `layout_template_region_FI_5` (`updated_by`),
  CONSTRAINT `layout_template_region_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `layout_template_region_FK_2` FOREIGN KEY (`layout_template_id`) REFERENCES `layout_template` (`id`),
  CONSTRAINT `layout_template_region_FK_3` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `layout_template_region_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `layout_template_region_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `layout_template_region`
--

LOCK TABLES `layout_template_region` WRITE;
/*!40000 ALTER TABLE `layout_template_region` DISABLE KEYS */;
/*!40000 ALTER TABLE `layout_template_region` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle`
--

DROP TABLE IF EXISTS `lifecycle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lifecycle` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lifecycle_FI_1` (`account_id`),
  KEY `lifecycle_FI_2` (`created_by`),
  KEY `lifecycle_FI_3` (`updated_by`),
  CONSTRAINT `lifecycle_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `lifecycle_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `lifecycle_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle`
--

LOCK TABLES `lifecycle` WRITE;
/*!40000 ALTER TABLE `lifecycle` DISABLE KEYS */;
INSERT INTO `lifecycle` VALUES (1,2,'Default',1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `lifecycle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_stage`
--

DROP TABLE IF EXISTS `lifecycle_stage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lifecycle_stage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `lifecycle_id` int(11) NOT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `is_locked` tinyint(1) NOT NULL DEFAULT '0',
  `match_type` int(11) DEFAULT '1',
  `last_run_at` datetime DEFAULT NULL,
  `runtime` float DEFAULT NULL,
  `is_paused` tinyint(1) NOT NULL DEFAULT '0',
  `is_being_processed` int(11) DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `total_prospects_matched` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lifecycle_stage_FI_1` (`account_id`),
  KEY `lifecycle_stage_FI_2` (`lifecycle_id`),
  KEY `lifecycle_stage_FI_3` (`created_by`),
  KEY `lifecycle_stage_FI_4` (`updated_by`),
  CONSTRAINT `lifecycle_stage_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `lifecycle_stage_FK_2` FOREIGN KEY (`lifecycle_id`) REFERENCES `lifecycle` (`id`),
  CONSTRAINT `lifecycle_stage_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `lifecycle_stage_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_stage`
--

LOCK TABLES `lifecycle_stage` WRITE;
/*!40000 ALTER TABLE `lifecycle_stage` DISABLE KEYS */;
INSERT INTO `lifecycle_stage` VALUES (1,2,1,'Prospects',0,1,1,NULL,NULL,0,0,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,1,'Assigned Prospects (MQLs)',1,1,1,NULL,NULL,0,0,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,2,1,'Opportunities (SQLs)',2,1,1,NULL,NULL,0,0,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(4,2,1,'Opportunities Won',3,1,1,NULL,NULL,0,0,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(5,2,1,'Opportunities Lost',4,1,1,NULL,NULL,0,0,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `lifecycle_stage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_stage_log`
--

DROP TABLE IF EXISTS `lifecycle_stage_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lifecycle_stage_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `lifecycle_id` int(11) DEFAULT NULL,
  `previous_lifecycle_stage_id` int(11) DEFAULT NULL,
  `next_lifecycle_stage_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `seconds_in_previous_stage` int(11) DEFAULT NULL,
  `transition_visitor_activity_id` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lifecycle_stage_log_FI_1` (`account_id`),
  KEY `lifecycle_stage_log_FI_2` (`lifecycle_id`),
  KEY `lifecycle_stage_log_FI_3` (`previous_lifecycle_stage_id`),
  KEY `lifecycle_stage_log_FI_4` (`next_lifecycle_stage_id`),
  KEY `lifecycle_stage_log_FI_5` (`prospect_id`),
  KEY `lifecycle_stage_log_FI_6` (`transition_visitor_activity_id`),
  KEY `lifecycle_stage_log_FI_7` (`campaign_id`),
  CONSTRAINT `lifecycle_stage_log_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `lifecycle_stage_log_FK_2` FOREIGN KEY (`lifecycle_id`) REFERENCES `lifecycle` (`id`),
  CONSTRAINT `lifecycle_stage_log_FK_3` FOREIGN KEY (`previous_lifecycle_stage_id`) REFERENCES `lifecycle_stage` (`id`),
  CONSTRAINT `lifecycle_stage_log_FK_4` FOREIGN KEY (`next_lifecycle_stage_id`) REFERENCES `lifecycle_stage` (`id`),
  CONSTRAINT `lifecycle_stage_log_FK_5` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `lifecycle_stage_log_FK_6` FOREIGN KEY (`transition_visitor_activity_id`) REFERENCES `visitor_activity` (`id`),
  CONSTRAINT `lifecycle_stage_log_FK_7` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_stage_log`
--

LOCK TABLES `lifecycle_stage_log` WRITE;
/*!40000 ALTER TABLE `lifecycle_stage_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_stage_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_stage_preview`
--

DROP TABLE IF EXISTS `lifecycle_stage_preview`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lifecycle_stage_preview` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `preview_key` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `num_matched` int(11) DEFAULT '0',
  `is_finished` tinyint(1) NOT NULL DEFAULT '0',
  `last_updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `notify_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_preview_key` (`account_id`,`preview_key`),
  CONSTRAINT `lifecycle_stage_preview_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_stage_preview`
--

LOCK TABLES `lifecycle_stage_preview` WRITE;
/*!40000 ALTER TABLE `lifecycle_stage_preview` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_stage_preview` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_stage_preview_prospect`
--

DROP TABLE IF EXISTS `lifecycle_stage_preview_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lifecycle_stage_preview_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `lifecycle_stage_preview_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_main` (`account_id`,`lifecycle_stage_preview_id`),
  KEY `lifecycle_stage_preview_prospect_FI_2` (`lifecycle_stage_preview_id`),
  KEY `lifecycle_stage_preview_prospect_FI_3` (`prospect_id`),
  CONSTRAINT `lifecycle_stage_preview_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `lifecycle_stage_preview_prospect_FK_2` FOREIGN KEY (`lifecycle_stage_preview_id`) REFERENCES `lifecycle_stage_preview` (`id`),
  CONSTRAINT `lifecycle_stage_preview_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_stage_preview_prospect`
--

LOCK TABLES `lifecycle_stage_preview_prospect` WRITE;
/*!40000 ALTER TABLE `lifecycle_stage_preview_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_stage_preview_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_stage_prospect`
--

DROP TABLE IF EXISTS `lifecycle_stage_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lifecycle_stage_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `lifecycle_id` int(11) DEFAULT NULL,
  `lifecycle_stage_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lifecycle_stage_prospect` (`lifecycle_id`,`prospect_id`),
  KEY `lifecycle_stage_prospect_FI_1` (`account_id`),
  KEY `lifecycle_stage_prospect_FI_3` (`lifecycle_stage_id`),
  KEY `lifecycle_stage_prospect_FI_4` (`prospect_id`),
  CONSTRAINT `lifecycle_stage_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `lifecycle_stage_prospect_FK_2` FOREIGN KEY (`lifecycle_id`) REFERENCES `lifecycle` (`id`),
  CONSTRAINT `lifecycle_stage_prospect_FK_3` FOREIGN KEY (`lifecycle_stage_id`) REFERENCES `lifecycle_stage` (`id`),
  CONSTRAINT `lifecycle_stage_prospect_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_stage_prospect`
--

LOCK TABLES `lifecycle_stage_prospect` WRITE;
/*!40000 ALTER TABLE `lifecycle_stage_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_stage_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_stage_queue`
--

DROP TABLE IF EXISTS `lifecycle_stage_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lifecycle_stage_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `transition_visitor_activity_id` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lifecycle_stage_queue_FI_1` (`account_id`),
  KEY `lifecycle_stage_queue_FI_2` (`prospect_id`),
  KEY `lifecycle_stage_queue_FI_3` (`transition_visitor_activity_id`),
  KEY `lifecycle_stage_queue_FI_4` (`campaign_id`),
  CONSTRAINT `lifecycle_stage_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `lifecycle_stage_queue_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `lifecycle_stage_queue_FK_3` FOREIGN KEY (`transition_visitor_activity_id`) REFERENCES `visitor_activity` (`id`),
  CONSTRAINT `lifecycle_stage_queue_FK_4` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_stage_queue`
--

LOCK TABLES `lifecycle_stage_queue` WRITE;
/*!40000 ALTER TABLE `lifecycle_stage_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `lifecycle_stage_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lifecycle_stage_rule`
--

DROP TABLE IF EXISTS `lifecycle_stage_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lifecycle_stage_rule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `lifecycle_stage_id` int(11) DEFAULT NULL,
  `lifecycle_stage_rule_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `compare` int(11) DEFAULT NULL,
  `operator` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `custom_url_id` int(11) DEFAULT NULL,
  `filex_id` int(11) DEFAULT NULL,
  `form_field_id` int(11) DEFAULT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `queue_id` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `form_handler_id` int(11) DEFAULT NULL,
  `landing_page_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `field_id` int(11) DEFAULT NULL,
  `webinar_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lifecycle_stage_rule_FI_1` (`account_id`),
  KEY `lifecycle_stage_rule_FI_2` (`lifecycle_stage_id`),
  KEY `lifecycle_stage_rule_FI_3` (`lifecycle_stage_rule_id`),
  KEY `lifecycle_stage_rule_FI_4` (`custom_url_id`),
  KEY `lifecycle_stage_rule_FI_5` (`filex_id`),
  KEY `lifecycle_stage_rule_FI_6` (`form_field_id`),
  KEY `lifecycle_stage_rule_FI_7` (`prospect_field_default_id`),
  KEY `lifecycle_stage_rule_FI_8` (`prospect_field_custom_id`),
  KEY `lifecycle_stage_rule_FI_9` (`user_id`),
  KEY `lifecycle_stage_rule_FI_10` (`queue_id`),
  KEY `lifecycle_stage_rule_FI_11` (`form_id`),
  KEY `lifecycle_stage_rule_FI_12` (`form_handler_id`),
  KEY `lifecycle_stage_rule_FI_13` (`landing_page_id`),
  KEY `lifecycle_stage_rule_FI_14` (`listx_id`),
  KEY `lifecycle_stage_rule_FI_15` (`field_id`),
  KEY `lifecycle_stage_rule_FI_16` (`webinar_id`),
  KEY `lifecycle_stage_rule_FI_17` (`profile_id`),
  KEY `lifecycle_stage_rule_FI_18` (`created_by`),
  KEY `lifecycle_stage_rule_FI_19` (`updated_by`),
  CONSTRAINT `lifecycle_stage_rule_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_10` FOREIGN KEY (`queue_id`) REFERENCES `queue` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_11` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_12` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_13` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_14` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_15` FOREIGN KEY (`field_id`) REFERENCES `field` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_16` FOREIGN KEY (`webinar_id`) REFERENCES `webinar` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_17` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_18` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_19` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_2` FOREIGN KEY (`lifecycle_stage_id`) REFERENCES `lifecycle_stage` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_3` FOREIGN KEY (`lifecycle_stage_rule_id`) REFERENCES `lifecycle_stage_rule` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_4` FOREIGN KEY (`custom_url_id`) REFERENCES `custom_url` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_5` FOREIGN KEY (`filex_id`) REFERENCES `filex` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_6` FOREIGN KEY (`form_field_id`) REFERENCES `form_field` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_7` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_8` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`),
  CONSTRAINT `lifecycle_stage_rule_FK_9` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lifecycle_stage_rule`
--

LOCK TABLES `lifecycle_stage_rule` WRITE;
/*!40000 ALTER TABLE `lifecycle_stage_rule` DISABLE KEYS */;
INSERT INTO `lifecycle_stage_rule` VALUES (1,2,1,NULL,4,7,16,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,2,NULL,20,NULL,16,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,2,3,NULL,21,9,12,'0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(4,2,3,NULL,20,NULL,16,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(5,2,4,NULL,14,3,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(6,2,4,NULL,20,NULL,16,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(7,2,5,NULL,14,4,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(8,2,5,NULL,20,NULL,16,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `lifecycle_stage_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `list_email`
--

DROP TABLE IF EXISTS `list_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `list_email` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `list_email_id` int(11) DEFAULT NULL,
  `drip_program_id` int(11) DEFAULT NULL,
  `drip_program_action_id` int(11) DEFAULT NULL,
  `email_message_id` int(11) DEFAULT NULL,
  `server_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_paused` int(11) DEFAULT '0',
  `is_queued` int(11) DEFAULT '0',
  `is_being_processed` int(11) DEFAULT '0',
  `is_sent` int(11) DEFAULT '0',
  `is_draft` int(11) DEFAULT '0',
  `is_crm_synced` int(11) DEFAULT '0',
  `is_hidden` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `client_type` int(11) DEFAULT NULL,
  `bounce_severity` int(11) DEFAULT '1',
  `has_opted_out` int(11) DEFAULT '0',
  `clicks` int(11) DEFAULT '0',
  `opens` int(11) DEFAULT '0',
  `spam_complaints` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_updated_at` (`updated_at`),
  KEY `ix_account_server_sent` (`account_id`,`server_id`,`is_sent`),
  KEY `ix_datatable` (`account_id`,`is_archived`,`is_hidden`,`sent_at`),
  KEY `is_queued` (`is_queued`),
  KEY `list_email_FI_2` (`user_id`),
  KEY `list_email_FI_3` (`campaign_id`),
  KEY `list_email_FI_4` (`prospect_id`),
  KEY `list_email_FI_5` (`listx_id`),
  KEY `list_email_FI_6` (`list_email_id`),
  KEY `list_email_FI_7` (`drip_program_id`),
  KEY `list_email_FI_8` (`drip_program_action_id`),
  KEY `list_email_FI_9` (`email_message_id`),
  KEY `list_email_FI_10` (`created_by`),
  KEY `list_email_FI_11` (`updated_by`),
  CONSTRAINT `list_email_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `list_email_FK_10` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `list_email_FK_11` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `list_email_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `list_email_FK_3` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `list_email_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `list_email_FK_5` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `list_email_FK_6` FOREIGN KEY (`list_email_id`) REFERENCES `list_email` (`id`),
  CONSTRAINT `list_email_FK_7` FOREIGN KEY (`drip_program_id`) REFERENCES `drip_program` (`id`),
  CONSTRAINT `list_email_FK_8` FOREIGN KEY (`drip_program_action_id`) REFERENCES `drip_program_action` (`id`),
  CONSTRAINT `list_email_FK_9` FOREIGN KEY (`email_message_id`) REFERENCES `email_message` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `list_email`
--

LOCK TABLES `list_email` WRITE;
/*!40000 ALTER TABLE `list_email` DISABLE KEYS */;
/*!40000 ALTER TABLE `list_email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `list_email_queue`
--

DROP TABLE IF EXISTS `list_email_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `list_email_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `email_id` int(11) NOT NULL,
  `server_id` int(11) DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `list_email_queue_email_id_unique` (`email_id`),
  KEY `list_email_queue_FI_1` (`account_id`),
  KEY `list_email_queue_FI_2` (`campaign_id`),
  CONSTRAINT `list_email_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `list_email_queue_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `list_email_queue_FK_3` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `list_email_queue`
--

LOCK TABLES `list_email_queue` WRITE;
/*!40000 ALTER TABLE `list_email_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `list_email_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `list_email_stats`
--

DROP TABLE IF EXISTS `list_email_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `list_email_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `email_id` int(11) NOT NULL,
  `stats_date` date DEFAULT NULL,
  `sent` int(11) DEFAULT '0',
  `queued` int(11) DEFAULT '0',
  `delivered` int(11) DEFAULT '0',
  `soft_bounce` int(11) DEFAULT '0',
  `hard_bounce` int(11) DEFAULT '0',
  `opted_out` int(11) DEFAULT '0',
  `unique_opens` int(11) DEFAULT '0',
  `opens` int(11) DEFAULT '0',
  `unique_clicks` int(11) DEFAULT '0',
  `total_clicks` int(11) DEFAULT '0',
  `spam_complaints` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `list_email_stats_lookup` (`email_id`,`stats_date`),
  KEY `list_email_stats_FI_1` (`account_id`),
  KEY `list_email_stats_FI_2` (`campaign_id`),
  CONSTRAINT `list_email_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `list_email_stats_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `list_email_stats_FK_3` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `list_email_stats`
--

LOCK TABLES `list_email_stats` WRITE;
/*!40000 ALTER TABLE `list_email_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `list_email_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `list_stats_log`
--

DROP TABLE IF EXISTS `list_stats_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `list_stats_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `fid` int(11) DEFAULT NULL,
  `type` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `update_type` int(11) DEFAULT NULL,
  `audit` text COLLATE utf8_unicode_ci,
  `is_processed` int(11) DEFAULT '0',
  `process_id` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ix_is_processed` (`account_id`,`is_processed`),
  CONSTRAINT `list_stats_log_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `list_stats_log`
--

LOCK TABLES `list_stats_log` WRITE;
/*!40000 ALTER TABLE `list_stats_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `list_stats_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `listx`
--

DROP TABLE IF EXISTS `listx`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `listx` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `dynamic_list_id` int(11) DEFAULT NULL,
  `connector_id` int(11) DEFAULT NULL,
  `email_connector_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_list_name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `is_dirty` int(11) DEFAULT '0',
  `is_public` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `is_crm_visible` int(11) DEFAULT '0',
  `is_test` int(11) DEFAULT '0',
  `prospect_count` int(11) DEFAULT '0',
  `database_mailable_size` int(11) DEFAULT '0',
  `stats_calculated_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_is_dirty` (`is_dirty`),
  KEY `listx_FI_1` (`account_id`),
  KEY `listx_FI_2` (`campaign_id`),
  KEY `listx_FI_3` (`dynamic_list_id`),
  KEY `listx_FI_4` (`connector_id`),
  KEY `listx_FI_5` (`created_by`),
  KEY `listx_FI_6` (`updated_by`),
  CONSTRAINT `listx_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `listx_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `listx_FK_3` FOREIGN KEY (`dynamic_list_id`) REFERENCES `dynamic_list` (`id`),
  CONSTRAINT `listx_FK_4` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `listx_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `listx_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listx`
--

LOCK TABLES `listx` WRITE;
/*!40000 ALTER TABLE `listx` DISABLE KEYS */;
INSERT INTO `listx` VALUES (1,2,1,NULL,NULL,NULL,NULL,'Customers',NULL,NULL,NULL,0,0,0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,1,NULL,NULL,NULL,NULL,'Partners',NULL,NULL,NULL,0,0,0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,2,1,NULL,NULL,NULL,NULL,'Monthly Newsletter',NULL,NULL,NULL,0,0,0,0,0,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(4,2,1,NULL,NULL,NULL,NULL,'Internal Test List',NULL,NULL,NULL,0,0,0,0,1,0,0,NULL,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `listx` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `listx_prospect`
--

DROP TABLE IF EXISTS `listx_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `listx_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `did_opt_in` int(11) DEFAULT '0',
  `did_opt_out` int(11) DEFAULT '0',
  `is_subscribed_connector` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `is_mailable` int(11) DEFAULT '1',
  `is_countable` int(11) DEFAULT '1',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `listx_prospect` (`listx_id`,`prospect_id`),
  KEY `ix_mailable` (`account_id`,`listx_id`,`is_mailable`),
  KEY `ix_countable` (`account_id`,`listx_id`,`is_countable`),
  KEY `listx_prospect_FI_3` (`prospect_id`),
  KEY `listx_prospect_FI_4` (`created_by`),
  KEY `listx_prospect_FI_5` (`updated_by`),
  CONSTRAINT `listx_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `listx_prospect_FK_2` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `listx_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `listx_prospect_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `listx_prospect_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listx_prospect`
--

LOCK TABLES `listx_prospect` WRITE;
/*!40000 ALTER TABLE `listx_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `listx_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `listx_split`
--

DROP TABLE IF EXISTS `listx_split`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `listx_split` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `listx_id` int(11) NOT NULL,
  `params` text COLLATE utf8_unicode_ci,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `notify_email` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `listx_split_FI_1` (`account_id`),
  KEY `listx_split_FI_2` (`listx_id`),
  KEY `listx_split_FI_3` (`created_by`),
  CONSTRAINT `listx_split_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `listx_split_FK_2` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `listx_split_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listx_split`
--

LOCK TABLES `listx_split` WRITE;
/*!40000 ALTER TABLE `listx_split` DISABLE KEYS */;
/*!40000 ALTER TABLE `listx_split` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `litmus_email_analytics`
--

DROP TABLE IF EXISTS `litmus_email_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `litmus_email_analytics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_id` int(11) NOT NULL,
  `guid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `report_guid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `analytics_html` text COLLATE utf8_unicode_ci,
  `needs_recreate` int(11) DEFAULT '0',
  `engagement_report_serialized` text COLLATE utf8_unicode_ci,
  `email_clients_report_serialized` text COLLATE utf8_unicode_ci,
  `activity_summary_report_serialized` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `litmus_email_analytics` (`account_id`,`email_id`),
  KEY `litmus_email_analytics_FI_2` (`email_id`),
  CONSTRAINT `litmus_email_analytics_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `litmus_email_analytics_FK_2` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `litmus_email_analytics`
--

LOCK TABLES `litmus_email_analytics` WRITE;
/*!40000 ALTER TABLE `litmus_email_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `litmus_email_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `litmus_email_resource`
--

DROP TABLE IF EXISTS `litmus_email_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `litmus_email_resource` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_user_id` int(11) DEFAULT NULL,
  `email_message_user_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `html_content` text COLLATE utf8_unicode_ci,
  `text_content` text COLLATE utf8_unicode_ci,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) NOT NULL DEFAULT '1',
  `from_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_from_assigned_user` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `litmus_email_resource_FI_1` (`account_id`),
  KEY `litmus_email_resource_FI_2` (`email_user_id`),
  KEY `litmus_email_resource_FI_3` (`email_message_user_id`),
  KEY `litmus_email_resource_FI_4` (`prospect_id`),
  CONSTRAINT `litmus_email_resource_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `litmus_email_resource_FK_2` FOREIGN KEY (`email_user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `litmus_email_resource_FK_3` FOREIGN KEY (`email_message_user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `litmus_email_resource_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `litmus_email_resource`
--

LOCK TABLES `litmus_email_resource` WRITE;
/*!40000 ALTER TABLE `litmus_email_resource` DISABLE KEYS */;
/*!40000 ALTER TABLE `litmus_email_resource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `litmus_test`
--

DROP TABLE IF EXISTS `litmus_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `litmus_test` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `litmus_test_set_id` int(11) NOT NULL,
  `litmus_fid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) NOT NULL DEFAULT '1',
  `status` int(11) NOT NULL DEFAULT '0',
  `litmus_state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_spam_test` int(11) NOT NULL DEFAULT '0',
  `litmus_found_in_spam` int(11) DEFAULT NULL,
  `litmus_spam_score` float DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `litmus_test_FI_1` (`account_id`),
  KEY `litmus_test_FI_2` (`litmus_test_set_id`),
  CONSTRAINT `litmus_test_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `litmus_test_FK_2` FOREIGN KEY (`litmus_test_set_id`) REFERENCES `litmus_test_set` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `litmus_test`
--

LOCK TABLES `litmus_test` WRITE;
/*!40000 ALTER TABLE `litmus_test` DISABLE KEYS */;
/*!40000 ALTER TABLE `litmus_test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `litmus_test_result_image`
--

DROP TABLE IF EXISTS `litmus_test_result_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `litmus_test_result_image` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `litmus_test_id` int(11) NOT NULL,
  `litmus_image_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `litmus_full_image_url` text COLLATE utf8_unicode_ci NOT NULL,
  `litmus_thumbnail_image_url` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `litmus_test_result_image_FI_1` (`account_id`),
  KEY `litmus_test_result_image_FI_2` (`litmus_test_id`),
  CONSTRAINT `litmus_test_result_image_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `litmus_test_result_image_FK_2` FOREIGN KEY (`litmus_test_id`) REFERENCES `litmus_test` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `litmus_test_result_image`
--

LOCK TABLES `litmus_test_result_image` WRITE;
/*!40000 ALTER TABLE `litmus_test_result_image` DISABLE KEYS */;
/*!40000 ALTER TABLE `litmus_test_result_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `litmus_test_result_spam_header`
--

DROP TABLE IF EXISTS `litmus_test_result_spam_header`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `litmus_test_result_spam_header` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `litmus_test_id` int(11) NOT NULL,
  `litmus_description` text COLLATE utf8_unicode_ci NOT NULL,
  `litmus_rating` float NOT NULL,
  `litmus_key` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `litmus_test_result_spam_header_FI_1` (`account_id`),
  KEY `litmus_test_result_spam_header_FI_2` (`litmus_test_id`),
  CONSTRAINT `litmus_test_result_spam_header_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `litmus_test_result_spam_header_FK_2` FOREIGN KEY (`litmus_test_id`) REFERENCES `litmus_test` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `litmus_test_result_spam_header`
--

LOCK TABLES `litmus_test_result_spam_header` WRITE;
/*!40000 ALTER TABLE `litmus_test_result_spam_header` DISABLE KEYS */;
/*!40000 ALTER TABLE `litmus_test_result_spam_header` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `litmus_test_set`
--

DROP TABLE IF EXISTS `litmus_test_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `litmus_test_set` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `parent_type` int(11) NOT NULL DEFAULT '1',
  `parent_id` int(11) NOT NULL,
  `type` int(11) NOT NULL DEFAULT '1',
  `litmus_resource_id` int(11) NOT NULL,
  `litmus_fid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  `litmus_state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `litmus_inbox_guid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `litmus_created_at` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `litmus_updated_at` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_synced_at` datetime DEFAULT NULL,
  `retry_started_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) NOT NULL,
  `created_by_email` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by_name` varchar(65) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `litmus_test_set_litmus_fid_unique` (`litmus_fid`),
  UNIQUE KEY `litmus_test_set_litmus_inbox_guid_unique` (`litmus_inbox_guid`),
  KEY `litmus_test_set_FI_1` (`account_id`),
  KEY `litmus_test_set_FI_2` (`created_by`),
  CONSTRAINT `litmus_test_set_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `litmus_test_set_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `litmus_test_set`
--

LOCK TABLES `litmus_test_set` WRITE;
/*!40000 ALTER TABLE `litmus_test_set` DISABLE KEYS */;
/*!40000 ALTER TABLE `litmus_test_set` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lmo_user_license_request`
--

DROP TABLE IF EXISTS `lmo_user_license_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lmo_user_license_request` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `background_queue_id` int(11) DEFAULT NULL,
  `license_type` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `error_message` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `quantity` int(11) NOT NULL,
  `developer_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `revision` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `tenant_org_id` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `license_definition_key` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `aggregation_group` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_lr_type_date` (`account_id`,`license_type`,`created_at`),
  KEY `lmo_user_license_request_FI_2` (`background_queue_id`),
  CONSTRAINT `lmo_user_license_request_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `lmo_user_license_request_FK_2` FOREIGN KEY (`background_queue_id`) REFERENCES `background_queue` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lmo_user_license_request`
--

LOCK TABLES `lmo_user_license_request` WRITE;
/*!40000 ALTER TABLE `lmo_user_license_request` DISABLE KEYS */;
/*!40000 ALTER TABLE `lmo_user_license_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mailable_stats`
--

DROP TABLE IF EXISTS `mailable_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mailable_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `mailable` int(11) DEFAULT '0',
  `unmailable` int(11) DEFAULT '0',
  `total_mailable` int(11) DEFAULT '0',
  `total_unmailable` int(11) DEFAULT '0',
  `stats_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mailable_stats_lookup` (`account_id`,`stats_date`),
  CONSTRAINT `mailable_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mailable_stats`
--

LOCK TABLES `mailable_stats` WRITE;
/*!40000 ALTER TABLE `mailable_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `mailable_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marketing_action_sync_queue`
--

DROP TABLE IF EXISTS `marketing_action_sync_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marketing_action_sync_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `visitor_activity_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `marketing_action_fid` varchar(18) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sync_status` int(11) DEFAULT NULL,
  `synced_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `visitor_activity_id` (`account_id`,`visitor_activity_id`),
  KEY `sync_status_ix` (`account_id`,`sync_status`),
  KEY `prospect_id_ix` (`account_id`,`prospect_id`,`visitor_activity_id`),
  KEY `marketing_action_sync_queue_FI_2` (`visitor_activity_id`),
  KEY `marketing_action_sync_queue_FI_3` (`prospect_id`),
  CONSTRAINT `marketing_action_sync_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `marketing_action_sync_queue_FK_2` FOREIGN KEY (`visitor_activity_id`) REFERENCES `visitor_activity` (`id`),
  CONSTRAINT `marketing_action_sync_queue_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marketing_action_sync_queue`
--

LOCK TABLES `marketing_action_sync_queue` WRITE;
/*!40000 ALTER TABLE `marketing_action_sync_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `marketing_action_sync_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marketing_resource_sync_queue`
--

DROP TABLE IF EXISTS `marketing_resource_sync_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marketing_resource_sync_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `object_id` int(11) DEFAULT '0',
  `object_type` int(11) DEFAULT '0',
  `marketing_resource_fid` varchar(18) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sync_status` int(11) DEFAULT NULL,
  `synced_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pardot_object_id_id` (`account_id`,`object_type`,`object_id`),
  KEY `sync_status_ix` (`account_id`,`sync_status`),
  CONSTRAINT `marketing_resource_sync_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marketing_resource_sync_queue`
--

LOCK TABLES `marketing_resource_sync_queue` WRITE;
/*!40000 ALTER TABLE `marketing_resource_sync_queue` DISABLE KEYS */;
INSERT INTO `marketing_resource_sync_queue` VALUES (1,2,1,4,NULL,20,NULL,'2016-03-24 16:07:14');
/*!40000 ALTER TABLE `marketing_resource_sync_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mc_email`
--

DROP TABLE IF EXISTS `mc_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mc_email` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `micro_campaign_id` int(11) NOT NULL,
  `email_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `fid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_fid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` int(11) DEFAULT '1',
  `is_being_processed` tinyint(4) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_mc_email_archived` (`account_id`,`micro_campaign_id`,`status`,`is_archived`,`is_being_processed`),
  KEY `ix_mc_email_account_dupe` (`account_id`,`created_by`,`fid`,`created_at`),
  KEY `ix_mc_email_account_mc_user` (`account_id`,`micro_campaign_id`,`created_by`),
  KEY `account_user_id_prospect_id` (`account_id`,`email_id`,`micro_campaign_id`,`prospect_id`),
  KEY `mc_email_account_original_fid` (`account_id`,`original_fid`),
  KEY `mc_email_FI_2` (`micro_campaign_id`),
  KEY `mc_email_FI_3` (`email_id`),
  KEY `mc_email_FI_4` (`prospect_id`),
  KEY `mc_email_FI_5` (`created_by`),
  KEY `mc_email_FI_6` (`updated_by`),
  CONSTRAINT `mc_email_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `mc_email_FK_2` FOREIGN KEY (`micro_campaign_id`) REFERENCES `micro_campaign` (`id`),
  CONSTRAINT `mc_email_FK_3` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `mc_email_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `mc_email_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `mc_email_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mc_email`
--

LOCK TABLES `mc_email` WRITE;
/*!40000 ALTER TABLE `mc_email` DISABLE KEYS */;
/*!40000 ALTER TABLE `mc_email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting`
--

DROP TABLE IF EXISTS `meeting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meeting` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `fid` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `duration_minutes` int(11) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `host` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `timezone` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `host_email` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `host_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `meeting_type` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `needs_registration` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `meeting_FI_1` (`account_id`),
  KEY `meeting_FI_2` (`connector_id`),
  CONSTRAINT `meeting_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `meeting_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting`
--

LOCK TABLES `meeting` WRITE;
/*!40000 ALTER TABLE `meeting` DISABLE KEYS */;
/*!40000 ALTER TABLE `meeting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_attendee`
--

DROP TABLE IF EXISTS `meeting_attendee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meeting_attendee` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `meeting_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `fid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attendance_status` int(11) NOT NULL DEFAULT '0',
  `registration_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `meeting_attendee_FI_1` (`account_id`),
  KEY `meeting_attendee_FI_2` (`meeting_id`),
  KEY `meeting_attendee_FI_3` (`prospect_id`),
  CONSTRAINT `meeting_attendee_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `meeting_attendee_FK_2` FOREIGN KEY (`meeting_id`) REFERENCES `meeting` (`id`),
  CONSTRAINT `meeting_attendee_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_attendee`
--

LOCK TABLES `meeting_attendee` WRITE;
/*!40000 ALTER TABLE `meeting_attendee` DISABLE KEYS */;
/*!40000 ALTER TABLE `meeting_attendee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merged_prospect`
--

DROP TABLE IF EXISTS `merged_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `merged_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `email` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `merge_into_prospect_id` int(11) DEFAULT NULL,
  `crm_lead_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_owner_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_contact_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `merged_prospect_FI_1` (`account_id`),
  KEY `merged_prospect_FI_2` (`updated_by`),
  CONSTRAINT `merged_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `merged_prospect_FK_2` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merged_prospect`
--

LOCK TABLES `merged_prospect` WRITE;
/*!40000 ALTER TABLE `merged_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `merged_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `micro_campaign`
--

DROP TABLE IF EXISTS `micro_campaign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `micro_campaign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email_message_id` int(11) NOT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `failure_email_id` int(11) DEFAULT NULL,
  `sobject_type` varchar(7) COLLATE utf8_unicode_ci NOT NULL,
  `status` int(11) DEFAULT '1',
  `is_one_to_one` tinyint(4) NOT NULL DEFAULT '0',
  `is_being_processed` tinyint(4) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `mc_type` tinyint(4) DEFAULT '0',
  `created_by` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_get_new_ids` (`account_id`,`status`,`is_archived`,`is_being_processed`,`id`),
  KEY `ix_micro_campaign_account_user` (`account_id`,`created_by`),
  KEY `ix_report` (`account_id`,`created_by`,`email_template_id`),
  KEY `ix_report_mc_type` (`account_id`,`email_template_id`,`created_by`,`mc_type`),
  KEY `account_user_created_at_template_id` (`account_id`,`created_by`,`created_at`,`email_template_id`),
  KEY `micro_campaign_FI_2` (`email_message_id`),
  KEY `micro_campaign_FI_3` (`email_template_id`),
  KEY `micro_campaign_FI_4` (`created_by`),
  KEY `micro_campaign_FI_5` (`updated_by`),
  CONSTRAINT `micro_campaign_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `micro_campaign_FK_2` FOREIGN KEY (`email_message_id`) REFERENCES `email_message` (`id`),
  CONSTRAINT `micro_campaign_FK_3` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`),
  CONSTRAINT `micro_campaign_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `micro_campaign_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `micro_campaign`
--

LOCK TABLES `micro_campaign` WRITE;
/*!40000 ALTER TABLE `micro_campaign` DISABLE KEYS */;
/*!40000 ALTER TABLE `micro_campaign` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `micro_campaign_hourly_summary`
--

DROP TABLE IF EXISTS `micro_campaign_hourly_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `micro_campaign_hourly_summary` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `micro_campaign_id` int(11) DEFAULT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `report_date` date NOT NULL,
  `report_hour` tinyint(4) NOT NULL,
  `sent` int(11) DEFAULT '0',
  `open` int(11) DEFAULT '0',
  `clicks` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_account_user_date_hour` (`account_id`,`user_id`,`report_date`,`report_hour`),
  KEY `ix_account_user_mc_date_hour` (`account_id`,`user_id`,`micro_campaign_id`,`report_date`,`report_hour`),
  KEY `ix_account_user_et_date_hour` (`account_id`,`user_id`,`email_template_id`,`report_date`,`report_hour`),
  KEY `ix_account_created_at` (`account_id`,`created_at`),
  KEY `micro_campaign_hourly_summary_FI_2` (`user_id`),
  KEY `micro_campaign_hourly_summary_FI_3` (`micro_campaign_id`),
  KEY `micro_campaign_hourly_summary_FI_4` (`email_template_id`),
  CONSTRAINT `micro_campaign_hourly_summary_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `micro_campaign_hourly_summary_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `micro_campaign_hourly_summary_FK_3` FOREIGN KEY (`micro_campaign_id`) REFERENCES `micro_campaign` (`id`),
  CONSTRAINT `micro_campaign_hourly_summary_FK_4` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `micro_campaign_hourly_summary`
--

LOCK TABLES `micro_campaign_hourly_summary` WRITE;
/*!40000 ALTER TABLE `micro_campaign_hourly_summary` DISABLE KEYS */;
/*!40000 ALTER TABLE `micro_campaign_hourly_summary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `multivariate_test`
--

DROP TABLE IF EXISTS `multivariate_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `multivariate_test` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `multivariate_test_period_id` int(11) DEFAULT NULL,
  `vanity_url_id` int(11) DEFAULT NULL,
  `bitly_url_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `multivariate_test_FI_1` (`account_id`),
  KEY `multivariate_test_FI_2` (`campaign_id`),
  KEY `multivariate_test_FI_3` (`multivariate_test_period_id`),
  KEY `multivariate_test_FI_4` (`vanity_url_id`),
  KEY `multivariate_test_FI_5` (`bitly_url_id`),
  KEY `multivariate_test_FI_6` (`created_by`),
  KEY `multivariate_test_FI_7` (`updated_by`),
  CONSTRAINT `multivariate_test_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `multivariate_test_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `multivariate_test_FK_3` FOREIGN KEY (`multivariate_test_period_id`) REFERENCES `multivariate_test_period` (`id`),
  CONSTRAINT `multivariate_test_FK_4` FOREIGN KEY (`vanity_url_id`) REFERENCES `vanity_url` (`id`),
  CONSTRAINT `multivariate_test_FK_5` FOREIGN KEY (`bitly_url_id`) REFERENCES `bitly_url` (`id`),
  CONSTRAINT `multivariate_test_FK_6` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `multivariate_test_FK_7` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `multivariate_test`
--

LOCK TABLES `multivariate_test` WRITE;
/*!40000 ALTER TABLE `multivariate_test` DISABLE KEYS */;
/*!40000 ALTER TABLE `multivariate_test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `multivariate_test_period`
--

DROP TABLE IF EXISTS `multivariate_test_period`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `multivariate_test_period` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `multivariate_test_id` int(11) DEFAULT NULL,
  `archived_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `multivariate_test_period_FI_1` (`account_id`),
  KEY `multivariate_test_period_FI_2` (`multivariate_test_id`),
  KEY `multivariate_test_period_FI_3` (`created_by`),
  CONSTRAINT `multivariate_test_period_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `multivariate_test_period_FK_2` FOREIGN KEY (`multivariate_test_id`) REFERENCES `multivariate_test` (`id`),
  CONSTRAINT `multivariate_test_period_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `multivariate_test_period`
--

LOCK TABLES `multivariate_test_period` WRITE;
/*!40000 ALTER TABLE `multivariate_test_period` DISABLE KEYS */;
/*!40000 ALTER TABLE `multivariate_test_period` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `multivariate_test_variation`
--

DROP TABLE IF EXISTS `multivariate_test_variation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `multivariate_test_variation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `multivariate_test_id` int(11) DEFAULT NULL,
  `multivariate_test_period_id` int(11) DEFAULT NULL,
  `landing_page_id` int(11) DEFAULT NULL,
  `traffic_percentage` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `multivariate_test_variation_FI_1` (`account_id`),
  KEY `multivariate_test_variation_FI_2` (`multivariate_test_id`),
  KEY `multivariate_test_variation_FI_3` (`multivariate_test_period_id`),
  KEY `multivariate_test_variation_FI_4` (`landing_page_id`),
  CONSTRAINT `multivariate_test_variation_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `multivariate_test_variation_FK_2` FOREIGN KEY (`multivariate_test_id`) REFERENCES `multivariate_test` (`id`),
  CONSTRAINT `multivariate_test_variation_FK_3` FOREIGN KEY (`multivariate_test_period_id`) REFERENCES `multivariate_test_period` (`id`),
  CONSTRAINT `multivariate_test_variation_FK_4` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `multivariate_test_variation`
--

LOCK TABLES `multivariate_test_variation` WRITE;
/*!40000 ALTER TABLE `multivariate_test_variation` DISABLE KEYS */;
/*!40000 ALTER TABLE `multivariate_test_variation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `natural_search_opportunity`
--

DROP TABLE IF EXISTS `natural_search_opportunity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `natural_search_opportunity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `opportunity_id` int(11) NOT NULL,
  `natural_search_query_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `value` int(11) DEFAULT '0',
  `revenue` int(11) DEFAULT '0',
  `vendor` int(11) NOT NULL,
  `is_won` int(11) NOT NULL,
  `is_closed` int(11) NOT NULL,
  `is_before_search` int(11) NOT NULL,
  `query_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_uniq` (`opportunity_id`,`natural_search_query_id`,`prospect_id`,`query_date`),
  KEY `natural_search_opportunity_FI_1` (`account_id`),
  KEY `natural_search_opportunity_FI_3` (`natural_search_query_id`),
  KEY `natural_search_opportunity_FI_4` (`prospect_id`),
  CONSTRAINT `natural_search_opportunity_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `natural_search_opportunity_FK_2` FOREIGN KEY (`opportunity_id`) REFERENCES `opportunity` (`id`),
  CONSTRAINT `natural_search_opportunity_FK_3` FOREIGN KEY (`natural_search_query_id`) REFERENCES `natural_search_query` (`id`),
  CONSTRAINT `natural_search_opportunity_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `natural_search_opportunity`
--

LOCK TABLES `natural_search_opportunity` WRITE;
/*!40000 ALTER TABLE `natural_search_opportunity` DISABLE KEYS */;
/*!40000 ALTER TABLE `natural_search_opportunity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `natural_search_prospect`
--

DROP TABLE IF EXISTS `natural_search_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `natural_search_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `natural_search_query_id` int(11) DEFAULT NULL,
  `vendor` int(11) NOT NULL,
  `query_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_uniq` (`prospect_id`,`natural_search_query_id`,`query_date`),
  KEY `natural_search_prospect_FI_1` (`account_id`),
  KEY `natural_search_prospect_FI_3` (`natural_search_query_id`),
  CONSTRAINT `natural_search_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `natural_search_prospect_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `natural_search_prospect_FK_3` FOREIGN KEY (`natural_search_query_id`) REFERENCES `natural_search_query` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `natural_search_prospect`
--

LOCK TABLES `natural_search_prospect` WRITE;
/*!40000 ALTER TABLE `natural_search_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `natural_search_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `natural_search_query`
--

DROP TABLE IF EXISTS `natural_search_query`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `natural_search_query` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `query` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nsq_unq` (`account_id`,`query`),
  CONSTRAINT `natural_search_query_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `natural_search_query`
--

LOCK TABLES `natural_search_query` WRITE;
/*!40000 ALTER TABLE `natural_search_query` DISABLE KEYS */;
/*!40000 ALTER TABLE `natural_search_query` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `natural_search_visitor`
--

DROP TABLE IF EXISTS `natural_search_visitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `natural_search_visitor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `natural_search_query_id` int(11) DEFAULT NULL,
  `query_date` datetime NOT NULL,
  `vendor` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_uniq` (`visitor_id`,`natural_search_query_id`,`query_date`),
  KEY `natural_search_visitor_FI_1` (`account_id`),
  KEY `natural_search_visitor_FI_3` (`natural_search_query_id`),
  CONSTRAINT `natural_search_visitor_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `natural_search_visitor_FK_2` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `natural_search_visitor_FK_3` FOREIGN KEY (`natural_search_query_id`) REFERENCES `natural_search_query` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `natural_search_visitor`
--

LOCK TABLES `natural_search_visitor` WRITE;
/*!40000 ALTER TABLE `natural_search_visitor` DISABLE KEYS */;
/*!40000 ALTER TABLE `natural_search_visitor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `natural_search_visitor_external_key`
--

DROP TABLE IF EXISTS `natural_search_visitor_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `natural_search_visitor_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_natural_search_visitor_id` FOREIGN KEY (`id`) REFERENCES `natural_search_visitor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `natural_search_visitor_external_key`
--

LOCK TABLES `natural_search_visitor_external_key` WRITE;
/*!40000 ALTER TABLE `natural_search_visitor_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `natural_search_visitor_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `new_prospect_cache`
--

DROP TABLE IF EXISTS `new_prospect_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `new_prospect_cache` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `new_prospect_cache_FI_1` (`account_id`),
  KEY `new_prospect_cache_FI_2` (`prospect_id`),
  CONSTRAINT `new_prospect_cache_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `new_prospect_cache_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `new_prospect_cache`
--

LOCK TABLES `new_prospect_cache` WRITE;
/*!40000 ALTER TABLE `new_prospect_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `new_prospect_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_audit`
--

DROP TABLE IF EXISTS `object_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `object_id` bigint(20) NOT NULL,
  `object_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(50) COLLATE utf8_unicode_ci DEFAULT 'object',
  `changes` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `object_audit_FI_1` (`account_id`),
  KEY `object_audit_FI_2` (`user_id`),
  CONSTRAINT `object_audit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `object_audit_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_audit`
--

LOCK TABLES `object_audit` WRITE;
/*!40000 ALTER TABLE `object_audit` DISABLE KEYS */;
INSERT INTO `object_audit` VALUES (1,2,NULL,2,'Account',NULL,'Undefined Context','object','{\"Company\":{\"f\":null,\"t\":\"Eastern Cloud Software\"},\"Type\":{\"f\":null,\"t\":5},\"Website\":{\"f\":null,\"t\":\"http:\\/\\/www.ecsoftware.com\\/\"},\"TrackerDomain\":{\"f\":null,\"t\":\"http:\\/\\/go.pardot.com\"},\"Country\":{\"f\":null,\"t\":\"United States\"},\"AddressOne\":{\"f\":null,\"t\":\"1564 River Street\"},\"AddressTwo\":{\"f\":null,\"t\":\"Suite 3200\"},\"City\":{\"f\":null,\"t\":\"Stevenson\"},\"State\":{\"f\":null,\"t\":\"Alabama\"},\"Zip\":{\"f\":null,\"t\":\"30426\"},\"Expiration\":{\"f\":null,\"t\":1594958400},\"MaxUsers\":{\"f\":5,\"t\":10},\"Timezone\":{\"f\":null,\"t\":\"America\\/New_York\"},\"Phone\":{\"f\":null,\"t\":\"555-555-5555\"},\"CreatedAt\":{\"f\":null,\"t\":1185720171},\"ShardId\":{\"f\":1,\"t\":2},\"Id\":{\"f\":null,\"t\":2}}','2016-03-24 16:07:13'),(2,2,NULL,1,'AccountLimit',NULL,'Undefined Context','object','{\"AccountId\":{\"f\":null,\"t\":2},\"MaxApiRequests\":{\"f\":null,\"t\":100000},\"MaxAutomations\":{\"f\":null,\"t\":2147483647},\"MaxBlocks\":{\"f\":null,\"t\":2147483647},\"MaxCustomObjects\":{\"f\":null,\"t\":4},\"MaxDripPrograms\":{\"f\":null,\"t\":2147483647},\"MaxDbSize\":{\"f\":null,\"t\":2147483647},\"MaxEmails\":{\"f\":null,\"t\":500000},\"MaxFileStorageSize\":{\"f\":null,\"t\":5120},\"MaxFilters\":{\"f\":null,\"t\":2147483647},\"MaxForms\":{\"f\":null,\"t\":2147483647},\"MaxFormHandlers\":{\"f\":null,\"t\":2147483647},\"MaxKeywords\":{\"f\":null,\"t\":1000},\"MaxLandingPages\":{\"f\":null,\"t\":2147483647},\"MaxLists\":{\"f\":null,\"t\":2147483647},\"MaxPageActions\":{\"f\":null,\"t\":25},\"MaxPersonalizations\":{\"f\":null,\"t\":2147483647},\"MaxProfiles\":{\"f\":null,\"t\":2147483647},\"MaxProspectFieldCustoms\":{\"f\":null,\"t\":2147483647},\"MaxSiteSearchUrls\":{\"f\":null,\"t\":2000},\"MaxUsers\":{\"f\":null,\"t\":2147483647},\"HasLitmusAccess\":{\"f\":false,\"t\":true},\"HasPhoneAccess\":{\"f\":false,\"t\":true},\"HasSocialAccess\":{\"f\":false,\"t\":true},\"HasChatSupportAccess\":{\"f\":false,\"t\":true},\"HasVanityUrlAccess\":{\"f\":false,\"t\":true},\"HasSocialData\":{\"f\":false,\"t\":true},\"HasPaidSearch\":{\"f\":false,\"t\":true},\"HasDynamicContent\":{\"f\":false,\"t\":true},\"HasMultivariateTests\":{\"f\":false,\"t\":true},\"HasCustomRoles\":{\"f\":false,\"t\":true},\"HasBlocks\":{\"f\":false,\"t\":true},\"HasMarketingCalendar\":{\"f\":false,\"t\":true},\"HasEmailBlocked\":{\"f\":false,\"t\":0},\"HasEmailAbTesting\":{\"f\":false,\"t\":true},\"MaxDynamicLists\":{\"f\":null,\"t\":9999},\"MaxTestLists\":{\"f\":null,\"t\":2147483647},\"MaxTestListMembers\":{\"f\":null,\"t\":100},\"MaxCompetitors\":{\"f\":null,\"t\":100},\"ConcurrentApiRequests\":{\"f\":null,\"t\":5},\"HasEmailOpensAdjustScoreOnce\":{\"f\":false,\"t\":true},\"HasPermanentBcc\":{\"f\":false,\"t\":false},\"HasNonmarketingEmail\":{\"f\":false,\"t\":false},\"MaxImportFilesizeMb\":{\"f\":100,\"t\":100},\"Id\":{\"f\":null,\"t\":1}}','2016-03-24 16:07:14'),(3,2,NULL,1,'AccountExtras',NULL,'Undefined Context','object','{\"AccountId\":{\"f\":null,\"t\":2},\"DripBucketId\":{\"f\":1,\"t\":1},\"CrmBucketId\":{\"f\":1,\"t\":1},\"CreatedAt\":{\"f\":null,\"t\":1458850034},\"Id\":{\"f\":null,\"t\":1}}','2016-03-24 16:07:14'),(4,2,NULL,1,'Connector',NULL,'Undefined Context','object','{\"ConnectorCategoryId\":{\"f\":null,\"t\":5},\"ConnectorVendorId\":{\"f\":null,\"t\":12},\"AccountId\":{\"f\":null,\"t\":2},\"IsVerified\":{\"f\":false,\"t\":true},\"Name\":{\"f\":null,\"t\":\"LinkedIn\"},\"CreatedAt\":{\"f\":null,\"t\":1458850034},\"Id\":{\"f\":null,\"t\":1}}','2016-03-24 16:07:14'),(5,2,NULL,2,'Connector',NULL,'Undefined Context','object','{\"ConnectorCategoryId\":{\"f\":null,\"t\":5},\"ConnectorVendorId\":{\"f\":null,\"t\":14},\"AccountId\":{\"f\":null,\"t\":2},\"IsVerified\":{\"f\":false,\"t\":true},\"Name\":{\"f\":null,\"t\":\"Data.com\"},\"CreatedAt\":{\"f\":null,\"t\":1458850034},\"Id\":{\"f\":null,\"t\":2}}','2016-03-24 16:07:14'),(6,2,NULL,2,'Account',NULL,'Undefined Context','object','{\"PluginCampaignId\":{\"f\":null,\"t\":2},\"EncryptionKey\":{\"f\":null,\"t\":\"a26d949fa140f486140bd76c7c2b2075\"},\"NewEncryptionKey\":{\"f\":null,\"t\":\"$1:obNEVAXo\\/pdIs\\/FltcN4g5pFuMqJ2\\/wtFmYLswsU0O8=:5Uvvpw792R4Izr7\\/8mHGdovnZOLUBkkyThg9Y4v5tuA=\"}}','2016-03-24 16:07:14'),(7,2,NULL,9,'User',NULL,'Undefined Context','object','{\"AccountId\":{\"f\":null,\"t\":2},\"Username\":{\"f\":null,\"t\":\"marketing@ecsoftware.com\"},\"Email\":{\"f\":null,\"t\":\"marketing@ecsoftware.com\"},\"PasswordExpiresAt\":{\"f\":null,\"t\":1347206400},\"IsActive\":{\"f\":false,\"t\":1},\"EncryptedPasswordAnswer\":{\"f\":null,\"t\":\"$1:uxXH+MhnHS2X6zm+foJ7LI2Q7eBO8GICpcFmwJi9g\\/Q=:SlRWxv3NOasIuelwlncqNN8a02L+Nd35yhm8I7aRaEE=\"},\"Role\":{\"f\":null,\"t\":2},\"FirstName\":{\"f\":null,\"t\":\"ecs Marketing\"},\"LastName\":{\"f\":null,\"t\":\"Manager\"},\"CrmUsername\":{\"f\":null,\"t\":\"eval@prospect_insight.demo\"},\"IsCrmUsernameVerified\":{\"f\":false,\"t\":1},\"Timezone\":{\"f\":null,\"t\":\"America\\/New_York\"},\"IsBillingContact\":{\"f\":false,\"t\":1},\"CreatedAt\":{\"f\":null,\"t\":1185720171},\"Id\":{\"f\":null,\"t\":9}}','2016-03-24 16:07:15'),(8,2,NULL,10,'User',NULL,'Undefined Context','object','{\"AccountId\":{\"f\":null,\"t\":2},\"Username\":{\"f\":null,\"t\":\"coordinator@ecsoftware.com\"},\"Email\":{\"f\":null,\"t\":\"coordinator@ecsoftware.com\"},\"PasswordExpiresAt\":{\"f\":null,\"t\":1347206400},\"IsActive\":{\"f\":false,\"t\":1},\"EncryptedPasswordAnswer\":{\"f\":null,\"t\":\"$1:K0EAVWRrGHFlqj+v8cYRe8JnCoeXb2hkOknIt7fS9+M=:zMog6vb3si9Zu\\/omzO84rjoR54xocvtyexiN1H7MWXU=\"},\"Role\":{\"f\":null,\"t\":3},\"FirstName\":{\"f\":null,\"t\":\"Marketing\"},\"LastName\":{\"f\":null,\"t\":\"Coordinator\"},\"CrmUsername\":{\"f\":null,\"t\":\"marketing.coordinator\"},\"Timezone\":{\"f\":null,\"t\":\"America\\/Los_Angeles\"},\"CreatedAt\":{\"f\":null,\"t\":1185720171},\"Id\":{\"f\":null,\"t\":10}}','2016-03-24 16:07:15'),(9,2,NULL,11,'User',NULL,'Undefined Context','object','{\"AccountId\":{\"f\":null,\"t\":2},\"Username\":{\"f\":null,\"t\":\"sales@ecsoftware.com\"},\"Email\":{\"f\":null,\"t\":\"sales@ecsoftware.com\"},\"PasswordExpiresAt\":{\"f\":null,\"t\":1347206400},\"IsActive\":{\"f\":false,\"t\":1},\"EncryptedPasswordAnswer\":{\"f\":null,\"t\":\"$1:Yypt9pVzMRL65H6rKJjoA1IOwoABJJzhQW012bQCUx8=:VevK9R6OOrwqAJKI1LH5rx\\/R0rlgnOfCJJEJ1xkACQw=\"},\"Role\":{\"f\":null,\"t\":4},\"FirstName\":{\"f\":null,\"t\":\"ECS Sales\"},\"LastName\":{\"f\":null,\"t\":\"Rep A\"},\"CrmUsername\":{\"f\":null,\"t\":\"sales.rep\"},\"Timezone\":{\"f\":null,\"t\":\"America\\/Chicago\"},\"CreatedAt\":{\"f\":null,\"t\":1185720171},\"Id\":{\"f\":null,\"t\":11}}','2016-03-24 16:07:15');
/*!40000 ALTER TABLE `object_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `opportunity`
--

DROP TABLE IF EXISTS `opportunity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opportunity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `crm_opportunity_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_opportunity_updated_at` datetime DEFAULT NULL,
  `visitor_referrer_id` int(11) DEFAULT NULL,
  `value` float DEFAULT NULL,
  `probability` float DEFAULT NULL,
  `stage` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL,
  `days_to_create` int(11) DEFAULT NULL,
  `days_to_close` int(11) DEFAULT NULL,
  `is_closed` int(11) DEFAULT '0',
  `is_won` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `updated_by` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nsq_unq` (`crm_opportunity_fid`,`account_id`),
  KEY `opportunity_FI_1` (`account_id`),
  KEY `opportunity_FI_2` (`campaign_id`),
  KEY `opportunity_FI_3` (`visitor_referrer_id`),
  KEY `opportunity_FI_4` (`updated_by`),
  KEY `opportunity_FI_5` (`created_by`),
  CONSTRAINT `opportunity_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `opportunity_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `opportunity_FK_3` FOREIGN KEY (`visitor_referrer_id`) REFERENCES `visitor_referrer` (`id`),
  CONSTRAINT `opportunity_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `opportunity_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `opportunity`
--

LOCK TABLES `opportunity` WRITE;
/*!40000 ALTER TABLE `opportunity` DISABLE KEYS */;
/*!40000 ALTER TABLE `opportunity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `opportunity_audit`
--

DROP TABLE IF EXISTS `opportunity_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opportunity_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `opportunity_id` int(11) NOT NULL,
  `crm_opportunity_history_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `old_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `new_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `opportunity_audit_FI_1` (`account_id`),
  KEY `opportunity_audit_FI_2` (`opportunity_id`),
  KEY `opportunity_audit_FI_3` (`created_by`),
  CONSTRAINT `opportunity_audit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `opportunity_audit_FK_2` FOREIGN KEY (`opportunity_id`) REFERENCES `opportunity` (`id`),
  CONSTRAINT `opportunity_audit_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `opportunity_audit`
--

LOCK TABLES `opportunity_audit` WRITE;
/*!40000 ALTER TABLE `opportunity_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `opportunity_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `opportunity_influence`
--

DROP TABLE IF EXISTS `opportunity_influence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opportunity_influence` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_touch_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `opportunity_id` int(11) NOT NULL,
  `opportunity_created_at` datetime NOT NULL,
  `opportunity_closed_at` datetime DEFAULT NULL,
  `opportunity_influence_to_creation` int(11) DEFAULT NULL,
  `opportunity_influence_to_closed` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `opp_inf_unq` (`account_id`,`campaign_touch_id`,`opportunity_id`),
  KEY `ix_camp_to_creation` (`account_id`,`campaign_id`,`opportunity_influence_to_creation`),
  KEY `ix_camp_to_closed` (`account_id`,`campaign_id`,`opportunity_influence_to_closed`),
  KEY `ix_opp_to_creation` (`account_id`,`opportunity_id`,`opportunity_influence_to_creation`),
  KEY `ix_opp_to_closed` (`account_id`,`opportunity_id`,`opportunity_influence_to_closed`),
  KEY `ix_opp_created_to_creation` (`account_id`,`opportunity_influence_to_creation`,`opportunity_created_at`,`campaign_id`),
  KEY `opportunity_influence_FI_2` (`campaign_touch_id`),
  KEY `opportunity_influence_FI_3` (`campaign_id`),
  KEY `opportunity_influence_FI_4` (`prospect_id`),
  KEY `opportunity_influence_FI_5` (`opportunity_id`),
  CONSTRAINT `opportunity_influence_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `opportunity_influence_FK_2` FOREIGN KEY (`campaign_touch_id`) REFERENCES `campaign_touch` (`id`),
  CONSTRAINT `opportunity_influence_FK_3` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `opportunity_influence_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `opportunity_influence_FK_5` FOREIGN KEY (`opportunity_id`) REFERENCES `opportunity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `opportunity_influence`
--

LOCK TABLES `opportunity_influence` WRITE;
/*!40000 ALTER TABLE `opportunity_influence` DISABLE KEYS */;
/*!40000 ALTER TABLE `opportunity_influence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `opportunity_prospect`
--

DROP TABLE IF EXISTS `opportunity_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opportunity_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `opportunity_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_opp_pros_uniq` (`opportunity_id`,`prospect_id`),
  KEY `opportunity_prospect_FI_1` (`account_id`),
  KEY `opportunity_prospect_FI_3` (`prospect_id`),
  CONSTRAINT `opportunity_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `opportunity_prospect_FK_2` FOREIGN KEY (`opportunity_id`) REFERENCES `opportunity` (`id`),
  CONSTRAINT `opportunity_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `opportunity_prospect`
--

LOCK TABLES `opportunity_prospect` WRITE;
/*!40000 ALTER TABLE `opportunity_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `opportunity_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_action`
--

DROP TABLE IF EXISTS `page_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `url_pattern` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `score_change` int(11) NOT NULL DEFAULT '1',
  `scoring_category_id` int(11) DEFAULT NULL,
  `is_priority` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `page_action_FI_1` (`account_id`),
  KEY `page_action_FI_2` (`scoring_category_id`),
  KEY `page_action_FI_3` (`created_by`),
  KEY `page_action_FI_4` (`updated_by`),
  CONSTRAINT `page_action_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `page_action_FK_2` FOREIGN KEY (`scoring_category_id`) REFERENCES `scoring_category` (`id`),
  CONSTRAINT `page_action_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `page_action_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_action`
--

LOCK TABLES `page_action` WRITE;
/*!40000 ALTER TABLE `page_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_action_visitor`
--

DROP TABLE IF EXISTS `page_action_visitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_action_visitor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `page_action_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `visitor_id` int(11) NOT NULL,
  `visitor_page_view_id` int(11) NOT NULL,
  `is_filtered` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_account_created` (`account_id`,`created_at`),
  KEY `page_action_visitor_FI_2` (`page_action_id`),
  KEY `page_action_visitor_FI_3` (`prospect_id`),
  KEY `page_action_visitor_FI_4` (`visitor_id`),
  KEY `page_action_visitor_FI_5` (`visitor_page_view_id`),
  CONSTRAINT `page_action_visitor_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `page_action_visitor_FK_2` FOREIGN KEY (`page_action_id`) REFERENCES `page_action` (`id`),
  CONSTRAINT `page_action_visitor_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `page_action_visitor_FK_4` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `page_action_visitor_FK_5` FOREIGN KEY (`visitor_page_view_id`) REFERENCES `visitor_page_view` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_action_visitor`
--

LOCK TABLES `page_action_visitor` WRITE;
/*!40000 ALTER TABLE `page_action_visitor` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_action_visitor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `page_action_visitor_external_key`
--

DROP TABLE IF EXISTS `page_action_visitor_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_action_visitor_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_page_action_visitor_id` FOREIGN KEY (`id`) REFERENCES `page_action_visitor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_action_visitor_external_key`
--

LOCK TABLES `page_action_visitor_external_key` WRITE;
/*!40000 ALTER TABLE `page_action_visitor_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `page_action_visitor_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_ad`
--

DROP TABLE IF EXISTS `paid_search_ad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_ad` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `connector_id` int(11) DEFAULT NULL,
  `paid_search_ad_group_id` int(11) NOT NULL,
  `vendor_ad_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `headline` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description_line_one` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description_line_two` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `display_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `destination_url` text COLLATE utf8_unicode_ci,
  `status` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_paused` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `paid_search_ad_vendor_ad_fid_joint` (`paid_search_ad_group_id`,`vendor_ad_fid`),
  KEY `paid_search_ad_FI_1` (`account_id`),
  KEY `paid_search_ad_FI_2` (`campaign_id`),
  KEY `paid_search_ad_FI_3` (`connector_id`),
  KEY `paid_search_ad_FI_5` (`created_by`),
  KEY `paid_search_ad_FI_6` (`updated_by`),
  CONSTRAINT `paid_search_ad_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_ad_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `paid_search_ad_FK_3` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `paid_search_ad_FK_4` FOREIGN KEY (`paid_search_ad_group_id`) REFERENCES `paid_search_ad_group` (`id`),
  CONSTRAINT `paid_search_ad_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `paid_search_ad_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_ad`
--

LOCK TABLES `paid_search_ad` WRITE;
/*!40000 ALTER TABLE `paid_search_ad` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_ad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_ad_click`
--

DROP TABLE IF EXISTS `paid_search_ad_click`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_ad_click` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `paid_search_ad_id` int(11) NOT NULL,
  `visitor_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `keyword` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `match_type` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `network` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `device` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `clicked_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_lookup` (`account_id`,`keyword`,`prospect_id`),
  KEY `keyword_lookup` (`account_id`,`keyword`,`clicked_at`),
  KEY `paid_search_ad_click_FI_2` (`paid_search_ad_id`),
  KEY `paid_search_ad_click_FI_3` (`visitor_id`),
  KEY `paid_search_ad_click_FI_4` (`prospect_id`),
  CONSTRAINT `paid_search_ad_click_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_ad_click_FK_2` FOREIGN KEY (`paid_search_ad_id`) REFERENCES `paid_search_ad` (`id`),
  CONSTRAINT `paid_search_ad_click_FK_3` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `paid_search_ad_click_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_ad_click`
--

LOCK TABLES `paid_search_ad_click` WRITE;
/*!40000 ALTER TABLE `paid_search_ad_click` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_ad_click` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_ad_click_external_key`
--

DROP TABLE IF EXISTS `paid_search_ad_click_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_ad_click_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_paid_search_ad_click_id` FOREIGN KEY (`id`) REFERENCES `paid_search_ad_click` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_ad_click_external_key`
--

LOCK TABLES `paid_search_ad_click_external_key` WRITE;
/*!40000 ALTER TABLE `paid_search_ad_click_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_ad_click_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_ad_group`
--

DROP TABLE IF EXISTS `paid_search_ad_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_ad_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `connector_id` int(11) DEFAULT NULL,
  `paid_search_campaign_id` int(11) NOT NULL,
  `vendor_ad_group_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_paused` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `paid_search_ad_group_vendor_ad_group_fid_unique` (`vendor_ad_group_fid`),
  UNIQUE KEY `ix_account_id_ad_group_fid` (`account_id`,`vendor_ad_group_fid`),
  KEY `paid_search_ad_group_FI_2` (`campaign_id`),
  KEY `paid_search_ad_group_FI_3` (`connector_id`),
  KEY `paid_search_ad_group_FI_4` (`paid_search_campaign_id`),
  KEY `paid_search_ad_group_FI_5` (`created_by`),
  KEY `paid_search_ad_group_FI_6` (`updated_by`),
  CONSTRAINT `paid_search_ad_group_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_ad_group_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `paid_search_ad_group_FK_3` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `paid_search_ad_group_FK_4` FOREIGN KEY (`paid_search_campaign_id`) REFERENCES `paid_search_campaign` (`id`),
  CONSTRAINT `paid_search_ad_group_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `paid_search_ad_group_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_ad_group`
--

LOCK TABLES `paid_search_ad_group` WRITE;
/*!40000 ALTER TABLE `paid_search_ad_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_ad_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_ad_group_stats`
--

DROP TABLE IF EXISTS `paid_search_ad_group_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_ad_group_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `paid_search_ad_group_id` int(11) NOT NULL,
  `clicks` int(11) DEFAULT '0',
  `cost` float DEFAULT '0',
  `impressions` int(11) DEFAULT '0',
  `prospects` int(11) DEFAULT '0',
  `opportunities` int(11) DEFAULT '0',
  `opportunities_won` int(11) DEFAULT '0',
  `opportunities_revenue` float DEFAULT '0',
  `stats_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `psags_unq` (`account_id`,`paid_search_ad_group_id`,`stats_date`),
  KEY `paid_search_ad_group_stats_FI_2` (`paid_search_ad_group_id`),
  CONSTRAINT `paid_search_ad_group_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_ad_group_stats_FK_2` FOREIGN KEY (`paid_search_ad_group_id`) REFERENCES `paid_search_ad_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_ad_group_stats`
--

LOCK TABLES `paid_search_ad_group_stats` WRITE;
/*!40000 ALTER TABLE `paid_search_ad_group_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_ad_group_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_ad_report`
--

DROP TABLE IF EXISTS `paid_search_ad_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_ad_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `paid_search_ad_id` int(11) DEFAULT NULL,
  `average_position` float DEFAULT '0',
  `clicks` int(11) DEFAULT '0',
  `conversion_rate` float DEFAULT '0',
  `conversions` int(11) DEFAULT '0',
  `cost` float DEFAULT '0',
  `impressions` int(11) DEFAULT '0',
  `prospects` int(11) DEFAULT '0',
  `assigned_prospects` int(11) DEFAULT '0',
  `opportunities` int(11) DEFAULT '0',
  `opportunities_won` int(11) DEFAULT '0',
  `opportunity_value` int(11) DEFAULT '0',
  `revenue` int(11) DEFAULT '0',
  `stats_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `paid_search_ad_report_lookup` (`paid_search_ad_id`,`stats_date`,`account_id`),
  KEY `paid_search_ad_report_FI_1` (`account_id`),
  KEY `paid_search_ad_report_FI_2` (`campaign_id`),
  CONSTRAINT `paid_search_ad_report_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_ad_report_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `paid_search_ad_report_FK_3` FOREIGN KEY (`paid_search_ad_id`) REFERENCES `paid_search_ad` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_ad_report`
--

LOCK TABLES `paid_search_ad_report` WRITE;
/*!40000 ALTER TABLE `paid_search_ad_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_ad_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_ad_stats`
--

DROP TABLE IF EXISTS `paid_search_ad_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_ad_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `paid_search_ad_id` int(11) NOT NULL,
  `clicks` int(11) DEFAULT '0',
  `cost` float DEFAULT '0',
  `impressions` int(11) DEFAULT '0',
  `prospects` int(11) DEFAULT '0',
  `opportunities` int(11) DEFAULT '0',
  `opportunities_won` int(11) DEFAULT '0',
  `opportunities_revenue` float DEFAULT '0',
  `stats_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `psas_unq` (`account_id`,`paid_search_ad_id`,`stats_date`),
  KEY `paid_search_ad_stats_FI_2` (`paid_search_ad_id`),
  CONSTRAINT `paid_search_ad_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_ad_stats_FK_2` FOREIGN KEY (`paid_search_ad_id`) REFERENCES `paid_search_ad` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_ad_stats`
--

LOCK TABLES `paid_search_ad_stats` WRITE;
/*!40000 ALTER TABLE `paid_search_ad_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_ad_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_campaign`
--

DROP TABLE IF EXISTS `paid_search_campaign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_campaign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `connector_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vendor_campaign_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `daily_budget` float DEFAULT NULL,
  `is_synced` int(11) DEFAULT '0',
  `synced_at` datetime DEFAULT NULL,
  `is_paused` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `paid_search_campaign_vendor_campaign_fid_unique` (`vendor_campaign_fid`),
  UNIQUE KEY `ix_account_id_vendor_campaign_fid` (`account_id`,`vendor_campaign_fid`),
  KEY `ix_synced` (`account_id`,`is_archived`,`is_synced`,`synced_at`),
  KEY `paid_search_campaign_FI_2` (`campaign_id`),
  KEY `paid_search_campaign_FI_3` (`connector_id`),
  KEY `paid_search_campaign_FI_4` (`created_by`),
  KEY `paid_search_campaign_FI_5` (`updated_by`),
  CONSTRAINT `paid_search_campaign_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_campaign_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `paid_search_campaign_FK_3` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `paid_search_campaign_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `paid_search_campaign_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_campaign`
--

LOCK TABLES `paid_search_campaign` WRITE;
/*!40000 ALTER TABLE `paid_search_campaign` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_campaign` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_campaign_stats`
--

DROP TABLE IF EXISTS `paid_search_campaign_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_campaign_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `paid_search_campaign_id` int(11) NOT NULL,
  `clicks` int(11) DEFAULT '0',
  `cost` float DEFAULT '0',
  `impressions` int(11) DEFAULT '0',
  `prospects` int(11) DEFAULT '0',
  `opportunities` int(11) DEFAULT '0',
  `opportunities_won` int(11) DEFAULT '0',
  `opportunities_revenue` float DEFAULT '0',
  `stats_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pscs_unq` (`account_id`,`paid_search_campaign_id`,`stats_date`),
  KEY `paid_search_campaign_stats_FI_2` (`paid_search_campaign_id`),
  CONSTRAINT `paid_search_campaign_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_campaign_stats_FK_2` FOREIGN KEY (`paid_search_campaign_id`) REFERENCES `paid_search_campaign` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_campaign_stats`
--

LOCK TABLES `paid_search_campaign_stats` WRITE;
/*!40000 ALTER TABLE `paid_search_campaign_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_campaign_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_keyword`
--

DROP TABLE IF EXISTS `paid_search_keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_keyword` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `tracker_id` int(11) DEFAULT NULL,
  `connector_id` int(11) DEFAULT NULL,
  `paid_search_ad_group_id` int(11) DEFAULT NULL,
  `vendor_keyword_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `keyword` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `match_type` int(11) DEFAULT NULL,
  `search_bid` float DEFAULT NULL,
  `content_bid` float DEFAULT NULL,
  `default_search_bid` float DEFAULT NULL,
  `default_content_bid` float DEFAULT NULL,
  `is_paused` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `paid_search_keyword_FI_1` (`account_id`),
  KEY `paid_search_keyword_FI_2` (`campaign_id`),
  KEY `paid_search_keyword_FI_3` (`tracker_id`),
  KEY `paid_search_keyword_FI_4` (`connector_id`),
  KEY `paid_search_keyword_FI_5` (`paid_search_ad_group_id`),
  KEY `paid_search_keyword_FI_6` (`created_by`),
  KEY `paid_search_keyword_FI_7` (`updated_by`),
  CONSTRAINT `paid_search_keyword_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_keyword_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `paid_search_keyword_FK_3` FOREIGN KEY (`tracker_id`) REFERENCES `tracker` (`id`),
  CONSTRAINT `paid_search_keyword_FK_4` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `paid_search_keyword_FK_5` FOREIGN KEY (`paid_search_ad_group_id`) REFERENCES `paid_search_ad_group` (`id`),
  CONSTRAINT `paid_search_keyword_FK_6` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `paid_search_keyword_FK_7` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_keyword`
--

LOCK TABLES `paid_search_keyword` WRITE;
/*!40000 ALTER TABLE `paid_search_keyword` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_keyword` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_opportunity`
--

DROP TABLE IF EXISTS `paid_search_opportunity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_opportunity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `opportunity_id` int(11) NOT NULL,
  `paid_search_query_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `value` int(11) DEFAULT '0',
  `revenue` int(11) DEFAULT '0',
  `vendor` int(11) NOT NULL,
  `is_won` int(11) NOT NULL,
  `is_closed` int(11) NOT NULL,
  `is_before_search` int(11) NOT NULL,
  `query_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_uniq` (`opportunity_id`,`paid_search_query_id`,`prospect_id`,`query_date`),
  KEY `paid_search_opportunity_FI_1` (`account_id`),
  KEY `paid_search_opportunity_FI_3` (`paid_search_query_id`),
  KEY `paid_search_opportunity_FI_4` (`prospect_id`),
  CONSTRAINT `paid_search_opportunity_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_opportunity_FK_2` FOREIGN KEY (`opportunity_id`) REFERENCES `opportunity` (`id`),
  CONSTRAINT `paid_search_opportunity_FK_3` FOREIGN KEY (`paid_search_query_id`) REFERENCES `paid_search_query` (`id`),
  CONSTRAINT `paid_search_opportunity_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_opportunity`
--

LOCK TABLES `paid_search_opportunity` WRITE;
/*!40000 ALTER TABLE `paid_search_opportunity` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_opportunity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_prospect`
--

DROP TABLE IF EXISTS `paid_search_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `paid_search_query_id` int(11) DEFAULT NULL,
  `vendor` int(11) NOT NULL,
  `query_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_uniq` (`prospect_id`,`paid_search_query_id`,`query_date`),
  KEY `paid_search_prospect_FI_1` (`account_id`),
  KEY `paid_search_prospect_FI_3` (`paid_search_query_id`),
  CONSTRAINT `paid_search_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_prospect_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `paid_search_prospect_FK_3` FOREIGN KEY (`paid_search_query_id`) REFERENCES `paid_search_query` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_prospect`
--

LOCK TABLES `paid_search_prospect` WRITE;
/*!40000 ALTER TABLE `paid_search_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_query`
--

DROP TABLE IF EXISTS `paid_search_query`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_query` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `query` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nsq_unq` (`account_id`,`query`),
  CONSTRAINT `paid_search_query_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_query`
--

LOCK TABLES `paid_search_query` WRITE;
/*!40000 ALTER TABLE `paid_search_query` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_query` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_visitor`
--

DROP TABLE IF EXISTS `paid_search_visitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_visitor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `paid_search_query_id` int(11) DEFAULT NULL,
  `query_date` datetime NOT NULL,
  `vendor` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_uniq` (`visitor_id`,`paid_search_query_id`,`query_date`),
  KEY `paid_search_visitor_FI_1` (`account_id`),
  KEY `paid_search_visitor_FI_3` (`paid_search_query_id`),
  CONSTRAINT `paid_search_visitor_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `paid_search_visitor_FK_2` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `paid_search_visitor_FK_3` FOREIGN KEY (`paid_search_query_id`) REFERENCES `paid_search_query` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_visitor`
--

LOCK TABLES `paid_search_visitor` WRITE;
/*!40000 ALTER TABLE `paid_search_visitor` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_visitor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paid_search_visitor_external_key`
--

DROP TABLE IF EXISTS `paid_search_visitor_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paid_search_visitor_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_paid_search_visitor_id` FOREIGN KEY (`id`) REFERENCES `paid_search_visitor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paid_search_visitor_external_key`
--

LOCK TABLES `paid_search_visitor_external_key` WRITE;
/*!40000 ALTER TABLE `paid_search_visitor_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `paid_search_visitor_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_list_member_sync_queue`
--

DROP TABLE IF EXISTS `person_list_member_sync_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_list_member_sync_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `listx_prospect_id` int(11) DEFAULT NULL,
  `person_list_member_fid` varchar(18) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sync_status` int(11) DEFAULT NULL,
  `synced_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `listx_prospect_id` (`account_id`,`listx_prospect_id`),
  KEY `sync_status_ix` (`account_id`,`sync_status`),
  KEY `person_list_member_sync_queue_FI_2` (`listx_prospect_id`),
  CONSTRAINT `person_list_member_sync_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `person_list_member_sync_queue_FK_2` FOREIGN KEY (`listx_prospect_id`) REFERENCES `listx_prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_list_member_sync_queue`
--

LOCK TABLES `person_list_member_sync_queue` WRITE;
/*!40000 ALTER TABLE `person_list_member_sync_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_list_member_sync_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_list_sync_queue`
--

DROP TABLE IF EXISTS `person_list_sync_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_list_sync_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `person_list_fid` varchar(18) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sync_status` int(11) DEFAULT NULL,
  `synced_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `listx_id` (`account_id`,`listx_id`),
  KEY `sync_status_ix` (`account_id`,`sync_status`),
  KEY `person_list_sync_queue_FI_2` (`listx_id`),
  CONSTRAINT `person_list_sync_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `person_list_sync_queue_FK_2` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_list_sync_queue`
--

LOCK TABLES `person_list_sync_queue` WRITE;
/*!40000 ALTER TABLE `person_list_sync_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_list_sync_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personalization`
--

DROP TABLE IF EXISTS `personalization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personalization` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `block_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `personalization_FI_1` (`account_id`),
  KEY `personalization_FI_2` (`campaign_id`),
  KEY `personalization_FI_3` (`block_id`),
  KEY `personalization_FI_4` (`created_by`),
  KEY `personalization_FI_5` (`updated_by`),
  CONSTRAINT `personalization_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `personalization_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `personalization_FK_3` FOREIGN KEY (`block_id`) REFERENCES `block` (`id`),
  CONSTRAINT `personalization_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `personalization_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personalization`
--

LOCK TABLES `personalization` WRITE;
/*!40000 ALTER TABLE `personalization` DISABLE KEYS */;
/*!40000 ALTER TABLE `personalization` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personalization_profile`
--

DROP TABLE IF EXISTS `personalization_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personalization_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `personalization_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `block_id` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `form_handler_id` int(11) DEFAULT NULL,
  `landing_page_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `personalization_profile_FI_1` (`account_id`),
  KEY `personalization_profile_FI_2` (`personalization_id`),
  KEY `personalization_profile_FI_3` (`profile_id`),
  KEY `personalization_profile_FI_4` (`block_id`),
  KEY `personalization_profile_FI_5` (`form_id`),
  KEY `personalization_profile_FI_6` (`form_handler_id`),
  KEY `personalization_profile_FI_7` (`landing_page_id`),
  KEY `personalization_profile_FI_8` (`listx_id`),
  KEY `personalization_profile_FI_9` (`created_by`),
  KEY `personalization_profile_FI_10` (`updated_by`),
  CONSTRAINT `personalization_profile_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `personalization_profile_FK_10` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `personalization_profile_FK_2` FOREIGN KEY (`personalization_id`) REFERENCES `personalization` (`id`),
  CONSTRAINT `personalization_profile_FK_3` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`),
  CONSTRAINT `personalization_profile_FK_4` FOREIGN KEY (`block_id`) REFERENCES `block` (`id`),
  CONSTRAINT `personalization_profile_FK_5` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `personalization_profile_FK_6` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`),
  CONSTRAINT `personalization_profile_FK_7` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `personalization_profile_FK_8` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `personalization_profile_FK_9` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personalization_profile`
--

LOCK TABLES `personalization_profile` WRITE;
/*!40000 ALTER TABLE `personalization_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `personalization_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profile`
--

DROP TABLE IF EXISTS `profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_FI_1` (`account_id`),
  KEY `profile_FI_2` (`created_by`),
  KEY `profile_FI_3` (`updated_by`),
  CONSTRAINT `profile_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `profile_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `profile_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profile`
--

LOCK TABLES `profile` WRITE;
/*!40000 ALTER TABLE `profile` DISABLE KEYS */;
INSERT INTO `profile` VALUES (1,2,'Default',0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profile_criteria`
--

DROP TABLE IF EXISTS `profile_criteria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profile_criteria` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `grade_adjustment` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_criteria_FI_1` (`account_id`),
  KEY `profile_criteria_FI_2` (`profile_id`),
  KEY `profile_criteria_FI_3` (`created_by`),
  KEY `profile_criteria_FI_4` (`updated_by`),
  CONSTRAINT `profile_criteria_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `profile_criteria_FK_2` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`),
  CONSTRAINT `profile_criteria_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `profile_criteria_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profile_criteria`
--

LOCK TABLES `profile_criteria` WRITE;
/*!40000 ALTER TABLE `profile_criteria` DISABLE KEYS */;
INSERT INTO `profile_criteria` VALUES (1,2,1,'Company Size',2,0,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,1,'Industry',2,1,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,2,1,'Location',2,2,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(4,2,1,'Job Title',2,3,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(5,2,1,'Department',2,4,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `profile_criteria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profile_criteria_prospect`
--

DROP TABLE IF EXISTS `profile_criteria_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profile_criteria_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `profile_criteria_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `does_match` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_criteria_prospect_FI_1` (`account_id`),
  KEY `profile_criteria_prospect_FI_2` (`profile_criteria_id`),
  KEY `profile_criteria_prospect_FI_3` (`prospect_id`),
  KEY `profile_criteria_prospect_FI_4` (`created_by`),
  KEY `profile_criteria_prospect_FI_5` (`updated_by`),
  CONSTRAINT `profile_criteria_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `profile_criteria_prospect_FK_2` FOREIGN KEY (`profile_criteria_id`) REFERENCES `profile_criteria` (`id`),
  CONSTRAINT `profile_criteria_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `profile_criteria_prospect_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `profile_criteria_prospect_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profile_criteria_prospect`
--

LOCK TABLES `profile_criteria_prospect` WRITE;
/*!40000 ALTER TABLE `profile_criteria_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `profile_criteria_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect`
--

DROP TABLE IF EXISTS `prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `queue_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `prospect_account_id` int(11) DEFAULT NULL,
  `deduplication_key` char(44) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `salutation` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_name` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `job_title` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `department` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_one` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_two` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `territory` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fax` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `annual_revenue` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `employees` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `industry` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `years_in_business` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subscribe` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `unsubscribe` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `comments` text COLLATE utf8_unicode_ci,
  `score` int(11) DEFAULT '0',
  `grade` int(11) DEFAULT '3',
  `last_scored_at` datetime DEFAULT NULL,
  `last_scored_visitor_activity_id` int(11) DEFAULT NULL,
  `last_scored_visitor_page_view_id` int(11) DEFAULT NULL,
  `first_activity_at` datetime DEFAULT NULL,
  `last_activity_at` datetime DEFAULT NULL,
  `crm_lead_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_owner_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_account_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_contact_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_last_activity` datetime DEFAULT NULL,
  `is_crm_synced` tinyint(1) NOT NULL DEFAULT '0',
  `is_crm_synced_nightly` tinyint(1) NOT NULL DEFAULT '1',
  `is_do_not_email` tinyint(1) NOT NULL DEFAULT '0',
  `is_do_not_call` tinyint(1) NOT NULL DEFAULT '0',
  `opted_out` tinyint(1) NOT NULL DEFAULT '0',
  `unsubscribe_hash` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_assigned_at` datetime DEFAULT NULL,
  `is_reviewed` tinyint(1) NOT NULL DEFAULT '0',
  `is_starred` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `server_id` int(11) DEFAULT NULL,
  `merge_into_prospect_id` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dedupe_key_unique` (`account_id`,`deduplication_key`),
  UNIQUE KEY `ix_account_unsubhash` (`account_id`,`unsubscribe_hash`),
  KEY `prospect_email_last_activity_at` (`account_id`,`email`,`last_activity_at`),
  KEY `prospect_FI_2` (`campaign_id`),
  KEY `prospect_FI_3` (`user_id`),
  KEY `prospect_FI_4` (`queue_id`),
  KEY `prospect_FI_5` (`profile_id`),
  KEY `prospect_FI_6` (`prospect_account_id`),
  KEY `prospect_FI_7` (`created_by`),
  KEY `prospect_FI_8` (`updated_by`),
  KEY `ix_account_id_last_activity_at` (`account_id`,`last_activity_at`),
  CONSTRAINT `prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `prospect_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `prospect_FK_4` FOREIGN KEY (`queue_id`) REFERENCES `queue` (`id`),
  CONSTRAINT `prospect_FK_5` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`),
  CONSTRAINT `prospect_FK_6` FOREIGN KEY (`prospect_account_id`) REFERENCES `prospect_account` (`id`),
  CONSTRAINT `prospect_FK_7` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `prospect_FK_8` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect`
--

LOCK TABLES `prospect` WRITE;
/*!40000 ALTER TABLE `prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_account`
--

DROP TABLE IF EXISTS `prospect_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `annual_revenue` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `billing_address_one` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `billing_address_two` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `billing_city` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `billing_state` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `billing_zip` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `billing_country` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `employees` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fax` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `industry` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_activity_at` datetime DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ownership` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_account_id` int(11) DEFAULT NULL,
  `phone` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rating` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shipping_address_one` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shipping_address_two` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shipping_city` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shipping_zip` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shipping_state` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shipping_country` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sic` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `site` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ticker_symbol` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_account_FI_1` (`account_id`),
  KEY `prospect_account_FI_2` (`created_by`),
  KEY `prospect_account_FI_3` (`updated_by`),
  KEY `prospect_account_FI_4` (`parent_account_id`),
  KEY `prospect_account_FI_5` (`user_id`),
  CONSTRAINT `prospect_account_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_account_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `prospect_account_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `prospect_account_FK_4` FOREIGN KEY (`parent_account_id`) REFERENCES `prospect_account` (`id`),
  CONSTRAINT `prospect_account_FK_5` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_account`
--

LOCK TABLES `prospect_account` WRITE;
/*!40000 ALTER TABLE `prospect_account` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_activity_report`
--

DROP TABLE IF EXISTS `prospect_activity_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_activity_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `report_date` date DEFAULT NULL,
  `page_view_count` int(11) DEFAULT NULL,
  `email_count` int(11) DEFAULT NULL,
  `form_count` int(11) DEFAULT NULL,
  `site_search_query_count` int(11) DEFAULT NULL,
  `landing_page_count` int(11) DEFAULT NULL,
  `paid_search_ad_count` int(11) DEFAULT NULL,
  `tracker_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_activity_report_FI_1` (`account_id`),
  KEY `prospect_activity_report_FI_2` (`campaign_id`),
  CONSTRAINT `prospect_activity_report_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_activity_report_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_activity_report`
--

LOCK TABLES `prospect_activity_report` WRITE;
/*!40000 ALTER TABLE `prospect_activity_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_activity_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_analysis`
--

DROP TABLE IF EXISTS `prospect_analysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_analysis` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `cost` float DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_analysis_FI_1` (`account_id`),
  KEY `prospect_analysis_FI_2` (`prospect_id`),
  KEY `prospect_analysis_FI_3` (`user_id`),
  KEY `prospect_analysis_FI_4` (`created_by`),
  KEY `prospect_analysis_FI_5` (`updated_by`),
  CONSTRAINT `prospect_analysis_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_analysis_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `prospect_analysis_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `prospect_analysis_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `prospect_analysis_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_analysis`
--

LOCK TABLES `prospect_analysis` WRITE;
/*!40000 ALTER TABLE `prospect_analysis` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_analysis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_assignment_audit_log`
--

DROP TABLE IF EXISTS `prospect_assignment_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_assignment_audit_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `fk_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `assignment_time` datetime NOT NULL,
  `should_send_assignment_email` int(11) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `ix_atime` (`account_id`,`prospect_id`,`assignment_time`),
  KEY `ix_user` (`account_id`,`user_id`,`should_send_assignment_email`,`assignment_time`),
  KEY `ix_user_time` (`account_id`,`should_send_assignment_email`,`type`,`fk_id`,`assignment_time`),
  KEY `prospect_assignment_audit_log_FI_2` (`prospect_id`),
  KEY `prospect_assignment_audit_log_FI_3` (`user_id`),
  CONSTRAINT `prospect_assignment_audit_log_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_assignment_audit_log_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `prospect_assignment_audit_log_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_assignment_audit_log`
--

LOCK TABLES `prospect_assignment_audit_log` WRITE;
/*!40000 ALTER TABLE `prospect_assignment_audit_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_assignment_audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_autofill_queue`
--

DROP TABLE IF EXISTS `prospect_autofill_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_autofill_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `visitor_id` int(11) NOT NULL,
  `is_finished` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `prospect_autofill_queue_FI_1` (`account_id`),
  KEY `prospect_autofill_queue_FI_2` (`prospect_id`),
  KEY `prospect_autofill_queue_FI_3` (`visitor_id`),
  CONSTRAINT `prospect_autofill_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_autofill_queue_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `prospect_autofill_queue_FK_3` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_autofill_queue`
--

LOCK TABLES `prospect_autofill_queue` WRITE;
/*!40000 ALTER TABLE `prospect_autofill_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_autofill_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_autofill_queue_external_key`
--

DROP TABLE IF EXISTS `prospect_autofill_queue_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_autofill_queue_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_prospect_autofill_queue_id` FOREIGN KEY (`id`) REFERENCES `prospect_autofill_queue` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_autofill_queue_external_key`
--

LOCK TABLES `prospect_autofill_queue_external_key` WRITE;
/*!40000 ALTER TABLE `prospect_autofill_queue_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_autofill_queue_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_banlist`
--

DROP TABLE IF EXISTS `prospect_banlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_banlist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `added_date` datetime NOT NULL,
  `reason` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_prospect` (`account_id`,`prospect_id`),
  KEY `prospect_banlist_FI_2` (`prospect_id`),
  CONSTRAINT `prospect_banlist_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_banlist_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_banlist`
--

LOCK TABLES `prospect_banlist` WRITE;
/*!40000 ALTER TABLE `prospect_banlist` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_banlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_conversion`
--

DROP TABLE IF EXISTS `prospect_conversion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_conversion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `source_referrer_id` int(11) DEFAULT NULL,
  `conversion_referrer_id` int(11) DEFAULT NULL,
  `seconds_as_visitor` int(11) DEFAULT NULL,
  `prospect_id` int(11) NOT NULL,
  `visitor_activity_id` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `object_type` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prospect_unique` (`prospect_id`),
  KEY `object_lookup` (`account_id`,`object_type`,`object_id`),
  KEY `created` (`created_at`),
  KEY `prospect_conversion_FI_2` (`source_referrer_id`),
  KEY `prospect_conversion_FI_3` (`conversion_referrer_id`),
  KEY `prospect_conversion_FI_5` (`visitor_activity_id`),
  CONSTRAINT `prospect_conversion_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_conversion_FK_2` FOREIGN KEY (`source_referrer_id`) REFERENCES `visitor_referrer` (`id`),
  CONSTRAINT `prospect_conversion_FK_3` FOREIGN KEY (`conversion_referrer_id`) REFERENCES `visitor_referrer` (`id`),
  CONSTRAINT `prospect_conversion_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `prospect_conversion_FK_5` FOREIGN KEY (`visitor_activity_id`) REFERENCES `visitor_activity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_conversion`
--

LOCK TABLES `prospect_conversion` WRITE;
/*!40000 ALTER TABLE `prospect_conversion` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_conversion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_conversion_external_key`
--

DROP TABLE IF EXISTS `prospect_conversion_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_conversion_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_prospect_conversion_id` FOREIGN KEY (`id`) REFERENCES `prospect_conversion` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_conversion_external_key`
--

LOCK TABLES `prospect_conversion_external_key` WRITE;
/*!40000 ALTER TABLE `prospect_conversion_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_conversion_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_deduplication_strategy`
--

DROP TABLE IF EXISTS `prospect_deduplication_strategy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_deduplication_strategy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `strategy_type` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_unique` (`account_id`),
  CONSTRAINT `prospect_deduplication_strategy_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_deduplication_strategy`
--

LOCK TABLES `prospect_deduplication_strategy` WRITE;
/*!40000 ALTER TABLE `prospect_deduplication_strategy` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_deduplication_strategy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_external_key`
--

DROP TABLE IF EXISTS `prospect_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_prospect_id` FOREIGN KEY (`id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_external_key`
--

LOCK TABLES `prospect_external_key` WRITE;
/*!40000 ALTER TABLE `prospect_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_field_custom`
--

DROP TABLE IF EXISTS `prospect_field_custom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_field_custom` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `field_id` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_field_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) DEFAULT '1',
  `is_record_multiple_responses` tinyint(1) NOT NULL DEFAULT '0',
  `default_mail_merge_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_use_values` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `is_crm_override` tinyint(1) NOT NULL DEFAULT '0',
  `is_required` int(11) DEFAULT '0',
  `is_validate` int(11) DEFAULT '0',
  `sync_crm_field_values` int(11) DEFAULT '0',
  `sync_with_gooddata` int(11) DEFAULT '0',
  `gooddata_sync_type` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_field_custom_FI_1` (`account_id`),
  KEY `prospect_field_custom_FI_2` (`created_by`),
  KEY `prospect_field_custom_FI_3` (`updated_by`),
  CONSTRAINT `prospect_field_custom_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_field_custom_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `prospect_field_custom_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_field_custom`
--

LOCK TABLES `prospect_field_custom` WRITE;
/*!40000 ALTER TABLE `prospect_field_custom` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_field_custom` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_field_custom_storage`
--

DROP TABLE IF EXISTS `prospect_field_custom_storage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_field_custom_storage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `value` text COLLATE utf8_unicode_ci,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_field_custom_storage_FI_1` (`account_id`),
  KEY `ix_prospect_field_custom_storage_account_id_id` (`account_id`,`id`),
  KEY `prospect_field_custom_storage_FI_2` (`prospect_id`),
  KEY `prospect_field_custom_storage_FI_3` (`prospect_field_custom_id`),
  KEY `prospect_field_custom_storage_FI_4` (`updated_by`),
  CONSTRAINT `prospect_field_custom_storage_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_field_custom_storage_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `prospect_field_custom_storage_FK_3` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`),
  CONSTRAINT `prospect_field_custom_storage_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_field_custom_storage`
--

LOCK TABLES `prospect_field_custom_storage` WRITE;
/*!40000 ALTER TABLE `prospect_field_custom_storage` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_field_custom_storage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_field_custom_value`
--

DROP TABLE IF EXISTS `prospect_field_custom_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_field_custom_value` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_field_custom_value_FI_1` (`account_id`),
  KEY `prospect_field_custom_value_FI_2` (`prospect_field_custom_id`),
  KEY `prospect_field_custom_value_FI_3` (`listx_id`),
  KEY `prospect_field_custom_value_FI_4` (`profile_id`),
  KEY `prospect_field_custom_value_FI_5` (`created_by`),
  KEY `prospect_field_custom_value_FI_6` (`updated_by`),
  CONSTRAINT `prospect_field_custom_value_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_field_custom_value_FK_2` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`),
  CONSTRAINT `prospect_field_custom_value_FK_3` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `prospect_field_custom_value_FK_4` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`),
  CONSTRAINT `prospect_field_custom_value_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `prospect_field_custom_value_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_field_custom_value`
--

LOCK TABLES `prospect_field_custom_value` WRITE;
/*!40000 ALTER TABLE `prospect_field_custom_value` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_field_custom_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_field_default`
--

DROP TABLE IF EXISTS `prospect_field_default`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_field_default` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `name` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `field_id` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_field_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `default_mail_merge_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_use_values` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `is_crm_override` int(11) DEFAULT '0',
  `is_required` int(11) DEFAULT '0',
  `is_validate` int(11) DEFAULT '0',
  `sync_crm_field_values` int(11) DEFAULT '0',
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_field_default_FI_1` (`account_id`),
  KEY `prospect_field_default_FI_2` (`updated_by`),
  CONSTRAINT `prospect_field_default_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_field_default_FK_2` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_field_default`
--

LOCK TABLES `prospect_field_default` WRITE;
/*!40000 ALTER TABLE `prospect_field_default` DISABLE KEYS */;
INSERT INTO `prospect_field_default` VALUES (1,'first_name',2,'First Name','first_name',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:13','2016-03-24 16:07:13'),(2,'last_name',2,'Last Name','last_name',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,'email',2,'Email','email',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(4,'company',2,'Company','company',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(5,'website',2,'Website','website',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(6,'job_title',2,'Job Title','job_title',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(7,'department',2,'Department','department',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(8,'country',2,'Country','country',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(9,'address_one',2,'Address One','address_one',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(10,'address_two',2,'Address Two','address_two',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(11,'city',2,'City','city',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(12,'state',2,'State','state',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(13,'territory',2,'Territory','territory',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(14,'zip',2,'Zip','zip',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(15,'phone',2,'Phone','phone',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(16,'fax',2,'Fax','fax',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(17,'source',2,'Source','source',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(18,'annual_revenue',2,'Annual Revenue','annual_revenue',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(19,'employees',2,'Employees','employees',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(20,'industry',2,'Industry','industry',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(21,'is_do_not_email',2,'Do Not Email','is_do_not_email',NULL,3,NULL,0,0,2,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(22,'is_do_not_call',2,'Do Not Call','is_do_not_call',NULL,3,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(23,'unsubscribe',2,'Unsubscribe','unsubscribe',NULL,1,NULL,0,1,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(24,'years_in_business',2,'Years In Business','years_in_business',NULL,1,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(25,'comments',2,'Comments','comments',NULL,5,NULL,0,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(26,'subscribe',2,'Subscribe','subscribe',NULL,3,NULL,0,1,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(27,'salutation',2,'Salutation','salutation',NULL,4,NULL,1,0,0,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(28,'pardot_hard_bounced',2,'Pardot Hard Bounced','pardot_hard_bounced',NULL,3,NULL,0,0,1,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(29,'email_bounced_reason',2,'Email Bounced Reason','email_bounced_reason',NULL,1,NULL,0,0,1,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(30,'email_bounced_date',2,'Email Bounced Date','email_bounced_date',NULL,1,NULL,0,0,1,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(31,'opted_out',2,'Opted Out','opted_out',NULL,3,NULL,0,0,2,0,0,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `prospect_field_default` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_field_default_value`
--

DROP TABLE IF EXISTS `prospect_field_default_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_field_default_value` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_field_default_value_FI_1` (`account_id`),
  KEY `prospect_field_default_value_FI_2` (`prospect_field_default_id`),
  KEY `prospect_field_default_value_FI_3` (`listx_id`),
  KEY `prospect_field_default_value_FI_4` (`created_by`),
  KEY `prospect_field_default_value_FI_5` (`updated_by`),
  CONSTRAINT `prospect_field_default_value_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_field_default_value_FK_2` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `prospect_field_default_value_FK_3` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `prospect_field_default_value_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `prospect_field_default_value_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_field_default_value`
--

LOCK TABLES `prospect_field_default_value` WRITE;
/*!40000 ALTER TABLE `prospect_field_default_value` DISABLE KEYS */;
INSERT INTO `prospect_field_default_value` VALUES (1,2,27,NULL,'Mr.','Mr.',NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(2,2,27,NULL,'Mrs.','Mrs.',NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(3,2,27,NULL,'Ms.','Ms.',NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(4,2,27,NULL,'Dr.','Dr.',NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14'),(5,2,27,NULL,'Prof.','Prof.',NULL,0,NULL,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `prospect_field_default_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_field_dependency`
--

DROP TABLE IF EXISTS `prospect_field_dependency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_field_dependency` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `form_id` int(11) NOT NULL,
  `master_field_id` int(11) NOT NULL,
  `master_field_type` int(11) NOT NULL,
  `master_field_value` text COLLATE utf8_unicode_ci NOT NULL,
  `slave_field_id` int(11) NOT NULL,
  `slave_field_type` int(11) NOT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_field_dependency_FI_1` (`account_id`),
  KEY `prospect_field_dependency_FI_2` (`created_by`),
  KEY `prospect_field_dependency_FI_3` (`updated_by`),
  CONSTRAINT `prospect_field_dependency_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_field_dependency_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `prospect_field_dependency_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_field_dependency`
--

LOCK TABLES `prospect_field_dependency` WRITE;
/*!40000 ALTER TABLE `prospect_field_dependency` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_field_dependency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_field_source`
--

DROP TABLE IF EXISTS `prospect_field_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_field_source` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `field` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `source` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prospect_email_unique` (`account_id`,`prospect_id`,`prospect_field_default_id`,`prospect_field_custom_id`),
  KEY `prospect_field_source_FI_2` (`prospect_id`),
  KEY `prospect_field_source_FI_3` (`prospect_field_default_id`),
  KEY `prospect_field_source_FI_4` (`prospect_field_custom_id`),
  CONSTRAINT `prospect_field_source_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_field_source_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `prospect_field_source_FK_3` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `prospect_field_source_FK_4` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_field_source`
--

LOCK TABLES `prospect_field_source` WRITE;
/*!40000 ALTER TABLE `prospect_field_source` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_field_source` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_profile_grade`
--

DROP TABLE IF EXISTS `prospect_profile_grade`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_profile_grade` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  `grade` int(11) DEFAULT '3',
  PRIMARY KEY (`id`),
  KEY `account_prospect_profile` (`account_id`,`prospect_id`),
  KEY `prospect_profile_grade_FI_2` (`prospect_id`),
  KEY `prospect_profile_grade_FI_3` (`profile_id`),
  CONSTRAINT `prospect_profile_grade_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_profile_grade_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `prospect_profile_grade_FK_3` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_profile_grade`
--

LOCK TABLES `prospect_profile_grade` WRITE;
/*!40000 ALTER TABLE `prospect_profile_grade` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_profile_grade` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_report`
--

DROP TABLE IF EXISTS `prospect_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `report_date` date DEFAULT NULL,
  `total_count` int(11) DEFAULT NULL,
  `assigned_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_report_FI_1` (`account_id`),
  KEY `prospect_report_FI_2` (`campaign_id`),
  CONSTRAINT `prospect_report_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_report_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_report`
--

LOCK TABLES `prospect_report` WRITE;
/*!40000 ALTER TABLE `prospect_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_score_audit`
--

DROP TABLE IF EXISTS `prospect_score_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_score_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  `automation_id` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `form_handler_id` int(11) DEFAULT NULL,
  `filex_id` int(11) DEFAULT NULL,
  `custom_url_id` int(11) DEFAULT NULL,
  `email_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `scoring_category_id` int(11) DEFAULT NULL,
  `workflow_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_score_audit_FI_1` (`account_id`),
  KEY `prospect_score_audit_FI_2` (`prospect_id`),
  KEY `prospect_score_audit_FI_3` (`automation_id`),
  KEY `prospect_score_audit_FI_4` (`form_id`),
  KEY `prospect_score_audit_FI_5` (`form_handler_id`),
  KEY `prospect_score_audit_FI_6` (`filex_id`),
  KEY `prospect_score_audit_FI_7` (`custom_url_id`),
  KEY `prospect_score_audit_FI_8` (`email_id`),
  KEY `prospect_score_audit_FI_9` (`user_id`),
  KEY `prospect_score_audit_FI_10` (`scoring_category_id`),
  CONSTRAINT `prospect_score_audit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_score_audit_FK_10` FOREIGN KEY (`scoring_category_id`) REFERENCES `scoring_category` (`id`),
  CONSTRAINT `prospect_score_audit_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `prospect_score_audit_FK_3` FOREIGN KEY (`automation_id`) REFERENCES `automation` (`id`),
  CONSTRAINT `prospect_score_audit_FK_4` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `prospect_score_audit_FK_5` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`),
  CONSTRAINT `prospect_score_audit_FK_6` FOREIGN KEY (`filex_id`) REFERENCES `filex` (`id`),
  CONSTRAINT `prospect_score_audit_FK_7` FOREIGN KEY (`custom_url_id`) REFERENCES `custom_url` (`id`),
  CONSTRAINT `prospect_score_audit_FK_8` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `prospect_score_audit_FK_9` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_score_audit`
--

LOCK TABLES `prospect_score_audit` WRITE;
/*!40000 ALTER TABLE `prospect_score_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_score_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_scoring_category_score`
--

DROP TABLE IF EXISTS `prospect_scoring_category_score`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_scoring_category_score` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `scoring_category_id` int(11) NOT NULL,
  `score` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_entry` (`account_id`,`prospect_id`,`scoring_category_id`),
  KEY `ix_account_scoring_category` (`scoring_category_id`,`account_id`),
  KEY `prospect_scoring_category_score_FI_2` (`prospect_id`),
  CONSTRAINT `prospect_scoring_category_score_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_scoring_category_score_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `prospect_scoring_category_score_FK_3` FOREIGN KEY (`scoring_category_id`) REFERENCES `scoring_category` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_scoring_category_score`
--

LOCK TABLES `prospect_scoring_category_score` WRITE;
/*!40000 ALTER TABLE `prospect_scoring_category_score` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_scoring_category_score` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_state_audit`
--

DROP TABLE IF EXISTS `prospect_state_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_state_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prospect_state_audit_FI_1` (`account_id`),
  KEY `prospect_state_audit_FI_2` (`prospect_id`),
  KEY `prospect_state_audit_FI_3` (`created_by`),
  CONSTRAINT `prospect_state_audit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_state_audit_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `prospect_state_audit_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_state_audit`
--

LOCK TABLES `prospect_state_audit` WRITE;
/*!40000 ALTER TABLE `prospect_state_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_state_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_summary_stats`
--

DROP TABLE IF EXISTS `prospect_summary_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_summary_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stats_date` date DEFAULT NULL,
  `account_id` int(11) NOT NULL,
  `prospects_assigned` int(11) DEFAULT '0',
  `prospects_created` int(11) DEFAULT '0',
  `prospects_converted` int(11) DEFAULT '0',
  `prospects_imported` int(11) DEFAULT '0',
  `opportunities_created` int(11) DEFAULT '0',
  `database_size` int(11) DEFAULT '0',
  `database_mailable_size` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `prospect_summary_stats_lookup` (`account_id`,`stats_date`),
  CONSTRAINT `prospect_summary_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_summary_stats`
--

LOCK TABLES `prospect_summary_stats` WRITE;
/*!40000 ALTER TABLE `prospect_summary_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_summary_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_sync_error`
--

DROP TABLE IF EXISTS `prospect_sync_error`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_sync_error` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `short_error` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `long_error` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prospect_id` (`prospect_id`),
  KEY `prospect_sync_error_FI_1` (`account_id`),
  CONSTRAINT `prospect_sync_error_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_sync_error_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_sync_error`
--

LOCK TABLES `prospect_sync_error` WRITE;
/*!40000 ALTER TABLE `prospect_sync_error` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_sync_error` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_sync_queue`
--

DROP TABLE IF EXISTS `prospect_sync_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_sync_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `sync_status` int(11) DEFAULT NULL,
  `email` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `synced_at` datetime DEFAULT NULL,
  `update_context` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `crm_state_bitmap` bigint(20) NOT NULL DEFAULT '0',
  `last_synced_bounce_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prospect_id` (`prospect_id`),
  KEY `crm_state_bitmap_sync_status_idx` (`account_id`,`sync_status`,`crm_state_bitmap`),
  CONSTRAINT `prospect_sync_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_sync_queue_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_sync_queue`
--

LOCK TABLES `prospect_sync_queue` WRITE;
/*!40000 ALTER TABLE `prospect_sync_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_sync_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prospect_tag_filter`
--

DROP TABLE IF EXISTS `prospect_tag_filter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_tag_filter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `tag_names` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `type` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`user_id`,`type`),
  KEY `prospect_tag_filter_FI_1` (`account_id`),
  CONSTRAINT `prospect_tag_filter_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `prospect_tag_filter_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prospect_tag_filter`
--

LOCK TABLES `prospect_tag_filter` WRITE;
/*!40000 ALTER TABLE `prospect_tag_filter` DISABLE KEYS */;
/*!40000 ALTER TABLE `prospect_tag_filter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `queue`
--

DROP TABLE IF EXISTS `queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_queue_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `queue_FI_1` (`account_id`),
  KEY `queue_FI_2` (`created_by`),
  KEY `queue_FI_3` (`updated_by`),
  CONSTRAINT `queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `queue_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `queue_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `queue`
--

LOCK TABLES `queue` WRITE;
/*!40000 ALTER TABLE `queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recent_prospect_activity`
--

DROP TABLE IF EXISTS `recent_prospect_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recent_prospect_activity` (
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `last_activity_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `is_starred` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `alert_sent_at` datetime DEFAULT NULL,
  `last_activity_id` int(11) NOT NULL,
  PRIMARY KEY (`prospect_id`),
  KEY `recent_prospect_activity_FI_1` (`account_id`),
  KEY `recent_prospect_activity_FI_3` (`user_id`),
  KEY `recent_prospect_activity_FI_4` (`last_activity_id`),
  KEY `recent_prospect_activity_JI_1` (`account_id`,`prospect_id`),
  KEY `recent_prospect_activity_JI_2` (`account_id`,`last_activity_at`),
  KEY `recent_prospect_activity_JI_3` (`account_id`,`user_id`,`last_activity_at`),
  KEY `recent_prospect_activity_JI_4` (`account_id`,`user_id`,`is_starred`,`last_activity_at`),
  CONSTRAINT `recent_prospect_activity_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `recent_prospect_activity_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `recent_prospect_activity_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `recent_prospect_activity_FK_4` FOREIGN KEY (`last_activity_id`) REFERENCES `visitor_activity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recent_prospect_activity`
--

LOCK TABLES `recent_prospect_activity` WRITE;
/*!40000 ALTER TABLE `recent_prospect_activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `recent_prospect_activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recent_visitor_ip`
--

DROP TABLE IF EXISTS `recent_visitor_ip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recent_visitor_ip` (
  `account_id` int(11) NOT NULL,
  `visitor_ip_address` int(10) unsigned NOT NULL,
  `last_visitor_id` int(11) NOT NULL,
  `last_visitor_updated_at` datetime NOT NULL,
  `external_visitor_id` binary(16) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`account_id`,`visitor_ip_address`),
  KEY `by_last_visitor_updated_at` (`account_id`,`last_visitor_updated_at`),
  KEY `recent_visitor_ip_FI_2` (`last_visitor_id`),
  CONSTRAINT `recent_visitor_ip_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `recent_visitor_ip_FK_2` FOREIGN KEY (`last_visitor_id`) REFERENCES `visitor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recent_visitor_ip`
--

LOCK TABLES `recent_visitor_ip` WRITE;
/*!40000 ALTER TABLE `recent_visitor_ip` DISABLE KEYS */;
/*!40000 ALTER TABLE `recent_visitor_ip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `score_change`
--

DROP TABLE IF EXISTS `score_change`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `score_change` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `scoring_model_change_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `points_before` int(11) NOT NULL,
  `points_after` int(11) NOT NULL,
  `last_processed_prospect_id` int(11) DEFAULT NULL,
  `end_prospect_id` int(11) NOT NULL,
  `last_processed_solr_offset` int(11) NOT NULL DEFAULT '0',
  `is_finished` int(11) NOT NULL DEFAULT '0',
  `finished_at` datetime DEFAULT NULL,
  `completed_successfully` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`scoring_model_change_id`,`type`),
  KEY `is_finished` (`account_id`,`is_finished`),
  KEY `score_change_FI_3` (`last_processed_prospect_id`),
  KEY `score_change_FI_4` (`end_prospect_id`),
  CONSTRAINT `score_change_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `score_change_FK_2` FOREIGN KEY (`scoring_model_change_id`) REFERENCES `scoring_model_change` (`id`),
  CONSTRAINT `score_change_FK_3` FOREIGN KEY (`last_processed_prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `score_change_FK_4` FOREIGN KEY (`end_prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `score_change`
--

LOCK TABLES `score_change` WRITE;
/*!40000 ALTER TABLE `score_change` DISABLE KEYS */;
/*!40000 ALTER TABLE `score_change` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scoring_category`
--

DROP TABLE IF EXISTS `scoring_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scoring_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `is_historic` tinyint(4) NOT NULL DEFAULT '0',
  `score_after` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_entry` (`account_id`,`name`),
  KEY `ix_created` (`account_id`,`created_at`),
  KEY `scoring_category_FI_2` (`created_by`),
  KEY `scoring_category_FI_3` (`updated_by`),
  CONSTRAINT `scoring_category_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `scoring_category_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `scoring_category_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scoring_category`
--

LOCK TABLES `scoring_category` WRITE;
/*!40000 ALTER TABLE `scoring_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `scoring_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scoring_category_change`
--

DROP TABLE IF EXISTS `scoring_category_change`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scoring_category_change` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `object_type` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `old_scoring_category_id` int(11) DEFAULT NULL,
  `new_scoring_category_id` int(11) DEFAULT NULL,
  `end_prospect_id` int(11) NOT NULL,
  `is_finished` int(11) NOT NULL DEFAULT '0',
  `finished_at` datetime DEFAULT NULL,
  `completed_successfully` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `notify_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `scoring_category_change_FI_1` (`account_id`),
  KEY `scoring_category_change_FI_2` (`old_scoring_category_id`),
  KEY `scoring_category_change_FI_3` (`new_scoring_category_id`),
  KEY `scoring_category_change_FI_4` (`end_prospect_id`),
  KEY `scoring_category_change_FI_5` (`created_by`),
  KEY `scoring_category_change_FI_6` (`notify_user_id`),
  CONSTRAINT `scoring_category_change_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `scoring_category_change_FK_2` FOREIGN KEY (`old_scoring_category_id`) REFERENCES `scoring_category` (`id`),
  CONSTRAINT `scoring_category_change_FK_3` FOREIGN KEY (`new_scoring_category_id`) REFERENCES `scoring_category` (`id`),
  CONSTRAINT `scoring_category_change_FK_4` FOREIGN KEY (`end_prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `scoring_category_change_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `scoring_category_change_FK_6` FOREIGN KEY (`notify_user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scoring_category_change`
--

LOCK TABLES `scoring_category_change` WRITE;
/*!40000 ALTER TABLE `scoring_category_change` DISABLE KEYS */;
/*!40000 ALTER TABLE `scoring_category_change` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scoring_category_folder`
--

DROP TABLE IF EXISTS `scoring_category_folder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scoring_category_folder` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `scoring_category_id` int(11) NOT NULL,
  `folder_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_entry` (`account_id`,`folder_id`),
  KEY `scoring_category_folder_FI_2` (`scoring_category_id`),
  KEY `scoring_category_folder_FI_3` (`folder_id`),
  CONSTRAINT `scoring_category_folder_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `scoring_category_folder_FK_2` FOREIGN KEY (`scoring_category_id`) REFERENCES `scoring_category` (`id`),
  CONSTRAINT `scoring_category_folder_FK_3` FOREIGN KEY (`folder_id`) REFERENCES `folder` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scoring_category_folder`
--

LOCK TABLES `scoring_category_folder` WRITE;
/*!40000 ALTER TABLE `scoring_category_folder` DISABLE KEYS */;
/*!40000 ALTER TABLE `scoring_category_folder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scoring_model_change`
--

DROP TABLE IF EXISTS `scoring_model_change`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scoring_model_change` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `end_prospect_id` int(11) NOT NULL,
  `is_finished` int(11) NOT NULL DEFAULT '0',
  `finished_at` datetime DEFAULT NULL,
  `completed_successfully` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `notify_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `is_finished` (`account_id`,`is_finished`),
  KEY `scoring_model_change_FI_2` (`end_prospect_id`),
  KEY `scoring_model_change_FI_3` (`created_by`),
  CONSTRAINT `scoring_model_change_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `scoring_model_change_FK_2` FOREIGN KEY (`end_prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `scoring_model_change_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scoring_model_change`
--

LOCK TABLES `scoring_model_change` WRITE;
/*!40000 ALTER TABLE `scoring_model_change` DISABLE KEYS */;
/*!40000 ALTER TABLE `scoring_model_change` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `segmentation`
--

DROP TABLE IF EXISTS `segmentation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `segmentation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `archive_date` date DEFAULT NULL,
  `match_type` int(11) DEFAULT '1',
  `is_being_processed` int(11) DEFAULT '0',
  `started_processing_at` datetime DEFAULT NULL,
  `total_processing_time` int(11) DEFAULT '0',
  `total_prospects_matched` int(11) DEFAULT NULL,
  `notify_user_id` int(11) DEFAULT NULL,
  `matching_status` int(11) DEFAULT '0',
  `metadata` text COLLATE utf8_unicode_ci,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `segmentation_FI_1` (`account_id`),
  KEY `segmentation_FI_2` (`created_by`),
  KEY `segmentation_FI_3` (`updated_by`),
  CONSTRAINT `segmentation_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `segmentation_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `segmentation_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `segmentation`
--

LOCK TABLES `segmentation` WRITE;
/*!40000 ALTER TABLE `segmentation` DISABLE KEYS */;
/*!40000 ALTER TABLE `segmentation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `segmentation_action`
--

DROP TABLE IF EXISTS `segmentation_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `segmentation_action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `segmentation_id` int(11) DEFAULT NULL,
  `action` int(11) DEFAULT NULL,
  `target` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `segmentation_action_FI_1` (`account_id`),
  KEY `segmentation_action_FI_2` (`segmentation_id`),
  KEY `segmentation_action_FI_3` (`listx_id`),
  KEY `segmentation_action_FI_4` (`created_by`),
  CONSTRAINT `segmentation_action_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `segmentation_action_FK_2` FOREIGN KEY (`segmentation_id`) REFERENCES `segmentation` (`id`),
  CONSTRAINT `segmentation_action_FK_3` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `segmentation_action_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `segmentation_action`
--

LOCK TABLES `segmentation_action` WRITE;
/*!40000 ALTER TABLE `segmentation_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `segmentation_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `segmentation_preview`
--

DROP TABLE IF EXISTS `segmentation_preview`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `segmentation_preview` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `segmentation_id` int(11) NOT NULL,
  `num_matched` int(11) DEFAULT '0',
  `is_finished` int(11) DEFAULT '0',
  `last_updated_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `notify_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_segmentation_id` (`account_id`,`segmentation_id`),
  KEY `segmentation_preview_FI_2` (`segmentation_id`),
  KEY `segmentation_preview_FI_3` (`created_by`),
  KEY `segmentation_preview_FI_4` (`updated_by`),
  KEY `segmentation_preview_FI_5` (`notify_user_id`),
  CONSTRAINT `segmentation_preview_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `segmentation_preview_FK_2` FOREIGN KEY (`segmentation_id`) REFERENCES `segmentation` (`id`),
  CONSTRAINT `segmentation_preview_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `segmentation_preview_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `segmentation_preview_FK_5` FOREIGN KEY (`notify_user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `segmentation_preview`
--

LOCK TABLES `segmentation_preview` WRITE;
/*!40000 ALTER TABLE `segmentation_preview` DISABLE KEYS */;
/*!40000 ALTER TABLE `segmentation_preview` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `segmentation_preview_prospect`
--

DROP TABLE IF EXISTS `segmentation_preview_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `segmentation_preview_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `segmentation_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `prospect` (`account_id`,`segmentation_id`,`prospect_id`),
  KEY `segmentation_preview_prospect_FI_2` (`segmentation_id`),
  KEY `segmentation_preview_prospect_FI_3` (`prospect_id`),
  CONSTRAINT `segmentation_preview_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `segmentation_preview_prospect_FK_2` FOREIGN KEY (`segmentation_id`) REFERENCES `segmentation` (`id`),
  CONSTRAINT `segmentation_preview_prospect_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `segmentation_preview_prospect`
--

LOCK TABLES `segmentation_preview_prospect` WRITE;
/*!40000 ALTER TABLE `segmentation_preview_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `segmentation_preview_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `segmentation_prospect`
--

DROP TABLE IF EXISTS `segmentation_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `segmentation_prospect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `wizard_id` int(11) DEFAULT NULL,
  `segmentation_id` int(11) DEFAULT NULL,
  `has_applied_action` int(11) DEFAULT '0',
  `process_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_seg_prospect_1` (`segmentation_id`,`prospect_id`),
  KEY `ix_action_job` (`account_id`,`process_id`,`has_applied_action`),
  KEY `segmentation_prospect_FI_2` (`prospect_id`),
  KEY `segmentation_prospect_FI_3` (`wizard_id`),
  CONSTRAINT `segmentation_prospect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `segmentation_prospect_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `segmentation_prospect_FK_3` FOREIGN KEY (`wizard_id`) REFERENCES `wizard` (`id`),
  CONSTRAINT `segmentation_prospect_FK_4` FOREIGN KEY (`segmentation_id`) REFERENCES `segmentation` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `segmentation_prospect`
--

LOCK TABLES `segmentation_prospect` WRITE;
/*!40000 ALTER TABLE `segmentation_prospect` DISABLE KEYS */;
/*!40000 ALTER TABLE `segmentation_prospect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `segmentation_rule`
--

DROP TABLE IF EXISTS `segmentation_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `segmentation_rule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `segmentation_id` int(11) DEFAULT NULL,
  `segmentation_rule_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `object_type` int(11) DEFAULT NULL,
  `operator` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `compare` int(11) DEFAULT NULL,
  `custom_url_id` int(11) DEFAULT NULL,
  `form_field_id` int(11) DEFAULT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `form_handler_id` int(11) DEFAULT NULL,
  `landing_page_id` int(11) DEFAULT NULL,
  `filex_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `queue_id` int(11) DEFAULT NULL,
  `field_id` int(11) DEFAULT NULL,
  `webinar_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `crm_campaign_id` int(11) DEFAULT NULL,
  `crm_campaign_status_id` int(11) DEFAULT NULL,
  `scoring_category_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `segmentation_rule_FI_1` (`account_id`),
  KEY `segmentation_rule_FI_2` (`segmentation_id`),
  KEY `segmentation_rule_FI_3` (`segmentation_rule_id`),
  KEY `segmentation_rule_FI_4` (`custom_url_id`),
  KEY `segmentation_rule_FI_5` (`form_field_id`),
  KEY `segmentation_rule_FI_6` (`prospect_field_default_id`),
  KEY `segmentation_rule_FI_7` (`prospect_field_custom_id`),
  KEY `segmentation_rule_FI_8` (`listx_id`),
  KEY `segmentation_rule_FI_9` (`form_id`),
  KEY `segmentation_rule_FI_10` (`form_handler_id`),
  KEY `segmentation_rule_FI_11` (`landing_page_id`),
  KEY `segmentation_rule_FI_12` (`filex_id`),
  KEY `segmentation_rule_FI_13` (`user_id`),
  KEY `segmentation_rule_FI_14` (`queue_id`),
  KEY `segmentation_rule_FI_15` (`field_id`),
  KEY `segmentation_rule_FI_16` (`webinar_id`),
  KEY `segmentation_rule_FI_17` (`profile_id`),
  KEY `segmentation_rule_FI_18` (`crm_campaign_id`),
  KEY `segmentation_rule_FI_19` (`crm_campaign_status_id`),
  KEY `segmentation_rule_FI_20` (`scoring_category_id`),
  KEY `segmentation_rule_FI_21` (`created_by`),
  CONSTRAINT `segmentation_rule_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `segmentation_rule_FK_10` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`),
  CONSTRAINT `segmentation_rule_FK_11` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `segmentation_rule_FK_12` FOREIGN KEY (`filex_id`) REFERENCES `filex` (`id`),
  CONSTRAINT `segmentation_rule_FK_13` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `segmentation_rule_FK_14` FOREIGN KEY (`queue_id`) REFERENCES `queue` (`id`),
  CONSTRAINT `segmentation_rule_FK_15` FOREIGN KEY (`field_id`) REFERENCES `field` (`id`),
  CONSTRAINT `segmentation_rule_FK_16` FOREIGN KEY (`webinar_id`) REFERENCES `webinar` (`id`),
  CONSTRAINT `segmentation_rule_FK_17` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`),
  CONSTRAINT `segmentation_rule_FK_18` FOREIGN KEY (`crm_campaign_id`) REFERENCES `crm_campaign` (`id`),
  CONSTRAINT `segmentation_rule_FK_19` FOREIGN KEY (`crm_campaign_status_id`) REFERENCES `crm_campaign_status` (`id`),
  CONSTRAINT `segmentation_rule_FK_2` FOREIGN KEY (`segmentation_id`) REFERENCES `segmentation` (`id`),
  CONSTRAINT `segmentation_rule_FK_20` FOREIGN KEY (`scoring_category_id`) REFERENCES `scoring_category` (`id`),
  CONSTRAINT `segmentation_rule_FK_21` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `segmentation_rule_FK_3` FOREIGN KEY (`segmentation_rule_id`) REFERENCES `segmentation_rule` (`id`),
  CONSTRAINT `segmentation_rule_FK_4` FOREIGN KEY (`custom_url_id`) REFERENCES `custom_url` (`id`),
  CONSTRAINT `segmentation_rule_FK_5` FOREIGN KEY (`form_field_id`) REFERENCES `form_field` (`id`),
  CONSTRAINT `segmentation_rule_FK_6` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `segmentation_rule_FK_7` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`),
  CONSTRAINT `segmentation_rule_FK_8` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `segmentation_rule_FK_9` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `segmentation_rule`
--

LOCK TABLES `segmentation_rule` WRITE;
/*!40000 ALTER TABLE `segmentation_rule` DISABLE KEYS */;
/*!40000 ALTER TABLE `segmentation_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shard_setting`
--

DROP TABLE IF EXISTS `shard_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shard_setting` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `setting_value` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_setting_key` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shard_setting`
--

LOCK TABLES `shard_setting` WRITE;
/*!40000 ALTER TABLE `shard_setting` DISABLE KEYS */;
/*!40000 ALTER TABLE `shard_setting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site`
--

DROP TABLE IF EXISTS `site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `site` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `stats_checked_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `site_FI_1` (`account_id`),
  KEY `site_FI_2` (`created_by`),
  KEY `site_FI_3` (`updated_by`),
  CONSTRAINT `site_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `site_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `site_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site`
--

LOCK TABLES `site` WRITE;
/*!40000 ALTER TABLE `site` DISABLE KEYS */;
/*!40000 ALTER TABLE `site` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_page`
--

DROP TABLE IF EXISTS `site_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `stats_checked_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_page_lookup` (`site_id`,`url`),
  KEY `site_page_FI_1` (`account_id`),
  CONSTRAINT `site_page_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `site_page_FK_2` FOREIGN KEY (`site_id`) REFERENCES `site` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_page`
--

LOCK TABLES `site_page` WRITE;
/*!40000 ALTER TABLE `site_page` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_page_keyword`
--

DROP TABLE IF EXISTS `site_page_keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_page_keyword` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `site_page_id` int(11) NOT NULL,
  `keyword_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_page_keyword_lookup` (`site_id`,`site_page_id`,`keyword_id`),
  KEY `site_page_keyword_FI_1` (`account_id`),
  KEY `site_page_keyword_FI_3` (`site_page_id`),
  KEY `site_page_keyword_FI_4` (`keyword_id`),
  CONSTRAINT `site_page_keyword_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `site_page_keyword_FK_2` FOREIGN KEY (`site_id`) REFERENCES `site` (`id`),
  CONSTRAINT `site_page_keyword_FK_3` FOREIGN KEY (`site_page_id`) REFERENCES `site_page` (`id`),
  CONSTRAINT `site_page_keyword_FK_4` FOREIGN KEY (`keyword_id`) REFERENCES `keyword` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_page_keyword`
--

LOCK TABLES `site_page_keyword` WRITE;
/*!40000 ALTER TABLE `site_page_keyword` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_page_keyword` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_page_stats`
--

DROP TABLE IF EXISTS `site_page_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_page_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `site_page_id` int(11) NOT NULL,
  `stats_date` date NOT NULL,
  `score` int(11) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `error_code` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_tracking_present` int(11) DEFAULT '0',
  `group1_1` int(11) DEFAULT NULL,
  `group1_2` int(11) DEFAULT NULL,
  `group1_3` int(11) DEFAULT NULL,
  `group1_4` int(11) DEFAULT NULL,
  `group1_5` int(11) DEFAULT NULL,
  `group1_6` int(11) DEFAULT NULL,
  `group1_7` int(11) DEFAULT NULL,
  `group1_8` int(11) DEFAULT NULL,
  `group1_9` int(11) DEFAULT NULL,
  `group1_10` int(11) DEFAULT NULL,
  `group2_1` int(11) DEFAULT NULL,
  `group2_2` int(11) DEFAULT NULL,
  `group2_3` int(11) DEFAULT NULL,
  `group2_4` int(11) DEFAULT NULL,
  `group2_5` int(11) DEFAULT NULL,
  `group2_6` int(11) DEFAULT NULL,
  `group2_7` int(11) DEFAULT NULL,
  `group2_8` int(11) DEFAULT NULL,
  `group2_9` int(11) DEFAULT NULL,
  `group2_10` int(11) DEFAULT NULL,
  `is_current` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_page_stats_lookup` (`site_id`,`site_page_id`,`stats_date`),
  KEY `site_page_stats_FI_1` (`account_id`),
  KEY `site_page_stats_FI_3` (`site_page_id`),
  CONSTRAINT `site_page_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `site_page_stats_FK_2` FOREIGN KEY (`site_id`) REFERENCES `site` (`id`),
  CONSTRAINT `site_page_stats_FK_3` FOREIGN KEY (`site_page_id`) REFERENCES `site_page` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_page_stats`
--

LOCK TABLES `site_page_stats` WRITE;
/*!40000 ALTER TABLE `site_page_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_page_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_search`
--

DROP TABLE IF EXISTS `site_search`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_search` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `layout_template_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `index_interval` int(11) DEFAULT NULL,
  `index_size` int(11) DEFAULT NULL,
  `sitemap_url` text COLLATE utf8_unicode_ci,
  `remove_title_content` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `no_results_content` text COLLATE utf8_unicode_ci,
  `hash` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_indexed_at` datetime DEFAULT NULL,
  `redirect_location` text COLLATE utf8_unicode_ci,
  `search_post_var_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `index_offset` int(11) DEFAULT '0',
  `is_thirdparty` tinyint(1) NOT NULL DEFAULT '0',
  `is_post` tinyint(1) NOT NULL DEFAULT '1',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `site_search_FI_1` (`account_id`),
  KEY `site_search_FI_2` (`campaign_id`),
  KEY `site_search_FI_3` (`layout_template_id`),
  KEY `site_search_FI_4` (`created_by`),
  KEY `site_search_FI_5` (`updated_by`),
  CONSTRAINT `site_search_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `site_search_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `site_search_FK_3` FOREIGN KEY (`layout_template_id`) REFERENCES `layout_template` (`id`),
  CONSTRAINT `site_search_FK_4` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `site_search_FK_5` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_search`
--

LOCK TABLES `site_search` WRITE;
/*!40000 ALTER TABLE `site_search` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_search` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_search_query`
--

DROP TABLE IF EXISTS `site_search_query`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_search_query` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `site_search_id` int(11) DEFAULT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `query` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `site_search_query_FI_1` (`account_id`),
  KEY `site_search_query_FI_2` (`campaign_id`),
  KEY `site_search_query_FI_3` (`site_search_id`),
  KEY `site_search_query_FI_4` (`visitor_id`),
  KEY `site_search_query_FI_5` (`prospect_id`),
  CONSTRAINT `site_search_query_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `site_search_query_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `site_search_query_FK_3` FOREIGN KEY (`site_search_id`) REFERENCES `site_search` (`id`),
  CONSTRAINT `site_search_query_FK_4` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `site_search_query_FK_5` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_search_query`
--

LOCK TABLES `site_search_query` WRITE;
/*!40000 ALTER TABLE `site_search_query` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_search_query` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_search_query_external_key`
--

DROP TABLE IF EXISTS `site_search_query_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_search_query_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_site_search_query_id` FOREIGN KEY (`id`) REFERENCES `site_search_query` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_search_query_external_key`
--

LOCK TABLES `site_search_query_external_key` WRITE;
/*!40000 ALTER TABLE `site_search_query_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_search_query_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_search_stats`
--

DROP TABLE IF EXISTS `site_search_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_search_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `site_search_id` int(11) DEFAULT NULL,
  `query` text COLLATE utf8_unicode_ci,
  `stats_date` date DEFAULT NULL,
  `total_requests` int(11) DEFAULT '0',
  `total_prospects` int(11) DEFAULT '0',
  `total_opportunities` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_search_stats_lookup` (`site_search_id`,`query`(255),`stats_date`),
  KEY `site_search_stats_FI_1` (`account_id`),
  CONSTRAINT `site_search_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `site_search_stats_FK_2` FOREIGN KEY (`site_search_id`) REFERENCES `site_search` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_search_stats`
--

LOCK TABLES `site_search_stats` WRITE;
/*!40000 ALTER TABLE `site_search_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_search_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_search_url`
--

DROP TABLE IF EXISTS `site_search_url`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_search_url` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `site_search_id` int(11) DEFAULT NULL,
  `url` text COLLATE utf8_unicode_ci,
  `title` text COLLATE utf8_unicode_ci,
  `description` text COLLATE utf8_unicode_ci,
  `summary` text COLLATE utf8_unicode_ci,
  `file_size` int(11) DEFAULT NULL,
  `error_code` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_tracking_present` tinyint(1) NOT NULL DEFAULT '0',
  `is_google_analytics_present` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `site_search_url_FI_1` (`account_id`),
  KEY `site_search_url_FI_2` (`site_search_id`),
  CONSTRAINT `site_search_url_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `site_search_url_FK_2` FOREIGN KEY (`site_search_id`) REFERENCES `site_search` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_search_url`
--

LOCK TABLES `site_search_url` WRITE;
/*!40000 ALTER TABLE `site_search_url` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_search_url` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_search_url_keyword`
--

DROP TABLE IF EXISTS `site_search_url_keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_search_url_keyword` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `site_search_url_id` int(11) DEFAULT NULL,
  `keyword` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `weight` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `site_search_url_keyword_FI_1` (`account_id`),
  KEY `site_search_url_keyword_FI_2` (`site_search_url_id`),
  CONSTRAINT `site_search_url_keyword_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `site_search_url_keyword_FK_2` FOREIGN KEY (`site_search_url_id`) REFERENCES `site_search_url` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_search_url_keyword`
--

LOCK TABLES `site_search_url_keyword` WRITE;
/*!40000 ALTER TABLE `site_search_url_keyword` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_search_url_keyword` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_stats`
--

DROP TABLE IF EXISTS `site_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `stats_date` date NOT NULL,
  `score` int(11) DEFAULT NULL,
  `group1_1` int(11) DEFAULT NULL,
  `group1_2` int(11) DEFAULT NULL,
  `group1_3` int(11) DEFAULT NULL,
  `group1_4` int(11) DEFAULT NULL,
  `group1_5` int(11) DEFAULT NULL,
  `group1_6` int(11) DEFAULT NULL,
  `group1_7` int(11) DEFAULT NULL,
  `group1_8` int(11) DEFAULT NULL,
  `group1_9` int(11) DEFAULT NULL,
  `group1_10` int(11) DEFAULT NULL,
  `group2_1` int(11) DEFAULT NULL,
  `group2_2` int(11) DEFAULT NULL,
  `group2_3` int(11) DEFAULT NULL,
  `group2_4` int(11) DEFAULT NULL,
  `group2_5` int(11) DEFAULT NULL,
  `group2_6` int(11) DEFAULT NULL,
  `group2_7` int(11) DEFAULT NULL,
  `group2_8` int(11) DEFAULT NULL,
  `group2_9` int(11) DEFAULT NULL,
  `group2_10` int(11) DEFAULT NULL,
  `is_current` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_stats_lookup` (`site_id`,`stats_date`),
  KEY `site_stats_FI_1` (`account_id`),
  CONSTRAINT `site_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `site_stats_FK_2` FOREIGN KEY (`site_id`) REFERENCES `site` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_stats`
--

LOCK TABLES `site_stats` WRITE;
/*!40000 ALTER TABLE `site_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_message`
--

DROP TABLE IF EXISTS `social_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `social_message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `extras` text COLLATE utf8_unicode_ci,
  `sent_at` datetime DEFAULT NULL,
  `scheduled_for` datetime DEFAULT NULL,
  `sent` tinyint(4) DEFAULT NULL,
  `is_archived` tinyint(4) NOT NULL DEFAULT '0',
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `last_failed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `social_message_FI_1` (`account_id`),
  KEY `social_message_FI_2` (`campaign_id`),
  KEY `social_message_FI_3` (`created_by`),
  KEY `social_message_FI_4` (`updated_by`),
  CONSTRAINT `social_message_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `social_message_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `social_message_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `social_message_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_message`
--

LOCK TABLES `social_message` WRITE;
/*!40000 ALTER TABLE `social_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `social_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_message_connector`
--

DROP TABLE IF EXISTS `social_message_connector`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `social_message_connector` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) DEFAULT NULL,
  `social_message_id` int(11) DEFAULT NULL,
  `company_page_id` int(11) DEFAULT NULL,
  `company_page_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `social_message_connector_FI_1` (`account_id`),
  KEY `social_message_connector_FI_2` (`connector_id`),
  KEY `social_message_connector_FI_3` (`social_message_id`),
  CONSTRAINT `social_message_connector_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `social_message_connector_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `social_message_connector_FK_3` FOREIGN KEY (`social_message_id`) REFERENCES `social_message` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_message_connector`
--

LOCK TABLES `social_message_connector` WRITE;
/*!40000 ALTER TABLE `social_message_connector` DISABLE KEYS */;
/*!40000 ALTER TABLE `social_message_connector` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_message_connector_error`
--

DROP TABLE IF EXISTS `social_message_connector_error`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `social_message_connector_error` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `social_message_connector_id` int(11) DEFAULT NULL,
  `error_message` text COLLATE utf8_unicode_ci,
  `acknowledged_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `social_message_connector_error_FI_1` (`account_id`),
  KEY `social_message_connector_error_FI_2` (`social_message_connector_id`),
  CONSTRAINT `social_message_connector_error_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `social_message_connector_error_FK_2` FOREIGN KEY (`social_message_connector_id`) REFERENCES `social_message_connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_message_connector_error`
--

LOCK TABLES `social_message_connector_error` WRITE;
/*!40000 ALTER TABLE `social_message_connector_error` DISABLE KEYS */;
/*!40000 ALTER TABLE `social_message_connector_error` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_message_connector_error_recovery_action`
--

DROP TABLE IF EXISTS `social_message_connector_error_recovery_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `social_message_connector_error_recovery_action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `social_message_connector_error_id` int(11) NOT NULL,
  `action` tinyint(4) NOT NULL,
  `recovery_date` datetime DEFAULT NULL,
  `recovered` tinyint(4) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `social_message_connector_error_recovery_action_recovered_index` (`recovered`),
  KEY `social_message_connector_error_recovery_action_FI_1` (`account_id`),
  KEY `social_message_connector_error_recovery_action_FI_2` (`social_message_connector_error_id`),
  KEY `social_message_connector_error_recovery_action_FI_3` (`created_by`),
  KEY `social_message_connector_error_recovery_action_FI_4` (`updated_by`),
  CONSTRAINT `social_message_connector_error_recovery_action_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `social_message_connector_error_recovery_action_FK_2` FOREIGN KEY (`social_message_connector_error_id`) REFERENCES `social_message_connector_error` (`id`),
  CONSTRAINT `social_message_connector_error_recovery_action_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `social_message_connector_error_recovery_action_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_message_connector_error_recovery_action`
--

LOCK TABLES `social_message_connector_error_recovery_action` WRITE;
/*!40000 ALTER TABLE `social_message_connector_error_recovery_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `social_message_connector_error_recovery_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_message_link`
--

DROP TABLE IF EXISTS `social_message_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `social_message_link` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `social_message_id` int(11) DEFAULT NULL,
  `social_message_connector_id` int(11) DEFAULT NULL,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `dest_url` text COLLATE utf8_unicode_ci,
  `bitly_url_id` int(11) DEFAULT NULL,
  `is_archived` tinyint(4) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `social_message_link_FI_1` (`account_id`),
  KEY `social_message_link_FI_2` (`social_message_id`),
  KEY `social_message_link_FI_3` (`social_message_connector_id`),
  KEY `social_message_link_FI_4` (`bitly_url_id`),
  KEY `social_message_link_FI_5` (`created_by`),
  KEY `social_message_link_FI_6` (`updated_by`),
  CONSTRAINT `social_message_link_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `social_message_link_FK_2` FOREIGN KEY (`social_message_id`) REFERENCES `social_message` (`id`),
  CONSTRAINT `social_message_link_FK_3` FOREIGN KEY (`social_message_connector_id`) REFERENCES `social_message_connector` (`id`),
  CONSTRAINT `social_message_link_FK_4` FOREIGN KEY (`bitly_url_id`) REFERENCES `bitly_url` (`id`),
  CONSTRAINT `social_message_link_FK_5` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `social_message_link_FK_6` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_message_link`
--

LOCK TABLES `social_message_link` WRITE;
/*!40000 ALTER TABLE `social_message_link` DISABLE KEYS */;
/*!40000 ALTER TABLE `social_message_link` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_message_link_stats`
--

DROP TABLE IF EXISTS `social_message_link_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `social_message_link_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `social_message_link_id` int(11) DEFAULT NULL,
  `stats_date` date DEFAULT NULL,
  `unique_clicks` int(11) DEFAULT '0',
  `total_clicks` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `social_message_link_stats_FI_1` (`account_id`),
  KEY `social_message_link_stats_FI_2` (`campaign_id`),
  KEY `social_message_link_stats_FI_3` (`social_message_link_id`),
  CONSTRAINT `social_message_link_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `social_message_link_stats_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `social_message_link_stats_FK_3` FOREIGN KEY (`social_message_link_id`) REFERENCES `social_message_link` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_message_link_stats`
--

LOCK TABLES `social_message_link_stats` WRITE;
/*!40000 ALTER TABLE `social_message_link_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `social_message_link_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_message_stats`
--

DROP TABLE IF EXISTS `social_message_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `social_message_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `social_message_id` int(11) NOT NULL,
  `clicks` int(11) DEFAULT '0',
  `unique_clicks` int(11) DEFAULT '0',
  `likes` int(11) DEFAULT '0',
  `comments` int(11) DEFAULT '0',
  `twitter_likes` int(11) DEFAULT '0',
  `twitter_comments` int(11) DEFAULT '0',
  `facebook_likes` int(11) DEFAULT '0',
  `facebook_comments` int(11) DEFAULT '0',
  `linkedin_likes` int(11) DEFAULT '0',
  `linkedin_comments` int(11) DEFAULT '0',
  `stats_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `social_message_stats_FI_1` (`account_id`),
  KEY `social_message_stats_FI_2` (`social_message_id`),
  CONSTRAINT `social_message_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `social_message_stats_FK_2` FOREIGN KEY (`social_message_id`) REFERENCES `social_message` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_message_stats`
--

LOCK TABLES `social_message_stats` WRITE;
/*!40000 ALTER TABLE `social_message_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `social_message_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `spam_complaint_stats`
--

DROP TABLE IF EXISTS `spam_complaint_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `spam_complaint_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `type` int(11) DEFAULT '11',
  `total` int(11) DEFAULT '0',
  `stats_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `spam_complaint_lookup` (`account_id`,`type`,`stats_date`),
  CONSTRAINT `spam_complaint_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `spam_complaint_stats`
--

LOCK TABLES `spam_complaint_stats` WRITE;
/*!40000 ALTER TABLE `spam_complaint_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `spam_complaint_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `static_variable`
--

DROP TABLE IF EXISTS `static_variable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `static_variable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` text COLLATE utf8_unicode_ci,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`account_id`,`name`),
  KEY `static_variable_FI_2` (`created_by`),
  KEY `static_variable_FI_3` (`updated_by`),
  CONSTRAINT `static_variable_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `static_variable_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `static_variable_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `static_variable`
--

LOCK TABLES `static_variable` WRITE;
/*!40000 ALTER TABLE `static_variable` DISABLE KEYS */;
/*!40000 ALTER TABLE `static_variable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_email`
--

DROP TABLE IF EXISTS `system_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_email` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `text_message` mediumtext COLLATE utf8_unicode_ci,
  `html_message` mediumtext COLLATE utf8_unicode_ci,
  `is_queued` int(11) DEFAULT '0',
  `is_being_processed` int(11) DEFAULT '0',
  `is_sent` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `system_email_FI_1` (`account_id`),
  CONSTRAINT `system_email_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_email`
--

LOCK TABLES `system_email` WRITE;
/*!40000 ALTER TABLE `system_email` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object_count` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`account_id`,`name`),
  KEY `tag_FI_2` (`created_by`),
  KEY `tag_FI_3` (`updated_by`),
  CONSTRAINT `tag_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `tag_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `tag_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag`
--

LOCK TABLES `tag` WRITE;
/*!40000 ALTER TABLE `tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag_object`
--

DROP TABLE IF EXISTS `tag_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `fk_id` int(11) NOT NULL,
  `object_name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object_created_at` datetime DEFAULT NULL,
  `object_is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_object` (`account_id`,`tag_id`,`type`,`fk_id`),
  KEY `tag_object_FI_2` (`tag_id`),
  KEY `tag_object_FI_3` (`created_by`),
  CONSTRAINT `tag_object_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `tag_object_FK_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`),
  CONSTRAINT `tag_object_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag_object`
--

LOCK TABLES `tag_object` WRITE;
/*!40000 ALTER TABLE `tag_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `tag_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag_object_audit`
--

DROP TABLE IF EXISTS `tag_object_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag_object_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `tag_object_id` int(11) NOT NULL,
  `removed_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tag_object_audit_FI_1` (`account_id`),
  CONSTRAINT `tag_object_audit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag_object_audit`
--

LOCK TABLES `tag_object_audit` WRITE;
/*!40000 ALTER TABLE `tag_object_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `tag_object_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thumbnail`
--

DROP TABLE IF EXISTS `thumbnail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `thumbnail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `s3_key` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `uri` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `thumbnail_FI_1` (`account_id`),
  KEY `thumbnail_FI_2` (`created_by`),
  KEY `thumbnail_FI_3` (`updated_by`),
  CONSTRAINT `thumbnail_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `thumbnail_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `thumbnail_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thumbnail`
--

LOCK TABLES `thumbnail` WRITE;
/*!40000 ALTER TABLE `thumbnail` DISABLE KEYS */;
/*!40000 ALTER TABLE `thumbnail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `top_company_page_view_count`
--

DROP TABLE IF EXISTS `top_company_page_view_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `top_company_page_view_count` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `stats_date` date DEFAULT NULL,
  `stats_hour` int(11) DEFAULT NULL,
  `page_view_count` int(11) DEFAULT NULL,
  `company_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_date_hour_company` (`account_id`,`stats_date`,`stats_hour`,`company_name`),
  CONSTRAINT `top_company_page_view_count_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `top_company_page_view_count`
--

LOCK TABLES `top_company_page_view_count` WRITE;
/*!40000 ALTER TABLE `top_company_page_view_count` DISABLE KEYS */;
/*!40000 ALTER TABLE `top_company_page_view_count` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tracker`
--

DROP TABLE IF EXISTS `tracker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tracker` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `email_id` int(11) DEFAULT NULL,
  `email_template_id` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `form_handler_id` int(11) DEFAULT NULL,
  `landing_page_id` int(11) DEFAULT NULL,
  `multivariate_test_id` int(11) DEFAULT NULL,
  `block_id` int(11) DEFAULT NULL,
  `personalization_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `tracker_redirect_id` int(11) DEFAULT NULL,
  `filex_id` int(11) DEFAULT NULL,
  `custom_url_id` int(11) DEFAULT NULL,
  `social_message_link_id` int(11) DEFAULT NULL,
  `value` varchar(25) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lookup_key` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_email_tracker_redirect` (`account_id`,`email_id`,`tracker_redirect_id`),
  KEY `account_email_template_tracker_redirect` (`account_id`,`email_template_id`,`tracker_redirect_id`),
  KEY `tracker_FI_2` (`campaign_id`),
  KEY `tracker_FI_3` (`email_id`),
  KEY `tracker_FI_4` (`email_template_id`),
  KEY `tracker_FI_5` (`form_id`),
  KEY `tracker_FI_6` (`form_handler_id`),
  KEY `tracker_FI_7` (`landing_page_id`),
  KEY `tracker_FI_8` (`multivariate_test_id`),
  KEY `tracker_FI_9` (`block_id`),
  KEY `tracker_FI_10` (`personalization_id`),
  KEY `tracker_FI_11` (`prospect_id`),
  KEY `tracker_FI_12` (`visitor_id`),
  KEY `tracker_FI_13` (`tracker_redirect_id`),
  KEY `tracker_FI_14` (`filex_id`),
  KEY `tracker_FI_15` (`custom_url_id`),
  KEY `tracker_FI_16` (`social_message_link_id`),
  KEY `tracker_FI_17` (`created_by`),
  CONSTRAINT `tracker_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `tracker_FK_10` FOREIGN KEY (`personalization_id`) REFERENCES `personalization` (`id`),
  CONSTRAINT `tracker_FK_11` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `tracker_FK_12` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `tracker_FK_13` FOREIGN KEY (`tracker_redirect_id`) REFERENCES `tracker_redirect` (`id`),
  CONSTRAINT `tracker_FK_14` FOREIGN KEY (`filex_id`) REFERENCES `filex` (`id`),
  CONSTRAINT `tracker_FK_15` FOREIGN KEY (`custom_url_id`) REFERENCES `custom_url` (`id`),
  CONSTRAINT `tracker_FK_16` FOREIGN KEY (`social_message_link_id`) REFERENCES `social_message_link` (`id`),
  CONSTRAINT `tracker_FK_17` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `tracker_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `tracker_FK_3` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `tracker_FK_4` FOREIGN KEY (`email_template_id`) REFERENCES `email_template` (`id`),
  CONSTRAINT `tracker_FK_5` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `tracker_FK_6` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`),
  CONSTRAINT `tracker_FK_7` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `tracker_FK_8` FOREIGN KEY (`multivariate_test_id`) REFERENCES `multivariate_test` (`id`),
  CONSTRAINT `tracker_FK_9` FOREIGN KEY (`block_id`) REFERENCES `block` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tracker`
--

LOCK TABLES `tracker` WRITE;
/*!40000 ALTER TABLE `tracker` DISABLE KEYS */;
INSERT INTO `tracker` VALUES (1,2,1,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2i','2016-03-24',NULL,'2016-03-24 16:07:14');
/*!40000 ALTER TABLE `tracker` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tracker_external_key`
--

DROP TABLE IF EXISTS `tracker_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tracker_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_tracker_id` FOREIGN KEY (`id`) REFERENCES `tracker` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tracker_external_key`
--

LOCK TABLES `tracker_external_key` WRITE;
/*!40000 ALTER TABLE `tracker_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `tracker_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tracker_redirect`
--

DROP TABLE IF EXISTS `tracker_redirect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tracker_redirect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `redirect_location` text COLLATE utf8_unicode_ci,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tracker_redirect_FI_1` (`account_id`),
  KEY `tracker_redirect_FI_2` (`campaign_id`),
  KEY `tracker_redirect_FI_3` (`created_by`),
  KEY `tracker_redirect_FI_4` (`updated_by`),
  CONSTRAINT `tracker_redirect_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `tracker_redirect_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `tracker_redirect_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `tracker_redirect_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tracker_redirect`
--

LOCK TABLES `tracker_redirect` WRITE;
/*!40000 ALTER TABLE `tracker_redirect` DISABLE KEYS */;
/*!40000 ALTER TABLE `tracker_redirect` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `twilio_call`
--

DROP TABLE IF EXISTS `twilio_call`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `twilio_call` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `call_type` int(11) NOT NULL,
  `call_sid` varchar(34) COLLATE utf8_unicode_ci DEFAULT NULL,
  `recording_sid` varchar(34) COLLATE utf8_unicode_ci DEFAULT NULL,
  `account_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `status` int(11) DEFAULT '0',
  `do_record` int(11) DEFAULT '0',
  `is_finished` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `twilio_call_FI_1` (`account_id`),
  KEY `twilio_call_FI_2` (`prospect_id`),
  KEY `twilio_call_FI_3` (`user_id`),
  CONSTRAINT `twilio_call_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `twilio_call_FK_2` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `twilio_call_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `twilio_call`
--

LOCK TABLES `twilio_call` WRITE;
/*!40000 ALTER TABLE `twilio_call` DISABLE KEYS */;
/*!40000 ALTER TABLE `twilio_call` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `twilio_form_notify`
--

DROP TABLE IF EXISTS `twilio_form_notify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `twilio_form_notify` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `is_wizard` int(11) NOT NULL,
  `form_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `wizard_id` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `twilio_form_notify_FI_1` (`account_id`),
  KEY `twilio_form_notify_FI_2` (`form_id`),
  KEY `twilio_form_notify_FI_3` (`user_id`),
  KEY `twilio_form_notify_FI_4` (`wizard_id`),
  CONSTRAINT `twilio_form_notify_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `twilio_form_notify_FK_2` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `twilio_form_notify_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `twilio_form_notify_FK_4` FOREIGN KEY (`wizard_id`) REFERENCES `wizard` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `twilio_form_notify`
--

LOCK TABLES `twilio_form_notify` WRITE;
/*!40000 ALTER TABLE `twilio_form_notify` DISABLE KEYS */;
/*!40000 ALTER TABLE `twilio_form_notify` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unsubscribe_page`
--

DROP TABLE IF EXISTS `unsubscribe_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unsubscribe_page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `layout_template_id` int(11) DEFAULT NULL,
  `custom_unsubscribe_success` text COLLATE utf8_unicode_ci,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_uniq_account` (`account_id`),
  KEY `unsubscribe_page_FI_2` (`layout_template_id`),
  KEY `unsubscribe_page_FI_3` (`updated_by`),
  CONSTRAINT `unsubscribe_page_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `unsubscribe_page_FK_2` FOREIGN KEY (`layout_template_id`) REFERENCES `layout_template` (`id`),
  CONSTRAINT `unsubscribe_page_FK_3` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unsubscribe_page`
--

LOCK TABLES `unsubscribe_page` WRITE;
/*!40000 ALTER TABLE `unsubscribe_page` DISABLE KEYS */;
INSERT INTO `unsubscribe_page` VALUES (1,2,'Unsubscribe Successful','Unsubscribe Page',1,NULL,0,NULL,'2016-03-24 16:07:14','2016-03-24 16:07:14');
/*!40000 ALTER TABLE `unsubscribe_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `updated_object`
--

DROP TABLE IF EXISTS `updated_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `updated_object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `object_type` int(11) NOT NULL,
  `change_type` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `updated_object_FI_1` (`account_id`),
  CONSTRAINT `updated_object_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `updated_object`
--

LOCK TABLES `updated_object` WRITE;
/*!40000 ALTER TABLE `updated_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `updated_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `email` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `username` varchar(80) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_name` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `job_title` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` text COLLATE utf8_unicode_ci,
  `html_email_signature` text COLLATE utf8_unicode_ci,
  `text_email_signature` text COLLATE utf8_unicode_ci,
  `role` int(11) NOT NULL,
  `custom_role_id` int(11) DEFAULT NULL,
  `rss_key` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password_expires_at` datetime DEFAULT NULL,
  `is_password_expirable` tinyint(1) NOT NULL DEFAULT '0',
  `is_billing_contact` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `crm_username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crm_user_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_crm_synced` int(11) DEFAULT '0',
  `is_crm_username_verified` tinyint(1) NOT NULL DEFAULT '0',
  `timezone` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale_code` varchar(40) COLLATE utf8_unicode_ci DEFAULT 'en_US',
  `language_code` varchar(40) COLLATE utf8_unicode_ci DEFAULT 'en_US',
  `email_encoding_code` varchar(40) COLLATE utf8_unicode_ci DEFAULT 'ISO-8859-1',
  `is_active` int(11) DEFAULT '0',
  `password_question_id` int(11) DEFAULT NULL,
  `encrypted_password_answer` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password_last_reset_at` datetime DEFAULT NULL,
  `activation_hash` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `activation_hash_date` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_username_unique` (`username`),
  KEY `user_account_id_email_index` (`account_id`,`email`),
  KEY `user_FI_2` (`custom_role_id`),
  KEY `user_FI_3` (`created_by`),
  KEY `user_FI_4` (`updated_by`),
  CONSTRAINT `user_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `user_FK_2` FOREIGN KEY (`custom_role_id`) REFERENCES `custom_role` (`id`),
  CONSTRAINT `user_FK_3` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `user_FK_4` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=315 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,1,'support@pardot.com',NULL,NULL,'Pardot','Support',NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,0,0,0,NULL,NULL,0,0,'America/New_York','en_US','en_US','ISO-8859-1',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(9,2,'marketing@ecsoftware.com','marketing@ecsoftware.com','$2a$12$QB7zOEM1QE8SdXvC3JevFunUewoRo7xEeammFOfi/u0phuQAcyI4e','ecs Marketing','Manager',NULL,NULL,NULL,NULL,NULL,2,NULL,'ec8ffc764e7ced04ec2012d1a90b33f8','2012-09-09 12:00:00',0,1,0,'eval@prospect_insight.demo',NULL,0,1,'America/New_York','en_US','en_US','ISO-8859-1',1,1,'$1:uxXH+MhnHS2X6zm+foJ7LI2Q7eBO8GICpcFmwJi9g/Q=:SlRWxv3NOasIuelwlncqNN8a02L+Nd35yhm8I7aRaEE=',NULL,'$2a$12$hm44Vduzpg4Imrp4x6YEJ.NtUg//zfBG1O02xqK0ThXMANYoKiw2G','2016-03-24 16:07:15',NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(10,2,'coordinator@ecsoftware.com','coordinator@ecsoftware.com','$2a$12$c/vMBrP.TxMZoYB6BoM6zu2Au0OqHVPQ.tugSrLZE4lZakSzHRaf6','Marketing','Coordinator',NULL,NULL,NULL,NULL,NULL,3,NULL,'ec8ffc764e7ced04ec2012d1a90b33f8','2012-09-09 12:00:00',0,0,0,'marketing.coordinator',NULL,0,0,'America/Los_Angeles','en_US','en_US','ISO-8859-1',1,1,'$1:K0EAVWRrGHFlqj+v8cYRe8JnCoeXb2hkOknIt7fS9+M=:zMog6vb3si9Zu/omzO84rjoR54xocvtyexiN1H7MWXU=',NULL,'$2a$12$vAE8lqul8.oHu0OZYRFTbuErG9p0JuyGsXEGPrK0Q9DcSdbu/3ibW','2016-03-24 16:07:15',NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(11,2,'sales@ecsoftware.com','sales@ecsoftware.com','$2a$12$vOOGjCaLLy.ftO8lzQzs9eh3kEyMnnBF3rpOdHgGiVr96Mhffe5qi','ECS Sales','Rep A',NULL,NULL,NULL,NULL,NULL,4,NULL,'b36db4f64f5c1f35bf9b03d44a034396','2012-09-09 12:00:00',0,0,0,'sales.rep',NULL,0,0,'America/Chicago','en_US','en_US','ISO-8859-1',1,1,'$1:Yypt9pVzMRL65H6rKJjoA1IOwoABJJzhQW012bQCUx8=:VevK9R6OOrwqAJKI1LH5rx/R0rlgnOfCJJEJ1xkACQw=',NULL,'$2a$12$igIl119n2w.IS0NvXUoZ6OnuqEAZZUrXM4HbyZxR3M4F9HqdeD8US','2016-03-24 16:07:15',NULL,NULL,'2007-07-29 10:42:51','2007-07-29 10:42:51'),(314,1,'agency',NULL,'nonvalidpassword','Agency','',NULL,NULL,NULL,NULL,NULL,2,NULL,'rss_key',NULL,0,0,0,NULL,NULL,0,0,'America/New_York','en_US','en_US','ISO-8859-1',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2016-03-24 16:07:16','2016-03-24 16:07:16');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_email`
--

DROP TABLE IF EXISTS `user_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_email` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `email_message_id` int(11) DEFAULT NULL,
  `is_queued` tinyint(1) NOT NULL DEFAULT '0',
  `is_sent` tinyint(1) NOT NULL DEFAULT '0',
  `is_draft` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_email_FI_1` (`account_id`),
  KEY `user_email_FI_2` (`campaign_id`),
  KEY `user_email_FI_3` (`user_id`),
  KEY `user_email_FI_4` (`email_message_id`),
  CONSTRAINT `user_email_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `user_email_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `user_email_FK_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `user_email_FK_4` FOREIGN KEY (`email_message_id`) REFERENCES `email_message` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_email`
--

LOCK TABLES `user_email` WRITE;
/*!40000 ALTER TABLE `user_email` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_email_stats`
--

DROP TABLE IF EXISTS `user_email_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_email_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `one_to_one_emails` int(11) DEFAULT '0',
  `mc_emails` int(11) DEFAULT '0',
  `stats_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_email_stats_lookup` (`user_id`,`stats_date`),
  UNIQUE KEY `user_email_stats_lookup_1` (`account_id`,`user_id`,`stats_date`),
  CONSTRAINT `user_email_stats_FK_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `user_email_stats_FK_2` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_email_stats`
--

LOCK TABLES `user_email_stats` WRITE;
/*!40000 ALTER TABLE `user_email_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_email_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_password`
--

DROP TABLE IF EXISTS `user_password`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_password` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `password` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_password_FI_1` (`account_id`),
  KEY `user_password_FI_2` (`user_id`),
  CONSTRAINT `user_password_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `user_password_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_password`
--

LOCK TABLES `user_password` WRITE;
/*!40000 ALTER TABLE `user_password` DISABLE KEYS */;
INSERT INTO `user_password` VALUES (1,2,9,'$2a$12$QB7zOEM1QE8SdXvC3JevFunUewoRo7xEeammFOfi/u0phuQAcyI4e','2016-03-24 16:07:15'),(2,2,10,'$2a$12$c/vMBrP.TxMZoYB6BoM6zu2Au0OqHVPQ.tugSrLZE4lZakSzHRaf6','2016-03-24 16:07:15'),(3,2,11,'$2a$12$vOOGjCaLLy.ftO8lzQzs9eh3kEyMnnBF3rpOdHgGiVr96Mhffe5qi','2016-03-24 16:07:15');
/*!40000 ALTER TABLE `user_password` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_setting`
--

DROP TABLE IF EXISTS `user_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_setting` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `setting_key` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `setting_value` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`account_id`,`user_id`,`setting_key`),
  KEY `user_setting_FI_2` (`user_id`),
  CONSTRAINT `user_setting_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `user_setting_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_setting`
--

LOCK TABLES `user_setting` WRITE;
/*!40000 ALTER TABLE `user_setting` DISABLE KEYS */;
INSERT INTO `user_setting` VALUES (1,2,9,'SendGlobalProspectActivityEmail',''),(2,2,9,'SendMessageDigest',''),(3,2,9,'SendPRospectActivityEmail','1'),(4,2,9,'SendProspectAssignEmail','1'),(5,2,9,'SendStarredProspectActivityAlert','1'),(6,2,9,'SendSearchMarketingEmail',''),(7,2,9,'SendVisitorActivityEmail',''),(8,2,10,'SendGlobalProspectActivityEmail',''),(9,2,10,'SendMessageDigest',''),(10,2,10,'SendPRospectActivityEmail','1'),(11,2,10,'SendProspectAssignEmail','1'),(12,2,10,'SendStarredProspectActivityAlert','1'),(13,2,10,'SendSearchMarketingEmail',''),(14,2,10,'SendVisitorActivityEmail',''),(15,2,11,'SendGlobalProspectActivityEmail',''),(16,2,11,'SendMessageDigest',''),(17,2,11,'SendPRospectActivityEmail','1'),(18,2,11,'SendProspectAssignEmail','1'),(19,2,11,'SendStarredProspectActivityAlert','1'),(20,2,11,'SendSearchMarketingEmail',''),(21,2,11,'SendVisitorActivityEmail','');
/*!40000 ALTER TABLE `user_setting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_widget_state`
--

DROP TABLE IF EXISTS `user_widget_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_widget_state` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `widget_id` binary(2) NOT NULL,
  `meta_data` longblob NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`account_id`,`user_id`,`widget_id`),
  KEY `user_widget_state_FI_2` (`user_id`),
  CONSTRAINT `user_widget_state_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `user_widget_state_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_widget_state`
--

LOCK TABLES `user_widget_state` WRITE;
/*!40000 ALTER TABLE `user_widget_state` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_widget_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uservoice_comment`
--

DROP TABLE IF EXISTS `uservoice_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uservoice_comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `uservoice_suggestion_id` int(11) NOT NULL,
  `fid` int(11) DEFAULT NULL,
  `user_email` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `text` text COLLATE utf8_unicode_ci,
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uservoice_comment_FI_1` (`account_id`),
  KEY `uservoice_comment_FI_2` (`connector_id`),
  KEY `uservoice_comment_FI_3` (`uservoice_suggestion_id`),
  KEY `uservoice_comment_FI_4` (`prospect_id`),
  CONSTRAINT `uservoice_comment_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `uservoice_comment_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `uservoice_comment_FK_3` FOREIGN KEY (`uservoice_suggestion_id`) REFERENCES `uservoice_suggestion` (`id`),
  CONSTRAINT `uservoice_comment_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uservoice_comment`
--

LOCK TABLES `uservoice_comment` WRITE;
/*!40000 ALTER TABLE `uservoice_comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `uservoice_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uservoice_forum`
--

DROP TABLE IF EXISTS `uservoice_forum`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uservoice_forum` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `url` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fid` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uservoice_forum_FI_1` (`account_id`),
  KEY `uservoice_forum_FI_2` (`connector_id`),
  CONSTRAINT `uservoice_forum_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `uservoice_forum_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uservoice_forum`
--

LOCK TABLES `uservoice_forum` WRITE;
/*!40000 ALTER TABLE `uservoice_forum` DISABLE KEYS */;
/*!40000 ALTER TABLE `uservoice_forum` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uservoice_suggestion`
--

DROP TABLE IF EXISTS `uservoice_suggestion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uservoice_suggestion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `uservoice_forum_id` int(11) NOT NULL,
  `forum_fid` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fid` int(11) DEFAULT NULL,
  `user_email` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `title` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `text` text COLLATE utf8_unicode_ci,
  `url` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `vote_count` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uservoice_suggestion_FI_1` (`account_id`),
  KEY `uservoice_suggestion_FI_2` (`connector_id`),
  KEY `uservoice_suggestion_FI_3` (`uservoice_forum_id`),
  KEY `uservoice_suggestion_FI_4` (`prospect_id`),
  CONSTRAINT `uservoice_suggestion_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `uservoice_suggestion_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `uservoice_suggestion_FK_3` FOREIGN KEY (`uservoice_forum_id`) REFERENCES `uservoice_forum` (`id`),
  CONSTRAINT `uservoice_suggestion_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uservoice_suggestion`
--

LOCK TABLES `uservoice_suggestion` WRITE;
/*!40000 ALTER TABLE `uservoice_suggestion` DISABLE KEYS */;
/*!40000 ALTER TABLE `uservoice_suggestion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uservoice_ticket`
--

DROP TABLE IF EXISTS `uservoice_ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uservoice_ticket` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `fid` int(11) DEFAULT NULL,
  `ticket_number` int(11) DEFAULT NULL,
  `user_email` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `assigned_to_name` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subject` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `text` text COLLATE utf8_unicode_ci,
  `state` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uservoice_ticket_FI_1` (`account_id`),
  KEY `uservoice_ticket_FI_2` (`connector_id`),
  KEY `uservoice_ticket_FI_3` (`prospect_id`),
  CONSTRAINT `uservoice_ticket_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `uservoice_ticket_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`),
  CONSTRAINT `uservoice_ticket_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uservoice_ticket`
--

LOCK TABLES `uservoice_ticket` WRITE;
/*!40000 ALTER TABLE `uservoice_ticket` DISABLE KEYS */;
/*!40000 ALTER TABLE `uservoice_ticket` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vanity_url`
--

DROP TABLE IF EXISTS `vanity_url`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vanity_url` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `url` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` int(11) NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_url` (`account_id`,`url`),
  KEY `vanity_url_FI_2` (`created_by`),
  CONSTRAINT `vanity_url_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `vanity_url_FK_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vanity_url`
--

LOCK TABLES `vanity_url` WRITE;
/*!40000 ALTER TABLE `vanity_url` DISABLE KEYS */;
/*!40000 ALTER TABLE `vanity_url` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `video`
--

DROP TABLE IF EXISTS `video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `video` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `fid` int(11) DEFAULT NULL,
  `hashed_fid` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `connector_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `thumbnail_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `plays` int(11) DEFAULT NULL,
  `page_loads` int(11) DEFAULT NULL,
  `visitors` int(11) DEFAULT NULL,
  `play_percentage` int(11) DEFAULT NULL,
  `watched_average` int(11) DEFAULT NULL,
  `is_archived` int(11) DEFAULT '0',
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `video_FI_1` (`account_id`),
  KEY `video_FI_2` (`connector_id`),
  CONSTRAINT `video_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `video_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video`
--

LOCK TABLES `video` WRITE;
/*!40000 ALTER TABLE `video` DISABLE KEYS */;
/*!40000 ALTER TABLE `video` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `video_activity`
--

DROP TABLE IF EXISTS `video_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `video_activity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `video_id` int(11) NOT NULL,
  `visitor_activity_id` int(11) NOT NULL,
  `activity_type` int(11) DEFAULT NULL,
  `visitor_key` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `event_key` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `watched_percent` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pulled_at` datetime DEFAULT NULL,
  `needs_pull_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `video_activity_FI_1` (`account_id`),
  KEY `video_activity_FI_2` (`video_id`),
  KEY `video_activity_FI_3` (`visitor_activity_id`),
  CONSTRAINT `video_activity_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `video_activity_FK_2` FOREIGN KEY (`video_id`) REFERENCES `video` (`id`),
  CONSTRAINT `video_activity_FK_3` FOREIGN KEY (`visitor_activity_id`) REFERENCES `visitor_activity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_activity`
--

LOCK TABLES `video_activity` WRITE;
/*!40000 ALTER TABLE `video_activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `video_activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `video_stats`
--

DROP TABLE IF EXISTS `video_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `video_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `video_id` int(11) NOT NULL,
  `page_loads` int(11) DEFAULT '0',
  `plays` int(11) DEFAULT '0',
  `play_percentage` int(11) DEFAULT '0',
  `prospects` int(11) DEFAULT '0',
  `visitors` int(11) DEFAULT '0',
  `watched_average` int(11) DEFAULT '0',
  `conversions` int(11) DEFAULT '0',
  `stats_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stats_lookup` (`account_id`,`video_id`,`stats_date`),
  KEY `video_stats_FI_2` (`video_id`),
  CONSTRAINT `video_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `video_stats_FK_2` FOREIGN KEY (`video_id`) REFERENCES `video` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_stats`
--

LOCK TABLES `video_stats` WRITE;
/*!40000 ALTER TABLE `video_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `video_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visit`
--

DROP TABLE IF EXISTS `visit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `visitor_id` int(11) NOT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `is_filtered` int(11) NOT NULL DEFAULT '0',
  `visitor_page_view_count` int(11) NOT NULL DEFAULT '0',
  `first_visitor_page_view_id` int(11) NOT NULL,
  `first_visitor_page_view_at` datetime NOT NULL,
  `last_visitor_page_view_id` int(11) NOT NULL,
  `last_visitor_page_view_at` datetime NOT NULL,
  `duration_in_seconds` int(11) NOT NULL DEFAULT '0',
  `is_complete` int(11) NOT NULL DEFAULT '0',
  `last_synced_at` datetime DEFAULT NULL,
  `crm_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `campaign_parameter` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `medium_parameter` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_parameter` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content_parameter` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `term_parameter` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `visit_first_visitor_page_view_id_unique` (`first_visitor_page_view_id`),
  UNIQUE KEY `visit_last_visitor_page_view_id_unique` (`last_visitor_page_view_id`),
  KEY `visit_index_5` (`account_id`,`visitor_page_view_count`),
  KEY `visit_index_6` (`account_id`,`first_visitor_page_view_at`),
  KEY `visit_index_7` (`account_id`,`last_visitor_page_view_at`),
  KEY `visit_index_8` (`account_id`,`duration_in_seconds`),
  KEY `visit_index_13` (`visitor_id`,`is_complete`),
  KEY `visit_index_18` (`account_id`,`is_filtered`,`visitor_page_view_count`),
  KEY `visit_index_19` (`account_id`,`is_filtered`,`first_visitor_page_view_at`),
  KEY `visit_index_20` (`account_id`,`is_filtered`,`last_visitor_page_view_at`),
  KEY `visit_index_21` (`account_id`,`is_filtered`,`duration_in_seconds`),
  KEY `prospect_index` (`prospect_id`,`is_filtered`),
  KEY `visitor_index` (`visitor_id`,`is_filtered`),
  CONSTRAINT `visit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `visit_FK_2` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `visit_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visit`
--

LOCK TABLES `visit` WRITE;
/*!40000 ALTER TABLE `visit` DISABLE KEYS */;
/*!40000 ALTER TABLE `visit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visit_external_key`
--

DROP TABLE IF EXISTS `visit_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visit_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_visit_id` FOREIGN KEY (`id`) REFERENCES `visit` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visit_external_key`
--

LOCK TABLES `visit_external_key` WRITE;
/*!40000 ALTER TABLE `visit_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `visit_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor`
--

DROP TABLE IF EXISTS `visitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `profile_id` int(11) DEFAULT NULL,
  `visitor_whois_id` int(11) DEFAULT NULL,
  `visitor_browser_id` int(11) DEFAULT NULL,
  `visitor_browser_version_id` int(11) DEFAULT NULL,
  `visitor_operating_system_id` int(11) DEFAULT NULL,
  `visitor_operating_system_version_id` int(11) DEFAULT NULL,
  `visitor_language_id` int(11) DEFAULT NULL,
  `visitor_screen_height_id` int(11) DEFAULT NULL,
  `visitor_screen_width_id` int(11) DEFAULT NULL,
  `visitor_page_view_count` int(11) DEFAULT NULL,
  `paid_search_ad_id` int(11) DEFAULT NULL,
  `is_flash_enabled` int(11) DEFAULT NULL,
  `is_java_enabled` int(11) DEFAULT NULL,
  `ip_address` varchar(15) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hostname` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `campaign_parameter` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `medium_parameter` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_parameter` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content_parameter` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `term_parameter` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_filtered` tinyint(1) NOT NULL DEFAULT '0',
  `is_identified` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_created_at` (`created_at`),
  KEY `visitor_FI_1` (`account_id`),
  KEY `visitor_FI_2` (`campaign_id`),
  KEY `visitor_FI_3` (`prospect_id`),
  KEY `visitor_FI_4` (`profile_id`),
  KEY `visitor_FI_5` (`visitor_browser_id`),
  KEY `visitor_FI_6` (`visitor_browser_version_id`),
  KEY `visitor_FI_7` (`visitor_operating_system_id`),
  KEY `visitor_FI_8` (`visitor_operating_system_version_id`),
  KEY `visitor_FI_9` (`visitor_language_id`),
  KEY `visitor_FI_10` (`visitor_screen_height_id`),
  KEY `visitor_FI_11` (`visitor_screen_width_id`),
  KEY `visitor_FI_12` (`paid_search_ad_id`),
  CONSTRAINT `visitor_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `visitor_FK_10` FOREIGN KEY (`visitor_screen_height_id`) REFERENCES `visitor_parameter` (`id`),
  CONSTRAINT `visitor_FK_11` FOREIGN KEY (`visitor_screen_width_id`) REFERENCES `visitor_parameter` (`id`),
  CONSTRAINT `visitor_FK_12` FOREIGN KEY (`paid_search_ad_id`) REFERENCES `paid_search_ad` (`id`),
  CONSTRAINT `visitor_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `visitor_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `visitor_FK_4` FOREIGN KEY (`profile_id`) REFERENCES `profile` (`id`),
  CONSTRAINT `visitor_FK_5` FOREIGN KEY (`visitor_browser_id`) REFERENCES `visitor_parameter` (`id`),
  CONSTRAINT `visitor_FK_6` FOREIGN KEY (`visitor_browser_version_id`) REFERENCES `visitor_parameter` (`id`),
  CONSTRAINT `visitor_FK_7` FOREIGN KEY (`visitor_operating_system_id`) REFERENCES `visitor_parameter` (`id`),
  CONSTRAINT `visitor_FK_8` FOREIGN KEY (`visitor_operating_system_version_id`) REFERENCES `visitor_parameter` (`id`),
  CONSTRAINT `visitor_FK_9` FOREIGN KEY (`visitor_language_id`) REFERENCES `visitor_parameter` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor`
--

LOCK TABLES `visitor` WRITE;
/*!40000 ALTER TABLE `visitor` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_activity`
--

DROP TABLE IF EXISTS `visitor_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_activity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `email_id` int(11) DEFAULT NULL,
  `email_preferences_page_id` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `form_handler_id` int(11) DEFAULT NULL,
  `site_search_query_id` int(11) DEFAULT NULL,
  `landing_page_id` int(11) DEFAULT NULL,
  `paid_search_ad_id` int(11) DEFAULT NULL,
  `multivariate_test_variation_id` int(11) DEFAULT NULL,
  `visitor_page_view_id` int(11) DEFAULT NULL,
  `filex_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `tracker_id` int(11) DEFAULT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `custom_url_id` int(11) DEFAULT NULL,
  `social_message_link_id` int(11) DEFAULT NULL,
  `connector_activity_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `is_filtered` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `opportunity_id` int(11) DEFAULT NULL,
  `visit_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `visitor_activity_visit_id_unique` (`visit_id`),
  KEY `visitor_activity_ix_created_at_composite` (`account_id`,`type`,`is_filtered`,`created_at`),
  KEY `visitor_activity_FI_2` (`campaign_id`),
  KEY `visitor_activity_FI_3` (`email_id`),
  KEY `visitor_activity_FI_4` (`email_preferences_page_id`),
  KEY `visitor_activity_FI_5` (`form_id`),
  KEY `visitor_activity_FI_6` (`form_handler_id`),
  KEY `visitor_activity_FI_7` (`site_search_query_id`),
  KEY `visitor_activity_FI_8` (`landing_page_id`),
  KEY `visitor_activity_FI_9` (`paid_search_ad_id`),
  KEY `visitor_activity_FI_10` (`multivariate_test_variation_id`),
  KEY `visitor_activity_FI_11` (`visitor_page_view_id`),
  KEY `visitor_activity_FI_12` (`filex_id`),
  KEY `visitor_activity_FI_13` (`prospect_id`),
  KEY `visitor_activity_FI_14` (`tracker_id`),
  KEY `visitor_activity_FI_15` (`visitor_id`),
  KEY `visitor_activity_FI_16` (`custom_url_id`),
  KEY `visitor_activity_FI_17` (`social_message_link_id`),
  KEY `visitor_activity_FI_18` (`connector_activity_id`),
  KEY `visitor_activity_FI_19` (`opportunity_id`),
  CONSTRAINT `visitor_activity_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `visitor_activity_FK_10` FOREIGN KEY (`multivariate_test_variation_id`) REFERENCES `multivariate_test_variation` (`id`),
  CONSTRAINT `visitor_activity_FK_11` FOREIGN KEY (`visitor_page_view_id`) REFERENCES `visitor_page_view` (`id`),
  CONSTRAINT `visitor_activity_FK_12` FOREIGN KEY (`filex_id`) REFERENCES `filex` (`id`),
  CONSTRAINT `visitor_activity_FK_13` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `visitor_activity_FK_14` FOREIGN KEY (`tracker_id`) REFERENCES `tracker` (`id`),
  CONSTRAINT `visitor_activity_FK_15` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `visitor_activity_FK_16` FOREIGN KEY (`custom_url_id`) REFERENCES `custom_url` (`id`),
  CONSTRAINT `visitor_activity_FK_17` FOREIGN KEY (`social_message_link_id`) REFERENCES `social_message_link` (`id`),
  CONSTRAINT `visitor_activity_FK_18` FOREIGN KEY (`connector_activity_id`) REFERENCES `connector_activity` (`id`),
  CONSTRAINT `visitor_activity_FK_19` FOREIGN KEY (`opportunity_id`) REFERENCES `opportunity` (`id`),
  CONSTRAINT `visitor_activity_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `visitor_activity_FK_20` FOREIGN KEY (`visit_id`) REFERENCES `visit` (`id`),
  CONSTRAINT `visitor_activity_FK_3` FOREIGN KEY (`email_id`) REFERENCES `email` (`id`),
  CONSTRAINT `visitor_activity_FK_4` FOREIGN KEY (`email_preferences_page_id`) REFERENCES `email_preferences_page` (`id`),
  CONSTRAINT `visitor_activity_FK_5` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `visitor_activity_FK_6` FOREIGN KEY (`form_handler_id`) REFERENCES `form_handler` (`id`),
  CONSTRAINT `visitor_activity_FK_7` FOREIGN KEY (`site_search_query_id`) REFERENCES `site_search_query` (`id`),
  CONSTRAINT `visitor_activity_FK_8` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `visitor_activity_FK_9` FOREIGN KEY (`paid_search_ad_id`) REFERENCES `paid_search_ad` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_activity`
--

LOCK TABLES `visitor_activity` WRITE;
/*!40000 ALTER TABLE `visitor_activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_activity_external_key`
--

DROP TABLE IF EXISTS `visitor_activity_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_activity_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_visitor_activity_id` FOREIGN KEY (`id`) REFERENCES `visitor_activity` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_activity_external_key`
--

LOCK TABLES `visitor_activity_external_key` WRITE;
/*!40000 ALTER TABLE `visitor_activity_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_activity_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_audit`
--

DROP TABLE IF EXISTS `visitor_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `landing_page_id` int(11) DEFAULT NULL,
  `form_field_id` int(11) DEFAULT NULL,
  `prospect_field_default_id` int(11) DEFAULT NULL,
  `prospect_field_custom_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `variable1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `variable2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `variable3` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `visitor_audit_FI_1` (`account_id`),
  KEY `visitor_audit_FI_2` (`visitor_id`),
  KEY `visitor_audit_FI_3` (`prospect_id`),
  KEY `visitor_audit_FI_4` (`form_id`),
  KEY `visitor_audit_FI_5` (`landing_page_id`),
  KEY `visitor_audit_FI_6` (`form_field_id`),
  KEY `visitor_audit_FI_7` (`prospect_field_default_id`),
  KEY `visitor_audit_FI_8` (`prospect_field_custom_id`),
  CONSTRAINT `visitor_audit_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `visitor_audit_FK_2` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `visitor_audit_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `visitor_audit_FK_4` FOREIGN KEY (`form_id`) REFERENCES `form` (`id`),
  CONSTRAINT `visitor_audit_FK_5` FOREIGN KEY (`landing_page_id`) REFERENCES `landing_page` (`id`),
  CONSTRAINT `visitor_audit_FK_6` FOREIGN KEY (`form_field_id`) REFERENCES `form_field` (`id`),
  CONSTRAINT `visitor_audit_FK_7` FOREIGN KEY (`prospect_field_default_id`) REFERENCES `prospect_field_default` (`id`),
  CONSTRAINT `visitor_audit_FK_8` FOREIGN KEY (`prospect_field_custom_id`) REFERENCES `prospect_field_custom` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_audit`
--

LOCK TABLES `visitor_audit` WRITE;
/*!40000 ALTER TABLE `visitor_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_audit_external_key`
--

DROP TABLE IF EXISTS `visitor_audit_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_audit_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_visitor_audit_id` FOREIGN KEY (`id`) REFERENCES `visitor_audit` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_audit_external_key`
--

LOCK TABLES `visitor_audit_external_key` WRITE;
/*!40000 ALTER TABLE `visitor_audit_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_audit_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_count`
--

DROP TABLE IF EXISTS `visitor_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_count` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `stats_date` date DEFAULT NULL,
  `stats_hour` int(11) DEFAULT NULL,
  `visitor_count` int(11) DEFAULT NULL,
  `max_visitor_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_date_hour` (`account_id`,`stats_date`,`stats_hour`),
  CONSTRAINT `visitor_count_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_count`
--

LOCK TABLES `visitor_count` WRITE;
/*!40000 ALTER TABLE `visitor_count` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_count` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_external_key`
--

DROP TABLE IF EXISTS `visitor_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_visitor_id` FOREIGN KEY (`id`) REFERENCES `visitor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_external_key`
--

LOCK TABLES `visitor_external_key` WRITE;
/*!40000 ALTER TABLE `visitor_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_geo_filter`
--

DROP TABLE IF EXISTS `visitor_geo_filter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_geo_filter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`user_id`,`type`),
  KEY `visitor_geo_filter_FI_1` (`account_id`),
  CONSTRAINT `visitor_geo_filter_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `visitor_geo_filter_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_geo_filter`
--

LOCK TABLES `visitor_geo_filter` WRITE;
/*!40000 ALTER TABLE `visitor_geo_filter` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_geo_filter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_opt_in`
--

DROP TABLE IF EXISTS `visitor_opt_in`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_opt_in` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `group_id` int(11) DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`account_id`,`country`),
  CONSTRAINT `visitor_opt_in_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_opt_in`
--

LOCK TABLES `visitor_opt_in` WRITE;
/*!40000 ALTER TABLE `visitor_opt_in` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_opt_in` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_opt_in_settings`
--

DROP TABLE IF EXISTS `visitor_opt_in_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_opt_in_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `style` text COLLATE utf8_unicode_ci,
  `link_style` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`account_id`),
  CONSTRAINT `visitor_opt_in_settings_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_opt_in_settings`
--

LOCK TABLES `visitor_opt_in_settings` WRITE;
/*!40000 ALTER TABLE `visitor_opt_in_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_opt_in_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_page_view`
--

DROP TABLE IF EXISTS `visitor_page_view`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_page_view` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `url` text COLLATE utf8_unicode_ci,
  `title` text COLLATE utf8_unicode_ci,
  `points` int(11) DEFAULT '1',
  `is_filtered` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `visit_id` int(11) DEFAULT NULL,
  `visitor_referrer_id` int(11) DEFAULT NULL,
  `duration_in_seconds` int(11) DEFAULT NULL,
  `last_synced_at` datetime DEFAULT NULL,
  `crm_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `visitor_page_view_FI_1` (`account_id`),
  KEY `visitor_page_view_FI_2` (`campaign_id`),
  KEY `visitor_page_view_FI_3` (`visitor_id`),
  KEY `visitor_page_view_FI_4` (`visit_id`),
  KEY `visitor_page_view_FI_5` (`visitor_referrer_id`),
  CONSTRAINT `visitor_page_view_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `visitor_page_view_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `visitor_page_view_FK_3` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `visitor_page_view_FK_4` FOREIGN KEY (`visit_id`) REFERENCES `visit` (`id`),
  CONSTRAINT `visitor_page_view_FK_5` FOREIGN KEY (`visitor_referrer_id`) REFERENCES `visitor_referrer` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_page_view`
--

LOCK TABLES `visitor_page_view` WRITE;
/*!40000 ALTER TABLE `visitor_page_view` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_page_view` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_page_view_count`
--

DROP TABLE IF EXISTS `visitor_page_view_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_page_view_count` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `stats_date` date DEFAULT NULL,
  `stats_hour` int(11) DEFAULT NULL,
  `page_view_count` int(11) DEFAULT NULL,
  `max_visitor_page_view_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_date_hour` (`account_id`,`stats_date`,`stats_hour`),
  CONSTRAINT `visitor_page_view_count_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_page_view_count`
--

LOCK TABLES `visitor_page_view_count` WRITE;
/*!40000 ALTER TABLE `visitor_page_view_count` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_page_view_count` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_page_view_external_key`
--

DROP TABLE IF EXISTS `visitor_page_view_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_page_view_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_visitor_page_view_id` FOREIGN KEY (`id`) REFERENCES `visitor_page_view` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_page_view_external_key`
--

LOCK TABLES `visitor_page_view_external_key` WRITE;
/*!40000 ALTER TABLE `visitor_page_view_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_page_view_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_parameter`
--

DROP TABLE IF EXISTS `visitor_parameter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_parameter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_parameter`
--

LOCK TABLES `visitor_parameter` WRITE;
/*!40000 ALTER TABLE `visitor_parameter` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_parameter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_queue`
--

DROP TABLE IF EXISTS `visitor_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT '0',
  `is_processing` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `visitor_queue_created_at_index` (`created_at`),
  KEY `visitor_queue_FI_1` (`account_id`),
  KEY `visitor_queue_FI_2` (`visitor_id`),
  CONSTRAINT `visitor_queue_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `visitor_queue_FK_2` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_queue`
--

LOCK TABLES `visitor_queue` WRITE;
/*!40000 ALTER TABLE `visitor_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_queue_external_key`
--

DROP TABLE IF EXISTS `visitor_queue_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_queue_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_visitor_queue_id` FOREIGN KEY (`id`) REFERENCES `visitor_queue` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_queue_external_key`
--

LOCK TABLES `visitor_queue_external_key` WRITE;
/*!40000 ALTER TABLE `visitor_queue_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_queue_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_referrer`
--

DROP TABLE IF EXISTS `visitor_referrer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_referrer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `visitor_id` int(11) DEFAULT NULL,
  `prospect_id` int(11) DEFAULT NULL,
  `referrer` text COLLATE utf8_unicode_ci,
  `vendor` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `query` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `click_fid` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `visitor_referrer_FI_1` (`account_id`),
  KEY `visitor_referrer_FI_2` (`campaign_id`),
  KEY `visitor_referrer_FI_3` (`visitor_id`),
  KEY `visitor_referrer_FI_4` (`prospect_id`),
  CONSTRAINT `visitor_referrer_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `visitor_referrer_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`),
  CONSTRAINT `visitor_referrer_FK_3` FOREIGN KEY (`visitor_id`) REFERENCES `visitor` (`id`),
  CONSTRAINT `visitor_referrer_FK_4` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_referrer`
--

LOCK TABLES `visitor_referrer` WRITE;
/*!40000 ALTER TABLE `visitor_referrer` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_referrer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_referrer_external_key`
--

DROP TABLE IF EXISTS `visitor_referrer_external_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_referrer_external_key` (
  `id` int(11) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `external_id` binary(16) NOT NULL,
  PRIMARY KEY (`id`,`type`),
  KEY `idx_external_id` (`type`,`external_id`),
  CONSTRAINT `fk_visitor_referrer_id` FOREIGN KEY (`id`) REFERENCES `visitor_referrer` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_referrer_external_key`
--

LOCK TABLES `visitor_referrer_external_key` WRITE;
/*!40000 ALTER TABLE `visitor_referrer_external_key` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_referrer_external_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_report`
--

DROP TABLE IF EXISTS `visitor_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `report_date` date DEFAULT NULL,
  `total_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `visitor_report_FI_1` (`account_id`),
  KEY `visitor_report_FI_2` (`campaign_id`),
  CONSTRAINT `visitor_report_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `visitor_report_FK_2` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_report`
--

LOCK TABLES `visitor_report` WRITE;
/*!40000 ALTER TABLE `visitor_report` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_whois_ip`
--

DROP TABLE IF EXISTS `visitor_whois_ip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_whois_ip` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_ip` bigint(20) DEFAULT NULL,
  `end_ip` bigint(20) DEFAULT NULL,
  `visitor_whois_location_id` int(11) DEFAULT NULL,
  `isp_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `org_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `active` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `visitor_whois_ip_FI_1` (`visitor_whois_location_id`),
  CONSTRAINT `visitor_whois_ip_FK_1` FOREIGN KEY (`visitor_whois_location_id`) REFERENCES `visitor_whois_location` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_whois_ip`
--

LOCK TABLES `visitor_whois_ip` WRITE;
/*!40000 ALTER TABLE `visitor_whois_ip` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_whois_ip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitor_whois_location`
--

DROP TABLE IF EXISTS `visitor_whois_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `visitor_whois_location` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `region` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `metro_code` int(11) DEFAULT NULL,
  `area_code` int(11) DEFAULT NULL,
  `active` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitor_whois_location`
--

LOCK TABLES `visitor_whois_location` WRITE;
/*!40000 ALTER TABLE `visitor_whois_location` DISABLE KEYS */;
/*!40000 ALTER TABLE `visitor_whois_location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `web_analytics_stats`
--

DROP TABLE IF EXISTS `web_analytics_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_analytics_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stats_date` date DEFAULT NULL,
  `account_id` int(11) NOT NULL,
  `visitors` int(11) DEFAULT '0',
  `page_views` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `web_analytics_stats_lookup` (`account_id`,`stats_date`),
  CONSTRAINT `web_analytics_stats_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `web_analytics_stats`
--

LOCK TABLES `web_analytics_stats` WRITE;
/*!40000 ALTER TABLE `web_analytics_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `web_analytics_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webinar`
--

DROP TABLE IF EXISTS `webinar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `webinar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `connector_id` int(11) NOT NULL,
  `fid` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `duration_minutes` int(11) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `host` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `timezone` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `host_email` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `host_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `webinar_type` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `needs_registration` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  `is_hidden` int(11) DEFAULT '0',
  `can_register_attendees` int(11) DEFAULT '1',
  `cannot_register_reason` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `registration_error` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pulled_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `webinar_FI_1` (`account_id`),
  KEY `webinar_FI_2` (`connector_id`),
  CONSTRAINT `webinar_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `webinar_FK_2` FOREIGN KEY (`connector_id`) REFERENCES `connector` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webinar`
--

LOCK TABLES `webinar` WRITE;
/*!40000 ALTER TABLE `webinar` DISABLE KEYS */;
/*!40000 ALTER TABLE `webinar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webinar_attendee`
--

DROP TABLE IF EXISTS `webinar_attendee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `webinar_attendee` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `webinar_id` int(11) NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `fid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attendance_status` int(11) NOT NULL DEFAULT '0',
  `registration_status` int(11) NOT NULL DEFAULT '0',
  `attendance_at` datetime DEFAULT NULL,
  `registration_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `webinar_attendee_FI_1` (`account_id`),
  KEY `webinar_attendee_FI_2` (`webinar_id`),
  KEY `webinar_attendee_FI_3` (`prospect_id`),
  CONSTRAINT `webinar_attendee_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `webinar_attendee_FK_2` FOREIGN KEY (`webinar_id`) REFERENCES `webinar` (`id`),
  CONSTRAINT `webinar_attendee_FK_3` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webinar_attendee`
--

LOCK TABLES `webinar_attendee` WRITE;
/*!40000 ALTER TABLE `webinar_attendee` DISABLE KEYS */;
/*!40000 ALTER TABLE `webinar_attendee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wizard`
--

DROP TABLE IF EXISTS `wizard`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wizard` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `object_id` int(11) DEFAULT NULL,
  `type` tinyint(4) DEFAULT NULL,
  `content` longtext COLLATE utf8_unicode_ci,
  `current_step_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_finished` int(11) DEFAULT '0',
  `is_archived` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `wizard_FI_1` (`account_id`),
  KEY `wizard_FI_2` (`user_id`),
  KEY `wizard_FI_3` (`current_step_id`),
  CONSTRAINT `wizard_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `wizard_FK_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `wizard_FK_3` FOREIGN KEY (`current_step_id`) REFERENCES `wizard_step` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wizard`
--

LOCK TABLES `wizard` WRITE;
/*!40000 ALTER TABLE `wizard` DISABLE KEYS */;
/*!40000 ALTER TABLE `wizard` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wizard_step`
--

DROP TABLE IF EXISTS `wizard_step`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wizard_step` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `wizard_id` int(11) DEFAULT NULL,
  `type` tinyint(4) DEFAULT NULL,
  `step_number` int(11) DEFAULT NULL,
  `is_finished` int(11) DEFAULT '0',
  `is_invalid` int(11) DEFAULT '0',
  `is_skipped` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `wizard_step_FI_1` (`account_id`),
  KEY `wizard_step_FI_2` (`wizard_id`),
  CONSTRAINT `wizard_step_FK_1` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `wizard_step_FK_2` FOREIGN KEY (`wizard_id`) REFERENCES `wizard` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wizard_step`
--

LOCK TABLES `wizard_step` WRITE;
/*!40000 ALTER TABLE `wizard_step` DISABLE KEYS */;
/*!40000 ALTER TABLE `wizard_step` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow`
--

DROP TABLE IF EXISTS `workflow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `status` mediumint(8) unsigned NOT NULL DEFAULT '1',
  `version` int(10) unsigned NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `start_workflow_node_id` int(10) unsigned DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_id_idx` (`account_id`),
  KEY `owner_id_idx` (`owner_id`),
  KEY `created_by_idx` (`created_by`),
  KEY `updated_by_idx` (`updated_by`),
  KEY `start_workflow_node_id_idx` (`start_workflow_node_id`),
  CONSTRAINT `workflow_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_created_by_user_id` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_owner_id_user_id` FOREIGN KEY (`owner_id`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_start_workflow_node_id_workflow_node_id` FOREIGN KEY (`start_workflow_node_id`) REFERENCES `workflow_node` (`id`),
  CONSTRAINT `workflow_updated_by_user_id` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow`
--

LOCK TABLES `workflow` WRITE;
/*!40000 ALTER TABLE `workflow` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_action`
--

DROP TABLE IF EXISTS `workflow_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_action` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `workflow_node_id` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parameters` text COLLATE utf8_unicode_ci,
  `sort_order` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `workflow_action_type_idx` (`type`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `workflow_node_id_idx` (`workflow_node_id`),
  KEY `created_by_idx` (`created_by`),
  KEY `updated_by_idx` (`updated_by`),
  CONSTRAINT `workflow_action_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_action_created_by_user_id` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_action_updated_by_user_id` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_action_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`),
  CONSTRAINT `workflow_action_workflow_node_id_workflow_node_id` FOREIGN KEY (`workflow_node_id`) REFERENCES `workflow_node` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_action`
--

LOCK TABLES `workflow_action` WRITE;
/*!40000 ALTER TABLE `workflow_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_action_audit`
--

DROP TABLE IF EXISTS `workflow_action_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_action_audit` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `workflow_node_id` int(10) unsigned NOT NULL,
  `workflow_action_id` int(10) unsigned NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `parameters` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueProspectIndex_idx` (`account_id`,`workflow_action_id`,`prospect_id`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `workflow_node_id_idx` (`workflow_node_id`),
  KEY `workflow_action_id_idx` (`workflow_action_id`),
  KEY `prospect_id_idx` (`prospect_id`),
  CONSTRAINT `workflow_action_audit_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_action_audit_prospect_id_prospect_id` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `workflow_action_audit_workflow_action_id_workflow_action_id` FOREIGN KEY (`workflow_action_id`) REFERENCES `workflow_action` (`id`),
  CONSTRAINT `workflow_action_audit_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`),
  CONSTRAINT `workflow_action_audit_workflow_node_id_workflow_node_id` FOREIGN KEY (`workflow_node_id`) REFERENCES `workflow_node` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_action_audit`
--

LOCK TABLES `workflow_action_audit` WRITE;
/*!40000 ALTER TABLE `workflow_action_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_action_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_activity_stat`
--

DROP TABLE IF EXISTS `workflow_activity_stat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_activity_stat` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `workflow_node_id` int(10) unsigned NOT NULL,
  `workflow_action_id` int(10) unsigned DEFAULT NULL,
  `prospect_id` int(11) NOT NULL,
  `action_type` tinyint(3) unsigned NOT NULL,
  `object_id` int(10) unsigned NOT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `allTheThingsUniqueIndex_idx` (`account_id`,`workflow_id`,`workflow_node_id`,`prospect_id`,`action_type`,`object_id`),
  KEY `actionObjectIndex_idx` (`account_id`,`workflow_id`,`workflow_node_id`,`action_type`,`object_id`),
  KEY `objectIdIndex_idx` (`account_id`,`workflow_id`,`action_type`,`object_id`),
  KEY `nodeIndex_idx` (`account_id`,`workflow_id`,`workflow_node_id`),
  KEY `actionIndex_idx_idx` (`account_id`,`workflow_id`,`workflow_node_id`,`workflow_action_id`),
  KEY `assetReporting_idx` (`account_id`,`workflow_action_id`,`action_type`,`object_id`,`timestamp`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `workflow_node_id_idx` (`workflow_node_id`),
  KEY `workflow_action_id_idx` (`workflow_action_id`),
  KEY `prospect_id_idx` (`prospect_id`),
  CONSTRAINT `workflow_activity_stat_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_activity_stat_prospect_id_prospect_id` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `workflow_activity_stat_workflow_action_id_workflow_action_id` FOREIGN KEY (`workflow_action_id`) REFERENCES `workflow_action` (`id`),
  CONSTRAINT `workflow_activity_stat_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`),
  CONSTRAINT `workflow_activity_stat_workflow_node_id_workflow_node_id` FOREIGN KEY (`workflow_node_id`) REFERENCES `workflow_node` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_activity_stat`
--

LOCK TABLES `workflow_activity_stat` WRITE;
/*!40000 ALTER TABLE `workflow_activity_stat` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_activity_stat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_metadata`
--

DROP TABLE IF EXISTS `workflow_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_metadata` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `metadata` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nameIndex_idx` (`account_id`,`workflow_id`,`name`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `created_by_idx` (`created_by`),
  KEY `updated_by_idx` (`updated_by`),
  CONSTRAINT `workflow_metadata_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_metadata_created_by_user_id` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_metadata_updated_by_user_id` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_metadata_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_metadata`
--

LOCK TABLES `workflow_metadata` WRITE;
/*!40000 ALTER TABLE `workflow_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_node`
--

DROP TABLE IF EXISTS `workflow_node`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_node` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parameters` text COLLATE utf8_unicode_ci,
  `match_type` tinyint(3) unsigned DEFAULT NULL,
  `timeout` int(10) unsigned DEFAULT NULL,
  `version` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `created_by_idx` (`created_by`),
  KEY `updated_by_idx` (`updated_by`),
  CONSTRAINT `workflow_node_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_node_created_by_user_id` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_node_updated_by_user_id` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_node_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_node`
--

LOCK TABLES `workflow_node` WRITE;
/*!40000 ALTER TABLE `workflow_node` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_node` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_node_audit`
--

DROP TABLE IF EXISTS `workflow_node_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_node_audit` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `workflow_node_id` int(10) unsigned NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `change_type` tinyint(3) unsigned NOT NULL,
  `changeset` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `allTheThingsUniqueIndex_idx` (`account_id`,`workflow_node_id`,`version`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `workflow_node_id_idx` (`workflow_node_id`),
  KEY `created_by_idx` (`created_by`),
  CONSTRAINT `workflow_node_audit_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_node_audit_created_by_user_id` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_node_audit_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`),
  CONSTRAINT `workflow_node_audit_workflow_node_id_workflow_node_id` FOREIGN KEY (`workflow_node_id`) REFERENCES `workflow_node` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_node_audit`
--

LOCK TABLES `workflow_node_audit` WRITE;
/*!40000 ALTER TABLE `workflow_node_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_node_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_node_edge`
--

DROP TABLE IF EXISTS `workflow_node_edge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_node_edge` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `source_workflow_node_id` int(10) unsigned NOT NULL,
  `destination_workflow_node_id` int(10) unsigned NOT NULL,
  `sort_order` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `source_workflow_node_id_idx` (`source_workflow_node_id`),
  KEY `destination_workflow_node_id_idx` (`destination_workflow_node_id`),
  KEY `created_by_idx` (`created_by`),
  KEY `updated_by_idx` (`updated_by`),
  CONSTRAINT `workflow_node_edge_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_node_edge_created_by_user_id` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_node_edge_destination_workflow_node_id_workflow_node_id` FOREIGN KEY (`destination_workflow_node_id`) REFERENCES `workflow_node` (`id`),
  CONSTRAINT `workflow_node_edge_source_workflow_node_id_workflow_node_id` FOREIGN KEY (`source_workflow_node_id`) REFERENCES `workflow_node` (`id`),
  CONSTRAINT `workflow_node_edge_updated_by_user_id` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_node_edge_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_node_edge`
--

LOCK TABLES `workflow_node_edge` WRITE;
/*!40000 ALTER TABLE `workflow_node_edge` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_node_edge` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_rule`
--

DROP TABLE IF EXISTS `workflow_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_rule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `workflow_node_id` int(10) unsigned NOT NULL,
  `parent_workflow_rule_id` int(10) unsigned DEFAULT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `subtype` tinyint(3) unsigned DEFAULT NULL,
  `match_type` tinyint(3) unsigned DEFAULT NULL,
  `operator` tinyint(4) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parameters` text COLLATE utf8_unicode_ci,
  `sort_order` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `updated_at` datetime NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `workflow_rule_type_idx` (`type`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `workflow_node_id_idx` (`workflow_node_id`),
  KEY `parent_workflow_rule_id_idx` (`parent_workflow_rule_id`),
  KEY `created_by_idx` (`created_by`),
  KEY `updated_by_idx` (`updated_by`),
  CONSTRAINT `workflow_rule_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_rule_created_by_user_id` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_rule_parent_workflow_rule_id_workflow_rule_id` FOREIGN KEY (`parent_workflow_rule_id`) REFERENCES `workflow_rule` (`id`),
  CONSTRAINT `workflow_rule_updated_by_user_id` FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_rule_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`),
  CONSTRAINT `workflow_rule_workflow_node_id_workflow_node_id` FOREIGN KEY (`workflow_node_id`) REFERENCES `workflow_node` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_rule`
--

LOCK TABLES `workflow_rule` WRITE;
/*!40000 ALTER TABLE `workflow_rule` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_source`
--

DROP TABLE IF EXISTS `workflow_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_source` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `is_suppressed` tinyint(1) NOT NULL,
  `listx_id` int(11) DEFAULT NULL,
  `sort_order` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `listx_id_idx` (`listx_id`),
  KEY `created_by_idx` (`created_by`),
  CONSTRAINT `workflow_source_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_source_created_by_user_id` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
  CONSTRAINT `workflow_source_listx_id_listx_id` FOREIGN KEY (`listx_id`) REFERENCES `listx` (`id`),
  CONSTRAINT `workflow_source_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_source`
--

LOCK TABLES `workflow_source` WRITE;
/*!40000 ALTER TABLE `workflow_source` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_source` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_state`
--

DROP TABLE IF EXISTS `workflow_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_state` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `workflow_node_id` int(10) unsigned NOT NULL,
  `prospect_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `workflow_node_version` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueProspectIndex_idx` (`account_id`,`workflow_id`,`prospect_id`),
  KEY `ix_expiresAt_idx` (`account_id`,`expires_at`),
  KEY `nodeReporting_idx` (`account_id`,`workflow_node_id`,`created_at`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `workflow_node_id_idx` (`workflow_node_id`),
  KEY `prospect_id_idx` (`prospect_id`),
  CONSTRAINT `workflow_state_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_state_prospect_id_prospect_id` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `workflow_state_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`),
  CONSTRAINT `workflow_state_workflow_node_id_workflow_node_id` FOREIGN KEY (`workflow_node_id`) REFERENCES `workflow_node` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_state`
--

LOCK TABLES `workflow_state` WRITE;
/*!40000 ALTER TABLE `workflow_state` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_state_audit`
--

DROP TABLE IF EXISTS `workflow_state_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_state_audit` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `workflow_id` int(10) unsigned NOT NULL,
  `workflow_node_id` int(10) unsigned NOT NULL,
  `next_workflow_node_id` int(10) unsigned DEFAULT NULL,
  `previous_workflow_node_id` int(10) unsigned DEFAULT NULL,
  `workflow_node_edge_id` int(10) unsigned DEFAULT NULL,
  `workflow_node_exit_path` int(10) unsigned DEFAULT NULL,
  `prospect_id` int(11) NOT NULL,
  `entered_date` datetime NOT NULL,
  `exit_date` datetime DEFAULT NULL,
  `actions_applied_at` datetime DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `workflow_node_version` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniqueProspectIndex_idx` (`account_id`,`workflow_id`,`workflow_node_id`,`prospect_id`),
  KEY `nodeReportingEntered_idx` (`account_id`,`workflow_node_id`,`entered_date`),
  KEY `nodeReportingExit_idx` (`account_id`,`workflow_node_id`,`next_workflow_node_id`,`exit_date`),
  KEY `account_id_idx` (`account_id`),
  KEY `workflow_id_idx` (`workflow_id`),
  KEY `workflow_node_id_idx` (`workflow_node_id`),
  KEY `next_workflow_node_id_idx` (`next_workflow_node_id`),
  KEY `previous_workflow_node_id_idx` (`previous_workflow_node_id`),
  KEY `workflow_node_edge_id_idx` (`workflow_node_edge_id`),
  KEY `prospect_id_idx` (`prospect_id`),
  CONSTRAINT `workflow_state_audit_account_id_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`),
  CONSTRAINT `workflow_state_audit_next_workflow_node_id_workflow_node_id` FOREIGN KEY (`next_workflow_node_id`) REFERENCES `workflow_node` (`id`),
  CONSTRAINT `workflow_state_audit_previous_workflow_node_id_workflow_node_id` FOREIGN KEY (`previous_workflow_node_id`) REFERENCES `workflow_node` (`id`),
  CONSTRAINT `workflow_state_audit_prospect_id_prospect_id` FOREIGN KEY (`prospect_id`) REFERENCES `prospect` (`id`),
  CONSTRAINT `workflow_state_audit_workflow_id_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `workflow` (`id`),
  CONSTRAINT `workflow_state_audit_workflow_node_edge_id_workflow_node_edge_id` FOREIGN KEY (`workflow_node_edge_id`) REFERENCES `workflow_node_edge` (`id`),
  CONSTRAINT `workflow_state_audit_workflow_node_id_workflow_node_id` FOREIGN KEY (`workflow_node_id`) REFERENCES `workflow_node` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_state_audit`
--

LOCK TABLES `workflow_state_audit` WRITE;
/*!40000 ALTER TABLE `workflow_state_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `workflow_state_audit` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-04-05 12:34:57
