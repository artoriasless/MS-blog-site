/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50624
Source Host           : localhost:3306
Source Database       : ms_blog

Target Server Type    : MYSQL
Target Server Version : 50624
File Encoding         : 65001

Date: 2016-10-20 10:45:00
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
  `user_id` int(10) unsigned DEFAULT NULL COMMENT '评论的用户id',
  `user_name` char(20) CHARACTER SET utf8 NOT NULL COMMENT '评论的用户名',
  `paper_id` int(10) unsigned NOT NULL COMMENT '评论所属的文章id',
  `comment_date` datetime NOT NULL COMMENT '评论日期',
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of comment_table
-- ----------------------------

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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of papers_table
-- ----------------------------
INSERT INTO `papers_table` VALUES ('1', '【jQuery】animate、slide、fade等动画的连续触发及滞后反复执行的bug', 'jquery', '', '2016-01-09 00:00:00', '2016-01', 'jquery中，使用animate、slide、fade等动画，如果多次触发（click、hover等），由于其执行是一个持续的过程，如果不采取一定的措施，会导致滞后多次执行的bug。', '<strong>【Preface】</strong><p>因为最近要做个操作选项的呼出，然后就想到了用默认隐藏，鼠标划过的时候显示的方法。</p><p>刚开始打算添加一个class=\"active\"，直接触发mouseover（或者mouseenter）的时候add，mouseout（或者mouseleave）的时候remove，这个解决方法很简单，也很实用，但是体验上可能不是那么酷炫，即没有动画的中间过渡过程，所以就想到了用animate或者slide这些jQuery的动画，然后一开始讲真，这个插件自己写，会碰到些问题，不太好实现（毕竟js掌握的不是很到位），然后听同事讲去找找jquery，导入后直接引用就可以了。</p><br><strong>【Main Body】</strong><p>网上找了一圈，有很多插件做得很赞，而且各种浏览器下的兼容性也能解决。不过个人而言，用到的地方很少，而且又要引入外部文件（可能会影响一点加载速度），有点不划算，最后找到一个用jquery内置的slide这些动画函数，基本OK了。</p><p class=\"sub-chapter\">-- bug重现 --</p><p>原本想做个动图的，好像太麻烦了，还是上代码吧。这个问题看本文的标题就应该知道怎么回事了，如果是没接触过问题的，可以先把代码拷贝下来试一下。</p></p>以animate动画为例（head等标签，jquery等js类库已经省去）：</p><div class=\"code-container\"><code><xmp><div style=\"width:70%;margin:50px auto;height:300px;\"></xmp><xmp class=\"indent-1\"><div id=\"test\" style=\"width:900px;height:100px;border:1px solid red;overflow:hidden;\"></xmp><xmp class=\"indent-2\"><div class=\"test\" style=\"margin-left:-6em\"></xmp><xmp class=\"indent-3\"><a>测试用的文字<i class=\"fa fa-arrow-right\"></i></a></xmp><xmp class=\"indent-2\"></div></xmp><xmp class=\"indent-1\"></div></xmp><xmp></div></xmp><xmp><script></xmp><xmp class=\"indent-1\">$(\'#test\').on(\'mouseover\', function() {</xmp><xmp class=\"indent-2\">var $thisTest = $(this).find(\'div.test\');</xmp><xmp class=\"indent-2\">$thisTest.css(\'position\', \'relative\');</xmp><xmp class=\"indent-2\">//  $thisTest.stop();</xmp><xmp class=\"indent-2\">$thisTest.filter(\':not(:animated)\').animate({marginLeft:\'0\'});</xmp><xmp class=\"indent-1\">})</xmp><xmp class=\"indent-1\">.on(\'mouseout\', function() {</xmp><xmp class=\"indent-2\">var $thisTest = $(this).find(\'div.test\');</xmp><xmp class=\"indent-2\">$thisTest.css(\'position\', \'relative\');</xmp><xmp class=\"indent-2\">//  $thisTest.stop();</xmp><xmp class=\"indent-2\">$thisTest.filter(\':not(:animated)\').animate({marginLeft:\'-6em\'});</xmp><xmp class=\"indent-1\">})</xmp><xmp></script></xmp></code></div><p>上面这份代码，是我后来百度了一下后，别人提到的另一种解决方案，但我个人感觉不是特别完美；stop()这个方法被我注释掉了，是我个人认为最完美的解决方法，至于差别我在后面提。</p><p>一开始的写法如下：</p><div class=\"code-container\"><code><xmp>$thisTest.animate({marginLeft:\'0em\'});</xmp><xmp>$thisTest.animate({marginLeft:\'-6em\'});</xmp></code></div><p>这两句代码，是没有filter()函数的，也就是最开始碰到这个bug的时候的代码的样子。</p><p>这个bug产生原因就是事件在短时间内（上一个动画未播放完），动画累积导致的（估计碰到这个问题的，回过头去看看代码都知道这个原因）。所以，解决的方法，有两个。</p><br><strong>【filter】</strong><p>一个就是用filter过滤，在动画发生前，过滤掉正在进行动画的元素，只让上一个动画已经结束的元素才能触发新的事件。</p><p>然后这就带来一个新问题了，当我把鼠标移至对应的内容上，mouseover事件触发，这个时候，在动画还未结束的时候，我再将鼠标移除对应内容区域外，mouseleave事件触发，但是因为上一个动画还未结束，所以即使触发了该事件，但预期的函数并未执行，此时预期中的“mouseleave事件触发，内容隐藏”结果便无法做到了。</p><br><strong>【stop】</strong><p>对于stop()，不管了解过没，还是再搬一遍吧。</p><div class=\"code-container\"><code><xmp>//  语法结构</xmp><xmp>$(\'#div\').stop();//停止当前动画，继续下一个动画</xmp><xmp>$(\'#div\').stop(true);//清除元素的所有动画</xmp><xmp>$(\'#div\').stop(false, true);//让当前动画直接到达末状态 ，继续下一个动画</xmp><xmp>$(\'#div\').stop(true, true);//清除元素的所有动画，让当前动画直接到达末状态</xmp></code></div><p>这个方案的思路，就是简单的：当我mouseover的时候，触发对应的动画，但是在动画还未结束的时候，我却要mouseleave，同时触发mouseleave对应的动画，这个时候我便需要停止对应元素正在进行的动画。然后，这个bug也就不存在了</p><p>最后，好像也没啥总结的，其实就是对animate、slide、fade动画函数的熟悉吧，同时再熟悉一下stop有参数无参数的区别</p><p>刚开始没想到用stop，过了一两天后，偶然看到API的时候，看到了stop，才突然有了用stop解决这个bug的设想。</p><br><p>PS：其实最无语的是，为什么刚开始的没有在百度找到呢（只怪自己一开始没输对关键字）。</p>');
INSERT INTO `papers_table` VALUES ('2', '【bootstrap】tooltip在触发元素remove后的小bug', 'bootstrap', 'tooltip', '2016-01-15 00:00:00', '2016-01', 'bootstrap中的tooltip，当遇到以下情形时：将触发tooltip的a标签进行remove后，其对应的tooltip会一直显示在页面上，导致出现bug。', '<strong>【Preface】</strong><p>现在页面中有个div，这个div右上角（或者其他位置）有个 × 的图标（这个图标添加tooltip工具提示），光标移到这个图标时，触发tooltip，提示“点击移除”这样类似的字样，然后点击后，把这个div作remove()这样的删除操作。</p><p>然后，问题来了，因为这个div被remove()了，导致生成的tooltip对应的 × 图标也被remove()，因为找不到，所以对应的mouseout（可能是mouseleave事件，参考了一下bootstrap的源码，没找出头绪，猜测是这两个的其中一个）事件就没法触发，导致tooltip工具提示一直在那里，出bug了。</p><br><strong>【Main Body】</strong><p>文字不多讲，先附代码（bootstrap、jquery的引入就不写了，节省篇幅）：</p><div class=\"code-container\"><code><xmp><div style=\"width:70%;margin:50px auto;height:300px;\"></xmp><xmp class=\"indent-1\"><a id=\"test01\" href=\"javascript:;\" data-toggle=\"tooltip\" title=\"反馈错误\" data-placement=\"top\" data-container=\"body\"></xmp><xmp class=\"indent-2\"><i class=\"fa fa-bug\"></i></xmp><xmp class=\"indent-1\"></a></xmp><xmp class=\"indent-1\"><a id=\"test\" href=\"javascript:;\" data-toggle=\"tooltip\" title=\"点击移除\" data-placement=\"top\" data-container=\"body\"></xmp><xmp class=\"indent-2\"><i class=\"fa fa-times\"></i></xmp><xmp class=\"indent-1\"></a></xmp><xmp></div></xmp><xmp><script></xmp><xmp class=\"indent-1\">$(\'[data-toggle=\"tooltip\"]\').tooltip();</xmp><xmp class=\"indent-1\">$(\'#test\').on(\'click\', function() {</xmp><xmp class=\"indent-2\">var $this = $(this);</xmp><xmp class=\"indent-2\">$this.remove();</xmp><xmp class=\"indent-2\">$(\'.tooltip.fade.top.in\').remove();//这行代码是我个人用来解决这个问题而添加的</xmp><xmp class=\"indent-1\">})</xmp><xmp></script></xmp></code></div><p>再放一张图（这里以火狐下为例，测试过再各个主流浏览器下都一样，就不多放图了），来看一下为什么我会使用这个方法的。</p><div class=\"code-container\"><code><xmp>$(\'.tooltip.fade.top.in\').remove();</xmp></code></div><div class=\"img-container size-md\"><img src=\"res/papers/2-01.jpg\"></div><p>光标移开后，再聚焦到对应的×图标上，对比一下id，发现id变了。</p><p>这里，顺便说一下，原本我是打算去看bootstrap的源码，看看他在tooltip这块的源码怎么写的，好从根源上解决问题。后来看了一部分后，放弃了，对我现在的半吊子水平来说，压力有点大。</p><p>但是至少从这个来说，生成的tooltip，id是随机的，而且tooltip的隐藏，并不是\"display:none\"的隐藏，应该是类似\"remove()\"的隐藏。</p><p>然后，使用了我的那个方法后，测试后之后（图片太费劲又浪费网络，就不放了），把 × 图标移除后，没有出现对应的tooltip图标不消失的bug，鼠标再次划过bug图标，也可以正常显示tooltip工具提示，至少现阶段看来没问题。</p><br><p class=\"sub-chapter\">-- 2016-01-16更新 --</p><p>接收到一些大神的指导，解决方法如下：</p><p>在remove之前，先将tooltip销毁</p><div class=\"code-container\"><code><xmp>$(\'#test\').tooltip(\'destroy\').remove();</xmp></code></div><p>结合我自己的方法，再补充一下destroy实例，应该是没有问题了。</p>');
INSERT INTO `papers_table` VALUES ('3', '【json】读取本地json时，无法读取到的bug时，自己踩的一些坑', 'json', null, '2016-02-10 00:00:00', '2016-02', '之前自己做了个小东西，反正就是中间有一部要读取本地的json文件，然后就需要自己写一个自定义json文件用作测试，然后就碰到了一个小坑，发现读取失败（也就是读取成功后的回调函数没有执行）。另外，读取json文件用的是jquery提供的getJSON()方法。', '<strong>【Preface】</strong><p>最近做一个小东西，然后中间有一部要读取本地的json文件，就需要自定义一个json文件用作测试，然后就碰到了一个小坑，发现读取失败（也就是读取成功后的回调函数没有执行）。另外，读取json文件用的是jquery提供的getJSON()方法。</p><p>另外有一个问题要提前说一下，本地读取json文件，chrome会读取失败（可能是我有些参数没设对，反正后来也没有去折腾），所以下面的测试，建议在FireFox下进行。</p><br><strong>【Main Body】</strong><p>这么说可能还有点不是特别直观，贴一下代码再附上描述吧（用的jquery封装好的方法，没办法，真的省了很多造轮子的时间）：</p><div class=\"code-container\"><code><xmp><script></xmp><xmp class=\"indent-1\">$.getJSON(path, function(data) {</xmp><xmp class=\"indent-2\">console.info(data)</xmp><xmp class=\"indent-2\">console.info(\'get json success!\')</xmp><xmp class=\"indent-1\">}</xmp><xmp class=\"indent-1\">console.info(\'another step!\')</xmp><xmp></script></xmp></code></div><p>然后，打开控制台，发现结果只打印了another step!这个字符串，也就是说，没有进到getJSON的回调函数中去。</p><p>后来找了半天，百度了半天，发现有个百度回答好像提到了单双引的问题。</p><p>抱着试一试的心态，把所有的单引号都改成了单引号，结果正常读取到了，即对应代码中，打印了another step!和get json success!这两个字符串。（因为回调的关系，所以another step这个字符串先被打印）</p><br><strong>【Summary】</strong><p>之前了解到的，json数据格式和js、html以及xml这样的标记语言语法类似，所以先入为主，但是json本地文件好像有有一些不同，用单引果然会出问题。</p><p>下一次如果发现本地json文件读取失败了，可以看看是不是因为用了单引号。</p><br><p class=\"sub-chapter\">-- 2016-08-05更新 --</p><p>最近写的时候有碰到坑了，好像还是自己挖的。</p><p>在json文件里面使用注释：//和/**/这两种，好像又无法读取了，后来把这些注释全部去掉后，又正常能读取了。</p><p>后来百度了一下，查到一点别人给的回答：</p><div class=\"refer-content\"><p>按照json.org上的说法，本身的JSON语法上就不包含注释</p><p>虽然可以按照JS的方式去注释处理了，不过可能不保证所有的JSON解析包都支持了。比如这两个就会报错:</p><p>http://www.oschina.net/p/json.simple</p><p>http://www.oschina.net/p/svenson</p><p>另外页面前端对JSON的处理,也不是简单的eval就够了,可以参考下jQuery对JSON的解析处理</p></div><p>以上，就是全部了。</p>');
INSERT INTO `papers_table` VALUES ('4', '【javascript】新增DOM节点无法监听事件，以及对于事件托管的个人感受', 'javascript', 'jquery，事件托管', '2016-03-20 00:00:00', '2016-03', '写监听事件及对应的触发函数，遇到的一点小坑。针对页面上已存在DOM节点（直接写在HTML上的），获取对应的DOM进行事件监听，没有一点问题，但是如果监听的某一个DOM节点是通过js动态生成的话，发现之前的事件监听无法获取到该DOM节点。', '<strong>【Preface】</strong><p>最近写监听事件及对应的触发函数，针对页面上已存在DOM节点（直接写在HTML上的），获取对应的DOM进行事件监听，没有一点问题，但是如果监听的某一个DOM节点是通过js动态生成的话，发现之前的事件监听无法获取到该DOM节点。</p><br><strong>【Main Body】</strong><p>照例，贴上示例代码配合说明（关于js，也是使用了jquery类库，又偷了点懒）：</p><strong>【html】</strong><div class=\"code-container\"><code><xmp><div id=\"testContainer\"></xmp><xmp class=\"indent-1\"><button class=\"test-btn\">测试的按钮</button></xmp><xmp></div></xmp></code></div><strong>【javascript】</strong><div class=\"code-container\"><code><xmp><script></xmp><xmp class=\"indent-1\">$(\'.test-btn\').on(\'click\', function() {</xmp><xmp class=\"indent-2\">alert(\'click!\');</xmp><xmp class=\"indent-2\">var test = \'<button class=\"test-btn\">测试的按钮</button>\';</xmp><xmp class=\"indent-2\">$(\'testContainer\').append(test);</xmp><xmp class=\"indent-1\">}</xmp><xmp class=\"indent-1\">/* 以下是修改之后、没有本文提到的问题的写法</xmp><xmp class=\"indent-1\">$(\'#testContainer\').on(\'click\', \'.test-btn\', function() {</xmp><xmp class=\"indent-2\">alert(\'click!\');</xmp><xmp class=\"indent-2\">var test = \'<button class=\"test-btn\">测试的按钮</button>\';</xmp><xmp class=\"indent-2\">$(\'testContainer\').append(test);</xmp><xmp class=\"indent-1\">}</xmp><xmp class=\"indent-1\">*/</xmp><xmp></script></xmp></code></div><p>上述示例代码，点击按钮后，会弹出一个alert，然后生成一个新的按钮，class名为test-btn，和原先的按钮一样。</p><p>运行上述代码后，就会发现点击了按钮之后，alert弹出来了，之后按钮也生成了，但是点击新生成的按钮，却是没有反应，换而言之，没有获取到这个DOM节点。</p><p>Why？！明明class名是对的，但是就是没有获取到呢？</p><p>根据我自己的理解，javascript的监听事件，应该是以页面载入完成后，生成的DOM树为准，即新添加的DOM节点，不在最初生成的DOM树里面，所以他是一直没法获取到新生成的DOM节点的。</p><p>之后，用了事件托管，也就是事件代理（以jquery为准），解决了上述问题。关于事件托管的一些个人看法及优点，在后面讲。</p><br><strong>【Summary】</strong><p>之前看到过一个关于事件监听和事件托管的一个比喻，个人感觉比较贴切，现在转述过来，希望有所帮助：</p><div class=\"refer-content\"><p>事件委托：现实中好比有100 个学生同时在某天中午收到快递，但这100 个学生不可能同时站在学校门口等，那么都会委托门卫去收取，然后再逐个交给学生。</p><p>假如这个时候新增了一个DOM元素，就好比新转来了一个学生，但是身份证明（比如学生证还没办下来），这个学生直接去门卫那里拿，因为没有身份证明，所以拿不到快递。</p><p>这个时候如果是委托门卫收取，门卫会根据对应的快递信息，将快递分发给该学生。</p><p>也就是解决了之前提到的，对于新增的DOM节点，javascript无法获取到对应的DOM元素。</p></div><p>另外，关于事件托管的优点，也在这里再转述一下吧（虽说都是套话）：</p><div class=\"refer-content\"><p>1．管理的函数变少了。不需要为每个元素都添加监听函数。对于同一个父节点下面类似的子元素，可以通过委托给父元素的监听函数来处理事件。</p><p>2．可以方便地动态添加和修改元素，不需要因为元素的改动而修改事件绑定。</p><p>3．JavaScript和DOM节点之间的关联变少了，这样也就减少了因循环引用而带来的内存泄漏发生的概率。</p></div><p>以上，就是关于事件托管方面的一点个人感受了。</p><br><p class=\"sub-chapter\">-- 2016-08-08更新 --</p><p>补充一点，关于事件托管的原理：利用冒泡事件的原理，将事件添加到父元素上，触发执行效果。</p>');
INSERT INTO `papers_table` VALUES ('5', '【html&css】关于input输入框，在移动端，enter显示为“搜索”', 'html&css', 'html5，webapp', '2016-07-15 00:00:00', '2016-07', '最近做一个项目，有一个小模块带有搜索功能。之前的前辈们直接监听keyup事件，即实时搜索（因为手机屏幕就那么点，没地方放“搜索”按钮），但是用过好多app后，感觉这一操作有点“反人类”（夸张了），而且动不动就去请求后台（虽说设置了500ms的延迟，但还是有点不够人性化），后来就想到了用大多数app的做法，监听enter事件，同时将“前往”两个字修改为“搜索”。', '<strong>【Preface】</strong><p>最近做一个项目，有一个小模块带有搜索功能，总之经历了一大堆蛋疼的尝试后细节调整后，改成了标题中写的那样。你问这么简单的问题还用尝试和修改细节？直接百度就出来答案了。</p><p>好吧，一开始确实挺简单的，直接监听enter事件，然后触发渲染搜索结果的事件，OK，1分钟不到，搞定。</p><p>之后过了一两天，听到别人讲，这个回车显示的是“前往”，能不能把它改成“搜索”啊。这时候才想起来，忽略了细节。</p><p>另外，之前的前辈们直接监听keyup事件，即实时搜索（因为手机屏幕就那么点，没地方放“搜索”按钮），但是用过好多app后，感觉这一操作有点“反人类”（夸张了），而且动不动就去请求后台（虽说设置了500ms的延迟，但还是有点不够人性化），后来就想到了用大多数app的做法，监听enter事件，同时将“前往”两个字修改为“搜索”。</p><p>PS：好吧，上一段是把东西调整好后总结的，其实中间没有一下子想到这个细节问题。</p><br><strong>【Main Body】</strong><p>废话不多说，直接上代码吧，至于效果，有兴趣的可以自己用手机试一下，截图就不放了：</p><div class=\"code-container\"><code><xmp><form></xmp><xmp class=\"indent-1\"><input type=\"search\" placeholder=\"input keyword\" onkeypress=\"if(event.keyCode==13){event.preventDefault();search();}\"></xmp><xmp></form></xmp></code></div><p>上面的这种写法好像不是特别规范，但是关键的一些内容都在了：主要是先将input的type设为search，然后在input外层套一个form表单，有的时候我们并不需要submit，所以就需要event.preventDefault()，然后去执行我们需要的事情——search()这个函数中。</p><br><strong>【Summay】</strong><p>之前其实也的时候也百度找了一下，其实原理很简单，就是input的type=search，然后再在外层套一个form表单，但是好多地方细节内容并没说清楚。</p><p>比如说，可能我们的搜索功能，用的是异步的ajax，而非表单提交后刷新页面，这个时候就需要进行阻止默认事件，这一点就没讲明。</p><p>而且看了那么多网站的内容后，有的时候真心想吐槽，这抄也抄的太没水准了，完全也不去看一下，以及里面写的内容的细节方面，完全就是把另一个网站的内容照搬过来了。</p><p>PS：最后吐槽一句，难怪好多人说百度不靠谱，其实不靠谱的是这些网站，很多内容都是一模一样（就连错，也是一模一样），然后网友心里不爽了，只能让百度来背锅了。但是百度这个铺天盖地的广告，确实让人不得不骂。O(∩_∩)O哈哈~</p>');
INSERT INTO `papers_table` VALUES ('6', '【javascript】关于js对象中，属性的“非常规”使用感受', 'javascript', 'json', '2016-07-25 00:00:00', '2016-07', '之前关于js中对象的介绍，稍微了解到一点，js对象操作属性有两种方式：点号引用和中括号引用。后来实际使用中，感觉好像如果使用中括号，那对应的属性名，其实和数组的索引原理类似（至少看起来）。', '<strong>【Preface】</strong><p>之前关于js中对象的介绍，稍微了解到一点，js对象操作属性有两种方式：点号引用和中括号引用。</p><p>后来实际使用中，感觉好像如果使用中括号，那对应的属性名，其实和数组的索引原理类似（至少看起来），然后根据实际应用，总结了一种“非常规”用途，稍微扩展一下的内容，好像都可以从这一点延伸扩展。</p><br><strong>【Main Body】</strong><p>先贴一下代码，把在preface中提到的两种方式更直观地展现一下：</p><div class=\"code-container\"><code><xmp><script></xmp><xmp class=\"indent-1\">var obj = {},</xmp><xmp class=\"indent-2\">attr1 = \'aaa\',</xmp><xmp class=\"indent-2\">attr2 = \'bbb\';</xmp><xmp class=\"indent-1\">obj.aaa = \'000\';</xmp><xmp class=\"indent-1\">console.info(obj.aaa);</xmp><xmp class=\"indent-1\">obj[\'aaa\'] = \'111\';</xmp><xmp class=\"indent-1\">obj[attr2] = \'222\';</xmp><xmp class=\"indent-1\">console.info(obj.aaa);</xmp><xmp class=\"indent-1\">console.info(obj[\'aaa\']);</xmp><xmp class=\"indent-1\">console.info(obj[attr1]);</xmp><xmp class=\"indent-1\">console.info(obj.bbb);</xmp><xmp class=\"indent-1\">console.info(obj[\'bbb\']);</xmp><xmp class=\"indent-1\">console.info(obj[attr2]);</xmp><xmp></script></xmp></code></div><p>运行结果如下图所示：</p><div class=\"img-container size-xs\"><img src=\"res/papers/12-01.jpg\"></div><p>如图可见，上述代码中三种引用方式进行属性读取、修改。（好吧，其实是两种，只不过当属性名为一个变量时，也当做一种情况了）</p><br><strong>【比对匹配】</strong><p>假设现在有如下场景，后台返回一个指定编码，对应指定的内容，详细信息如下：</p><div class=\"refer-content\"><p>\'-1\' : \'到店\',</p><p>\'0\' : \'现付\',</p><p>\'10\' : \'网银\',</p><p>\'20\' : \'支付宝\',</p><p>\'30\' : \'微信\',</p><p>\'40\' : \'刷卡\',</p><p>\'90\' : \'拉卡拉\',</p><p>\'95\' : \'第三方平台\',</p><p>\'97\' : \'优惠券\',</p><p>\'98\' : \'账户余额\',</p><p>\'99\' : \'积分\',</p><p>\'100\': \'会员卡\',</p><p>\'101\': \'店内会员卡\',</p><p>\'102\': \'储值卡\',</p><p>\'110\': \'线下支付\',</p><p>\'111\': \'挂账\'</p></div><p>在这里不得不先吐槽一下这个场景假设的有点不太现实，毕竟后台为什么不直接传对应的内容呢。好吧，暂且不用管这个，就假设有这么一个情景需要进行内容的比对匹配。</p><p>常规方式，可能想到定义一个数组，但是这些要比对的内容，对应的编码不连续啊，好像用数组不太适用啊。</p><p>所以另一种方式，可能就是写个swtich，然后一个个比对。但是如果要比的内容有100项，乃至1000项呢···这个时候就有点尴尬了。</p><p>最后，为了省点代码，就用js里面的对象属性当做索引来解决这一问题。</p><div class=\"code-container\"><code><xmp>var obj = {\'-1\':\'到店\',\'0\':\'现付\',\'10\' : \'网银\',\'20\':\'支付宝\',\'30\':\'微信\',\'40\':\'刷卡\',\'90\':\'拉卡拉\',\'95\':\'第三方平台\',\'97\':\'优惠券\',\'98\':\'账户余额\',\'99\':\'积分\',\'100\':\'会员卡\',\'101\':\'店内会员卡\',\'102\':\'储值卡\',\'110\':\'线下支付\',\'111\':\'挂账\'}</xmp></code></div><p>定义后台传来的数据编码：var index = data.no；直接obj[index]，就能得到指定编码的内容是什么了。</p><br><strong>【Summary】</strong><p>最后，本来还想着说写个两三种用途的，好像一下子到了写的时候，又想不起来了（有另一个，也是关于匹配比对的，但是太麻烦，后续再更新吧）。</p><p>总结起来，就是js中，对象的属性，其实和数组的索引的原理类似，只不过对象的“索引”（即属性）不是连续的数值类型。</p><p>PS：其实是在使用for和for in的时候，才突然一下，然后想到了这个。另外，for和for in的效率，前者比后者高，还是有一定道理的，可能就是前者少做了一点循环工作吧。</p> ');
INSERT INTO `papers_table` VALUES ('7', '【javascript】关于js函数自执行的另一种写法：function前加!、+、-等', 'javascript', '自执行函数，匿名函数立即执行', '2016-07-30 00:00:00', '2016-07', '最近闲着无聊，翻看了一下zepto的源码，虽说看的云里雾里，似懂非懂，无意间看到他的一种写法“+ function() {...}”，当时就蒙圈了，这特么这么写几个意思？后来百度了一下，好像是自执行函数的“非常规”写法（之所以说非常规，因为平常习惯的用法都是添加括号来调用匿名函数。', '<strong>【Preface】</strong><p>最近闲着无聊，翻看了一下zepto的源码，虽说看的云里雾里，似懂非懂，无意间看到他的一种写法“+ function() {...}”，当时就蒙圈了，这特么这么写几个意思？</p><p>后来百度了一下，好像是自执行函数的“非常规”写法（之所以说非常规，因为平常习惯的用法都是添加括号来调用匿名函数，以及关于function和!（逻辑运算符）、+-···（一元运算符）的一些使用。</p><br><strong>【Main Body】</strong><p>贴一下代码，以下是几种自执行函数的写法（前面两个是常规的括号的写法）：</p><div class=\"code-container\"><code><xmp><script></xmp><xmp class=\"indent-1\">(function(){console.info(\'1\')})();</xmp><xmp class=\"indent-1\">(function(){console.info(\'2\')}());</xmp><xmp class=\"indent-1\">!function(){console.info(\'3\')}();</xmp><xmp class=\"indent-1\">+function(){console.info(\'4\');}();</xmp><xmp class=\"indent-1\">-function(){console.info(\'5\');}();</xmp><xmp class=\"indent-1\">*function(){console.info(\'6\');}();</xmp><xmp class=\"indent-1\">1,function(){console.info(\'7\');}();</xmp><xmp class=\"indent-1\">1&function(){console.info(\'8\');}();</xmp><xmp class=\"indent-1\">1|function(){console.info(\'9\');}();</xmp><xmp class=\"indent-1\">1&&function(){console.info(\'10\');}();/* 因为js的特性，如果逻辑“与”（“且”）第一位就是false（或者能转换为false的，比如0），则不会检查后面的内容 */</xmp><xmp class=\"indent-1\">0||function(){console.info(\'11\');}();/* 因为js的特性，如果逻辑“或”第一位就是true（或者能转换为true的，比如1），则不会检查后面的内容 */</xmp><xmp></script></xmp></code></div><p>上述几种，根据了解到的一下内容，自己推断的几种写法，将语句输入到浏览器控制台，function内的语句也能正常运行（不要全部一起放在浏览器，好像会报错，分开一句一句验证可以正常运行）。</p><p>只由于匿名function，如果不定义return的值，默认返回的是undefined，所以函数能正常执行，但是最后返回的内容会有一点不一样。</p><br><strong>【Reference】</strong><p>后来百度了一下，找到一篇文章，关于“function和感叹号”的，里面发现了好多自己没想到的东西，现概括后转述一下。（<a class=\"external-link\" href=\"http://swordair.com/function-and-exclamation-mark/\" target=\"_blank\">查看原文</a>）</p><strong>为什么自执行函数能那样写？为什么必须这样写？</strong><p>其实无论是括号，还是感叹号，让整个语句合法化做的事情只有一件，就是让一个函数声明语句变成了一个表达式。</p><div class=\"code-container\"><code><xmp>function a() {...}    //undefined</xmp><xmp>function b() {...}()  //SyntaxError: unexpected_token</xmp></code></div><p>上述的代码示例，一个是函数声明，第二个函数声明，在那么一个声明后直接加上括号调用，解析器不理解并且报错。</p><p>因为混淆了函数声明和函数调用，以这种方式声明的函数a，应该以a()这种方式进行调用。</p><p>但是括号则不一样，它将一个函数声明转化成了一个表达式，解析器不再以函数声明的方式处理函数a，二十作为一个函数表达式处理，也因此只有在程序执行到函数a的时候才能被访问。</p><p>因此，任何消除函数声明和函数表达式之间歧义的方法，都可以被解析器正确识别。</p><p>除去上述的几种添加逻辑运算符、一元运算符和操作符，关键字也可以做到：</p><div class=\"code-container\"><code><xmp>void function() {alert(\'iifksp\')}()        // undefined</xmp><xmp>new function() {alert(\'iifksp\')}()         // Object</xmp><xmp>delete function() {alert(\'iifksp\')}()      // true</xmp></code></div><p>最后，该作者关于性能这块，做了一个测试，详细的说明可以去原文看一下，现将他的测试结果转述一下（我也想自己做一下测试看的，但是不知道从何下手）：</p><div class=\"img-container size-md\"><img src=\"res/papers/13-01.jpg\"></div><br><strong>【Summary】</strong><div class=\"refer-content\"><p>new方法永远最慢——这也是理所当然的。其它方面很多差距其实不大，但有一点可以肯定的是，感叹号并非最为理想的选择。</p><p>反观传统的括号，在测试里表现始终很快，在大多数情况下比感叹号更快——所以平时我们常用的方式毫无问题，甚至可以说是最优的。</p><p>加减号在chrome表现惊人，而且在其他浏览器下也普遍很快，相比感叹号效果更好。</p><p>当然这只是个简单测试，不能说明问题。但有些结论是有意义的：括号和加减号最优。</p><p>但是为什么这么多开发者钟情于感叹号？我觉得这只是一个习惯问题，它们之间的优劣完全可以忽略。一旦习惯了一种代码风格，那么这种约定会使得程序从混乱变得可读。如果习惯了感叹号，我不得不承认，它比括号有更好的可读性。我不用在阅读时留意括号的匹配，也不用在编写时粗心遗忘——</p></div><p>所以对于zepto这个js类库，主要针对移动端，他是用+而不是!或者括号，还是有一定道理的——对于性能的极致追求（？）。</p>');
INSERT INTO `papers_table` VALUES ('8', '【linux】CentOS系统，初始化阿里云ECS的运行环境①——mysql', 'linux', 'centos 6.5，阿里云ECS，mysql', '2016-10-18 00:00:00', '2016-10', '正如标题所述，主要是记录了一下自己配置服务器的时候，一些填坑记录。', '<strong>【Preface】</strong><p>最近抽空（上班闲得没事），把原先的静态站点（<a class=\"external-link\" href=\"https://monkingstand.github.io\" target=\"_blank\">传送门</a>）改造了一下，用nodejs做服务器运行环境，数据库选了mysql，重新写了一下，然后租了个服务器，准备挂上去。然后就尴尬了，裸机Linux，各种需要配置，正好站点缺干货（填坑记录），能放一点是一点。</p><br><strong>【Main Body】</strong><strong>---服务器环境（除了系统类型和版本，硬件等其他信息好像没什么卵用）：</strong><p>OS Info：CentOS_6.5_x64</p><br><strong>---安装mysql</strong><div class=\"code-container\"><code><xmp>yum install mysql-server</xmp></code></div><p>默认安装的是mysql 5.1，因为5.6太麻烦了，又要各种折腾，而且5.6和5.1除开在性能方面会有点差别，其他都差不多，就不需要费力去折腾了。</p><p>另外，在安装过程中会让你确认一下的，输入y后回车，等待安装完成。</p><br><strong>---启动服务</strong><div class=\"code-container\"><code><xmp>service mysqld start</xmp></code></div><br><strong>---测试连接</strong><div class=\"code-container\"><code><xmp>mysql</xmp></code></div><p>输入mysql后回车，应该会切换到带mysql前缀的mysql命令面板。</p><br><strong>---关闭连接</strong><div class=\"code-container\"><code><xmp>\\q</xmp></code></div><br><strong>---设置开机启动</strong><div class=\"code-container\"><code><xmp>chkconfig mysqld on</xmp></code></div><br><strong>---开启3306端口并保存</strong><div class=\"code-container\"><code><xmp>/sbin/iptables -I INPUT -p tcp --dport 3306 -j ACCEPT</xmp><xmp>/etc/rc.d/init.d/iptables save</xmp></code></div><br><strong>---修改密码并设置允许远程访问（需要先在命令行输入mysql后，进入带mysql前缀的mysql命令面板）</strong><p>①设置密码。</p><div class=\"code-container\"><code><xmp>use mysql;</xmp><xmp>update user set password=password(\'12345\') where user=\'root\';</xmp><xmp>flush privileges;</xmp></code></div><p>其中，12345就是你要设置的新密码，对应的用户名是root。</p><p>另外，看了一下这个，感觉可以自己新建个用户，通过insert into语句，不过关于权限怎么配置，这个倒是不知道，不过我也没试，只是猜想。</p><p>②设置mysql远程访问。</p><div class=\"code-container\"><code><xmp>grant all privileges on *.* to \'root\'@\'%\' identified by \'12345\' with grant option;</xmp></code></div><br><strong>---重启服务，使用Navicat for mysql等图形化软件操作数据库</strong><div class=\"code-container\"><code><xmp>service mysqld restart</xmp></code></div><p>到现在，mysql基本已经安装配置完了，我在自己的电脑上用Navicat连了一下远程服务器上的mysql，连接成功，并且新增了表，在服务器的终端显示了一下全部的表，发现新建成功。</p><br><p class=\"sub-chapter\">-- 2016-10-19更新 --</p><p>在上一步，完成了mysql的安装配置后，有用Navicat进行了远程连接，并且新增了一条记录，后来发现好像出现了乱码（主要是中文）。懒得截图再描述了，这里是原文（<a class=\"external-link\" href=\"http://jingyan.baidu.com/article/fec7a1e5f8d3201190b4e782.html\" target=\"_blank\">传送门</a>）</p>');

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
  `user_name` char(20) CHARACTER SET utf8 NOT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `type` (`type`),
  KEY `paper_id` (`paper_id`),
  KEY `comment_id` (`comment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of subcomment_table
-- ----------------------------

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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of tags_index
-- ----------------------------
INSERT INTO `tags_index` VALUES ('1', 'html&css', '0000000001');
INSERT INTO `tags_index` VALUES ('2', 'javascript', '0000000003');
INSERT INTO `tags_index` VALUES ('3', 'jquery', '0000000001');
INSERT INTO `tags_index` VALUES ('4', 'json', '0000000001');
INSERT INTO `tags_index` VALUES ('5', 'bootstrap', '0000000001');
INSERT INTO `tags_index` VALUES ('6', 'nodejs', '0000000000');
INSERT INTO `tags_index` VALUES ('7', 'reactjs', '0000000000');
INSERT INTO `tags_index` VALUES ('8', 'linux', '0000000001');

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
-- Records of timeline_index
-- ----------------------------
INSERT INTO `timeline_index` VALUES ('1', '2016-01', '2');
INSERT INTO `timeline_index` VALUES ('2', '2016-02', '1');
INSERT INTO `timeline_index` VALUES ('3', '2016-03', '1');
INSERT INTO `timeline_index` VALUES ('4', '2016-07', '3');
INSERT INTO `timeline_index` VALUES ('5', '2016-10', '1');
INSERT INTO `timeline_index` VALUES ('6', '1111-11', '0');

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

-- ----------------------------
-- Records of user_table
-- ----------------------------
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
SET @count1 = (SELECT COUNT(*) FROM timeline_index WHERE timeline = new.timeline);
SET @count2 = (SELECT COUNT(*) FROM tags_index WHERE name = new.tag);
IF @count1 = 0 THEN
INSERT INTO timeline_index(timeline, papers_count) VALUES(new.timeline, 1);
ELSE
UPDATE timeline_index SET papers_count = papers_count + 1 WHERE timeline = new.timeline;
END IF;
IF @count2 = 0 THEN
INSERT INTO tags_index(name, papers_count) VALUES(new.tag, 1);
ELSE
UPDATE tags_index SET papers_count = papers_count + 1 WHERE name = new.tag;
END IF;
END
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `update_trigger_before`;
DELIMITER ;;
CREATE TRIGGER `update_trigger_before` BEFORE UPDATE ON `papers_table` FOR EACH ROW SET new.content = REPLACE(REPLACE(new.content, CHAR(10), ''), CHAR(13), '')
;
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
