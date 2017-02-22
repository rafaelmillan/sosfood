// This example displays an address form, using the autocomplete feature
// of the Google Places API to help users fill in the information.

var placeSearch, autocomplete;
var componentForm = {
  // street_number: 'short_name',
  // route: 'long_name',
  locality: 'long_name',
  // administrative_area_level_1: 'short_name',
  country: 'long_name',
  postal_code: 'short_name'
};

function initAutocomplete() {
  // Create the autocomplete object, restricting the search to geographical
  // location types.
  autocomplete = new google.maps.places.Autocomplete(
      /** @type {!HTMLInputElement} */(document.getElementById('distribution_address_1')),
      {types: ['geocode']});

  // When the user selects an address from the dropdown, populate the address
  // fields in the form.
  autocomplete.addListener('place_changed', fillInAddress);
}

function fillInAddress() {
  // Get the place details from the autocomplete object.
  var place = autocomplete.getPlace();
  var street_number = ''
  var route = ''
  var locality = ''
  var country = ''
  var postal_code = ''

  // for (var component in componentForm) {
  //   document.getElementById(component).value = '';
  //   document.getElementById(component).disabled = false;
  // }

  // Get each component of the address from the place details
  // and fill the corresponding field on the form.
  for (var i = 0; i < place.address_components.length; i++) {
    var addressType = place.address_components[i].types[0];
    if (addressType == 'street_number') {
      street_number = place.address_components[i]['long_name']
    } else if (addressType == 'route') {
      route = place.address_components[i]['long_name']
    } else if (addressType == 'locality') {
      locality = place.address_components[i]['long_name']
    } else if (addressType == 'postal_code') {
      postal_code = place.address_components[i]['long_name']
    } else if (addressType == 'country') {
      country = place.address_components[i]['long_name']
    }
  }
  document.getElementById('distribution_address_1').value = street_number + ' ' + route;
  document.getElementById('postal_code').value = postal_code;
  document.getElementById('locality').value = locality;
  document.getElementById('country').value = country;
}

// Bias the autocomplete object to the user's geographical location,
// as supplied by the browser's 'navigator.geolocation' object.
function geolocate() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      var geolocation = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      };
      var circle = new google.maps.Circle({
        center: geolocation,
        radius: position.coords.accuracy
      });
      autocomplete.setBounds(circle.getBounds());
    });
  }
}

























































// $(document).ready(function() {
//   var distribution_address = $('#distribution_address_1').get(0);

//   if (distribution_address) {
//     var autocomplete = new google.maps.places.Autocomplete(distribution_address_1, { types: ['geocode'] });
//     google.maps.event.addListener(autocomplete, 'place_changed', onPlaceChanged);
//     google.maps.event.addDomListener(distribution_address_1, 'keydown', function(e) {
//       if (e.keyCode == 13) {
//         e.preventDefault(); // Do not submit the form on Enter.
//       }
//     });
//   }
// });

// function onPlaceChanged() {
//   var place = this.getPlace();
//   var components = getAddressComponents(place);

//   $('#distribution_address_1').trigger('blur').val(components.address_1);
//   $('#distribution_postal_code').val(components.zip_code);
//   $('#distribution_city').val(components.city);
//   // if (components.country_code) {
//   //   // $('#distribution_country').val(components.country_code);
//   // }
// }

// function getAddressComponents(place) {
//   // If you want lat/lng, you can look at:
//   // - place.geometry.location.lat()
//   // - place.geometry.location.lng()

//   var street_number = null;
//   var route = null;
//   var zip_code = null;
//   var city = null;
//   // var country_code = null;
//   for (var i in place.address_1_components) {
//     var component = place.address_1_components[i];
//     for (var j in component.types) {
//       var type = component.types[j];
//       if (type == 'street_number') {
//         street_number = component.long_name;
//       } else if (type == 'route') {
//         route = component.long_name;
//       } else if (type == 'postal_code') {
//         zip_code = component.long_name;
//       } else if (type == 'locality') {
//         city = component.long_name;
//       }
//     }
//   }

//   return {
//     address_1: street_number == null ? route : (street_number + ' ' + route),
//     postal_code: postal_code,
//     city: city,
//     // country_code: country_code
//   };
// }
