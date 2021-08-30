/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 50732
 Source Host           : localhost:3306
 Source Schema         : gobloger

 Target Server Type    : MySQL
 Target Server Version : 50732
 File Encoding         : 65001

 Date: 30/08/2021 13:57:05
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for go_admin
-- ----------------------------
DROP TABLE IF EXISTS `go_admin`;
CREATE TABLE `go_admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `rid` int(11) NOT NULL DEFAULT '0' COMMENT '角色ID',
  `mobile` char(11) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '手机号',
  `uname` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '用户名',
  `pass` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '密码',
  `ip` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登陆IP',
  `login_time` datetime DEFAULT NULL COMMENT '登陆时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of go_admin
-- ----------------------------
BEGIN;
INSERT INTO `go_admin` VALUES (1, 0, '', 'admin', '$2y$10$htP.ywZjf3Zu6bsFZ.w/9.1UGMJJrkin666vrwh89rBvTGyv3qwbq', '::1', '2021-08-27 16:40:23', '2021-08-17 18:09:41');
COMMIT;

-- ----------------------------
-- Table structure for go_article
-- ----------------------------
DROP TABLE IF EXISTS `go_article`;
CREATE TABLE `go_article` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `category_id` int(11) NOT NULL DEFAULT '0',
  `image` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `weight` int(11) NOT NULL DEFAULT '0',
  `click` int(11) NOT NULL DEFAULT '0' COMMENT '点击量',
  `content` longtext CHARACTER SET utf8mb4 NOT NULL,
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of go_article
-- ----------------------------
BEGIN;
INSERT INTO `go_article` VALUES (1, '一次对 Tui Editor XSS 的挖掘与分析', 1, '/storage/images/20210625/f7079b992dfbf53cdf49d9439bebc111.jpeg', 1, 0, '###TOAST Tui Editor是一款富文本Markdown编辑器\n\n- TOAST Tui Editor是一款富文本Markdown编辑器，用于给HTML表单提供Markdown和富文本编写支持。最近我们在工作中需要使用到它，相比于其他一些Markdown编辑器，它更新迭代较快，功能也比较强大。另外，它不但提供编辑器功能，也提供了渲染功能（Viewer），也就是说编辑和显示都可以使用Tui Editor搞定。\n\n- Tui Editor的Viewer功能使用方法很简单：\n\nimport Viewer from \'@toast-ui/editor/dist/toastui-editor-viewer\';\nimport \'@toast-ui/editor/dist/toastui-editor-viewer.css\';\n\n\nconst viewer = new Viewer({\n    el: document.querySelector(\'#viewer\'),\n    height: \'600px\',\n    initialValue: `# Markdown`\n});\n调用后，Markdown会被渲染成HTML并显示在#viewer的位置。那么我比较好奇，这里是否会存在XSS。\n\n在Markdown编辑器的预览（Preview）位置也是使用Viewer，但是大部分编辑器的预览功能即使存在XSS也只能打自己（self-xss），但Tui Editor将预览功能提出来作为一个单独的模块，就不仅限于self了。\n\n0x01 理解渲染流程\n代码审计第一步，先理解整个程序的结构与工作流程，特别是处理XSS的部分。\n\n常见的Markdown渲染器对于XSS问题有两种处理方式：\n\n在渲染的时候格外注意，在写入标签和属性的时候进行实体编码\n渲染时不做任何处理，渲染完成以后再将整个数据作为富文本进行过滤\n相比起来，后一种方式更加安全（它的安全主要取决于富文本过滤器的安全性）。前一种方式的优势是，不会因为二次过滤导致丢失一些正常的属性，另外少了一遍处理效率肯定会更高，它的缺点是一不注意就可能出问题，另外也不支持直接在Markdown里插入HTML。\n\n对，Markdown里是可以直接插入HTML标签的，可以将Markdown理解为HTML的一种子集。\n\nTui Editor使用了第二种方式，我在他代码中发现了一个默认的HTML sanitizer，在用户没有指定自己的sanitizer时将使用这个内置的sanitizer：https://github.com/nhn/tui.editor/blob/48a01f5/apps/editor/src/sanitizer/htmlSanitizer.ts\n\n我的目标就是绕过这个sanitizer来执行XSS。代码不多，总结一下大概的过滤过程是：\n\n先正则直接去除注释与onload属性的内容\n将上面处理后的内容，赋值给一个新创建的div的innerHTML属性，建立起一颗DOM树\n用黑名单删除掉一些危险DOM节点，比如iframe、script等\n用白名单对属性进行一遍处理，处理逻辑是\n只保留白名单里名字开头的属性\n对于满足正则/href|src|background/i的属性，进行额外处理\n处理完成后的DOM，获取其HTML代码返回', '2021-08-17 18:57:33');
COMMIT;

-- ----------------------------
-- Table structure for go_auth_menu
-- ----------------------------
DROP TABLE IF EXISTS `go_auth_menu`;
CREATE TABLE `go_auth_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '菜单名称',
  `pid` int(11) NOT NULL DEFAULT '0' COMMENT '父级ID',
  `icon` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'icon',
  `route` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '路由',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT '权重',
  `show` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1显示、2隐藏',
  `son` tinyint(1) NOT NULL DEFAULT '0' COMMENT '子菜单',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of go_auth_menu
-- ----------------------------
BEGIN;
INSERT INTO `go_auth_menu` VALUES (1, '系统设置', 0, 'el-icon-setting', '', 0, 2, 1, '2021-06-15 16:38:52');
INSERT INTO `go_auth_menu` VALUES (2, '权限设置', 0, 'el-icon-lock', '', 0, 2, 1, '2021-06-11 17:20:05');
INSERT INTO `go_auth_menu` VALUES (3, '菜单设置', 2, '31', '/admin/auth.menu/index', 1, 2, 2, '2021-06-10 17:08:02');
INSERT INTO `go_auth_menu` VALUES (4, '角色设置', 2, '', '/admin/auth.role/index', 1, 2, 2, '2021-06-11 17:49:43');
INSERT INTO `go_auth_menu` VALUES (5, '添加\\修改', 3, '', '/admin/auth.menu/post', 0, 1, 2, '2021-06-16 11:28:41');
INSERT INTO `go_auth_menu` VALUES (6, '删除', 3, '', '/admin/auth.menu/delete', 0, 1, 2, '2021-06-16 11:29:45');
INSERT INTO `go_auth_menu` VALUES (7, '批量删除', 3, '', '/admin/auth.menu/deletes', 0, 1, 2, '2021-06-16 11:30:16');
INSERT INTO `go_auth_menu` VALUES (8, '添加\\修改', 4, '', '/admin/auth.role/post', 0, 1, 2, '2021-06-16 18:01:53');
INSERT INTO `go_auth_menu` VALUES (9, '删除', 4, '', '/admin/auth.role/delete', 0, 1, 2, '2021-06-16 18:02:19');
INSERT INTO `go_auth_menu` VALUES (10, '批量删除', 4, '', '/admin/auto.role/deletes', 0, 1, 2, '2021-06-16 18:03:11');
INSERT INTO `go_auth_menu` VALUES (11, '管理员', 2, '', '/admin/auth.admin/index', 0, 2, 2, '2021-06-16 18:04:27');
INSERT INTO `go_auth_menu` VALUES (12, '添加\\修改', 11, '', '/admin/auth.admin/post', 0, 1, 2, '2021-06-16 18:05:19');
INSERT INTO `go_auth_menu` VALUES (13, '删除', 11, '', '/admin/auth.admin/delete', 0, 1, 2, '2021-06-16 18:05:51');
INSERT INTO `go_auth_menu` VALUES (14, '批量删除', 11, '', '/admin/auth.admin/deletes', 0, 1, 2, '2021-06-16 18:06:53');
INSERT INTO `go_auth_menu` VALUES (15, '站点配置', 1, 'el-icon-c-scale-to-original', '/admin/config/index?active_name=basic', 0, 2, 2, '2021-06-21 16:39:05');
INSERT INTO `go_auth_menu` VALUES (16, '增加配置', 15, '', '/admin/config/post', 0, 1, 2, '2021-06-22 15:44:17');
INSERT INTO `go_auth_menu` VALUES (17, '更新配置', 15, '', '/admin/config/save', 0, 1, 2, '2021-06-22 15:44:51');
INSERT INTO `go_auth_menu` VALUES (18, '配置分组', 15, '', '/admin/config/group', 0, 1, 2, '2021-06-22 15:45:24');
INSERT INTO `go_auth_menu` VALUES (19, '附件管理', 1, 'el-icon-picture-outline', '/admin/general.files/index', 0, 2, 2, '2021-06-23 14:54:49');
INSERT INTO `go_auth_menu` VALUES (20, '附件修改', 19, '', '/admin/general.files/edit', 0, 1, 2, '2021-06-23 14:58:04');
INSERT INTO `go_auth_menu` VALUES (21, '附件删除', 19, '', '/admin/general.files/delete', 0, 1, 2, '2021-06-23 14:58:43');
INSERT INTO `go_auth_menu` VALUES (22, '附件批量删除', 19, '', '/admin/general.fiels/deletes', 0, 1, 2, '2021-06-23 14:59:33');
INSERT INTO `go_auth_menu` VALUES (23, '删除配置', 15, '', '/admin/config/delete', 0, 1, 2, '2021-06-23 15:03:26');
INSERT INTO `go_auth_menu` VALUES (24, '基础设置', 0, 'el-icon-menu', '', 0, 2, 1, '2021-06-25 11:46:40');
INSERT INTO `go_auth_menu` VALUES (25, '网站分类', 24, '', '/admin/category/index', 0, 2, 2, '2021-06-25 11:48:48');
INSERT INTO `go_auth_menu` VALUES (26, '添加\\修改', 25, '', '/admin/category/post', 0, 1, 2, '2021-06-25 11:50:05');
INSERT INTO `go_auth_menu` VALUES (27, '删除', 25, '', '/admin/category/delete', 0, 1, 2, '2021-06-25 11:50:36');
INSERT INTO `go_auth_menu` VALUES (28, '批量删除', 25, '', '/admin/category/deletes', 0, 1, 2, '2021-06-25 11:51:00');
INSERT INTO `go_auth_menu` VALUES (29, '系统工具', 0, 'el-icon-s-ticket', '', 0, 2, 1, '2021-07-03 17:18:09');
INSERT INTO `go_auth_menu` VALUES (30, '模块生成器', 29, '', '/admin/general.tool/index', 0, 2, 2, '2021-07-03 17:19:19');
INSERT INTO `go_auth_menu` VALUES (31, '文章管理', 24, '', '/admin/article/index', 1, 2, 1, '2021-08-17 18:40:59');
INSERT INTO `go_auth_menu` VALUES (32, '添加\\修改', 31, '', '/admin/article/post', 0, 1, 2, '2021-08-17 18:41:45');
INSERT INTO `go_auth_menu` VALUES (33, '删除', 31, '', '/admin/article/delete', 0, 1, 2, '2021-08-17 18:42:32');
INSERT INTO `go_auth_menu` VALUES (34, '批量删除', 31, '', '/admin/article/deletes', 0, 1, 2, '2021-08-17 18:42:51');
COMMIT;

-- ----------------------------
-- Table structure for go_auth_role
-- ----------------------------
DROP TABLE IF EXISTS `go_auth_role`;
CREATE TABLE `go_auth_role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '角色名称',
  `routes` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '权限ID',
  `desc` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '描述',
  `selected` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '级联选择',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of go_auth_role
-- ----------------------------
BEGIN;
INSERT INTO `go_auth_role` VALUES (1, '管理员', '1,15,17,19,20', '拥有很多权限', '[[1,15,17],[1,19,20]]', '2021-06-16 16:15:11');
COMMIT;

-- ----------------------------
-- Table structure for go_category
-- ----------------------------
DROP TABLE IF EXISTS `go_category`;
CREATE TABLE `go_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '分类名称',
  `pid` int(11) DEFAULT '0' COMMENT '父级ID',
  `url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '跳转地址',
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '图片地址',
  `tag` tinyint(1) DEFAULT NULL COMMENT 'tag,1首页，2热门，3推荐',
  `keywords` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '关键词',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '描述',
  `weigh` int(11) DEFAULT '0' COMMENT '权重',
  `status` tinyint(1) DEFAULT '1' COMMENT '1正常，2隐藏',
  `create_time` datetime DEFAULT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类详情',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of go_category
-- ----------------------------
BEGIN;
INSERT INTO `go_category` VALUES (1, '文章', 0, '/article', '', 2, '', 'go', 1, 1, '2021-08-17 18:14:28', '');
INSERT INTO `go_category` VALUES (2, '关于', 0, '/pages', '', 2, '', '关于', 2, 1, '2021-08-17 18:15:06', '一名在上海漂泊、流浪混迹与社会基层7年PHPER。\n但是不得不说：英雄虽迟暮，壮心犹在存。\n35岁敏感而又沉重，职业生涯所剩无几，但是我不得不继续迈步前行，提高职业竞争，从我做起，因此Go成了我目前的一个方向。\n');
INSERT INTO `go_category` VALUES (3, '友链', 0, '/link', '', 2, '', '友链', 3, 1, '2021-08-17 18:15:43', '');
COMMIT;

-- ----------------------------
-- Table structure for go_comments
-- ----------------------------
DROP TABLE IF EXISTS `go_comments`;
CREATE TABLE `go_comments` (
  `cid` int(11) NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `aid` int(11) NOT NULL DEFAULT '0' COMMENT '文章ID',
  `type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'article' COMMENT '评论类型',
  `pid` int(11) NOT NULL DEFAULT '0' COMMENT '父亲ID',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论名称',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '000000' COMMENT '邮箱',
  `ip` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'IP',
  `url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '网址',
  `body` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '评论内容',
  `create_time` int(11) NOT NULL DEFAULT '0' COMMENT '评论时间',
  PRIMARY KEY (`cid`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of go_comments
-- ----------------------------
BEGIN;
INSERT INTO `go_comments` VALUES (1, 1, 'article', 0, 'tang', '251784425@qq.com', '127.0.0.1:58017', '', 'hello word', 1629899994);
INSERT INTO `go_comments` VALUES (2, 1, 'article', 1, 'yii', '251784425@qq.com', '127.0.0.1:58017', '', '@tang nice to meet you', 1629900063);
INSERT INTO `go_comments` VALUES (3, 1, 'article', 2, 'jun', '000000@qq.com', '127.0.0.1:59589', '', '@yii @tang i want to do ', 1629900373);
INSERT INTO `go_comments` VALUES (4, 1, 'article', 0, 'ewe', '251784425@qq.com', '127.0.0.1:60608', '', '你说这是对的嘛', 1629912375);
INSERT INTO `go_comments` VALUES (5, 1, 'article', 1, 'exa', '251784425@qq.com', '127.0.0.1:60608', '', '@tang 感觉说的很好', 1629912428);
INSERT INTO `go_comments` VALUES (6, 1, 'article', 4, 'how', '251784425@qq.com', '127.0.0.1:62901', '', 'alert(1)', 1629930159);
INSERT INTO `go_comments` VALUES (7, 1, 'article', 6, 'jinh', '552440420@qq.com', '127.0.0.1:52225', '', '@how yes i so', 1629951747);
INSERT INTO `go_comments` VALUES (8, 1, 'article', 1, 'jiag', '251784425@qq.com', '127.0.0.1:52307', '', '@tang how do it', 1629951860);
INSERT INTO `go_comments` VALUES (9, 1, 'article', 8, 'tangyii', '251784425@qq.com', '127.0.0.1:52746', '', '@jiag i am tangyiijun', 1629951974);
INSERT INTO `go_comments` VALUES (10, 1, 'article', 0, 'www', '251784425@qq.com', '127.0.0.1:53791', '', 'w我来了', 1629952201);
INSERT INTO `go_comments` VALUES (11, 1, 'article', 10, 'low', '251784425@qq.com', '127.0.0.1:53791', '', '@www 方法是发视频发视频返回福州的自行车发自拍好评v中xvvxvv都猴猴发哦发的好舒服后阿福后撒返回发顺丰好烦好烦红啊丰厚啊丰厚啊分红', 1629952324);
INSERT INTO `go_comments` VALUES (12, 1, 'article', 5, 'mike', '251784425@qq.com', '127.0.0.1:64708', '', '@exa how to do it', 1630051781);
INSERT INTO `go_comments` VALUES (13, 0, 'pages', 0, 'kk', '251784425@qq.com', '127.0.0.1:51675', '', 'yes i love you', 1630052567);
INSERT INTO `go_comments` VALUES (14, 0, 'pages', 13, 'dd', '251784425@qq.com', '127.0.0.1:54061', '', '@kk thanks for much!', 1630053146);
INSERT INTO `go_comments` VALUES (15, 1, 'article', 11, 'xxxx', '251784425@qq.com', '127.0.0.1:54710', '', '@low 3231', 1630053323);
INSERT INTO `go_comments` VALUES (16, 1, 'article', 15, 'xxs', '251784425@qq.com', '127.0.0.1:55655', '', '@xxxx 模式拍的恶发是非得失', 1630053508);
COMMIT;

-- ----------------------------
-- Table structure for go_comments_paths
-- ----------------------------
DROP TABLE IF EXISTS `go_comments_paths`;
CREATE TABLE `go_comments_paths` (
  `ancestor` int(11) NOT NULL DEFAULT '0' COMMENT '父级commentId',
  `descendant` int(11) NOT NULL DEFAULT '0' COMMENT '后代commentId',
  `len` int(11) NOT NULL DEFAULT '0' COMMENT '层级',
  PRIMARY KEY (`ancestor`,`descendant`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of go_comments_paths
-- ----------------------------
BEGIN;
INSERT INTO `go_comments_paths` VALUES (1, 1, 0);
INSERT INTO `go_comments_paths` VALUES (1, 2, 0);
INSERT INTO `go_comments_paths` VALUES (1, 3, 0);
INSERT INTO `go_comments_paths` VALUES (1, 5, 0);
INSERT INTO `go_comments_paths` VALUES (1, 8, 0);
INSERT INTO `go_comments_paths` VALUES (1, 9, 0);
INSERT INTO `go_comments_paths` VALUES (1, 12, 0);
INSERT INTO `go_comments_paths` VALUES (2, 2, 0);
INSERT INTO `go_comments_paths` VALUES (2, 3, 0);
INSERT INTO `go_comments_paths` VALUES (3, 3, 0);
INSERT INTO `go_comments_paths` VALUES (4, 4, 0);
INSERT INTO `go_comments_paths` VALUES (4, 6, 0);
INSERT INTO `go_comments_paths` VALUES (4, 7, 0);
INSERT INTO `go_comments_paths` VALUES (5, 5, 0);
INSERT INTO `go_comments_paths` VALUES (5, 12, 0);
INSERT INTO `go_comments_paths` VALUES (6, 6, 0);
INSERT INTO `go_comments_paths` VALUES (6, 7, 0);
INSERT INTO `go_comments_paths` VALUES (7, 7, 0);
INSERT INTO `go_comments_paths` VALUES (8, 8, 0);
INSERT INTO `go_comments_paths` VALUES (8, 9, 0);
INSERT INTO `go_comments_paths` VALUES (9, 9, 0);
INSERT INTO `go_comments_paths` VALUES (10, 10, 0);
INSERT INTO `go_comments_paths` VALUES (10, 11, 0);
INSERT INTO `go_comments_paths` VALUES (10, 15, 0);
INSERT INTO `go_comments_paths` VALUES (10, 16, 0);
INSERT INTO `go_comments_paths` VALUES (11, 11, 0);
INSERT INTO `go_comments_paths` VALUES (11, 15, 0);
INSERT INTO `go_comments_paths` VALUES (11, 16, 0);
INSERT INTO `go_comments_paths` VALUES (12, 12, 0);
INSERT INTO `go_comments_paths` VALUES (13, 13, 0);
INSERT INTO `go_comments_paths` VALUES (13, 14, 0);
INSERT INTO `go_comments_paths` VALUES (14, 14, 0);
INSERT INTO `go_comments_paths` VALUES (15, 15, 0);
INSERT INTO `go_comments_paths` VALUES (15, 16, 0);
INSERT INTO `go_comments_paths` VALUES (16, 16, 0);
COMMIT;

-- ----------------------------
-- Table structure for go_config
-- ----------------------------
DROP TABLE IF EXISTS `go_config`;
CREATE TABLE `go_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'key',
  `value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '值',
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'label',
  `group` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分组',
  `rule` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '验证',
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '类型',
  `options` varchar(800) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '选项值',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of go_config
-- ----------------------------
BEGIN;
INSERT INTO `go_config` VALUES (1, 'group', '{\"basic\":\"基础配置\",\"dictionary\":\"配置分组\",\"email\":\"邮箱配置\"}', '配置分组', 'dictionary', NULL, 'json', '');
INSERT INTO `go_config` VALUES (2, 'title', 'GoBlog', '网站名称', 'basic', 'require', 'input', '');
INSERT INTO `go_config` VALUES (3, 'keywords', 'GoBlog', '关键词', 'basic', '', 'input', '');
INSERT INTO `go_config` VALUES (4, 'email_type', '2', '类型', 'email', '', 'select', '[{\"id\":\"1\",\"name\":\"QQ\"},{\"id\":\"2\",\"name\":\"163\"}]');
INSERT INTO `go_config` VALUES (6, 'description', 'GoBlog', '描述', 'basic', '', 'input', '');
INSERT INTO `go_config` VALUES (7, 'record', '蜀ICP备15010979号-1', '备案号', 'basic', '', 'input', '');
INSERT INTO `go_config` VALUES (8, 'version', '1.0.0', '版本号', 'basic', '', 'input', '');
INSERT INTO `go_config` VALUES (11, 'admin_title', 'GoBlog', '后台名称', 'basic', '', 'input', '');
INSERT INTO `go_config` VALUES (13, 'logo', '/storage/images/20210625/e56f623289dfc113a3e24caaa4919452.jpeg', 'Logo', 'basic', '', 'Image', '');
INSERT INTO `go_config` VALUES (14, 'persons', '一名在上海漂泊、流浪混迹于社会基层7年PHPER。英雄虽迟暮，壮心犹在存\n<br>so...<br>立下Flag,学习Go从这里开始ba～', '个人简介', 'basic', '', 'Textarea', '');
INSERT INTO `go_config` VALUES (15, 'copyright', 'Copyright &copy; 2021 Powered by GoBlog', '版权', 'basic', '', 'Input', '');
INSERT INTO `go_config` VALUES (16, 'seotitle', 'go,blog,php,pyton', 'seo标题', 'basic', '', 'Input', '');
COMMIT;

-- ----------------------------
-- Table structure for go_files
-- ----------------------------
DROP TABLE IF EXISTS `go_files`;
CREATE TABLE `go_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '源文件名称',
  `size` double(11,2) NOT NULL DEFAULT '0.00' COMMENT '文件大小',
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文件路径',
  `ext` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '后缀',
  `mime_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文件类型',
  `width` int(11) NOT NULL DEFAULT '0' COMMENT '图像宽',
  `height` int(11) NOT NULL DEFAULT '0' COMMENT '图像高',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of go_files
-- ----------------------------
BEGIN;
INSERT INTO `go_files` VALUES (1, 'Foxmail20210621042636.png', 2.38, '/storage/images/20210623/346a7a7b1187918e0d68265436022c3e.png', 'png', 'image/png', 223, 218, '2021-06-23 11:58:46');
INSERT INTO `go_files` VALUES (2, 'src=http___www.gzxdxh.com_uploads_allimg_200312_06235222C_0.jpg&refer=http___www.gzxdxh.jpeg', 38.16, '/storage/images/20210625/f7079b992dfbf53cdf49d9439bebc111.jpeg', 'jpeg', 'image/jpeg', 580, 300, '2021-06-25 11:34:39');
INSERT INTO `go_files` VALUES (3, 'u=4084129530,3438713827&fm=26&fmt=auto&gp=0.webp', 8.11, '/storage/images/20210625/854c41a9b0bb3298f9a45892b8849046.webp', 'webp', 'image/webp', 348, 347, '2021-06-25 11:39:36');
INSERT INTO `go_files` VALUES (4, 'src=http___jn.php.tedu.cn_img_201709_1504771686441.png&refer=http___jn.php.tedu.jpeg', 9.53, '/storage/images/20210625/e56f623289dfc113a3e24caaa4919452.jpeg', 'jpeg', 'image/jpeg', 536, 313, '2021-06-25 11:40:15');
INSERT INTO `go_files` VALUES (5, 'src=http___pic.soutu123.com_back_pic_04_26_43_285839aea9ef03c.jpg!_fw_700_quality_90_unsharp_true_compress_true&refer=http___pic.soutu123.jpeg', 41.38, '/storage/images/20210625/8083a27271b6b387f5f26530b1dacc6e.jpeg', 'jpeg', 'image/jpeg', 650, 514, '2021-06-25 11:43:48');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
