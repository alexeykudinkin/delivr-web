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
//    this.activeInput    = null;
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

            this.geoCodingService = new google.maps.Geocoder();

            this.navigatorService = {
                atCurrentPosition: function (handler) {
                    if (navigator.geolocation) {
                        navigator.geolocation.getCurrentPosition(function (position) {
                            handler(position);
                        })
                    }
                }
            };

            this.reverseGC = function (coordinates, callback) {
                this.geoCodingService.geocode({ latLng: coordinates }, function (results, status) {
                    if (status == google.maps.GeocoderStatus.OK)
                        callback(coordinates, results[0].formatted_address);
                    else
                        callback(coordinates, coordinates);
                });
            };

            this.initMap = function (scope, canvas, options) {

                if (!canvas)
                    throw "Canvas supplied may not be 'undefined'";

                var mapOptions = $.extend({}, {
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

                scope.map = new google.maps.Map(canvas, mapOptions);
            };
        }

        return new Services();
    }])

    .factory('travelFormStorageService', [ function () {

        var storageService = {
            model: {},

            save: function () {
                localStorage.travelForm = angular.toJson(storageService.model);
            },

            restore: function () {
                storageService.model = angular.fromJson(localStorage.travelForm);
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
                    delivrEnvironmentService.initMap($rootScope, element[0], scope.googleMapOptions || {});
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
            $scope.autoCompleteServices = {};

            $document.ready(function () {
                $scope.registerTrackerAndAutoComplete();
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

            $.ajax({
                type:     'POST',
                url:      '/travels',
                data:     $scope.travel.model,
                dataType: 'json'
            }).done(function (data) {
                //              console.log(data);
                alert(data);
            }).error(function (jqXHR, status, error) {
                console.log("[AJAX]: " + status + ":" + error);
            });

        };

        $scope.createTravel = function() {
            $scope.travels.push(new Travel());
        };

        ///////////////////////////////////////////////////////////////////////////////////////////

        $scope.registerTrackerAndAutoComplete = function () {

            $("div .form-body").on("click", "div[data-tracking-target]", function() {
                var input = $(this);

                $scope.activeInput = input;
                $scope.bindAutoComplete(input);
            });

            google.maps.event.addListener($rootScope.map, 'click', function (click) {
                $scope.markPosition({ coordinates: click.latLng });
            });
        };

        $scope.bindAutoComplete = function (form) {
            var target  = $(form).data("tracking-target");
            var input   = $(form).children(".address").get(0);

            if ($scope.autoCompleteServices[target])
                return;

            $scope.autoCompleteServices[target] = new google.maps.places.Autocomplete(input, { types: [ 'geocode' ] });

            delivrEnvironmentService.navigatorService.atCurrentPosition(function (position) {
                var location = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
                $scope.autoCompleteServices[target].setBounds(new google.maps.LatLngBounds(location, location));
            });

            google.maps.event.addDomListener(input, 'keydown', function (event) {
                    switch (event.keyCode) {
                        case 13: /* Stop bubbling up the form! */
                            event.preventDefault();
                            break;
                    }
                }
            );

            google.maps.event.addListener($scope.autoCompleteServices[target], 'place_changed', function () {

                var map     = $rootScope.map;
                var place   = $scope.autoCompleteServices[target].getPlace();

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

                    $scope.markPosition(position);
                }
            })
        };

        $scope.markPosition = function (position) {
            var map     = $rootScope.map;

            var input   = $scope.activeInput;
            var travel  = $scope.travel;

            var target = $(input).data("tracking-target");

            if (target) {
                var travelInfo = travel[target];

                if (travelInfo) {
                    travelInfo.marker.setMap(null);

                    travelInfo.marker   = null;
                    travelInfo.input    = null;
                }

                var infoW   = new google.maps.InfoWindow();
                var marker  = new google.maps.Marker({
                    map: map,
                    position: position["coordinates"],
                    draggable: true
                });

                travel[target] = travelInfo = {
                    marker: marker,
                    input: {
                        address:        $(input).children(".address"),
                        coordinates:    $(input).children(".coordinates")
                    }
                };

                var setResolved =
                    function (coordinates, address) {
                        var addr    = $(travelInfo.input.address);
                        var coords  = $(travelInfo.input.coordinates);

                        addr    .val(address);
                        coords  .val(coordinates);

                        // AngularJS compatibility layer
                        // Please FIXME ASAP

                        console.log(travelInfo.input);

                        addr    .trigger('input');
                        coords  .trigger('input');

                        infoW.setContent(address);
                        infoW.open(map, marker);
                    };

                if (position["address"])
                    setResolved(marker.getPosition(), position["address"]);
                else
                    delivrEnvironmentService.reverseGC(marker.getPosition(), setResolved);

                google.maps.event.addListener(marker, 'dragend', function (_) {
                    delivrEnvironmentService.reverseGC(marker.getPosition(), setResolved);
                });
            }
        };

        ///////////////////////////////////////////////////////////////////////////////////////////

        $scope.forth = function () {
            travelFormStorageService.save();
            $scope.accounted = true;

            console.log($scope.travel.model);
        };

        $scope.back = function () {
            travelFormStorageService.restore();
            $scope.accounted = false;
            $scope.travel = travelFormStorageService;

            console.log($scope.travel.model);
        };

        init();

    } ]);