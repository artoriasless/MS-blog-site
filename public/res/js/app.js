var papers = {
	init: function(){
		$.getJSON('res/papers/category.json', function(data) {
			var tags     = data.tags,
				timeline = data.timeline,
				category = data.category;

			window.category = category;
			papers.initTags(tags);
		    papers.initLatest(category);
		    papers.initTimeline(timeline);
		    papers.initCategory(category);

		    $('#bodyContainer').addClass('category');
		    showContent('#bodyContainer');
	    })
	},
	initTags: function(tags) {
		/* 初始化“我的标签”，统计对应标签的的篇数 */
		/* <dd><a><span class="tag-name">html&css</span>(<span class="tag-count">--</span>)</a></dd> */
		var i = 0,
			tagsStr   = '',
			tagsCount = tags.length;

		for (var key in tags) {
			var tempTag   = tags[key],
				tempCount = tempTag.length,
				indexStr  = (tempCount != 0) ? tempTag.join(',') : '-1';

			tagsStr +=	'<dd><a onclick="papers.renderCategory(\'' + indexStr + '\')">' +
							'<span class="tag-name">' + key + '</span>(<span class="tag-count">' + tempCount + '</span>)' +
						'</a></dd>';
		}
		i ++;

		$('#tagList').append(tagsStr);
	},
	initLatest: function(category) {
		/* 初始化“最近文章”，显示最近的5篇文章标题 */
		var descIndex = category.length - 1,
			latestStr = '',
			count     = 0;

		for (; descIndex >= 0; descIndex --) {
			count ++;
			latestStr +=	'<dd>' +
								'<a data-no="' + count + '." title="【' + category[descIndex].date + '】' + category[descIndex].title + '" onclick="papers.renderPaper(\'' + category[descIndex].index + '\')">' +
									category[descIndex].title +
								'</a>' +
							'</dd>';
			if (count == 5) break;
		}

		$('#latestList').append(latestStr);
	},
	initTimeline: function(timeline) {
		/* 初始化时间线，按时间先后显示有发布文章的年月,即 2016-03-03 -> 2016-02-02 -> 2016-01-01 */
        var timelineStr = '';

        for (key in timeline) {
        	var indexStr = timeline[key].length ? timeline[key].join() : '-1';
        	timelineStr =	'<dd>' +
        						'<a onclick="papers.renderCategory(\'' + indexStr + '\')">' +
        							'<span class="time-val">' + key + '</span>(<span class="count">' + timeline[key].length + '</span>)' +
        						'</a>' +
        					'</dd>' + timelineStr;
        }

        $('#timeList').append(timelineStr);
	},
	initCategory: function(category) {
		/* 初始化目录，显示全部的文章标题 */
		var indexStr  = '',
			descIndex = category.length - 1;

		for (; descIndex >= 1; descIndex --) {
			indexStr += category[descIndex].index + ',';
		}
		indexStr += '0';
		papers.renderCategory(indexStr);

		$('#bodyContainer').addClass('init category');
	},
	renderCategory: function(indexStr) {
		/* 根据标签、时间轴，渲染显示对应类别下的文章目录 */
		/* 传过来的indexStr已经按照时间远近，从最近到最早进行了排序 */
		/* 设置滚动条滚到顶部，即复位 */
		window.scrollTo(0, 0);
		$('#bodyContainer').addClass('category');

		if (indexStr == '-1') {

			$('#paperContent .paper-title h1').empty().text('Directory');
			$('#paperContent .paper-content').empty().addClass('no-item');
			showContent('#paperContent');
			return ;
		}
		var indexArr   = indexStr.split(','),
			indexCount  = indexArr.length,
			categoryStr = '';
		
		if (indexCount != category.length) {
			$('#bodyContainer').removeClass('init');
		}
		else {
			$('#bodyContainer').addClass('init');
		}

		for (var i = 0; i < indexCount; i ++) {
			var tempObj = category[indexArr[i]],
				tags    = tempObj.tag + (tempObj.others ? ('，' + tempObj.others) : '');

			categoryStr +=	'<div class="category-item">' +
								'<div class="item-title">' +
									'<h2><a onclick="papers.renderPaper(\'' + tempObj.index + '\')" title="' + tempObj.title + '" data-hover="' + tempObj.title + '">' + tempObj.title + '</a></h2>' +
								'</div>' +
								'<div class="item-subtitle">' +
									'<h3>' +
										'<span class="subtitle-date">' + 
											'<i class="fa fa-calendar"></i>&nbsp;<span class="date-val">' + tempObj.date + '</span>' + 
										'</span>' +
										'<span class="subtitle-tags">' + 
											'<i class="fa fa-tags"></i>&nbsp;<span class="tags-val">' + tags + '</span>' + 
										'</span>' +
									'</h3>' +
								'</div>' +
								'<div class="item-abstract"><p>' + tempObj.abstract +'</p></div>' +
							'</div>';
		}
		
		hideContent('#paperContent')
		$('#paperContent .paper-title h1').empty().text('Directory');
		$('#paperContent .paper-content').removeClass('no-item').empty().append(categoryStr);
		showContent('#paperContent');
		//TODO
		console.info('目录显示采用分页！TODO')
	},
	renderPaper: function(index) {
		/* 根据指定的文章索引，渲染对应的文章内容,路径path结合index自动生成 */
		/* path:"res/papers/content/contentxxx.json" */
		hideContent('#paperContent');
		var number = '',
			path   = 'res/papers/content/content';

		if (parseInt(index) < 10) { number = '00' + index; }
		else if (10 <= parseInt(index) && parseInt(index) < 100) { number = '0' + index; }
		path += (number + '.json');
		
		$.getJSON(path, function(data) {
			var title   = data.title,
				date    = data.date,
				tag     = data.tag,
				content = data.content.join(''),

				maxIndex  = category.length - 1,
				preIndex  = (index == maxIndex) ? '-1' : (parseInt(index) + 1),
				nextIndex = (index == 0) ? '-1' : (parseInt(index) - 1);

			$('#bodyContainer').removeClass('category init');
			$('#paperContent .paper-title h1').empty().text(title);
			$('#paperContent .paper-subtitle .date-val').text(date);
			$('#paperContent .paper-subtitle .tags-val').text(tag);
			$('#paperContent .paper-content').empty().append(content);
			$('.code-container').each(function() {
				var count = 1;
				/* xmp标签在HTML4.0中被废除，且在IE中不能正常显示，现改为pre标签 —————— edit in 2016-08-07 */
				$(this).find('xmp').each(function() {
					if ($(this).hasClass('indent-4') && count > 100) { $(this).addClass('indent-lg'); }

					if ($(this).hasClass('indent-5') && count > 9 && count < 100) { $(this).addClass('indent-sm'); }
					if ($(this).hasClass('indent-5') && count < 9) { $(this).addClass('indent-xs'); }

					if ($(this).hasClass('indent-6') && count > 9 && count < 100) { $(this).addClass('indent-sm'); }
					if ($(this).hasClass('indent-6') && count < 9) { $(this).addClass('indent-xs'); }

					$(this).attr('data-line', count++);

				})
			})

			if (preIndex != '-1') {
				$('#prePaper').text(category[preIndex].title).attr({
					'onclick': 'papers.renderPaper(\'' + preIndex + '\')',
					'title'  : category[preIndex].title
				});
			}
			else { $('#prePaper').text('已经是第一篇了！没有上一篇了！').removeAttr('onclick'); }

			if (nextIndex != '-1') {
				$('#nextPaper').text(category[nextIndex].title).attr({
					'onclick': 'papers.renderPaper(\'' + nextIndex + '\')',
					'title'  : category[nextIndex].title
				});
			}
			else { $('#nextPaper').text('已经是最后一篇了！没有下一篇了！').removeAttr('onclick'); }

			/* 设置滚动条滚到顶部，即复位 */
			window.scrollTo(0, 0);
			showContent('#paperContent');
	    })
	}
}

function hideContent(selector) {
	$(selector).addClass('hidden');
	$('#loading').removeClass('hidden');
}

function showContent(selector) {
	setTimeout(function(){
    	$('#loading').addClass('hidden');
    	$(selector).removeClass('hidden').addClass('fade-in-animate');
    }, 1000)
}

/* export */
window.papers = papers;