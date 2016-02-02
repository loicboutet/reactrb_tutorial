module Components
  module Todos
    class TitleEdit < React::Component::Base


      param :todo, type: Todo
      param :on_blur, type: Proc
      param :on_enter, type: Proc
      param css_class: :edit

      def render
        input(class: params.css_class, placeholder: "what is left todo?", value: params.todo.title).on(:blur) do
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
