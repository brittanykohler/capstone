var map;
var infowindow;
function initMap() {
  var pos;
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      pos = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      };
      map = new google.maps.Map(document.getElementById('map'), {
        center: pos,
        zoom: 15
      });
      var service = new google.maps.places.PlacesService(map);
      // console.log(gon.distance_needed);
      service.nearbySearch({
        location: pos,
        radius: gon.distance_needed,
        // types: ['store']
      }, callback);
    }, function() {
      handleLocationError(true, infoWindow, map.getCenter());
    });
  } else {
    // Browser doesn't support Geolocation
    handleLocationError(false, infoWindow, map.getCenter());
  }
  infowindow = new google.maps.InfoWindow();
}

function handleLocationError(browserHasGeolocation, infoWindow, pos) {
  infoWindow.setPosition(pos);
  infoWindow.setContent(browserHasGeolocation ?
  'Error: The Geolocation service failed.' :
  'Error: Your browser doesn\'t support geolocation.');
}

function callback(results, status) {
  // console.log(results);
  if (status === google.maps.places.PlacesServiceStatus.OK) {
    for (var i = 0; i < results.length; i++) {
      createMarker(results[i]);
    }
  }
}

function createMarker(place) {
  var placeLoc = place.geometry.location;
  var marker = new google.maps.Marker({
    map: map,
    position: place.geometry.location
  });

  google.maps.event.addListener(marker, 'click', function() {
    var contentString = place.name + ' Distance: ' + getDistance(place);
    infowindow.setContent(contentString);
    infowindow.open(map, this);
  });
}

function getDistance(place) {
  var origin1 = new google.maps.LatLng(map.center.lat(), map.center.lng());
  var destination1 = new google.maps.LatLng(place.geometry.location.lat(), place.geometry.location.lng());
  var service = new google.maps.DistanceMatrixService();
  var distance;
  service.getDistanceMatrix(
    {
      origins: [origin1],
      destinations: [destination1],
      travelMode: google.maps.TravelMode.WALKING,
    }, callback);
  function callback(response, status) {
    // return response.rows[0].elements[0].distance.value;
    console.log("hi");
    distance = response.rows[0].elements[0].distance.value;
  }
  console.log(distance);
  return distance;
}

function getSteps(place) {

}
