require 'extensions'

module ApplicationHelper

  module ViewHelper

    def add_link_to_fields(form, anchor, association)
      singular  = association.to_s.singularize.sub(/[\[\]]/, '')
      instance  = form.object.class.reflect_on_association(association).klass.new
      content   = form.fields_for(association, instance, :child_index => 'new_' + singular) do |subform|
        render singular + '_field', :form => subform
      end

      content = "function() {
                  var nid = new Date().getTime();
                  var re  = new RegExp(\"#{"new_" + singular}\", 'g');

                  return \"#{escape_javascript(content)}\".replace(re, nid);
                }"

      onclick = "add_fields_before(#{anchor}, #{content})"

      button_to_function('Add ' + association.to_s, onclick, class: "btn btn-primary")
    end

  end

  include ViewHelper
  include Extensions

end
