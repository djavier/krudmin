module Krudmin
  module Fields
    class DateTime < Base
      SEARCH_PREDICATES = [:eq, :not_eq, :lt, :lteq, :gt, :gteq]

      def date
        I18n.localize(
          data.in_time_zone(timezone).to_date,
          format: format,
        )
      end

      def datetime
        I18n.localize(
          data.in_time_zone(timezone),
          format: format,
          default: data,
        )
      end

      def to_s
        case value
        when ::DateTime
          datetime
        when ::Date
          date
        else
          datetime
        end
      end

      def format
        options.fetch(:format, :default)
      end

      def timezone
        options.fetch(:timezone, "UTC")
      end

      def render_search(page, h, options)
        form = options.fetch(:form)
        _attribute = attribute

        Arbre::Context.new do
          div(class: "col-sm-6") do
            ul(class: "list-unstyled") do
              li form.hidden_field "#{_attribute}__from_options", value: :gteq
              li form.date_field "#{_attribute}__from", required: false, class: "form-control"
            end
          end

          div(class: "col-sm-6") do
            ul(class: "list-unstyled") do
              li form.hidden_field "#{_attribute}__to_options", value: :gteq
              li form.date_field "#{_attribute}__to", required: false, class: "form-control"
            end
          end
        end
      end
    end
  end
end
