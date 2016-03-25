-- MySQL dump 10.13  Distrib 5.6.29, for osx10.11 (x86_64)
--
-- Host: 127.0.0.1    Database: pardot_global
-- ------------------------------------------------------
-- Server version	5.6.29

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
-- Table structure for table `access_logs`
--

DROP TABLE IF EXISTS `access_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` varchar(255) DEFAULT NULL,
  `query_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `queries`
--

DROP TABLE IF EXISTS `queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `database` varchar(255) DEFAULT NULL,
  `datacenter` varchar(255) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `sql` text,
  `view` varchar(255) DEFAULT NULL,
  `is_limited` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-03-25 17:54:48
INSERT INTO schema_migrations (version) VALUES ('20140825172247');

INSERT INTO schema_migrations (version) VALUES ('20140915151939');

