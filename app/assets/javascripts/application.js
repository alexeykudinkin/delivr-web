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


function Queue() {}
Queue.prototype = {

    callbacks: {},

    queue: function(event, callback) {
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

function Shipper() {}
function Services() {
    this.gc = new google.maps.Geocoder();
}

function bind(context, method) {
    return function() {
        return context[method].apply(context, arguments);
    }
}

Shipper.prototype = {

    Q: new Queue(),

    init: function () {
        var mapOptions = {
            center: new google.maps.LatLng(59.96512, 30.15732),
            zoom: 10
        };

        this.services   = new Services();
        this.map        = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

        this.Q.notify("init");

        //this.createTravel();
        //this.registerTracker();
    },

    createTravel: function() {
        function Travel() {}
        this.travel = new Travel();
    },

    registerTracker: function () {
        var map      = this.map;
        var tracking = null;

        google.maps.event.addListener(map, 'click', function (click) {
            var markerOptions = {
                position:   click.latLng,
                map:        map,
                draggable:  true
            };

            mark(tracking, markerOptions)
        });

        $("input[data-tracking-target]").click(function() {
            tracking = $(this).data("tracking-target");
        });
    },

    show: function(travel) {}

};


var shipper = new Shipper();


function mark(target, options)
{
    if (target && !shipper.travel[target])
    {
        var marker = new google.maps.Marker(options);

        shipper.travel[target] = {
            marker: marker,
            input:  {
                address:      "#travel_" + target + "_attributes_address",
                coordinates:  "#travel_" + target + "_attributes_coordinates"
            }
        };

        var setResolved =
            function (address, coordinates) {
                $(shipper.travel[target].input.coordinates) .val(coordinates);
                $(shipper.travel[target].input.address)     .val(address);
            };

        reverseGC(marker.getPosition(), setResolved);

        google.maps.event.addListener(marker, 'dragend', function (_) {
            reverseGC(marker.getPosition(), setResolved);
        });
    }
}

function reverseGC(location, callback) {
    shipper.services.gc.geocode({ latLng: location }, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK)
            callback(results[0].formatted_address, location);
        else
            callback(location, location);
    });
}


