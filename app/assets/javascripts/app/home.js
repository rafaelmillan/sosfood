$(function() {
  $("#btn-scroll").click(function(e) {
    e.preventDefault;
    $('html, body').animate({
      scrollTop: $('#comment-ca-marche').offset().top}, 'slow'
      );
  });

});

