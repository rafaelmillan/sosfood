$(document).ready(function() {

  var organizations = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    prefetch: '/organizations.json',
    remote: {
      url: '/organizations.json?query=%QUERY',
      wildcard: '%QUERY'
    }
  });

  $('#org-wrapper .typeahead').typeahead(null, {
    display: 'name',
    minLength: 0,
    source: organizations
  });

});

