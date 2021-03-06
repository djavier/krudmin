module Krudmin
  class NavigationItems
    include Enumerable

    attr_reader :user
    def initialize(user:, items: nil)
      @user = user
      @items = items
    end

    def each(&block)
      visible_items.each(&block)
    end

    private

    def visible_items
      items.select(&:visible)
    end

    def routes
      Rails.application.routes.url_helpers
    end

    def items
      @items ||= [
        Krudmin::NavigationItems::Node.new(:dashboard, Krudmin::Config.krudmin_root_path, icon: :tachometer)
      ].concat(Krudmin::Config.menu_items.call).compact
    end

    class Node
      include Enumerable

      attr_reader :label, :link, :label_class, :visible, :items, :icon, :module_path

      def initialize(label, link, visible: true, items: [], icon: :file, module_path: nil)
        @label, @visible, @items, @icon, @module_path = label, visible, items, icon, module_path

        @label_class = "menu-node-#{label}".parameterize

        @link = link.is_a?(Symbol) ? routes.send(link) : link
      end

      def each(&block)
        items.select(&:visible).each(&block)
      end

      class << self
        def routes
          Rails.application.routes.url_helpers
        end

        def node_for(label, resource, visible: true, icon: :file, module_path: nil, manage: true, add: true)
          new(label, "#", items: links_for(resource, module_path, manage: manage, add: add), icon: icon, visible: visible, module_path: module_path) if(manage || add)
        end

        def links_for(resource, module_path = '', manage: true, add: true)
          module_path = "#{module_path}_" if module_path.present?

          links = [
            new(I18n.t("krudmin.actions.manage"), routes.send("#{module_path}#{resource.pluralize}_path"), icon: :list, visible: manage),
            new(I18n.t("krudmin.actions.add_new"), routes.send("new_#{module_path}#{resource}_path"), icon: :plus, visible: add),
          ]
        end
      end

      private

      def visible_items
        items.select(&:visible)
      end

      def routes
        Rails.application.routes.url_helpers
      end
    end
  end
end
