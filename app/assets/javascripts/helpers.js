
function Coordinates(c) {
    this.stringized = c.toString();
}

Coordinates.prototype.matcher = new RegExp("\\(([\\d]+\\.[\\d]+),\\s*([\\d]+\\.[\\d]+)\\)");

Coordinates.prototype.toLatLng = function () {

    var s = this.stringized;
    var r = this.matcher.exec(s);

    if (r[0] != s || r.length != 3)
        throw "Failed to decouple given coordinates: " + s;

    return new google.maps.LatLng(r[1], r[2]);
};

