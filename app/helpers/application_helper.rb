require 'extensions'

module ApplicationHelper

  module ViewHelper

    def push_fields_for(form, association)
      singular  = association.to_s.singularize.sub(/[\[\]]/, '')
      instance  = form.object.class.reflect_on_association(association).klass.new

      form.fields_for(association, instance) do |subform|
        render singular + '_field', form: subform
      end
    end

    def link_to_add_fields(form, anchor, association)
      singular  = association.to_s.singularize.sub(/[\[\]]/, '')
      instance  = form.object.class.reflect_on_association(association).klass.new
      id        = 'new_' + singular
      content   = form.fields_for(association, instance, :child_index => id) do |subform|
        render singular + '_field', form: subform, parent: form, id: "#{singular}-#{id}"
      end

      content = "function() {
                  var nid = new Date().getTime();
                  var re  = new RegExp(\"#{id}\", 'g');

                  return \"#{escape_javascript(content)}\".replace(re, nid);
                }"

      onclick = "add_fields_before(#{anchor}, #{content})"

      button_to_function('Add ' + association.to_s, onclick, class: "btn btn-primary")
    end

  end

  include ViewHelper
  include Extensions

end
