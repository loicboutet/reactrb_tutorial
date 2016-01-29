module Components
  module Todos
    class Footer < React::Component::Base

      param :scope
      param :uncomplete_todo

      def render
        footer(class: "footer", style: {display: "block"}) do
          span(class: "todo-count") do
            "#{params.uncomplete_todo.count} #{params.uncomplete_todo.count > 1 ? "items" : "item"} left"
          end
          ul(class: "filters") do
            li { a(class: "#{'selected' if params.scope == "all"}", href: "/todos") { "All" }}
            li { a(class: "#{'selected' if params.scope == "complete"}", href: "/todos?scope=complete") { "Completed" }}
            li { a(class: "#{'selected' if params.scope == "active"}", href: "/todos?scope=active") { "Active" }}
          end
          button(class: "clear-completed", style: {display: "none"}) { "clear completed" }
        end
      end
    end
  end
end
