gmap = null
baloon = null
locations = null

colors =
  rosso:  "red"
  giallo: "yellow"
  blu:    "blue"
  verde:  "green"

map_init = ->
  mapDiv = $ "#map"
  gmap = new google.maps.Map mapDiv.get(0),
    center: new google.maps.LatLng 0, 20 # map start position
    zoom: 3
    mapTypeId: google.maps.MapTypeId.TERRAIN

  google.maps.event.addListenerOnce gmap, "tilesloaded", markers

markers = ->
  baloon = new google.maps.InfoWindow
    content: 'not loaded...'
  # google.maps.event.addListener baloon, 'closeclick', baloon_closed

  $.getJSON "/locations/#{data_name}.json", (locations) ->
    for loc in locations
      marker_place loc

label = (object, value) ->
  if object[value]
    "<p><strong>#{value.replace(/_/, " ")}:</strong> #{object[value]}</p>"
  else
    ""

color_field = location.search[1..-1]

debug = 0

handle_color = (loc) ->
  if color_field == "diff"
    if loc["performance"] == "pink"
      "red" # non monitoreds
    else
      "green" # monitoreds
  else
    loc[color_field]

marker_place = (loc) ->
  return unless loc.lat
  color = handle_color loc
  return if color == "pink" # nil
  image = "/img/marker_med_#{color}.png"
  latLng = new google.maps.LatLng loc.lat, loc.lng
  marker = new google.maps.Marker
    position: latLng
    map: gmap
    icon: image
  google.maps.event.addListener marker, 'click', ->
    # console.log loc
    baloon.setContent "<p><strong>#{loc.location_name}</strong></p>
    #{label loc, "project_id"}
    #{label loc, "cris_id"}
    #{label loc, "project_title"}
    #{label loc, "zone"}"
    #  #{label loc, "domain"}
    #  #{label loc, "year"}"
    baloon.open gmap, this
    return

# baloon_closed = ->
#   console.log "baloon close"


# filters = _(fields).keys()
#
# draw_buttons = ->
#   for filter in filters
#     nav  = $ "nav"
#     view = "<a href='#{location.pathname}?#{filter}' class='filter'>#{filter}</a>"
#     nav.append view

# init_filters = ->
#   draw_buttons()


$ ->
  map_init()
  # init_filters()
