
//
// Binding
//

function bind(context, method) {
    return function() {
        return context[method].apply(context, arguments);
    }
}
