var environmentServices = angular.module('environmentServices', []);


environmentServices.factory('Geocoder', [function () {
    function GoogleGeocoderService() {
        this.geocoder = new google.maps.Geocoder();
    }

    GoogleGeocoderService.prototype.resolveByCoordinates = function (latLng, success, failure) {
        this.geocoder.geocode({ latLng: latLng }, function (results, status) {
            var address;

            if (status == google.maps.GeocoderStatus.OK)
                success({ latLng: latLng, address: results[0].formatted_address });
            else if (failure instanceof Function)
                failure(status);
        });
    };

    GoogleGeocoderService.prototype.resolveByAddress = function (address, success, failure) {
        this.geocoder.geocode({ address: address }, function (results, status) {
            var latLng;

            if (status == google.maps.GeocoderStatus.OK)
                success({ latLng: results[0].geometry.location, address: address });
            else if (failure instanceof Function)
                failure(status);
        });
    };

    return new GoogleGeocoderService();
}]);



environmentServices.factory('Direction', [function () {
    function GoogleDirectionsService() {
        this.direction = new google.maps.DirectionsService();
    }

    GoogleDirectionsService.prototype.route = function (request, success, failure) {
        this.direction.route(request, function (result, status) {
            if (status == google.maps.DirectionsStatus.OK)
                success(result);
            else if (failure instanceof Function)
                failure(status);
        });
    };

    return new GoogleDirectionsService();
}]);



environmentServices.factory('Distance', [function () {
    function GoogleDistanceService() {
        this.distance = new google.maps.DistanceMatrixService();
    }

    GoogleDistanceService.prototype.distanceMatrix = function (positions, success, failure) {
        this.distance.getDistanceMatrix({
            origins: positions,
            destinations: positions,
            travelMode: google.maps.TravelMode.DRIVING
        }, function (response, status) {

               function makeDistanceMatrix(response) {
                   var matrix = [];
                   response.rows.forEach(function (row, index, array) {
                       var line = [];
                       row.elements.forEach(function (element, index, array) {
                           line.push(Math.floor(0.5 + element.duration.value / 60));
                       });
                       matrix.push(line);
                   });
                   return matrix;
               }

               if (status == google.maps.DistanceMatrixStatus.OK)
                   success(makeDistanceMatrix(response));
               else
                   failure(status);
        });
    }

    return new GoogleDistanceService();
}]);



environmentServices.factory('Geolocation', [function () {
    return {
        atCurrentPosition: function (success, failure) {
            if (navigator.geolocation)
                navigator.geolocation.getCurrentPosition(success, failure);
            else
                failure({
                    UNKNOWN_ERROR: 0,
                    PERMISSION_DENIED: 1,
                    POSITION_UNAVAILABLE: 2,
                    TIMEOUT: 3,
                    code: 0,
                    message: "Navigator service is unavailable"
                });
        }
    };
}]);
