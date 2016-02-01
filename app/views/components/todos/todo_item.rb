module Components
  module Todos
    class TodoItem < React::Component::Base

      param :todo, type: Todo
      define_state editing: false


      def cancel_edit
        state.editing! false
      end

      after_update do
        if state.editing
          edit_element = Element[".edit"]
          edit_element.focus
          `#{edit_element}[0].setSelectionRange(edit_element.val().length, edit_element.val().length)`
        end
      end

      def render
        li(class: "#{params.todo.complete ? "completed" : ""} #{state.editing ? "editing" : ""}") do
          if state.editing
            TitleEdit todo: params.todo, on_blur: -> {cancel_edit}, on_enter: -> {cancel_edit}
          else
            div(class: "view")do
              input(type: :checkbox, (params.todo.complete ? :defaultChecked : :unchecked) => true, :class => "toggle").on(:click) do
                params.todo.complete = !params.todo.complete
                params.todo.save
              end
              label do
                params.todo.title
              end.on(:doubleClick) do
                state.editing! true
              end
              a(class: :destroy).on(:click) do
                params.todo.destroy
              end
            end
          end

        end
      end
    end
  end
end
