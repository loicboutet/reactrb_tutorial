module Components
  module Todos
    class TodoItem < React::Component::Base

      param :todo, type: Todo
      define_state editing: false


      after_update do
        edit_element = Element[".edit"]
        edit_element.focus
        `#{edit_element}[0].setSelectionRange(edit_element.val().length, edit_element.val().length)`
      end

      def handle_blur
        state.editing! false if state.editing
      end

      def handle_enter
        state.editing! false
      end

      def render
        li(class: "#{params.todo.complete ? "completed" : ""} #{state.editing ? "editing" : ""}") do
          div(class: "view")do
            input(type: :checkbox, (params.todo.complete ? :defaultChecked : :unchecked) => true, :class => "toggle").on(:click) do
              params.todo.complete = !params.todo.complete
              params.todo.save
            end
            label do
              params.todo.title
            end.on(:doubleClick) do
              puts "in double click"
              state.editing! true
            end
            a(class: :destroy).on(:click) do
              params.todo.destroy
            end

          end
          TitleInput todo: params.todo, on_blur: -> {handle_blur}, on_enter: -> {handle_enter}

        end
      end
    end
  end
end
