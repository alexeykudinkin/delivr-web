#
# The main page.
#
# This class handles most of the user interactions with the buttons/menus/forms on the page, as well as manages
# the WebSocket connection.  It delegates to other classes to manage everything else.
#

# FIXME
# Invert dependencies chain
trackingServiceModule = angular.module "TrackingService", [ "TrackingMapOverlayModule" ]

trackingServiceModule.controller("TrackingServiceController", [ "$document", "$scope", "MapService", "TrackingMapOverlay", ($document, $scope, mapService, TrackingMapOverlay) ->


  class TrackingServiceControllerModel
    constructor: (courier, travel) ->
      # the current user
#      @email = ko.observable()

      # FIXME
      @id = "THISISUNIQUECLIENTID"

      @courier  = courier
      @travel   = travel


      # Contains a message to say that we're either connecting or reconnecting
#      @connecting   = $scope.connecting
#      @disconnected = $scope.disconnected

      # The MockGps model
#      @mockGps = ko.observable()
      # The GPS model
#      @gps = ko.observable()

      # If we're closing
      @closing = false

      @subscription = null

      @retries = 0

      # Load the previously entered email if set
#      if localStorage.email
#        @email(localStorage.email)
#        @connect()
      self = this
      $document.ready () ->
        self.tryConnect()

    # The user clicked connect
#    submitEmail: ->
#      localStorage.email = @email()
#      @connect()

    tryConnect: ->
      if @retries < 1
        if @retries > 1
          self = this
          setTimeout () ->
            self.connect()
          , Math.pow(8, @retries) * 100
        else
          @connect()
        ++@retries

    # Connect function. Connects to the websocket, and sets up callbacks.
    connect: ->
#      id = @email()
#      $scope.connecting = "Connecting..."
#      $scope.disconnected = null
      @ws = new WebSocket($("meta[name='tracker']").attr("content") + @id)

      # When the websocket opens, create a new map and new GPS
      @ws.onopen = (event) =>
#        @connecting(null)
        @map = new TrackingMapOverlay(@ws, mapService.getMap())

        console.log("Connected!")

        if @ws.readyState == 1 # OPEN
          @onSuccess()

        console.log("[WS:]", @ws)
        console.log("[MAP:]", @map)
#        @gps(new Gps(@ws))

      @ws.onclose = (event) =>
        # Need to handle reconnects in case of errors
        if (!event.wasClean && !self.closing)
          @tryConnect()
#          $scope.connecting = "Reconnecting..."
#        else
#          @disconnected(true)
        @closing = false
        # Destroy everything and clean it all up.
        @map.destroy() if @map
#        @mockGps().destroy() if @mockGps()
#        @gps().destroy() if @gps()
        @map = null
#        @mockGps(null)
#        @gps(null)

      # Handle the stream of feature updates
      @ws.onmessage = (event) =>
        json = JSON.parse(event.data)
        #console.log(json)

        if json.event == "user-positions"
          # Update all the markers on the map
          @map.updateMarkers(json.positions.features)

    onSuccess: () ->
      console.log "On-Success[Base]"

      @subscribe()

    # Disconnect the web socket
    disconnect: ->
      @closing = true
      @ws.close()

    # Switch between the mock GPS and the real GPS
#    toggleMockGps: ->
#      if @mockGps()
#        @mockGps().destroy()
#        @mockGps(null)
#        @gps(new Gps(@ws))
#      else
#        @gps().destroy() if @gps()
#        @gps(null)
#        @mockGps(new MockGps(@ws))

    subscribe0: (target) ->
      action =
        action:   "subscribe",
        targets:  [ "#{target}" ]

      console.log action

      @ws.send(JSON.stringify(action))

    subscribe: ->
      if @subscription
        @subscription = null
      else
#        @subscription = $("[data-bot]").data()["bot"]
        @subscription = "#{@courier}:#{@travel}"
        @subscribe0(@subscription)


  class TrackingServiceControllerModelMock extends TrackingServiceControllerModel

    constructor: (courier, travel, path) ->
      super(courier, travel)
      @path = path

    onSuccess: () ->
      super()

      console.log "On-Success[Mock]"

      @dispatchFakeCourier(@courier, @travel, @path, @ws)

    dispatchFakeCourier: (courier, travel, path, ws) ->
      dispatch =
        action: "dispatch",
        id:     "#{courier}:#{travel}",
        path:
          type:         "LineString",
          coordinates:  path.map((ll) -> [ ll.lng(), ll.lat() ])

      ws.send(JSON.stringify(dispatch))

      console.log "Dispatched!"


  $scope.track = (courier, travel) ->
    new TrackingServiceControllerModel(courier, travel)

  $scope.fakeTrack = (courier, travel, poly) ->
    # FIXME: Abstract all geo- harness
    path = google.maps.geometry.encoding.decodePath(poly)
    new TrackingServiceControllerModelMock(courier, travel, path)

  return

])