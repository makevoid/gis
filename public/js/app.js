(function() {
  var addMarkers, initialize;

  initialize = function() {
    var map, mapDiv;
    mapDiv = document.getElementById("map");
    map = new google.maps.Map(mapDiv, {
      center: new google.maps.LatLng(37.4419, -122.1419),
      zoom: 13,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    return google.maps.event.addListenerOnce(map, "tilesloaded", addMarkers);
  };

  addMarkers = function() {
    var bounds, i, latLng, latSpan, lngSpan, marker, northEast, southWest, _results;
    bounds = map.getBounds();
    southWest = bounds.getSouthWest();
    northEast = bounds.getNorthEast();
    lngSpan = northEast.lng() - southWest.lng();
    latSpan = northEast.lat() - southWest.lat();
    i = 0;
    _results = [];
    while (i < 10) {
      latLng = new google.maps.LatLng(southWest.lat() + latSpan * Math.random(), southWest.lng() + lngSpan * Math.random());
      marker = new google.maps.Marker({
        position: latLng,
        map: map
      });
      _results.push(i++);
    }
    return _results;
  };

  $(function() {
    var map;
    map = void 0;
    return initialize();
  });

}).call(this);
