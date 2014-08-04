
//
// Extensions
//

// FIXME

// Arrays

Array.prototype.last = function () {
    return this[this.length - 1];
};

Array.prototype.flatten = function() {
    "use strict";
    var flattened = [];
    flattened.concat.apply(flattened, this);
};


// Objects

//Object.prototype.values = function () {

//};