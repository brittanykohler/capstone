var map, dms;
var dirService, dirRenderer;
var highlightedCell;
var routeQuery;
var bounds;
var panning = false;
var destinations = new Array();
var destinationsHigh = new Array();
var destinationsLow = new Array();
var destinationNames = new Array();
var origins;
var query;

function initialize() {
  var pos;

  // Get current location
  navigator.geolocation.getCurrentPosition(function(position) {
    pos = {
      lat: position.coords.latitude,
      lng: position.coords.longitude
    }
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

    // Search for places that are +15% of distance needed
    console.log("before search")
    service.radarSearch({
      location: pos,
      radius: (gon.distance_needed * 1),
      keyword: 'park'
    }, callback);

    function callback(results, status) {
      console.log(status)
      if (status === google.maps.places.PlacesServiceStatus.OK) {
        destinationsHigh = results;
        if (destinationsLow.length > 0) {
          destinations = getComplement(destinationsLow, destinationsHigh);
          listPlaces();
        }
      }
    }

    // Search for places that are -15% of distance needed
    service.radarSearch({
      location: pos,
      radius: (gon.distance_needed * .70),
      keyword: 'park'
    }, callback2);

    function callback2(results, status) {
        console.log(status)
      if (status === google.maps.places.PlacesServiceStatus.OK) {
        destinationsLow = results;
        if (destinationsHigh.length > 0) {
          destinations = getComplement(destinationsLow, destinationsHigh);
          listPlaces();
        }
      }
    }
    console.log("here")
  });
}

// Get places that are in between the -15% radius and the +15% radius
function getComplement(arr1, arr2) {
  var complement = new Array();

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

function listPlaces() {
  // query limit is 10 per second
  for (var i = 0; i < 10; i++) {
    getName(destinations[i], i, function(name, id) {
      addPlace(name, id);
      getDistance(destinations[id], id, addDistance);
      getSteps(destinations[id], id, addSteps);
    });
  }
}

function addPlace(name, id) {
  console.log(id)
  $(".places").append("<p class='" + id + "'>" + name + "</p>");
  $("." + id).click(function() {
    getRouteFunction(id);
  });
}

function addDistance(distance, id) {
  console.log(id)
  $("." + id).append("<span> distance: " + distance + "</span>");
}

function addSteps(distanceMeters, id) {
  console.log(id)
  var steps = Math.round((distanceMeters * 100) / gon.stride_length_walking);
  $("." + id).append("<span> steps: " + steps + "</span>");
}

function getName(place, id, callback2) {
  var name;
  var service = new google.maps.places.PlacesService(map);
  var request = {
    placeId: place.place_id
  };
  service.getDetails(request, callback);

  function callback(place, status) {
    if (status == google.maps.places.PlacesServiceStatus.OK) {
      name = place.name;
      callback2(name, id);
    }
  }

}

function getDistance(place, id, callback2) {
  dms = new google.maps.DistanceMatrixService();
  var distance;
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
      distance = response.rows[0].elements[0].distance.text;
      callback2(distance, id);
    }
  });
}

function getSteps(place, id, callback2) {
  dms = new google.maps.DistanceMatrixService();
  var distanceMeters;
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
      distanceMeters = response.rows[0].elements[0].distance.value;
      callback2(distanceMeters, id);
    }
  });
}

function getRouteFunction(j) {
  console.log("getting route");
  var query = {
    origins: origins,
    destinations: destinations,
    travelMode: google.maps.TravelMode.WALKING,
    unitSystem: 1
    // travelMode: google.maps.TravelMode.WALKING,
    // unitSystem: google.maps.UnitSystem.IMPERIAL
  };
  // return function() {
    routeQuery = {
      origin: origins[0],
      destination: new google.maps.LatLng(destinations[j].geometry.location.lat(), destinations[j].geometry.location.lng()),
      travelMode: google.maps.TravelMode.WALKING,
      unitSystem: query.unitSystem,
    };
    showRoute();
  // };
}

function showRoute() {
  if (dirService == null) {
      dirService = new google.maps.DirectionsService();
  }
  if (dirRenderer == null) {
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
