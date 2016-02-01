# Getting started with React.rb and Rails

## Chapter 5 - Integrate everything in a main component

Now that all the actionnable part of our UI are in components, we can actually encapsulate all that in one top level component. Let's create a new component :

```
rails g reactrb:component todos::index
```

Why call it index? Because it will replace the index page of our controller and we'll see in a minute that will make things easier to call it. However you could also call TodoApp or any other name that you would like.

So the goal of our new component is to replace the code inside the views/todos/index.html.erb. If we look at the code we can see that the view use 3 instance variables : @todos, @uncomplete_todos and @scope. So this will be the 3 params we have to add to our component :

```
param :scope
param :uncomplete_todo
param :todos
```

And now, like we did before we convert this :

```
<section class="todoapp">
  <header class="header">
    <h1>todos</h1>
    <%= react_component "TopBar" %>
    <!-- <input class="new-todo" placeholder="What needs to be done?" autofocus=""> -->
  </header>
  <section class="main" style="display: block;">
    <!-- <input class="toggle-all" type="checkbox"> -->
    <label for="toggle-all">Mark all as complete</label>
    <ul class="todo-list">
      <% @todos.each do |todo| %>
        <%= react_component "TodoItem", todo: todo %>
      <% end %>
    </ul>
  </section>
  <%= react_component "Footer", scope: @scope, uncomplete_todo: @uncomplete_todo %>
</section>
```

Into this :

```
section(class: "todoapp") do
  header(class: "header") do
    h1 do
      "todos"
    end
    TopBar()
  end
  section(class: "main", style: {display: "block"}) do
    ul(class: "todo-list") do
      params.todos.each do |todo|
        TodoItem todo: todo
      end
    end
  end
  Footer scope: params.scope, uncomplete_todo: params.uncomplete_todo
end
```

Fairly common stuff for us now. The only trick is to watch out for TopBar, which is a component which does not need any params. So we have to add the () or {}, otherwise it will just be the constant and won't display anything.

The last step is to call the component from the controller. In the inex action of the TodosController :

```
@todos = Todo.all
@scope = "all"
if %w(active complete).include?(params[:scope])
  @todos = @todos.send(params[:scope].to_sym)
  @scope = params[:scope]
end
@uncomplete_todo = Todo.active
render_component todos:@todos, scope:@scope, uncomplete_todo: @uncomplete_todo
```

We just have to call render_component, and pass the params. We do not need to tell it which component to call, because by default it will look for an Index component in the Todos directory. Since we are respecting the same convention than for the rails views we don't have to explicit the component.



#### How it works:

TODO
