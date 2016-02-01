module Components
  module Todos
    class TodoItem < React::Component::Base

      param :todo, type: Todo
      define_state editing: false


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
            input(class: "edit", defaultValue: params.todo.title).form_control().on(:blur) do
              state.editing! false if state.editing
            end.on(:change) do |e|
              params.todo.title = e.target.value
            end.on(:key_down) do |e|
              if e.key_code == 13
                params.todo.save
                state.editing! false
              end
            end
          else
            div(class: "view")do
              input(type: :checkbox, (params.todo.complete ? :cdefaultChecked : :unchecked) => true, :class => "toggle").on(:click) do
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
