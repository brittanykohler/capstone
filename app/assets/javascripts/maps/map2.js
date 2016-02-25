var map, dms;
var dirService, dirRenderer;
var highlightedCell;
var routeQuery;
var bounds;
var panning = false;
var destinations = new Array();
var origins;
var query;

function initialize() {
  var pos;
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
    destinations = [new google.maps.LatLng(47.621908, -122.351625)];
    var service = new google.maps.places.PlacesService(map);
    service.nearbySearch({
      location: pos,
      radius: gon.distance_needed,
      // types: ['store']
    }, callback);

    function callback(results, status) {
      if (status === google.maps.places.PlacesServiceStatus.OK) {
        for (var i = 0; i < results.length; i++) {
          place = results[i].geometry.location
          destinations.push(place);
        }
        createTable();
        dms = new google.maps.DistanceMatrixService();

        dirService = new google.maps.DirectionsService();
        dirRenderer = new google.maps.DirectionsRenderer({preserveViewport:true});
        dirRenderer.setMap(map);

        google.maps.event.addListener(map, 'idle', function() {
          if (panning) {
            map.fitBounds(bounds);
            panning = false;
          }
        });
        updateMatrix();
      }
    }
  });
}

function updateMatrix() {
  var query = {
    origins: origins,
    destinations: destinations,
    travelMode: "WALKING",
    unitSystem: 1
    // travelMode: google.maps.TravelMode.WALKING,
    // unitSystem: google.maps.UnitSystem.IMPERIAL
  };
  dms.getDistanceMatrix(query, function(response, status) {
      if (status == "OK") {
        populateTable(response.rows);
      }
    }
  );
}

function createTable() {
  var table = document.getElementById('matrix');
  var tr = addRow(table);
  addElement(tr);
  for (var j = 0; j < destinations.length; j++) {
    var td = addElement(tr);
    td.setAttribute("class", "destination");
    td.appendChild(document.createTextNode(destinations[j]));
  }

  for (var i = 0; i < origins.length; i++) {
    tr = addRow(table);
    var td = addElement(tr);
    td.setAttribute("class", "origin");
    td.appendChild(document.createTextNode(origins[i]));
    for (var j = 0; j < destinations.length; j++) {
      var td = addElement(tr, 'element-' + i + '-' + j);
      td.onmouseover = getRouteFunction(i,j);
      td.onclick = getRouteFunction(i,j);
    }
  }
}

function populateTable(rows) {
  for (var i = 0; i < rows.length; i++) {
    for (var j = 0; j < rows[i].elements.length; j++) {
      var distance = rows[i].elements[j].distance.text;
      var duration = rows[i].elements[j].duration.text;
      var td = document.getElementById('element-' + i + '-' + j);
      td.innerHTML = distance + "<br/>" + duration;
    }
  }
}

function getRouteFunction(i, j) {
  var query = {
    origins: origins,
    destinations: destinations,
    travelMode: "WALKING",
    unitSystem: 1
    // travelMode: google.maps.TravelMode.WALKING,
    // unitSystem: google.maps.UnitSystem.IMPERIAL
  };
  return function() {
    routeQuery = {
      origin: origins[i],
      destination: destinations[j],
      travelMode: query.travelMode,
      unitSystem: query.unitSystem,
    };

    if (highlightedCell) {
      highlightedCell.style.backgroundColor="#ffffff";
    }
    highlightedCell = document.getElementById('element-' + i + '-' + j);
    highlightedCell.style.backgroundColor="#e0ffff";
    showRoute();
  };
}

function showRoute() {
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

function updateMode() {
  switch (document.getElementById("mode").value) {
    case "driving":
      query.travelMode = google.maps.TravelMode.DRIVING;
      break;
    case "walking":
      query.travelMode = google.maps.TravelMode.WALKING;
      break;
  }
  updateMatrix();
  if (routeQuery) {
    routeQuery.travelMode = query.travelMode;
    showRoute();
  }
}

function updateUnits() {
  switch (document.getElementById("units").value) {
    case "km":
      query.unitSystem = google.maps.UnitSystem.METRIC;
      break;
    case "mi":
      query.unitSystem = google.maps.UnitSystem.IMPERIAL;
      break;
  }
  updateMatrix();
}

function addRow(table) {
  var tr = document.createElement('tr');
  table.appendChild(tr);
  return tr;
}

function addElement(tr, id) {
  var td = document.createElement('td');
  if (id) {
    td.setAttribute('id', id);
  }
  tr.appendChild(td);
  return td;
}
