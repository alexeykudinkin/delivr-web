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
//= require turbolinks
//= require_tree .

'use strict';

//
// Services
//

//function Shipper() {
//    this.current    = null;
//    this.travels        = [];
//}


//
// Queue
//

//function Queue() {}
//
//Queue.prototype = {
//
//    callbacks: {},
//
//    enqueue: function(event, callback) {
//        if (!this.callbacks[event])
//            this.callbacks[event] = [];
//
//        this.callbacks[event].push(callback);
//    },
//
//    notify: function(event) {
//        if (this.callbacks[event])
//        {
//            this.callbacks[event].forEach(function (callback) {
//                callback(event)
//            });
//        }
//    }
//};


//
// Modules
//

angular.module('delivr', [ 'ngAnimate' ])

    .config([ '$locationProvider', function ($locationProvider) {

        // Configure HTML5 to get links working on JSFiddle
        $locationProvider.html5Mode(true);
    } ])

    //
    // Services
    //

    .factory('delivrEnvironmentService', [ function() {

        function Services() {

            function imbue(self, map) {
                self.directionsRenderingService.setMap(map);
            }

            this.geoCodingService           = new google.maps.Geocoder();
            this.directionsService          = new google.maps.DirectionsService();
            this.directionsRenderingService = new google.maps.DirectionsRenderer();

            this.navigatorService = {
                atCurrentPosition: function (handler) {
                    if (navigator.geolocation) {
                        navigator.geolocation.getCurrentPosition(function (position) {
                            handler(position);
                        })
                    }
                }
            };

            this.resolveAddress = function (coordinates, callback) {
                this.geoCodingService.geocode({ latLng: coordinates }, function (results, status) {
                    if (status == google.maps.GeocoderStatus.OK)
                        callback(coordinates, results[0].formatted_address);
                    else
                        callback(coordinates, coordinates);
                });
            };

            this.init = function (scope, canvas, options) {

                if (!canvas)
                    throw "Canvas supplied may not be 'undefined'";

                var mapOptions = $.extend({}, {

                    // FIXME
                    center: new google.maps.LatLng(59.96512, 30.15732),
                    zoom:   10,

                    mapTypeControl: true,
                    mapTypeControlOptions: {
                        style:      google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
                        position:   google.maps.ControlPosition.TOP_RIGHT
                    },

                    panControl: true,
                    panControlOptions: {
                        position:   google.maps.ControlPosition.RIGHT_TOP
                    },

                    zoomControl: true,
                    zoomControlOptions: {
                        style:      google.maps.ZoomControlStyle.LARGE,
                        position:   google.maps.ControlPosition.RIGHT_TOP
                    }
                }, options);

                var map = scope.map = new google.maps.Map(canvas, mapOptions);

                imbue(this, map);
            };
        }

        return new Services();
    }])

    .factory('travelFormStorageService', [ function () {

        function strip(source) {
            if (!angular.isObject(source))
                return source;

            var stripped = {};
            Object.keys(source).forEach(function (key, index, array) {
                    if (String(key)[0] !== "$") {
                        stripped[key] = strip(source[key]);
                    }
                }
            );

            return stripped;
        }

        function update(source, target) {
            Object.keys(source).forEach(function (key, index, array) {
                target[key] = source[key];
            })
        }

        var storageService = {

            model: {
                origin_attributes:          {},
                destinations_attributes:    {},

                $bare: function () {
                    return strip(this);
                },

                $serialize: function() {
                    return {
                        travel: this.$bare()
                    }
                }
            },

            save: function () {
                localStorage.travelForm = angular.toJson(storageService.model.$bare());
            },

            restore: function () {
                if (localStorage.travelForm) {
                    update(angular.fromJson(localStorage.travelForm), this.model);
                }
            }
        };

        return storageService;
    } ])


    //
    // Directives
    //

    .directive('googleMap', [ '$window', '$rootScope', 'delivrEnvironmentService', function ($window, $rootScope, delivrEnvironmentService) {
        return {
            restrict: 'A',
            scope: {
                googleMapOptions:   '='
            },
            link: function (scope, element, attrs) {

                function loadGoogleMapsAsync() {

                    var loadGoogleMaps =
                        (function ($, window) {
                            "use strict";

                            var now = $.now();
                            var promise;

                            return function (version, apiKey, language, sensor) {
                                if (promise) {
                                    return promise;
                                }

                                var deferred = $.Deferred();

                                var resolveDeferred = function () {
                                    deferred.resolve(window.google && window.google.maps ? window.google.maps : false);
                                };

                                var callbackName = "loadGoogleMaps_" + (now++);

                                // Default params
                                var params =
                                    $.extend({
                                            "sensor": sensor || "false"
                                        },
                                        apiKey ? {
                                            "key": apiKey
                                        } : {},
                                        language ? {
                                            "language": language
                                        } : {});

                                if (window.google && window.google.maps) {
                                    resolveDeferred();
                                } else if (window.google && window.google.load) {
                                    window.google.load("maps", version || 3, {
                                        "other_params": $.param(params),
                                        "callback": resolveDeferred
                                    });
                                } else {
                                    params = $.extend(params, {
                                        'callback': callbackName
                                    });

                                    window[callbackName] = function () {
                                        resolveDeferred();

                                        //Delete callback
                                        setTimeout(function () {
                                            try {
                                                delete window[callbackName];
                                            } catch (e) {
                                            }
                                        }, 20);
                                    };

                                    // Can't use the jXHR promise actually because 'script' doesn't support 'callback=?'
                                    $.ajax({
                                        dataType: 'script',
                                        data: params,
                                        url: '//maps.googleapis.com/maps/api/js'
                                    });

                                }

                                promise = deferred.promise();

                                return promise;
                            };

                        })(jQuery, window);

                    $.when(loadGoogleMaps())
                        .then(function () {
                            /* NOP */
                        })
                        .done(function () {
                            initGoogleMaps();
                        });
                }

                function initGoogleMaps() {
                    delivrEnvironmentService.init($rootScope, element[0], scope.googleMapOptions || {});
                }

                if ($window.google && $window.google.maps) {
                    initGoogleMaps();
                } else {
                    loadGoogleMapsAsync();
                }
            }
        };
    }])


    //
    // Controllers
    //

    .controller('DelivrEnvironmentController', [ '$scope', '$rootScope', 'delivrEnvironmentService', function ($scope, $rootScope, delivrEnvironmentService) {
        // NOP
    } ])

    //
    // Controllers
    //

    .controller('TravelFormController', [ '$window', '$document', '$rootScope', '$scope', 'delivrEnvironmentService', 'travelFormStorageService', function ($window, $document, $rootScope, $scope, delivrEnvironmentService, travelFormStorageService) {

        // Travels

        function Travel() {}

        function Address() {}

        Address.prototype.format = function() {
            return this["route"] + ", " + this["street_number"] + ", " + this["locality"];
        };

        //
        // Local declarations
        //

        // Sanity checking harness

        function validateTravel(travel) { /* NOP */ }

        function init() {
            $scope.accounted            = false;
            $scope.travel               = travelFormStorageService;

            google.maps.event.addListener($rootScope.map, 'click', function (click) {
                $scope.$activeTracker && $scope.$activeTracker(click.latLng);
            });
        }

        //
        // Scope declarations
        //

        $scope.pushNextItemFor = function (destination) {
            if (!destination.items_attributes) {
                destination.items_attributes = {};
            }

            var next = Object.keys(destination.items_attributes).length;

            destination.items_attributes[next] = {};
        };

        $scope.pushNextDestination = function () {

            if (!$scope.travel.model.destinations_attributes) {
                $scope.travel.model.destinations_attributes = {};
            }

            var destinations_attributes = $scope.travel.model.destinations_attributes;
            var next = Object.keys(destinations_attributes).length;

            destinations_attributes[next] = {};
        };

        $scope.submitTravel = function () {

            validateTravel($scope.travel.model);

            console.log($scope.travel.model);
            console.log($scope.travel.model.$bare());

            $.ajax({
                type:     'POST',
                url:      '/travels',
                data:     $scope.travel.model.$serialize(),
                dataType: 'json'
            }).done(function (data) {
                console.log("[AJAX][S]: Successfully created!");
            }).error(function (jqXHR, status, error) {
                console.log("[AJAX][E]: " + status + ":" + error);
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
                $scope.markPosition({ coordinates: position }, target);
            };
        };

        $scope.tryBindAutoComplete = function (target, input) {
            if (target.$autoCompleteService)
                return;

            target.$autoCompleteService = new google.maps.places.Autocomplete(input, { types: [ 'geocode' ] });

            delivrEnvironmentService.navigatorService.atCurrentPosition(function (position) {
                var location = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
                target.$autoCompleteService.setBounds(new google.maps.LatLngBounds(location, location));
            });

            google.maps.event.addDomListener(input, 'keydown', function (event) {
                    switch (event.keyCode) {
                        case 13: /* Stop bubbling up the form! */
                            event.preventDefault();
                            break;
                    }
                }
            );

            google.maps.event.addListener(target.$autoCompleteService, 'place_changed', function () {

                var map = $rootScope.map;

                var place = target.$autoCompleteService.getPlace();

                // Hide elements not providing corresponding geometry-info
                if (place.geometry) {
                    if (place.geometry.viewport) {
                        map.fitBounds(place.geometry.viewport);
                    } else {
                        map.setCenter(place.geometry.location);
                        map.setZoom(10);
                    }

                    var filtered = new Address();

                    var format = {
                        street_number:  'short_name',
                        route:          'long_name',
                        locality:       'long_name'
                    };

                    for (var i = 0; i < place.address_components.length; ++i) {
                        var type = place.address_components[i].types[0];

                        if (format[type]) {
                            filtered[type] = place.address_components[i][format[type]]
                        }
                    }

                    var position = {
                        coordinates:    place.geometry.location,
                        address:        filtered.format()
                    };

                    $scope.markPosition(position, target);
                }
            })
        };

        $scope.markPosition = function (position, target) {

            var map     = $rootScope.map;

            var mapInfo = target.$mapInfo;

            if (mapInfo) {
                mapInfo.marker.setMap(null);
                mapInfo.marker = null;
            }

            var infoW   = new google.maps.InfoWindow();
            var marker  = new google.maps.Marker({
                map:        map,
                position:   position["coordinates"],
                draggable:  true
            });

            target.$mapInfo = {
                marker: marker
            };

            var setResolved =
                function (coordinates, address) {

                    // This is for all models bound to the `address` and `coordinates`
                    // to be notified of change, due to `setResolved` being fired as a
                    // callback of the geocoding service
                    $scope.$apply(
                        function () {
                            target.address      = address;
                            target.coordinates  = coordinates.toString(); // FIXME: Replace with LatLng
                        });

                    infoW.setContent(address);
                    infoW.open(map, marker);
                };

            if (position["address"]) {
                setResolved(marker.getPosition(), position["address"]);
            } else {
                delivrEnvironmentService.resolveAddress(marker.getPosition(), setResolved);
            }

            google.maps.event.addListener(marker, 'dragend', function (_) {
                delivrEnvironmentService.resolveAddress(marker.getPosition(), setResolved);
            });
        };

        $scope.calculateRoute = function () {

            function makeReqBy(model) {
                var origin = new Coordinates(model.origin_attributes.coordinates).toLatLng();

                var waypoints = delivr.util.values(model.destinations_attributes).map(function (destination) {
                    return new Coordinates(destination.coordinates).toLatLng();
                });

                // FIXME
                var destination = waypoints.last();

                waypoints = waypoints.slice(0, waypoints.length - 1);

                return {
                    origin:         origin,
                    destination:    destination,

                    waypoints:      waypoints.map(function (waypoint) {
                                        return {
                                            location: waypoint,
                                            stopover: true
                                        }
                                    }),

                    optimizeWaypoints: true,

                    provideRouteAlternatives: false,
                    travelMode: google.maps.TravelMode.DRIVING,
                    unitSystem: google.maps.UnitSystem.METRIC
                }
            }

            var request = makeReqBy($scope.travel.model);

            console.log(request);

            delivrEnvironmentService.directionsService.route(request, function(result, status) {
                if (status == google.maps.DirectionsStatus.OK) {
                    delivrEnvironmentService.directionsRenderingService.setDirections(result);
                }
            });
        };

        ///////////////////////////////////////////////////////////////////////////////////////////

        $scope.forth = function () {
            travelFormStorageService.save();

            $scope.accounted = true;

            $scope.calculateRoute();
        };

        $scope.back = function () {
            travelFormStorageService.restore();

            $scope.accounted = false;

            $scope.travel = travelFormStorageService;
        };

        ///////////////////////////////////////////////////////////////////////////////////////////

        // DEBUG_ONLY

        $scope.$dumpTravel = function () {
            console.log("Travel: \n");
            console.log($scope.travel);
        };

        ///////////////////////////////////////////////////////////////////////////////////////////

        $document.ready(function (_) {
            init();
        });

    } ])

    .controller('TravelsListingController', [ '$scope', '$rootScope', function ($scope, $rootScope) {

        var map = $rootScope.map;

        // FIXME
        var originMarker, destinationMarkers;

        $scope.showTravel = function ($event) {

            // FIXME: ASAP

            var travelDOM = $($event.target).closest("div .travel");

            var origin          = new Coordinates($("div #origin", travelDOM).data("coordinates")).toLatLng();
            var destinations    =
                $("div #destinations > .destination", travelDOM)
                    .toArray()
                    .map(function (dest) {
                        return new Coordinates($(dest).data("coordinates")).toLatLng();
                    });

            originMarker = new google.maps.Marker({
                position:   origin,
                map:        map,
                draggable:  false
            });

            destinationMarkers =
                destinations.map(function (dest) {
                    return new google.maps.Marker({
                        position:   dest,
                        map:        map,
                        draggable:  false
                    });
                });
        };

        $scope.hideTravel = function ($event) {
            originMarker.setMap(null);
            destinationMarkers.forEach(function (marker) { marker.setMap(null); });
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
