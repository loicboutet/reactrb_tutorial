module ComponentHelpers

  def build_test_url_for(controller)

    unless controller
      Object.const_set("ReactTestController", Class.new(ActionController::Base)) unless defined?(::ReactTestController)
      controller = ::ReactTestController
    end

    route_root = controller.name.gsub(/Controller$/,"").underscore

    unless controller.method_defined? :test
      controller.class_eval do
        define_method(:test) do
          route_root = self.class.name.gsub(/Controller$/,"").underscore
          test_params = Rails.cache.read("/#{route_root}/#{params[:id]}")
          @component_name = test_params[0]
          @component_params = test_params[1]
          render_params = test_params[2]
          render_on = render_params.delete(:render_on) || :both
          mock_time = render_params.delete(:mock_time)
          style_sheet = render_params.delete(:style_sheet)
          javascript = render_params.delete(:javascript)
          page = "<%= react_component @component_name, @component_params, { prerender: #{render_on != :client_only} } %>"
          if (render_on != :server_only && !render_params[:layout]) || javascript
            page = "<%= javascript_include_tag '#{javascript || 'application'}' %>\n"+page
          end
          if mock_time || (defined?(Timecop) && Timecop.top_stack_item)
            unix_millis = ((mock_time || Time.now).to_f * 1000.0).to_i
            page = "<%= javascript_include_tag 'spec/libs/lolex' %>\n"+
            "<script type='text/javascript'>\n"+
            "  window.original_setInterval = setInterval;\n"+
            "  window.lolex_clock = lolex.install(#{unix_millis});\n"+
            "  window.original_setInterval(function() {window.lolex_clock.tick(10)}, 10);\n"+
            "</script>\n"+page
            # page = "<%= javascript_include_tag 'spec/libs/time_shift' %>\n"+
            # "<script type='text/javascript'>\n"+
            # "Date = TimeShift.Date\n"+
            # "TimeShift.setTime(#{unix_millis});\n"+
            # "</script>\n"+page
          end
          if !render_params[:layout] || style_sheet
            page = "<%= stylesheet_link_tag '#{style_sheet || 'application'}' %>\n"+page
          end
          render_params[:inline] = page
          render render_params
        end
      end

      begin
        routes = Catprint::Application.routes
        routes.disable_clear_and_finalize = true
        routes.clear!
        routes.draw do
          get "/#{route_root}/:id", to: "#{route_root}#test"
        end
        Catprint::Application.routes_reloader.paths.each{ |path| load(path) }
        routes.finalize!
        ActiveSupport.on_load(:action_controller) { routes.finalize! }
      ensure
        routes.disable_clear_and_finalize = false
      end
    end

    "/#{route_root}/#{@test_id = (@test_id || 0) + 1}"

  end

  def mount(component_name, params=nil, opts = {})
    unless params
      params = opts
      opts = {}
    end
    test_url = build_test_url_for(opts.delete(:controller))
    Rails.cache.write(test_url, [component_name, params, opts])
    visit test_url
  end

  def size_window(width=nil, height=nil)
    width, height = width if width.is_a? Array
    portrait = true if height == :portrait
    case width
    when :small
      width, height = [480, 320]
    when :mobile
      width, height = [640, 480]
    when :tablet
      width, height = [960, 640]
    when :default, nil
      width, height = [1024, 768]
    end
    if portrait
      width, height = [height, width]
    end
    if page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.window.resize_to(width, height)
    elsif page.driver.respond_to?(:resize)
      page.driver.resize(width, height)
    end
  end

end
