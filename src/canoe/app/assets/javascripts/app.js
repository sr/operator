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

  $('.js-servers-toggle').click(function(event) {
    var $this = $(this);
    var $serverDiv = $("#" + $this.attr('data-divname'));
    if ($this.is(":checked")) {
      $serverDiv.show();
    } else {
      $serverDiv.hide();
    }
  });

  $('.js-sha-expand').click(function(event) {
    var $this = $(this);
    if ($this.html() == $this.attr('data-sha')) {
      $this.html($this.attr('data-sha').substring(0,12) + '...');
    } else {
      $this.html($this.attr('data-sha'));
    }
  });

  $('.form-disable-on-submit').submit(function() {
    $(this).find('button').prop('disabled', true);
    return true;
  });

  if ($('#deploy_log_output').length > 0) {
    $('#deploy_log_output').scrollTop($('#deploy_log_output')[0].scrollHeight);
  }
});

$.extend($.easing, {
  easeInOutExpo: function (x, t, b, c, d) {
    if (t===0) return b;
    if (t==d) return b+c;
    if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b;
    return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;
  }
});
