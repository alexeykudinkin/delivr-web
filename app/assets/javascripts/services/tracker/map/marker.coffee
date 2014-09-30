#
# A marker class
#

trackingMarker = angular.module "TrackingMarkerModule", [ "TrackingMarkerRendererModule" ]

#define ["leaflet", "markerRenderer"], (Leaflet, renderer) ->

trackingMarker.factory "TrackingMarker", [ "TrackingMarkerRenderer", (trackingMarkerRenderer) ->

  class Marker
    constructor: (map, feature, latLng) ->
      @map = map
      @feature = feature

      # If it has a count, it's a cluster
      if feature.properties.count
        #@marker = new Leaflet.Marker(latLng,
        #  icon: renderer.createClusterMarkerIcon(feature.properties.count)
        #)
        @marker = new google.maps.Marker
          position: latLng,
          icon: trackingMarkerRenderer.createClusterMarkerIcon(feature.properties.count)
        # Otherwise it's a user
      else
        userId = feature.id
        #@marker = new Leaflet.Marker(latLng,
        #  title: feature.id
        #)

        @marker = new google.maps.Marker
          position: latLng,

        # The popup should contain the gravatar of the user and their id
        #@marker.bindPopup(renderer.renderPopup(userId))

      @lastSeen = new Date().getTime()
      #@marker.addTo(map)
      @marker.setMap(map)

      @trail = new google.maps.MVCArray()
      @trail.push(latLng)

      @path = new google.maps.Polyline
        path: @trail,
        geodesic: true,
        strokeColor: "#FF0000",
        strokeOpacity: 1,
        strokeWeight: 2.0

      @path.setMap(@map)


    # Update a marker with the given feature and latLng coordinates
    update: (feature, latLng) ->
      # Update the position
      #@marker.setLatLng(latLng)
      @marker.setPosition(latLng)
      @trail.push(latLng)

      # If it's a cluster, check if the size of the cluster has changed
      if feature.properties.count
        if feature.properties.count != @feature.properties.count
          @marker.setIcon(renderer.createClusterMarkerIcon(feature.properties.count))

      # Animate the marker - calculate how long it took to get from its last position
      # to current, and then set the CSS3 transition time to equal that
      lastUpdate = @feature.properties.timestamp
      updated = feature.properties.timestamp
      time = (updated - lastUpdate)
      if time > 0
        if time > 10000
          time = 10000
        # FIXME
        #renderer.transition(@marker._icon, time)
        #renderer.transition(@marker._shadow, time) if @marker._shadow

      # Finally update feature
      @feature = feature
      @lastSeen = new Date().getTime()

    # Snap the marker to where it should be, ie stop animating
    snap: ->
      # FIXME
      #renderer.resetTransition @marker._icon
      #renderer.resetTransition @marker._shadow if @marker._shadow

    # Remove the marker from the map
    remove: ->
      #@map.removeLayer(@marker)
      @marker.setMap(null)
      @path.setMap(null)

  return Marker

]