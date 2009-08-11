$(function() {
	var location = window.location + "";
	var tagsShowing = false;
	
	$("#tags").hide();
	$("a.tags").click(function() {
	    if (tagsShowing)
	        $("#tags").slideUp();
	    else
	        $("#tags").slideDown();
	        
	    tagsShowing = !tagsShowing;

	   return false;
	});
		
  $(".blog_post h1").addClass("alt");
  // $("h2,h3,h4,h5").addClass("alt");
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
	
  $(".blog_post .comments form").submit(function() {
    
      var form = $(this)[0]
    
      $.post($(this).attr("action"), $(this).serialize(), function(data, textStatus) {
        
        if (data == "error")
        {
          $(".blog_post .comments .success.message").hide();
          $(".blog_post .comments .error.message").show();
        }
        else 
        {
          $(".blog_post .comments .error.message").hide();
          $(".blog_post .comments .success.message").show();
          
          form.reset();
          $(".blog_post .comments .each").append(data).flash();
        }
      })
      return false;
    });
	
  // $(".blog_post .content h1").each(function () {
  //    var h1 = $(this)
  //    $(this).closest("div.blog_post").find("span.meta.link").each(function () {
  //      h1.wrapInner("<a href='"+$(this).html()+"'></a>");
  //    })
  //  })
	
	
	
	
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

