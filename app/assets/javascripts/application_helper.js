
function add_fields(self, association, content) {
    var nid = new Date().getTime();
    var re  = new RegExp("new_" + association, 'g');
    $(self).before(content.replace(re, nid));
}