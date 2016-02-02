# Getting started with React.rb and Rails


## Chapter 2 - Our first React.rb Component

Now that we have installed React.rb and that everything is running, it's time to make our first component !

In order to do that, we will use the generator :

* run `bundle exec rails g reactrb:component todos::footer`

A file "footer.rb" will be created in app/views/components/todos/
As you can see our component is a normal ruby class. You will notice that our class has a render method. It this method
that is called when the component is displayed (or rendered). We will now put the code of our footer inside this component
to see how a component is displayed.

So we want our component to render the following code from app/views/todos/index.html.erb :
```
  <footer class="footer" style="display: block;">
    <span class="todo-count"><%= pluralize(@uncomplete_todo.count, 'item')%> left</span>
    <ul class="filters">
      <li>
        <a href="/todos" class=<%= "selected" if @scope == "all" %>>All</a>
      </li>
      <li>
        <a href="/todos?scope=active" class=<%= "selected" if @scope == "active" %>>Active</a>
      </li>
      <li>
        <a href="/todos?scope=complete" class=<%= "selected" if @scope == "complete" %>>Completed</a>
      </li>
    </ul>
    <button class="clear-completed" style="display: none;"></button>
  </footer>
```

In a React.rb component, much like you can write html inside the javascript with jsx, there is a very simple dsl to write html
inside the ruby code. Our previous html becomes :

```ruby
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
```

A few things to notice here :
1. First, we changed the `<%= pluralize(@uncomplete_todo.count, 'item')%>` which became `"#{params.uncomplete_todo.count} #{params.uncomplete_todo.count > 1 ? "items" : "item"} left"`. Why? We have to remember that this React.rb component will be executed both by the server when prerendering AND by the client's browser after being compiled by Opal. the `pluralize`method is a rails helper, and Opal does not provide at the moment an implementation of the rails helper. So we cannot use it.
2. we use `params.uncomplete_todo` and `params.scope` instead of @uncomplete_todo and @scope. Why? Same as above, we are executing this code on the browser. @uncomplete_todo and @scope are instance variable of the controller, so we do not have access to them when the code will be executed on the client. In order to solve the problem we have to put at the top of our app/views/components/todos/footer.rb file :

```
  param :scope
  param :uncomplete_todo
```

This way we can set those params when invoking the component. Params are very important for React. When you change a param of a component, React automatically re-render the component. We will see after that this is very useful !

So our final app/views/components/todos/footer.rb file should be :

```ruby
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
```

So now our component is ready ! We just need to call it inside app/views/todos/index.html.erb :

```
<section class="todoapp">
  <header class="header">
    <h1>todos</h1>
    <h2 class="new_todo"><%= link_to 'New Todo', new_todo_path %></h2>
    <!-- <input class="new-todo" placeholder="What needs to be done?" autofocus=""> -->
  </header>
  <section class="main" style="display: block;">
    <!-- <input class="toggle-all" type="checkbox"> -->
    <label for="toggle-all">Mark all as complete</label>
    <ul class="todo-list">
      <% @todos.each do |todo| %>
        <li class="<%= "completed" if todo.complete? %>">
          <div class="view">
            <%= link_to edit_todo_url(todo) do %>
              <input class="toggle" type="checkbox" <%= "checked" if todo.complete? %> onclick="return  true">
              <label><%= todo.title %></label>
            <% end %>
            <%= link_to '', todo, class: :destroy, method: :delete, data: { confirm: 'Are you sure?' } %>
          </div>
        </li>
      <% end %>
    </ul>
  </section>
  <%= react_component "Footer", scope: @scope, uncomplete_todo: @uncomplete_todo %>
</section>
```

You can reload the page and everything... should be the same :) We have just made our first component which is display some HTML according to some params. If you want to check that it is in fact React.rb displaying our footer you can open web tools and check the console. You should see something similar to :
```
************************ React Browser Context Initialized ****************************
isomorphic_helpers.rb:37Reactive record prerendered data being loaded: [Object]
```

Which is a sure sign that React.rb did some work ! Congratulation !


#### How it works:

TODO