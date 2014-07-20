
//
// Binding
//

function bind(context, method) {
    return function() {
        return context[method].apply(context, arguments);
    }
}


//
// Extensions
//

Array.prototype.last = function() {
    return this[this.length - 1];
}