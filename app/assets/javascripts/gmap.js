function initialize() {
    //  Initialize the map parameters
    var center = new google.maps.LatLng(45.5009512, -73.5675947);
    var mapOptions = {
        center: center,
        zoom: 16
    };

    //  Initialize the map object and attach it to the element with id 'map-canvas'
    var map = new google.maps.Map(document.getElementById('map-canvas'));

    //  Initialize the marker and attach it to the previously created map
    var marker = new google.maps.Marker({
        position: center,
        map: map,
        title: "Here! Ici!"
    });
}
