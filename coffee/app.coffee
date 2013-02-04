gmap = null

map_init = ->
  mapDiv = $ "#map"
  gmap = new google.maps.Map mapDiv.get(0),
    center: new google.maps.LatLng 20, 100 # map start position
    zoom: 2
    mapTypeId: google.maps.MapTypeId.ROADMAP

  google.maps.event.addListenerOnce gmap, "tilesloaded", addMarkers


addMarkers = ->
  $.getJSON "/locations", (locations) ->
    for loc in locations
      image = "/img/marker_med.png"
      latLng = new google.maps.LatLng loc.lat, loc.lng
      marker = new google.maps.Marker
        position: latLng
        map: gmap
        icon: image


$ ->
  map_init()
