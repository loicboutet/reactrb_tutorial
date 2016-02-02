module Components
  module Todos
    class Index < React::Component::Base

      export_state :filter

      before_mount do
        Index.filter! :active
      end

      def render
        section.todoapp do
          header.header do
            h1 { "todos" }
            TopBar()
          end
          section.main(style: {display: :block}) do
            #label(for: "toggle-all") { "Mark all as complete" }
            ul.todo_list do
              Todo.send(Index.filter).each do |todo|
                TodoItem todo: todo
              end
            end
          end
          puts "rendering this baby... #{Index.filter}"
          Footer(scope: Index.filter, uncomplete_todo: Todo.active)
        end
      end
    end
  end
end
