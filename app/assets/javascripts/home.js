$(function() {
  $("#btn-scroll").click(function(e) {
    e.preventDefault;
    $('html, body').animate({
      scrollTop: $('#search-section').offset().top}, 'slow'
      );
  });

})

