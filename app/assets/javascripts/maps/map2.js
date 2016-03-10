var map, dms;
// var dirService,
var dirRenderer;
var highlightedCell;
var routeQuery;
var bounds;
var panning = false;
var origins;

function initialize() {
  var infoWindow = new google.maps.InfoWindow({map: map});
  // Get current location
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) { // location is found
      var pos = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      };
      var mapOptions = {
        zoom: 15,
        center: pos,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      map = new google.maps.Map(document.getElementById("map"), mapOptions);

      origins = [
        new google.maps.LatLng(pos.lat, pos.lng)
      ];

      var service = new google.maps.places.PlacesService(map);

      var radarSearch = function(place, distanceMultiplier){
        return new Promise(function(resolve, reject){
          service.radarSearch({
            location: pos,
            radius: (gon.distance_needed * distanceMultiplier),
            type: place
          }, function(results, status){
            if(status === 'error'){
              return reject(status);
            } else {
              return resolve(results);
            }
          });
        });
      };

      var joinedRadarSearch = function(place) {
        return Promise.all([radarSearch(place, 0.85), radarSearch(place, 1)]);
      };

      joinedRadarSearch(gon.place_type).then(function(searchResults) {
        var destinations = getComplement(searchResults[0], searchResults[1]);
        destinations = setDistances(destinations, pos);
        destinations = setDistanceDiffs(destinations);
        destinations = sortByProximity(destinations);
        if (destinations.length > 0) {
          listPlaces(destinations.slice(0, 5));
        } else {
          displayPlacesError();
        }
      });
    }, function() {
      handleLocationError(true, infoWindow); // Error with finding location
    });
  } else {
    // Browser doesn't support Geolocation
    handleLocationError(false, infoWindow);
  }
}

// Deal with geolocation errors
function handleLocationError(browserHasGeolocation, infoWindow) {
  infoWindow.setContent(browserHasGeolocation ?
                        'Error: The Geolocation service failed.' :
                        'Error: Your browser doesn\'t support geolocation.');
  $("#map").css('background', 'transparent');
  $("#map").css('padding-top', '20px');
  $("#map").html(browserHasGeolocation ?
                        'Error: It looks like you don\'t have location services turned on. Please update your location settings in your browser to view trip results.' :
                        'Error: Your browser doesn\'t support geolocation. Please use an updated browser to view trip results.');
}

function displayPlacesError() {
  $(".places").append("Sorry, there are no places that match your search. Please try again with different choices.");
}


// Get places that are in between the smaller radius and the larger radius
function getComplement(arr1, arr2) {
  var complement = [];

  for (var i = 0; i < arr2.length; i++) {
    var unique = true;
    for (var j = 0; j < arr1.length; j++) {
      if (arr1[j].place_id == arr2[i].place_id) {
        unique = false;
        break;
      }
    }
    if (unique) {
      complement.push(arr2[i]);
    }
  }
  return complement;
}

function setDistances(destinations, currentLocation) {
  for (var i = 0; i < destinations.length; i++) {
    destinations[i].distance = calcDistance(destinations[i], currentLocation);
  }
  return destinations;
}

// calculating distance in meters
function calcDistance(place, currentLocation) {
  var lat1 = place.geometry.location.lat();
  var lon1 = place.geometry.location.lng();
  var lat2 = currentLocation.lat;
  var lon2 = currentLocation.lng;
  var R = 6371; // Radius of the earth in km
  var dLat = deg2rad(lat2-lat1);  // deg2rad below
  var dLon = deg2rad(lon2-lon1);
  var a =
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon/2) * Math.sin(dLon/2)
    ;
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  var d = R * c; // Distance in km
  d *= 1000; // Convert to meters
  return d;
}

function deg2rad(deg) {
  return deg * (Math.PI/180);
}

function setDistanceDiffs(destinations) {
  for (var i = 0; i < destinations.length; i++) {
    destinations[i].distanceDiff = Math.abs(destinations[i].distance - gon.distance_needed);
  }
  return destinations;
}

function sortByProximity(destinations) {
  destinations.sort(function(a, b) {
    return a.distanceDiff - b.distanceDiff;
  });
  return destinations;
}


// function listPlaces(destinations) {
//   // query limit is 10 per second
//   for (var i = 0; i < 5; i++) {
//     getName(destinations[i], i, function(name, id) {
//       destinations[id].name = name;
//       getDistance(destinations[id], id, function(distanceMeters, id) {
//         destinations[id].steps = calcSteps(distanceMeters);
//       });
//     });
//   }
//   //sort
//   var sortedDestinations = sortBySteps(destinations.slice(0, 5));
//   //div stuff
// }

function addNameAndSteps(destination) {
  return new Promise(function(fulfill, reject) {
    getName(destination, 0, function(name, id) {
      destination.name = name;
      getDistance(destination, 0, function(distanceMeters, id) {
        destination.steps = calcSteps(distanceMeters);
        fulfill(destination);
      });
    });
  });
}


function listPlaces(destinations) {
  return Promise.all(destinations.map(function(destination) {
    return addNameAndSteps(destination);
  })).then(function(destinationsWithNamesAndSteps) {
    var sortedDestinations = sortBySteps(destinationsWithNamesAndSteps);
  });
}



function sortBySteps(places) {
  places.sort(function(a, b) {
    return a.steps - b.steps;
  });
  return places;
}

function calcSteps(distance) {
  return Math.round((distance * 100) / gon.stride_length_walking);
}

function addPlace(name, id, destinations) {
  $(".places").append("<p class='place" + id + " place-box'>" + name + "</p>");
  $(".place" + id).click(function() {
    getRouteFunction(id, destinations);
  });
}

function addSteps(distanceMeters, id) {
  var steps = Math.round((distanceMeters * 100) / gon.stride_length_walking);
  $(".place" + id).append("<span> steps: " + steps + "</span>");
}

function getName(place, id, callback2) {
  var service = new google.maps.places.PlacesService(map);
  var request = {
    placeId: place.place_id
  };
  service.getDetails(request, callback);

  function callback(result, status) {
    if (status == google.maps.places.PlacesServiceStatus.OK) {
      callback2(result.name, id);
    }
  }
}

function getDistance(place, id, callback2) {
  dms = new google.maps.DistanceMatrixService();
  var query = {
    origins: origins,
    destinations: [new google.maps.LatLng(place.geometry.location.lat(), place.geometry.location.lng())],
    travelMode: google.maps.TravelMode.WALKING,
    unitSystem: google.maps.UnitSystem.IMPERIAL
  };
  dms.getDistanceMatrix(query, function(response, status) {
    if (status == "OK") {
      var distanceMeters = response.rows[0].elements[0].distance.value;
      callback2(distanceMeters, id);
    }
  });
}

function getRouteFunction(j, destinations) {
  var query = {
    origins: origins,
    destinations: destinations,
    travelMode: google.maps.TravelMode.WALKING,
    unitSystem: google.maps.UnitSystem.IMPERIAL
  };
  routeQuery = {
    origin: origins[0],
    destination: new google.maps.LatLng(destinations[j].geometry.location.lat(), destinations[j].geometry.location.lng()),
    travelMode: google.maps.TravelMode.WALKING,
    unitSystem: query.unitSystem,
  };
  if (highlightedCell) {
    highlightedCell.removeClass("highlighted-cell");
  }
  highlightedCell = $('.place' + j);
  highlightedCell.addClass("highlighted-cell");
  showRoute();
}

function showRoute() {
  var dirService = new google.maps.DirectionsService();
  if (dirRenderer === undefined) {
    dirRenderer = new google.maps.DirectionsRenderer({preserveViewport:true});
  }
  dirRenderer.setMap(map);
  google.maps.event.addListener(map, 'idle', function() {
    if (panning) {
      map.fitBounds(bounds);
      panning = false;
    }
  });

  dirService.route(routeQuery, function(result, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      dirRenderer.setDirections(result);
      bounds = new google.maps.LatLngBounds();
      bounds.extend(result.routes[0].overview_path[0]);
      var k = result.routes[0].overview_path.length;
      bounds.extend(result.routes[0].overview_path[k-1]);
      panning = true;
      map.panTo(bounds.getCenter());
    }
  });
}
