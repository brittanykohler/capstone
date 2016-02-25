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

    // Search for places that are +15% of distance needed
    var service = new google.maps.places.PlacesService(map);
    service.radarSearch({
      location: pos,
      radius: (gon.distance_needed * 1.15),
      keyword: 'park'
    }, callback);

    function callback(results, status) {
      console.log("radar search results", results);
      if (status === google.maps.places.PlacesServiceStatus.OK) {
        for (var i = 0; i < results.length; i++) {
          place = results[i].geometry.location
          // service.getDetails(results[i], function(result, status) {
          //   console.log("detail search result:", result);
          //   if (status !== google.maps.places.PlacesServiceStatus.OK) {
          //     console.error(status);
          //     return;
          //   }
          //   name = result.name
          // });
          destinationsHigh.push(place);
          // destinationNames.push(name);
        }
        console.log("destinationsHigh", destinationsHigh)

        // updateMatrix();
      }
    }

    // Search for places that are -15% of distance needed
    service.radarSearch({
      location: pos,
      radius: (gon.distance_needed * .85),
      keyword: 'park'
    }, callback2);

    function callback2(results, status) {
      console.log("radar search results", results);
      if (status === google.maps.places.PlacesServiceStatus.OK) {
        for (var i = 0; i < results.length; i++) {
          place = results[i].geometry.location
          // service.getDetails(results[i], function(result, status) {
          //   console.log("detail search result:", result);
          //   if (status !== google.maps.places.PlacesServiceStatus.OK) {
          //     console.error(status);
          //     return;
          //   }
          //   name = result.name
          // });
          destinationsLow.push(place);
          // destinationNames.push(name);
        }
        console.log("destinationsLow", destinationsLow)

        // updateMatrix();
      }
    }
    var both = _.(destinationsHigh, destinationsLow);
    console.log(both);
  });
}

// createTable();
// dms = new google.maps.DistanceMatrixService();
//
// dirService = new google.maps.DirectionsService();
// dirRenderer = new google.maps.DirectionsRenderer({preserveViewport:true});
// dirRenderer.setMap(map);
//
// google.maps.event.addListener(map, 'idle', function() {
//   if (panning) {
//     map.fitBounds(bounds);
//     panning = false;
//   }
// });
//
// function updateMatrix() {
//   console.log("in updateMatrix function");
//   var query = {
//     origins: origins,
//     destinations: destinations,
//     travelMode: "WALKING",
//     unitSystem: 1
//     // travelMode: google.maps.TravelMode.WALKING,
//     // unitSystem: google.maps.UnitSystem.IMPERIAL
//   };
//   dms.getDistanceMatrix(query, function(response, status) {
//       console.log("distance matrix", status);
//       if (status == "OK") {
//         console.log("distance matrix response: ", response);
//         // sortDestinations(response.rows);
//         // createTable();
//         // populateTable(response.rows);
//       }
//     }
//   );
// }

// function createTable() {
//   var table = document.getElementById('matrix');
//   var tr = addRow(table);
//   addElement(tr);
//   for (var j = 0; j < origins.length; j++) {
//     var td = addElement(tr);
//     td.setAttribute("class", "origin");
//     td.appendChild(document.createTextNode("Info"));
//   }

//   for (var i = 0; i < destinations.length; i++) {
//     tr = addRow(table);
//     var td = addElement(tr);
//     td.setAttribute("class", "destination");
//     td.appendChild(document.createTextNode(destinationNames[i]));
//     for (var j = 0; j < origins.length; j++) {
//       var td = addElement(tr, 'element-' + j + '-' + i);
//       td.onmouseover = getRouteFunction(j,i);
//       td.onclick = getRouteFunction(j,i);
//     }
//   }
// }

// function populateTable(rows) {
//   for (var i = 0; i < rows.length; i++) {
//     for (var j = 0; j < rows[i].elements.length; j++) {
//       var distance = rows[i].elements[j].distance.text;
//       var duration = rows[i].elements[j].duration.text;
//       var steps = (rows[i].elements[j].distance.value * 100) / gon.stride_length_walking;
//       steps = Math.round(steps);
//       var td = document.getElementById('element-' + i + '-' + j);
//       td.innerHTML = distance + "<br/>" + duration + "<br/>" + steps + " steps";
//     }
//   }
// }

// function getRouteFunction(i, j) {
//   var query = {
//     origins: origins,
//     destinations: destinations,
//     travelMode: "WALKING",
//     unitSystem: 1
//     // travelMode: google.maps.TravelMode.WALKING,
//     // unitSystem: google.maps.UnitSystem.IMPERIAL
//   };
//   return function() {
//     routeQuery = {
//       origin: origins[i],
//       destination: destinations[j],
//       travelMode: query.travelMode,
//       unitSystem: query.unitSystem,
//     };
//
//     if (highlightedCell) {
//       highlightedCell.style.backgroundColor="#ffffff";
//     }
//     highlightedCell = document.getElementById('element-' + i + '-' + j);
//     highlightedCell.style.backgroundColor="#e0ffff";
//     showRoute();
//   };
// }
//
// function showRoute() {
//   dirService.route(routeQuery, function(result, status) {
//     if (status == google.maps.DirectionsStatus.OK) {
//       dirRenderer.setDirections(result);
//       bounds = new google.maps.LatLngBounds();
//       bounds.extend(result.routes[0].overview_path[0]);
//       var k = result.routes[0].overview_path.length;
//       bounds.extend(result.routes[0].overview_path[k-1]);
//       panning = true;
//       map.panTo(bounds.getCenter());
//     }
//   });
// }
//
// function updateUnits() {
//   switch (document.getElementById("units").value) {
//     case "km":
//       query.unitSystem = google.maps.UnitSystem.METRIC;
//       break;
//     case "mi":
//       query.unitSystem = google.maps.UnitSystem.IMPERIAL;
//       break;
//   }
//   updateMatrix();
// }

// function addRow(table) {
//   var tr = document.createElement('tr');
//   table.appendChild(tr);
//   return tr;
// }
//
// function addElement(tr, id) {
//   var td = document.createElement('td');
//   if (id) {
//     td.setAttribute('id', id);
//   }
//   tr.appendChild(td);
//   return td;
// }
