$(document).ready(function() {

  var organizations = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    identify: function(obj) { return obj.name; },
    prefetch: '/organizations.json',
    remote: {
      url: '/organizations.json?query=%QUERY',
      wildcard: '%QUERY'
    }
  });

  function organizationsWithDefaults(query, sync) {
    if (query === '') {
      sync(organizations.all().sort(function(a,b) {
          if (a.name < b.name) {
            return -1
          } else if (a.name > b.name) {
            return 1
          } else {
            return 0
          }
        })
      );
    }

    else {
      organizations.search(query, sync);
    }
  }

  $('#org-wrapper .typeahead').typeahead({
    minLength: 0,
    highlight: true
  },
  {
    name: 'organization',
    display: 'name',
    source: organizationsWithDefaults,
    limit: 50
  });

});

