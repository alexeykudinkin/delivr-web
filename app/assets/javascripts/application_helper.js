
function add_fields_before(anchor, content) {
    if ($.isFunction(content))
        $(anchor).before(content.apply());
    else
        $(anchor).before(content);
}