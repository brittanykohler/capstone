var map, dms;
var dirService, dirRenderer;
var highlightedCell;
var routeQuery;
var bounds;
var panning = false;
// var destinations = [];
var destinationsHigh = [];
var destinationsLow = [];
var destinationNames = [];
var origins;
var query;
var pos;

function initialize() {
  // Get current location
  navigator.geolocation.getCurrentPosition(function(position) {
    pos = {
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
      console.log(place, distanceMultiplier);
      return new Promise(function(resolve, reject){
        service.radarSearch({
          location: pos,
          radius: (gon.distance_needed * distanceMultiplier),
          keyword: place
        }, function(results, status){
          if(status === 'error'){
            return reject(status);
          } else {
            console.log(results);
            return resolve(results);
          }
        });
      }
    );

    };

    var joinedRadarSearch = function(place) {
      return Promise.all([radarSearch(place, 0.95), radarSearch(place, 0.7)]);
    };

    joinedRadarSearch('park').then(function(searchResults) {
      console.log(searchResults);
      var destinations = getComplement(searchResults[0], searchResults[1]);
      listPlaces(destinations);
    });


    // Search for places that are ~distance needed
    // service.radarSearch({
    //   location: pos,
    //   radius: (gon.distance_needed * 0.95),
    //   keyword: 'park'
    // }, callback);
    //
    // function callback(results, status) {
    //   console.log(status);
    //   if (status === google.maps.places.PlacesServiceStatus.OK) {
    //     destinationsHigh = results;
    //     if (destinationsLow.length > 0) {
    //       destinations = getComplement(destinationsLow, destinationsHigh);
    //       listPlaces();
    //     } else if (destinationsHigh.length < 5) { // search results too low to fill page
    //       nearbySearch();
    //     }
    //   }
    // }
    //
    // // Search for places that are less than distance needed
    // service.radarSearch({
    //   location: pos,
    //   radius: (gon.distance_needed * 0.70),
    //   keyword: 'park'
    // }, callback2);
    //
    // function callback2(results, status) {
    //     console.log(status);
    //   if (status === google.maps.places.PlacesServiceStatus.OK) {
    //     destinationsLow = results;
    //     if (destinationsHigh.length > 0) {
    //       destinations = getComplement(destinationsLow, destinationsHigh);
    //       listPlaces();
    //     }
    //   }
    // }
  });
}

// Use nearby search if radar search returns no results
function nearbySearch() {
  console.log("nearby search");
  var service = new google.maps.places.PlacesService(map);
  service.nearbySearch({
    location: pos,
    radius: gon.distance_needed,
  }, parseResults);
}

function parseResults(results, status) {
  console.log(results);
  if (status == google.maps.places.PlacesServiceStatus.OK) {
    destinations = results;
    listPlaces();
  }
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

function listPlaces(destinations) {
  // query limit is 10 per second
  for (var i = 0; i < 5; i++) {
    getName(destinations[i], i, function(name, id) {
      addPlace(name, id, destinations);
      // getDistance(destinations[id], id, addDistance);
      getSteps(destinations[id], id, addSteps);
    });
  }
}

function addPlace(name, id, destinations) {
  console.log(id);
  $(".places").append("<p class='place" + id + " place-box'>" + name + "</p>");
  $(".place" + id).click(function() {
    getRouteFunction(id, destinations);
  });
}

function addDistance(distance, id) {
  $(".place" + id).append("<span> distance: " + distance + "</span>");
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

  function callback(place, status) {
    if (status == google.maps.places.PlacesServiceStatus.OK) {
      callback2(place.name, id);
    }
  }
}

function getDistance(place, id, callback2) {
  dms = new google.maps.DistanceMatrixService();
  var query = {
    origins: origins,
    destinations: [new google.maps.LatLng(place.geometry.location.lat(), place.geometry.location.lng())],
    travelMode: "WALKING",
    unitSystem: 1
    // travelMode: google.maps.TravelMode.WALKING,
    // unitSystem: google.maps.UnitSystem.IMPERIAL
  };
  dms.getDistanceMatrix(query, function(response, status) {
    if (status == "OK") {
      var distance = response.rows[0].elements[0].distance.text;
      callback2(distance, id);
    }
  });
}

function getSteps(place, id, callback2) {
  dms = new google.maps.DistanceMatrixService();
  var query = {
    origins: origins,
    destinations: [new google.maps.LatLng(place.geometry.location.lat(), place.geometry.location.lng())],
    travelMode: "WALKING",
    unitSystem: 1
    // travelMode: google.maps.TravelMode.WALKING,
    // unitSystem: google.maps.UnitSystem.IMPERIAL
  };
  dms.getDistanceMatrix(query, function(response, status) {
    if (status == "OK") {
      var distanceMeters = response.rows[0].elements[0].distance.value;
      callback2(distanceMeters, id);
    }
  });
}

function getRouteFunction(j, destinations) {
  console.log("getting route");
  var query = {
    origins: origins,
    destinations: destinations,
    travelMode: google.maps.TravelMode.WALKING,
    unitSystem: 1
    // travelMode: google.maps.TravelMode.WALKING,
    // unitSystem: google.maps.UnitSystem.IMPERIAL
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
  console.log('place' + j);
  console.log(highlightedCell);
  highlightedCell.addClass("highlighted-cell");
  showRoute();
}

function showRoute() {
  if (dirService === undefined) {
      dirService = new google.maps.DirectionsService();
  }
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

  console.log("showing route");
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
