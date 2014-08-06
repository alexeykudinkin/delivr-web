
var delivr = {

    //
    // DOM
    //

    dom: {
        add_fields_before: function (anchor, content) {
            if ($.isFunction(content))
                $(anchor).before(content.apply());
            else
                $(anchor).before(content);
        }
    },

    util: {

        //
        // Binding
        //

        bind: function (context, method) {
            return function () {
                return context[method].apply(context, arguments);
            }
        },

        // Other

        values: function (o) {
            var vals = [];
            Object.keys(o).forEach(function (key, index, array) {
                vals.push(o[key]);
            });
            return vals;
        },


        //
        // Unit systems
        //

        us: {

            toKilo: function (meters, prec) {
                "use strict";
                return (meters / 1000).toFixed(prec);
            },

            toMinutes: function (seconds, prec) {
                "use strict";
                return (seconds / 60).toFixed(prec);
            }

        }

    }

};
