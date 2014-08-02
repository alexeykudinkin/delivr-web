require 'extensions'

module ApplicationHelper

  module Extensions

    # Nothing to see here (till)

  end

  module ViewHelper

    def push_fields_for(form, association, ngmodel_prefix = nil)
      singular  = association.to_s.singularize.sub(/[\[\]]/, '')
      instance  = form.object.class.reflect_on_association(association).klass.new

      form.fields_for(association, instance) do |subform|
        render singular + '_field',
               form: subform,
               ngmodel_prefix: "#{ngmodel_prefix}.#{association}_attributes"
      end
    end

    def push_onclick_button_to(name, html_options)
      # FIXME:  I know this is lame
      #         however damned f*cking Ruby doesn't allow me
      #         to combine this into single fold (damn it!)
      options =
        html_options.to_a
          .map do |kv|
            "#{kv.first}=\"#{ERB::Util.html_escape(kv.second)}\""
          end
          .reduce("") do |s, p|
            "#{s} #{p}"
          end

      button = <<-RUBY_EVAL
        <button type="button" #{options}>
          #{name}
        </button>
      RUBY_EVAL

      button.html_safe
    end

    #
    # This is a collection of helpers making things plain (old) 'jquery-way'
    #
    module JQuery

      def link_to_add_fields(form, anchor, association, ngmodel_prefix = nil)
        singular  = association.to_s.singularize.sub(/[\[\]]/, '')
        instance  = form.object.class.reflect_on_association(association).klass.new
        id        = 'new_' + singular
        content   = form.fields_for(association, instance, :child_index => id) do |subform|
          render singular + '_field',
                 form: subform,
                 parent: form,
                 id: "#{singular}-#{id}",
                 ngmodel_prefix: "#{ngmodel_prefix}.#{association}_attributes[#{id}]"
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

    #
    # This is a collection of helpers making things the 'angular-way'
    #
    module Angular

      def link_to_add_fields_angular(form, association, ngmodel_prefix = nil)
        singular  = association.to_s.singularize.sub(/[\[\]]/, '')
        instance  = form.object.class.reflect_on_association(association).klass.new

        proc = Proc.new do |options|
          index = options[:index]
          form.fields_for(association, instance, :child_index => index) do |subform| # :child_index is just irrelevant
            render  singular + '_field',
                    form:    subform,
                    parent:  form,

                    ngmodel_prefix:   "#{ngmodel_prefix}.#{association}_attributes[#{index}]"
          end
        end

        yield proc
      end

    end

  end

  include ViewHelper
  include Extensions

  include Angular

end
