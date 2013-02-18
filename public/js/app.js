var baloon, color_field, colors, draw_buttons, fields, filters, gmap, handle_color, init_filters, label, locations, map_init, marker_place, markers;

gmap = null;

baloon = null;

locations = null;

colors = {
  rosso: "red",
  giallo: "yellow",
  blu: "blue",
  verde: "green"
};

fields = {
  domain: {
    ngo: "blue",
    food: "red",
    edf: "green"
  },
  years: {
    "before_2002": "blue",
    "2002-2006": "red",
    "2007-2013": "green"
  }
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
    return "<p><strong>" + (value.replace(/_/, " ")) + ":</strong> " + object[value] + "</p>";
  } else {
    return "";
  }
};

color_field = location.search.slice(1);

handle_color = function(loc) {
  var color, field, scheme;
  color = "red";
  field = loc[color_field];
  scheme = fields[color_field];
  color = scheme[field.toLowerCase()];
  return color;
};

marker_place = function(loc) {
  var color, image, latLng, marker;
  color = handle_color(loc);
  image = "/img/marker_med_" + color + ".png";
  latLng = new google.maps.LatLng(loc.lat, loc.lng);
  marker = new google.maps.Marker({
    position: latLng,
    map: gmap,
    icon: image
  });
  return google.maps.event.addListener(marker, 'click', function() {
    baloon.setContent("<p><strong>" + loc.location_name + "</strong></p>    " + (label(loc, "project_id")) + "    " + (label(loc, "cris_id")) + "    " + (label(loc, "project_title")) + "    " + (label(loc, "zone")) + "    " + (label(loc, "domain")) + "    " + (label(loc, "year")));
    baloon.open(gmap, this);
  });
};

filters = _(fields).keys();

draw_buttons = function() {
  var filter, nav, view, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = filters.length; _i < _len; _i++) {
    filter = filters[_i];
    nav = $("nav");
    view = "<a href='" + location.pathname + "?" + filter + "' class='filter'>" + filter + "</a>";
    _results.push(nav.append(view));
  }
  return _results;
};

init_filters = function() {
  return draw_buttons();
};

$(function() {
  map_init();
  return init_filters();
});
