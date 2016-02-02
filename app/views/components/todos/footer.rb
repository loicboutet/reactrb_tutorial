module Components
  module Todos
    class Footer < React::Component::Base

      param :scope
      param :uncomplete_todo

      def render
        footer(class: "footer", style: {display: "block"}) do
          span(class: "todo-count") do
            "#{params.uncomplete_todo.count} item#{'s' unless params.uncomplete_todo.count == 1} left"
          end
          ul(class: "filters") do
            li { a(class: "#{'selected' if params.scope == "all"}") { "All" }.on(:click) { Index.filter! :all } }
            li { a(class: "#{'selected' if params.scope == "complete"}") { "Completed" }.on(:click) { Index.filter! :complete }}
            li { a(class: "#{'selected' if params.scope == "active"}") { "Active" }.on(:click) { Index.filter! :active }}
          end
          button(class: "clear-completed", style: {display: "none"}) { "clear completed" }
        end
      end
    end
  end
end
