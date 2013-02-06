var baloon, colors, gmap, locations, map_init, marker_place, markers;

gmap = null;

baloon = null;

locations = [];

colors = {
  rosso: "red",
  giallo: "yellow",
  blu: "blue"
};

map_init = function() {
  var mapDiv;
  mapDiv = $("#map");
  gmap = new google.maps.Map(mapDiv.get(0), {
    center: new google.maps.LatLng(20, 100),
    zoom: 2,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  });
  return google.maps.event.addListenerOnce(gmap, "tilesloaded", markers);
};

markers = function() {
  baloon = new google.maps.InfoWindow({
    content: 'not loaded...'
  });
  return $.getJSON("/locations/" + data_name + ".json", function(locations) {
    var loc, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = locations.length; _i < _len; _i++) {
      loc = locations[_i];
      _results.push(marker_place(loc));
    }
    return _results;
  });
};

marker_place = function(loc) {
  var cat_color, color, image, latLng, marker;
  color = "red";
  cat_color = colors[loc.category];
  if (cat_color) {
    color = cat_color;
  }
  image = "/img/marker_med_" + color + ".png";
  latLng = new google.maps.LatLng(loc.lat, loc.lng);
  marker = new google.maps.Marker({
    position: latLng,
    map: gmap,
    icon: image
  });
  return google.maps.event.addListener(marker, 'click', function() {
    baloon.setContent("<p><strong>" + loc.name + "</strong></p><p>project id: " + loc.project_id + "</p><p>cris id: " + loc.cris_id + "</p>");
    baloon.open(gmap, this);
  });
};

$(function() {
  return map_init();
});
