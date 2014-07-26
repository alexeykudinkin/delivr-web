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


//
// Services
//

function Shipper() {
    this.activeInput    = null;
    this.travels        = [];
}

function Services() {

    this.geoCodingService = new google.maps.Geocoder();

    this.autoCompleteService = {};

    this.navigatorService = {
        atCurrentPosition: function (handler) {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (position) {
                    handler(position);
                })
            }
        }
    }
}


//
// Queue
//

function Queue() {}

Queue.prototype = {

    callbacks: {},

    enqueue: function(event, callback) {
        if (!this.callbacks[event])
            this.callbacks[event] = [];

        this.callbacks[event].push(callback);
    },

    notify: function(event) {
        if (this.callbacks[event])
        {
            this.callbacks[event].forEach(function (callback) {
                callback(event)
            });
        }
    }
};


//
// Travels
//

function Address() {}

Address.prototype.format = function() {
    return this["route"] + ", " + this["street_number"] + ", " + this["locality"];
};

function Travel() {}


//
// Shipper
//

Shipper.prototype = {

    Q: new Queue(),

    init: function () {
        var canvas = $("#map-canvas").get(0);

        this.initMap(canvas);

        this.services = new Services();

        this.Q.notify("init");
    },

    initMap: function (canvas, options) {
        if (!canvas)
            return;

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

        this.map = new google.maps.Map(canvas, mapOptions);

        this.Q.notify("init:map");
    },

    createTravel: function() {
        this.travels.push(new Travel());
    },

    registerTrackerAndAutoComplete: function () {
        var thisT   = this;
        var map     = this.map;

        $("div .form-body").on("click", "div[data-tracking-target]", function() {
            var input = $(this);

            thisT.activeInput = input;
            thisT.bindAutoComplete(input);
        });

        google.maps.event.addListener(map, 'click', function (click) {
            thisT.markPosition({ coordinates: click.latLng });
        });
    },

    markPosition: function (position) {
        var input   = this.activeInput;
        var map     = this.map;

        var travel  = this.travels.last();

        var target = $(input).data("tracking-target");

        if (target) {
            var travelInfo = travel[target];

            if (travelInfo) {
                travelInfo.marker.setMap(null);

                travelInfo.marker   = null;
                travelInfo.input    = null;
            }

            var infoW = new google.maps.InfoWindow();
            var marker = new google.maps.Marker({
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
                this.reverseGC(marker.getPosition(), setResolved);

            var thisT = this;

            google.maps.event.addListener(marker, 'dragend', function (_) {
                thisT.reverseGC(marker.getPosition(), setResolved);
            });
        }
    },

    reverseGC: function (location, callback) {
        this.services.geoCodingService.geocode({ latLng: location }, function (results, status) {
            if (status == google.maps.GeocoderStatus.OK)
                callback(location, results[0].formatted_address);
            else
                callback(location, location);
        });
    },

    bindAutoComplete: function (form) {
        var target  = $(form).data("tracking-target");
        var input   = $(form).children(".address").get(0);

        if (this.services.autoCompleteService[target])
            return;

        this.services.autoCompleteService[target] = new google.maps.places.Autocomplete(input, { types: [ 'geocode' ] });

        var thisT   = this;
        var map     = this.map;

        this.services.navigatorService.atCurrentPosition(function (position) {
            var location = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            thisT.services.autoCompleteService[target].setBounds(new google.maps.LatLngBounds(location, location));
        });

        google.maps.event.addDomListener(input, 'keydown', function (event) {
                switch (event.keyCode) {
                    case 13: /* Stop bubbling up the form! */
                        event.preventDefault();
                        break;
                }
            }
        );

        google.maps.event.addListener(this.services.autoCompleteService[target], 'place_changed', function () {

            var place = thisT.services.autoCompleteService[target].getPlace();

            console.log(place);

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

                thisT.markPosition(position);
            }
        })
    }

};

var shipper = new Shipper();