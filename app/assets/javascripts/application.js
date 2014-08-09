// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs

//= require angular/angular
//= require angular/angular-messages
//= require angular/angular-animate

//= require bootstrap/bootstrap.js
//= require bootstrap/ui-bootstrap-tpls.js

//= require_tree .


(function ($) {

    'use strict';

    //
    // Base config
    //

    function Config() {

        // Delivr API

        this.DELIVR_API_BASE = '//localhost:3000';
        this.DELIVR_API_ACCOUNTING = this.DELIVR_API_BASE + '/account.json';

        // Google Maps API

        this.GOOGLE_MAPS_API = '//maps.googleapis.com/maps/api/js';
    }

    var config = new Config();


    //
    // Modules
    //

    var delivrApp = angular.module('delivr', [
        'ngAnimate',
        'ngMessages',
        'ui.bootstrap',
        'environmentServices',
        'tspSolver'
    ]);

    delivrApp.config(['$locationProvider', function ($locationProvider) {
        // Configure HTML5 to get links working on JSFiddle
        $locationProvider.html5Mode(true);
    }]);

    //
    // Services
    //

    delivrApp.factory('RenderingService', [function () {
        function RenderingService() {
            this.renderingService = new google.maps.DirectionsRenderer();
        }

        RenderingService.prototype.bind = function (scope, canvas, options) {
            if (!canvas)
                throw "Canvas supplied may not be 'undefined'";

            var mapOptions = $.extend({}, {
                // FIXME
                center: new google.maps.LatLng(59.96512, 30.15732),
                zoom: 10,

                mapTypeControl: true,
                mapTypeControlOptions: {
                    style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
                    position: google.maps.ControlPosition.TOP_RIGHT
                },

                panControl: true,
                panControlOptions: {
                    position: google.maps.ControlPosition.RIGHT_TOP
                },

                zoomControl: true,
                zoomControlOptions: {
                    style: google.maps.ZoomControlStyle.LARGE,
                    position: google.maps.ControlPosition.RIGHT_TOP
                }
           }, options);

           var map = scope.map = new google.maps.Map(canvas, mapOptions);
           this.renderingService.setMap(map);
        }

	RenderingService.prototype.setDirections = function (directions) {
            this.renderingService.setDirections(directions);
        }

        RenderingService.prototype.setRouteIndex = function (index) {
            this.renderingService.setRouteIndex(index);
        }

        return new RenderingService();
    }]);

    delivrApp.factory('TravelFormStorageService', [function () {
        function strip(source) {
            if (!angular.isObject(source))
                return source;

            var stripped = {};
            Object.keys(source).forEach(function (key, index, array) {
                if (String(key)[0] !== "$") {
                    stripped[key] = strip(source[key]);
                }
            });

            return stripped;
        }

        function update(source, target) {
            Object.keys(source).forEach(function (key, index, array) {
                target[key] = source[key];
            });
        }

	var storageService = {
            model: {
                origin_attributes: {},
                destinations_attributes: {},

                $bare: function () {
                    return strip(this);
                },

                $serialize: function () {
                    return { travel: this.$bare() };
                }
            },

            save: function () {
                localStorage.travelForm = angular.toJson(storageService.model.$bare());
            },

            restore: function () {
                if (localStorage.travelForm)
                    update(angular.fromJson(localStorage.travelForm), this.model);
            }
        };

        return storageService;
    }]);


    //
    // Directives
    //

    delivrApp.directive('googleMap', ['$window', '$rootScope', 'RenderingService',
        function ($window, $rootScope, RenderingService) {
            return {
                restrict: 'A',
                scope: { googleMapOptions: '=' },
                link: function (scope, element, attrs) {

                    function loadGoogleMapsAsync() {
                        var loadGoogleMaps =
                            (function ($, window) {
                                "use strict";
                                var now = $.now();
                                var promise;

                                return function (version, apiKey, language, sensor) {
                                    if (promise)
                                        return promise;

                                    var deferred = $.Deferred();
                                    var resolveDeferred = function () {
                                        deferred.resolve(window.google && window.google.maps ? window.google.maps : false);
                                    };

                                    var callbackName = "loadGoogleMaps_" + (now++);

                                    // Default params
                                    var params = $.extend({"sensor": sensor || "false"},
                                                          apiKey ? { "key": apiKey } : {},
                                                          language ? { "language": language} : {});

                                    if (window.google && window.google.maps) {
                                        resolveDeferred();
                                    } else if (window.google && window.google.load) {
                                        window.google.load("maps", version || 3, {
                                            "other_params": $.param(params),
                                            "callback": resolveDeferred
                                        });
                                    } else {
                                        params = $.extend(params, { 'callback': callbackName });

                                        window[callbackName] = function () {
                                            resolveDeferred();
                                            //Delete callback
                                            setTimeout(function () {
                                                try { delete window[callbackName]; } catch (e) { }
                                            }, 20);
                                        };

                                        // Can't use the jXHR promise actually because 'script' doesn't support 'callback=?'
                                        $.ajax({
                                            dataType: 'script',
                                            data: params,
                                            url: config.GOOGLE_MAPS_API
                                        });
                                    }

                                    promise = deferred.promise();

                                    return promise;
                                };
                            })(jQuery, window);

                        $.when(loadGoogleMaps())
                            .then(function () { }).done(function () { initGoogleMaps(); });
                    }

                    function initGoogleMaps() {
                        RenderingService.bind($rootScope, element[0], scope.googleMapOptions || {});
                    }

                    if ($window.google && $window.google.maps)
                        initGoogleMaps();
                    else
                        loadGoogleMapsAsync();
                }
            };
        }]
     );

    delivrApp.directive('verifyAddress', ['$window', '$rootScope',
        function ($window, $rootScope) {
            return {
                restrict:   'A',
                require:    [ 'form' /* WTF? Why 'ngForm' breaks? hmm... maybe ng-form? */ ],
                link: function (scope, element, attrs, controller) { }
            }
        }]
    );


    //
    // Controllers
    //

    delivrApp.controller('TravelFormController', ['$window', '$document', '$rootScope', '$scope', 'Geolocation', 'Geocoder', 'Direction', 'RenderingService', 'TravelFormStorageService', 'TspSolver', 
        function ($window, $document, $rootScope, $scope, Geolocation, Geocoder, Direction, RenderingService, TravelFormStorageService, TspSolver) {
            $scope.accounted    = false;
            $scope.travel       = TravelFormStorageService;
            $scope.settings     = {
                timepicker: {
                    hourStep:   1,
                    minuteStep: 5,
                    isMeridian: false,
                    mouseWheel: false
                }
            };

            function Travel() {}
            function Address() {}
            Address.prototype.format = function () {
                return this["route"] + ", " + this["street_number"] + ", " + this["locality"];
            };

            function validateTravel(travel) {}
            function initOnDOMReady() {
                google.maps.event.addListener($rootScope.map, 'click', function (click) {
                    $scope.$activeTracker && $scope.$activeTracker(click.latLng);
                });
            }

            function Item() {}
            function Destination() {
                this.items_attributes = {}
                this.due_date = {}
            }

            // Timestamp current time to properly detect
            // 00:00 AM crossing

            (function () {
                $scope.$now = $scope.$now || new Date();
            }());

            $scope.pushNextItemFor = function (destination) {
                var next = Object.keys(destination.items_attributes).length;
                destination.items_attributes[next] = new Item();
            };

            $scope.pushNextDestinationIfNone = function () {
                if (Object.keys($scope.travel.model.destinations_attributes).length == 0)
                    $scope.pushNextDestination()
            };

            $scope.pushNextDestination = function () {
                var destinations_attributes = $scope.travel.model.destinations_attributes;
                var next = Object.keys(destinations_attributes).length;
                destinations_attributes[next] = new Destination();
                $scope.pushNextItemFor(destinations_attributes[next]);
            };

            $scope.submitTravel = function () {
                validateTravel($scope.travel.model);
                $.ajax({
                    type: 'POST',
                    url: '/travels',
                    data: $scope.travel.model.$serialize(),
                    dataType: 'json'
                }).success(function (jqXHR, status, data) {
                    $scope.log("[AJAX][S]: Successfully created!");
                    var location = data.getResponseHeader("location");
                    window.location.replace(location);
                }).error(function (jqXHR, status, error) {
                    $scope.log("[AJAX][E]: " + status + "/" + error);
                });

            };

            $scope.registerClickerAndAutoComplete = function (target, $event) {
                $scope.tryBindTracker(target);
                $scope.tryBindAutoComplete(target, $event.target);
                $scope.$activeTracker = target.$trackingService;
            };

            $scope.tryBindTracker = function (target) {
                if (target.$trackingService)
                    return;
                target.$trackingService = function (position) {
                    $scope.tryResolveAndMarkPosition({ latLng: position }, target);
                };
            };

            $scope.tryBindAutoComplete = function (target, input) {
                if (target.$autoCompleteService)
                    return;

                target.$autoCompleteService = new google.maps.places.Autocomplete(input, { types: [ 'geocode' ] });

                Geolocation.atCurrentPosition(function (position) {
                    var location = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
                    target.$autoCompleteService.setBounds(new google.maps.LatLngBounds(location, location));
                });

                google.maps.event.addListener(target.$autoCompleteService, 'place_changed', function () {
                    var map = $rootScope.map;
                    var place = target.$autoCompleteService.getPlace();

                    //
                    // Check whether place lookup succeeded: reset marker if it did,
                    // and drop previously resolved coordinates otherwise
                    //

                    if (place.geometry.viewport) {
                        map.fitBounds(place.geometry.viewport);
                    } else {
                        map.setCenter(place.geometry.location);
                        map.setZoom(10);
                    }

                    var filtered = new Address();
                    var format = {
                        street_number: 'short_name',
                        route: 'long_name',
                        locality: 'long_name'
                    };

                    for (var i = 0; i < place.address_components.length; ++i) {
                        var type = place.address_components[i].types[0];
                        if (format[type])
                            filtered[type] = place.address_components[i][format[type]]
                    }

                    var position = {
                        latLng: place.geometry.location,
                        address: filtered.format()
                    };
                    $scope.tryResolveAndMarkPosition(position, target);
                });
            };

            $scope.tryResolveAndMarkPosition = function (position, target) {
                var map = $rootScope.map;
                if (target.$mapInfo) {
                    target.$mapInfo.marker.setMap(null);
                    target.$mapInfo = null;
                }

                var marker = new google.maps.Marker({
                    map: map,
                    position: position.latLng,
                    draggable: true
                });

                target.$mapInfo = { marker: marker };
                var popup = new google.maps.InfoWindow();

                function updateMarker(position) {
                    $scope.$apply(function () {
                        target.address = position.address;
                        target.coordinates = position.latLng.toString();
                    });
                    popup.setContent(position.address);
                    popup.open(map, marker);
                }

                google.maps.event.addListener(marker, 'dragend', function () {
                    Geocoder.resolveByCoordinates(marker.getPosition(), updateMarker);
                });

                if (position.address)
                    updateMarker(position);
                else
                    Geocoder.resolveByCoordinates(marker.getPosition(), updateMarker);
            };


            function doReqBy(model, callback) {

                var waypoints = [{
                    latLng: new Coordinates(model.origin_attributes.coordinates).toLatLng(),
                    from: 0,
                    to: 60*24
                }];

                delivr.util.values(model.destinations_attributes).forEach(function (value, index, array) {

                    // "Event Horizon" is extended max up to 24h up to _now_ therefore if we checked up
                    // that some order crosses the 00:00 AM line, we just shift it by another 24 hours

                    var fromHours = value.due_date.starts.getHours();
                    var toHours   = value.due_date.ends.getHours();

                    if ($scope.$now.getHours() > fromHours)
                        fromHours += 24;

                    if ($scope.$now.getHours() > toHours)
                        toHours += 24;

                    waypoints.push({
                        latLng: new Coordinates(value.coordinates).toLatLng(),
                        from:   fromHours * 60 + value.due_date.starts.getMinutes(),
                        to:     toHours * 60 + value.due_date.ends.getMinutes()
                    });
                });

                TspSolver.solve(waypoints, function (route) {
                    var waypoints = route.slice(1, route.length - 1).map(function (value, index, array) {
                        return {
                            location: value.point.latLng,
                            stopover: true
                        };
                    });

                    var request = {
                        origin: route[0].point.latLng,
                        destination: route[route.length - 1].point.latLng,
                        waypoints: waypoints,
                        optimizeWaypoints: false,
                        provideRouteAlternatives: false,
                        travelMode: google.maps.TravelMode.DRIVING,
                        unitSystem: google.maps.UnitSystem.METRIC
                    };

                    Direction.route(request, callback);
                });
            }

            // Make Directions API proper request by supplied travel model

            function makeReqBy(model) {

                var origin = new Coordinates(model.origin_attributes.coordinates).toLatLng();
                var destination;

                var waypoints = delivr.util.values(model.destinations_attributes).map(function (destination) {
                    return new Coordinates(destination.coordinates).toLatLng();
                });


                function euclidSquaredDistance(a, b) {
                    return Math.pow(a.lat() - b.lat(), 2) + Math.pow(a.lng() - b.lng(), 2);
                }

                if (waypoints.length < 2) {

                    destination = waypoints[0];

                } else {

                    var bb = (function (points) {
                        var nw, se;

                        if (points.length < 2)
                            throw "";

                        nw = points[0];
                        se = points[1];

                        for (var i = 2; i < points.length; ++i) {
                            var p = points[i];

                            // FIXME: Scale those to not to break into denormalized ones

                            if (p.lat() > se.lat() || p.lng() > se.lng())
                                se = p;
                            else if (p.lat() < nw.lat() || p.lng() < nw.lng())
                                nw = p;
                        }

                        return [ nw, se ];
                    })(waypoints);

                    //
                    // Take the most far waypoint as a "destination"
                    //

                    if (euclidSquaredDistance(origin, bb[0]) > euclidSquaredDistance(origin, bb[1]))
                        destination = bb[0];
                    else
                        destination = bb[1];
                }

                waypoints = waypoints.filter(function (wp) {
                    return !wp.equals(destination);
                });

                return {
                    origin: origin,
                    destination: destination,

                    waypoints: waypoints.map(function (waypoint) {
                        return {
                            location: waypoint,
                            stopover: true
                        }
                    }),

                    optimizeWaypoints: true,

                    provideRouteAlternatives: true,
                    travelMode: google.maps.TravelMode.DRIVING,
                    unitSystem: google.maps.UnitSystem.METRIC
                }
            }

            $scope.composeTravelRoutes = function (callback) {
                var map = $rootScope.map;
                var elem = angular.element($("div #travel-summary"));

                // Create the tsp object
                tsp = new BpTspSolver(map, elem, Geocoder.geocoder, Direction.direction);

                tsp.setTravelMode(google.maps.DirectionsTravelMode.DRIVING);

                // Add points (by coordinates, or by address).
                // The first point added is the starting location.
                // The last point added is the final destination (in the case of A - Z mode)

                var r = makeReqBy($scope.travel.model);

                tsp.addWaypoint(r.origin);  // Note: The callback is new for version 3, to ensure waypoints and addresses appear in the order they were added in.
                //tsp.addAddress(r.origin, null);

                r.waypoints.forEach(function (wp) {
                    tsp.addWaypoint(wp.location);
                });

                tsp.addWaypoint(r.destination);

                // Solve the problem (start and end up at the first location)
                //tsp.solveRoundTrip(null);

                // Or, if you want to start in the first location and end at the last,
                // but don't care about the order of the points in between:
                tsp.solveAtoZ(function () {
                    // Retrieve the solution (so you can display it to the user or do whatever :-)
                    var dir = tsp.getGDirections();  // This is a normal GDirections object.

                    callback(dir);
                });

                // The order of the elements in dir now correspond to the optimal route.

                // If you just want the permutation of the location indices that is the best route:
                //var order = tsp.getOrder();

                // If you want the duration matrix that was used to compute the route:
                //var durations = tsp.getDurations();

                // There are also other utility functions, see the source.
            };

            $scope.composeTravelRoutes0 = function (callback) {
                var request = makeReqBy($scope.travel.model);
                Direction.route(request, callback);
            };

            $scope.composeTravelRoutes1 = function (callback) {
                doReqBy($scope.travel.model, callback);
            };

            $scope.selected = function (route) {
                return $scope.travel.model.route_attributes === route;
            };

            $scope.selectRoute = function (route) {
                $scope.travel.model.route_attributes = route;

                // FIXME: Move out non-idempotent service out of services
                RenderingService.setRouteIndex(route.$index);
            };

            ///////////////////////////////////////////////////////////////////////////////////////////

            //
            // Route UI harness
            //

            function lengthOf(route) {
                return route.legs.reduce(function (acc, leg) {
                    return acc + leg.distance.value;
                }, 0);
            }

            function durationOf(route) {
                return route.legs.reduce(function (acc, leg) {
                    return acc + leg.duration.value;
                }, 0);
            }

            function polylineOf(route) {
                return route.overview_polyline;
            }

            function serializeOrder(route) {
                return route.waypoint_order.reduce(function (s, index, i) {
                    if (i != 0)
                        s += ",";
                    return s + index.toString();
                }, "");
            }

            function costOf(route) {
                if (!route.length || !route.$items)
                    return NaN;

                var req = {
                    route: {
                        length: route.length,
                        items:  route.$items
                    }
                };

                var cost;

                $.ajax({
                    type:   'GET',
                    url:    '/account.json',
                    data:   req,

                    async:  false,

                    // FIXME: `success` are deprecated, migrate to `done`

                    success: function (r) {
                        cost = r.cost;
                    }
                });

                return cost;
            }


            function Route(items, route, index) {
                this.$route     = route;
                this.$index     = index;

                this.$items     = items;

                this.length     = lengthOf(route);
                this.duration   = durationOf(route);
                this.cost       = costOf(this);

                this.order      = serializeOrder(route);

                this.polyline   = polylineOf(route);
            }

            Route.prototype.inKilo = function () {
                return delivr.util.us.toKilo(this.length, 1);
            };

            Route.prototype.inMinutes = function () {
                return delivr.util.us.toMinutes(this.duration, 0);
            };

            $scope.forth = function () {
                TravelFormStorageService.save();

                $scope.accounted = true;

                $scope.composeTravelRoutes1(function (result) {

                    if (result.status == google.maps.DirectionsStatus.OK) {

                        RenderingService.setDirections(result);

                        var items =
                            delivr.util.values($scope.travel.model.destinations_attributes)
                                .map(function (d) { return delivr.util.values(d.items_attributes); })
//                                .flatten();

                        items.flatten();

                        // This is b/c callback would be run out of Angular's scope,
                        // therefore making him oblivious to any such a change
                        $scope.$apply(function () {
                            $scope.travel.model.$routes = result.routes.map(function (route, index) {
                                return new Route(items, route, index);
                            });
                        });
                    }
                });
            };

            $scope.back = function () {
                TravelFormStorageService.restore();

                $scope.accounted = false;

                $scope.travel = TravelFormStorageService;
            };

            ///////////////////////////////////////////////////////////////////////////////////////////

            $scope.log = function (o) {
                console.log($scope.name + ": " + o.toString());
            };

            ///////////////////////////////////////////////////////////////////////////////////////////

            // DEBUG_ONLY

            $scope.$debugLog = function (o) {
                console.log(o);
            };

            $scope.$dumpTravel = function () {
                console.log("Route: \n");
                console.log($scope.travel);
            };

            ///////////////////////////////////////////////////////////////////////////////////////////

            $document.ready(function (_) {
                initOnDOMReady();
            });

        } ])

        //
        // Controllers
        //

        .controller('TravelsListingController', [ '$scope', '$rootScope', function ($scope, $rootScope) {

            // FIXME
            var originMarker, destinationMarkers;

            $scope.showTravel = function ($event) {

                var map = $rootScope.map;

                // FIXME: ASAP

                var travelDOM = $($event.target).closest("div .travel");

                var origin = new Coordinates($("div #origin", travelDOM).data("coordinates")).toLatLng();
                var destinations =
                    $("div #destinations > .destination", travelDOM)
                        .toArray()
                        .map(function (dest) {
                            return new Coordinates($(dest).data("coordinates")).toLatLng();
                        });

                originMarker = new google.maps.Marker({
                    position: origin,
                    map: map,
                    draggable: false
                });

                destinationMarkers =
                    destinations.map(function (dest) {
                        return new google.maps.Marker({
                            position: dest,
                            map: map,
                            draggable: false
                        });
                    });
            };

            $scope.hideTravel = function ($event) {
                originMarker.setMap(null);
                destinationMarkers.forEach(function (marker) {
                    marker.setMap(null);
                });
            };

            // Dumb sliding animation

            // For travel dashboard

            // FIXME: Replace with native Angular animation

            $scope.slideTravelDashboard = function ($event) {
                var travelDOM = $($event.target).closest("div .travel");

                $(".travel-dashboard", travelDOM)
                    .stop(true, true)
                    .slideToggle()
                    .removeClass('ng-hide'); // FIXME
            };

            // And travel's items

            $scope.slideItemsList = function ($event) {
                var travelDOM = $($event.target).closest("div .destination");

                $(".destination-items-list", travelDOM)
                    .stop(true, true)
                    .slideToggle()
                    .removeClass('ng-hide'); // FIXME
            };

        }]);


        //
        // Enable opted-in Bootstrap JS Popover- and Tooltip-API
        //

        $(function () {
            $('body').popover({
                selector: '[data-toggle="popover"]'
            });

            $('body').tooltip({
                selector: 'a[rel="tooltip"], [data-toggle="tooltip"]'
            });
        });

})(jQuery);
