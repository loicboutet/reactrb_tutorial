module Components
  module Todos
    class TodoItem < React::Component::Base

      required_param :todo, type: Todo

      def test
      end

      def render
        li(class: (params.todo.complete ? "completed" : "")) do
          div(class: "view")do
            input(type: :checkbox, (params.todo.complete ? :defaultChecked : :unchecked) => true, :class => "toggle").on(:change) do
              # params.todo.complete = !params.todo.complete
              # puts params.todo.complete
              # puts params.todo.save
              t = Todo.find(params.todo.id)
              t.complete = !t.complete
              t.save
            end
            label do
              params.todo.title
            end
          end
        end
      end
    end
  end
end
