var papers = {
	init: function(){
		this.initTags();
		this.initLatest();
		this.initTimeline();
		this.initCategory();

		$('#bodyContainer').addClass('category');
		showContent('#bodyContainer');
	},
	initTags: function() {
		var renderTags = function(tagsArr) {
			var tagsCount = tagsArr.length,
				tagsStr   = '';
			for (var i = 0; i < tagsCount; i ++) {
				tagsStr +=	'<dd><a onclick="papers.renderCategory(\'tagName,' + tagsArr[i].tagName + '\')">' +
								'<span class="tag-name">' + tagsArr[i].tagName + '</span>(<span class="tag-count">' + tagsArr[i].papersCount + '</span>)' +
							'</a></dd>';
			}	
			
			$('#tagList').append(tagsStr);
		};

		$.ajax({
			url : 'http://127.0.0.1:8181/initTags.node',
			type: 'POST',
			success: function(data) {
				renderTags(data);
			}
		})
	},
	initLatest: function() {
		var renderLatest = function(latestArr) {
			var latestCount = (latestArr.length > 5) ? 5 : tagsArr.length,
				latestStr   = '';
			for (var i = 0; i < latestCount; i ++) {
				latestStr += '<dd>' +
							     '<a data-no="' + (i + 1) + '. " title="【' + latestArr[i].date + '】' + latestArr[i].title + '" onclick="papers.renderPaper(\'' + latestArr[i].id + '\')">' +
							         latestArr[i].title +
								'</a>' +
							 '</dd>';
			}

			$('#latestList').append(latestStr);
		}

		$.ajax({
			url : 'http://127.0.0.1:8181/initLatest.node',
			type: 'POST',
			success: function(data) {
				renderLatest(data);
			}
		})
		
	},
	initTimeline: function() {
		var renderTimeline = function(timelineArr) {
			var timelineCount = timelineArr.length,
				timelineStr   = '';
			for (var i = 0; i < timelineCount; i ++) {
				timelineStr += '<dd>' +
        					       '<a onclick="papers.renderCategory(\'timeline,' + timelineArr[i].timeline + '\')">' +
        					           '<span class="time-val">' + timelineArr[i].timeline + '</span>(<span class="count">' + timelineArr[i].papersCount + '</span>)' +
        					       '</a>' +
        					   '</dd>';
			}

			$('#timeList').append(timelineStr);
		}

		$.ajax({
			url : 'http://127.0.0.1:8181/initTimeline.node',
			type: 'POST',
			success: function(data) {
				renderTimeline(data);
			}
		})
	},
	initCategory: function() {
		this.renderCategory('all');
	},
	renderCategory: function(categoryArgument) {
		window.scrollTo(0, 0);
		$('#bodyContainer').addClass('category');

		var renderType = categoryArgument.split(',')[0];

		var renderTypeCategory = {
			'all'     : '/initCategory.node',
			'tagName' : '/categoryByTagName.node',
			'timeline': '/categoryByTimeline.node'
		};

		if (renderType == 'all') { $('#bodyContainer').addClass('init'); }
		else { $('#bodyContainer').removeClass('init'); }

		var	renderDirectory = function(directoryArr) {
			var directoryCount = directoryArr.length,
				directoryStr   = '';
			for (var i = 0; i < directoryCount; i ++) {
				directoryStr += '<div class="category-item">' +
									'<div class="item-title">' +
										'<h2><a onclick="papers.renderPaper(\'' + directoryArr[i].id + '\')" title="' + directoryArr[i].title + '" data-hover="' + directoryArr[i].title + '">' + directoryArr[i].title + '</a></h2>' +
									'</div>' +
									'<div class="item-subtitle">' +
										'<h3>' +
											'<span class="subtitle-date">' + 
												'<i class="fa fa-calendar"></i>&nbsp;<span class="date-val">' + directoryArr[i].date + '</span>' + 
											'</span>' +
											'<span class="subtitle-tags">' + 
												'<i class="fa fa-tags"></i>&nbsp;<span class="tags-val">' + directoryArr[i].tag + (directoryArr[i].subtag ? ('，' + directoryArr[i].subtag) : '') + '</span>' + 
											'</span>' +
										'</h3>' +
									'</div>' +
									'<div class="item-abstract"><p>' + directoryArr[i].abstract +'</p></div>' +
								'</div>';
			}

			hideContent('#paperContent');
			$('#paperContent .paper-title h1').empty().text('Directory');
			$('#paperContent .paper-content').removeClass('no-item').empty().append(directoryStr);
			showContent('#paperContent');
		};

		$.ajax({
			url : 'http://127.0.0.1:8181' + renderTypeCategory[renderType],
			type: 'POST',
			dataType: 'JSON',
			data    : {
				'categoryArgument': categoryArgument.split(',')[1]
			},
			success: function(data) {
				renderDirectory(data);
			}
		})
	},
	renderPaper: function(paperId) {
		var renderContent = function(contentArr) {
			window.scrollTo(0, 0);
			hideContent('#paperContent');

			var contentCount   = contentArr,
				currentContent = {};
			
			if (contentArr.length == 2) {
				if (contentArr[0].id == paperId) {
					$('#prePaper').text('已经是第一篇了！没有上一篇了！').removeAttr('onclick');
					currentContent = contentArr[0];
					$('#nextPaper').text(contentArr[1].title).attr({
						'onclick': 'papers.renderPaper(\'' + contentArr[1].id + '\')',
						'title'  : contentArr[1].title
					});
				}
				else {
					$('#prePaper').text(contentArr[0].title).attr({
						'onclick': 'papers.renderPaper(\'' + contentArr[0].id + '\')',
						'title'  : contentArr[0].title
					});
					currentContent = contentArr[1];
					$('#nextPaper').text('已经是最后一篇了！没有下一篇了！').removeAttr('onclick');
				}
			}
			else {
				$('#prePaper').text(contentArr[0].title).attr({
					'onclick': 'papers.renderPaper(\'' + contentArr[0].id + '\')',
					'title'  : contentArr[0].title
				});
				currentContent = contentArr[1];
				$('#nextPaper').text(contentArr[2].title).attr({
					'onclick': 'papers.renderPaper(\'' + contentArr[2].id + '\')',
					'title'  : contentArr[2].title
				});
			}

			tags = currentContent.tag + (currentContent.subtag ? ('，' + currentContent.subtag) : '');
			$('#bodyContainer').removeClass('category init');
			$('#paperContent .paper-title h1').empty().text(currentContent.title);
			$('#paperContent .paper-subtitle .date-val').text(currentContent.date);
			$('#paperContent .paper-subtitle .tags-val').text(tags);
			$('#paperContent .paper-content').empty().append(currentContent.content);
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
			showContent('#paperContent');
		};

		$.ajax({
			url : 'http://127.0.0.1:8181/paperById.node',
			type: 'POST',
			dataType: 'JSON',
			data    : {
				'paperId': paperId
			},
			success: function(data) {
				renderContent(data);
			}
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