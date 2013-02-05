gmap = null

colors =
  rosso:  "red"
  giallo: "yellow"
  blu:    "blue"

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
      color = "red"
      cat_color = colors[loc.category]
      color = cat_color if cat_color
      image = "/img/marker_med_#{color}.png"
      latLng = new google.maps.LatLng loc.lat, loc.lng
      marker = new google.maps.Marker
        position: latLng
        map: gmap
        icon: image


$ ->
  map_init()
