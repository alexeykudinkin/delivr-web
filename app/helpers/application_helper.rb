require 'extensions'

module ApplicationHelper

  module ViewHelper

    def add_link_to_fields(form, association)
      singular  = association.to_s.singularize.sub(/[\[\]]/, '')
      instance  = form.object.class.reflect_on_association(association).klass.new
      content   = form.fields_for(association, instance, :child_index => 'new_' + singular) do |subform|
        render singular + '_field', :form => subform
      end
      link_to_function('Add ' + association.to_s, "add_fields(this, \"#{singular}\", \"#{escape_javascript(content)}\")")
    end

  end

  include ViewHelper

  include Extensions

end
