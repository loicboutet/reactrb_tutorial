module Components
  module Todos
    class TitleInput < React::Component::Base


      param :todo, type: Todo
      param :on_blur, type: Proc
      param :on_enter, type: Proc

      # param :my_param
      # param param_with_default: "default value"
      # param :param_with_default2, default: "default value" # alternative syntax
      # param :param_with_type, type: Hash
      # param :array_of_hashes, type: [Hash]
      # collect_all_other_params_as :attributes  #collects all other params into a hash

      # The following are the most common lifecycle call backs,
      # the following are the most common lifecycle call backs# delete any that you are not using.
      # call backs may also reference an instance method i.e. before_mount :my_method

      before_mount do
        # any initialization particularly of state variables goes here.
        # this will execute on server (prerendering) and client.
      end

      after_mount do
        # any client only post rendering initialization goes here.
        # i.e. start timers, HTTP requests, and low level jquery operations etc.
      end

      before_update do
        # called whenever a component will be re-rerendered
      end

      before_unmount do
        # cleanup any thing (i.e. timers) before component is destroyed
      end

      def render
        input(class: "edit", defaultValue: params.todo.title).on(:blur) do
          params.on_blur
        end.on(:change) do |e|
          params.todo.title = e.target.value
        end.on(:key_down) do |e|
          if e.key_code == 13
            params.todo.save
            params.on_enter
          end
        end
      end
    end
  end
end
