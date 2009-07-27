$(function() {
	var location = window.location + "";
		
	$("h2,h3,h4,h5,.blog_post h1").addClass("alt");
	$("#nav > a").each(function() {

		var pattern = new RegExp($(this).attr("href") + "$");
		if (location.match(pattern))
		{
			$(this).addClass("currentnav");
		}
	})
	
	$(".blog_post .content p > img").wrap("<div class='frame'></div>");
	$(".blog_post .content p > a > img").parent().wrap("<div class='frame'></div>");	
	
	$(".blog_post .content .download a").wrap("<div></div>");
	
	// $(".blog_post").after("<hr />");
	
	// $(".blog_post .content p:contains('download:')").each(function() {
	// 	var div = $('<div class="download"></div>');
	// 	var links = $(this).children("a");
	// 	
	// 	div.append(links);
	// 	links.wrap("<div></div>");
	// 	
	// 	$(this).replaceWith(div);
	// });
	
	// $(".blog_post .content p:contains('notice:')").each(function() {
	// 	$(this).addClass("notice").html($(this).html().replace("notice:",""));
	// });
})

