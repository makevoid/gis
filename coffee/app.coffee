gmap, baloon, locations = null, null, null

colors =
  rosso:  "red"
  giallo: "yellow"
  blu:    "blue"

map_init = ->
  mapDiv = $ "#map"
  gmap = new google.maps.Map mapDiv.get(0),
    center: new google.maps.LatLng 20, 100 # map start position
    zoom: 2
    mapTypeId: google.maps.MapTypeId.TERRAIN

  google.maps.event.addListenerOnce gmap, "tilesloaded", markers



markers = ->
  baloon = new google.maps.InfoWindow
    content: 'not loaded...'
  # google.maps.event.addListener baloon, 'closeclick', baloon_closed

  $.getJSON "/locations/#{data_name}.json", (locations) ->
    for loc in locations
      marker_place loc

marker_place = (loc) ->
  color = "red"
  cat_color = colors[loc.category]
  color = cat_color if cat_color
  image = "/img/marker_med_#{color}.png"
  latLng = new google.maps.LatLng loc.lat, loc.lng
  marker = new google.maps.Marker
    position: latLng
    map: gmap
    icon: image
  google.maps.event.addListener marker, 'click', ->
    # console.log locations
    baloon.setContent "<p><strong>#{loc.name}</strong></p><p>project id: #{loc.project_id}</p><p>cris id: #{loc.cris_id}</p>"
    baloon.open gmap, this
    return

# baloon_closed = ->
#   console.log "baloon close"

$ ->
  map_init()
