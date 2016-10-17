/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50624
Source Host           : localhost:3306
Source Database       : ms_blog

Target Server Type    : MYSQL
Target Server Version : 50624
File Encoding         : 65001

Date: 2016-10-17 09:34:43
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for comment_table
-- ----------------------------
DROP TABLE IF EXISTS `comment_table`;
CREATE TABLE `comment_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` int(2) unsigned NOT NULL DEFAULT '0',
  `content` text CHARACTER SET utf8 NOT NULL COMMENT '用户评论的主体内容',
  `user_id` int(10) unsigned NOT NULL COMMENT '评论的用户id',
  `user_name` char(20) CHARACTER SET utf8 NOT NULL COMMENT '评论的用户名',
  `paper_id` int(10) unsigned NOT NULL COMMENT '评论所属的文章id',
  `comment_date` datetime NOT NULL COMMENT '评论日期',
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for papers_table
-- ----------------------------
DROP TABLE IF EXISTS `papers_table`;
CREATE TABLE `papers_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '文章内容表，自增id',
  `title` varchar(255) CHARACTER SET utf8 NOT NULL COMMENT '文章的标题',
  `tag` char(20) CHARACTER SET utf8 NOT NULL COMMENT '文章所属标签名称',
  `subtag` char(50) CHARACTER SET utf8 DEFAULT NULL COMMENT '文章副标签，可为空',
  `publish_date` datetime NOT NULL COMMENT '文章上传/发布时间',
  `timeline` char(7) NOT NULL,
  `abstract` text CHARACTER SET utf8 NOT NULL COMMENT '文章简述',
  `content` text CHARACTER SET utf8 NOT NULL COMMENT '文章主体内容',
  UNIQUE KEY `id` (`id`),
  KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for subcomment_table
-- ----------------------------
DROP TABLE IF EXISTS `subcomment_table`;
CREATE TABLE `subcomment_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` int(2) unsigned NOT NULL COMMENT '评论类型，1表示一级子评论，2表示二级子评论，以此类推',
  `content` text CHARACTER SET utf8 NOT NULL COMMENT '子评论内容主体',
  `paper_id` int(10) unsigned NOT NULL COMMENT '子评论所属的文章id',
  `comment_id` int(10) unsigned NOT NULL COMMENT '所属评论的id',
  `comment_date` datetime NOT NULL COMMENT '子评论发布的时间',
  `user_name` char(20) CHARACTER SET utf8 DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `type` (`type`),
  KEY `paper_id` (`paper_id`),
  KEY `comment_id` (`comment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for tags_index
-- ----------------------------
DROP TABLE IF EXISTS `tags_index`;
CREATE TABLE `tags_index` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '标签索引表，自增id',
  `name` char(20) CHARACTER SET utf8 NOT NULL COMMENT '标签索引表，标签名称',
  `papers_count` int(10) unsigned zerofill NOT NULL COMMENT '标签索引表，对应标签的文章数',
  UNIQUE KEY `id` (`id`) USING BTREE,
  UNIQUE KEY `name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for timeline_index
-- ----------------------------
DROP TABLE IF EXISTS `timeline_index`;
CREATE TABLE `timeline_index` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `timeline` char(7) NOT NULL,
  `papers_count` int(10) unsigned NOT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for user_table
-- ----------------------------
DROP TABLE IF EXISTS `user_table`;
CREATE TABLE `user_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account` char(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `user_name` char(20) CHARACTER SET utf8 NOT NULL,
  `avatar` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `email` char(50) DEFAULT NULL,
  `mobile` char(255) DEFAULT NULL,
  `register_date` datetime NOT NULL,
  `github_link` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `account` (`account`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
DROP TRIGGER IF EXISTS `add_trigger_before`;
DELIMITER ;;
CREATE TRIGGER `add_trigger_before` BEFORE INSERT ON `papers_table` FOR EACH ROW BEGIN
SET new.content = REPLACE(REPLACE(new.content, CHAR(10), ''), CHAR(13), '');
SET new.timeline = new.publish_date;
END
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `add_trigger_after`;
DELIMITER ;;
CREATE TRIGGER `add_trigger_after` AFTER INSERT ON `papers_table` FOR EACH ROW BEGIN
UPDATE tags_index SET papers_count = papers_count + 1 WHERE name = new.tag;
SET @count = (SELECT COUNT(*) FROM timeline_index WHERE timeline = new.timeline);
IF @count = 0 THEN
INSERT INTO timeline_index(timeline, papers_count) VALUES(new.timeline, 1);
ELSE
UPDATE timeline_index SET papers_count = papers_count + 1 WHERE timeline = new.timeline;
END IF;
END
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `update_trigger_before`;
DELIMITER ;;
CREATE TRIGGER `update_trigger_before` BEFORE UPDATE ON `papers_table` FOR EACH ROW SET new.content = REPLACE(REPLACE(new.content, CHAR(10), ''), CHAR(13), '')
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `update_trigger_after`;
DELIMITER ;;
CREATE TRIGGER `update_trigger_after` AFTER UPDATE ON `papers_table` FOR EACH ROW BEGIN
UPDATE tags_index SET papers_count = papers_count - 1 WHERE name = old.tag;
UPDATE tags_index SET papers_count = papers_count + 1 WHERE name = new.tag;
END
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `delete_trigger`;
DELIMITER ;;
CREATE TRIGGER `delete_trigger` AFTER DELETE ON `papers_table` FOR EACH ROW BEGIN
UPDATE tags_index SET papers_count = papers_count - 1 WHERE name = old.tag;
UPDATE timeline_index SET papers_count = papers_count - 1 WHERE timeline = old.timeline;
DELETE FROM comment_table WHERE paper_id = old.id;
DELETE FROM subcomment_table WHERE paper_id = old.id;
END
;;
DELIMITER ;
