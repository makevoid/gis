var addMarkers, gmap, map_init;

gmap = null;

map_init = function() {
  var mapDiv;
  mapDiv = $("#map");
  gmap = new google.maps.Map(mapDiv.get(0), {
    center: new google.maps.LatLng(20, 100),
    zoom: 2,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });
  return google.maps.event.addListenerOnce(gmap, "tilesloaded", addMarkers);
};

addMarkers = function() {
  return $.getJSON("/locations", function(locations) {
    var image, latLng, loc, marker, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = locations.length; _i < _len; _i++) {
      loc = locations[_i];
      image = "/img/marker_med.png";
      latLng = new google.maps.LatLng(loc.lat, loc.lng);
      _results.push(marker = new google.maps.Marker({
        position: latLng,
        map: gmap,
        icon: image
      }));
    }
    return _results;
  });
};

$(function() {
  return map_init();
});
