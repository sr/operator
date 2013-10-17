function toggleMenu() {
  var w = 240;
  var l = parseInt($nav.css('left'),10) === 0 ? -w : 0;
  if($(window).width() < 992) {
      $nav.animate({'left': l}, 100, 'easeInOutExpo');
      $('#content').animate({'left': l+w}, 100, 'easeInOutExpo');
  }
}

$(function(){
  $nav = $('aside[role="navigation"]');
  $('[role="banner"] .navbar-toggle').click(toggleMenu);

	$('.js-unlock-toggle').click(function(event) {
		event.preventDefault();
		$('#unlock-forms').show();
		$('#unlock-hider').hide();
	});

	$('.js-locking-toggle').click(function(event) {
		event.preventDefault();
		$('#lock-forms').show();
		$('#lock-hider').hide();
	});

	$('.js-confirm').submit(function() {
		var $this = $(this);
		return confirm($this.attr('data-confirm'));
	});

  $('.js-sha-expand').click(function(event) {
    var $this = $(this);
    if ($this.html() == $this.attr('data-sha')) {
      $this.html($this.attr('data-sha').substring(0,12) + '...');
    } else {
      $this.html($this.attr('data-sha'));
    }
  })


});