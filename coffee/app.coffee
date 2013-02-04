

initialize = ->
  mapDiv = document.getElementById("map")
  map = new google.maps.Map(mapDiv,
    center: new google.maps.LatLng(37.4419, -122.1419)
    zoom: 13
    mapTypeId: google.maps.MapTypeId.ROADMAP
  )
  google.maps.event.addListenerOnce map, "tilesloaded", addMarkers


addMarkers = ->
  bounds = map.getBounds()
  southWest = bounds.getSouthWest()
  northEast = bounds.getNorthEast()
  lngSpan = northEast.lng() - southWest.lng()
  latSpan = northEast.lat() - southWest.lat()
  i = 0

  while i < 10
    latLng = new google.maps.LatLng(southWest.lat() + latSpan * Math.random(), southWest.lng() + lngSpan * Math.random())
    marker = new google.maps.Marker(
      position: latLng
      map: map
    )
    i++

$ ->
  map = undefined
  initialize()
