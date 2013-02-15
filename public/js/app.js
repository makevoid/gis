var baloon, colors, gmap, label, locations, map_init, marker_place, markers;

gmap = null;

baloon = null;

locations = null;

colors = {
  rosso: "red",
  giallo: "yellow",
  blu: "blue",
  verde: "green"
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

label = function(object, value) {
  if (object[value]) {
    return "<p>" + (value.replace(/_/, " ")) + ": " + object[value] + "</p>";
  } else {
    return "";
  }
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
    baloon.setContent("<p><strong>" + loc.name + "</strong></p>" + (label(loc, "project_id")) + (label(loc, "cris_id")) + (label(loc, "project_title")));
    baloon.open(gmap, this);
  });
};

$(function() {
  return map_init();
});
