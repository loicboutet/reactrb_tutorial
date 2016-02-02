# Getting started with React.rb and Rails

## Chapter 3 - A Component linked to a Model

So in chapter 2 we have seen how to display a basic component. Now we will make a component to update our Todo model.
See the list of todos? Noticed how annoying it is to have to go to another page in order to edit them? Time to improve
our UI. Let's do an in-place editing of those todos.

First we have to create our component file. Like last time we can do :
* `bundle exec rails g reactrb:component Todos::TodoItem`

Which will create a file app/views/components/todos/todo_item.rb
An interesting thing to consider here, is the name we gave the component. We did not call it "Todo". Why? Because components
are *classes*. Which means that the class of our component would be called "Todo"... Which is the class name of the *model* Todo.

Now this component will be in charged to display a todo from the list. So we want to convert the code currently displaying the todo in the index to a react.rb code like we did in chapter 2. To be able to display the todo, we have to be able to pass it to the component, so let's define inside our new todo_item.rb file :

```
  param :todo, type: Todo
```

And now we want the component to be able to display the todo, just like the previous chapter we will transform the code from views/todos/index.html to some react.rb code inside the render method. So this code :

```
  <li class="<%= "completed" if todo.complete? %>">
    <div class="view">
      <%= link_to edit_todo_url(todo) do %>
        <input class="toggle" type="checkbox" <%= "checked" if todo.complete? %> onclick="return  true">
        <label><%= todo.title %></label>
      <% end %>
      <%= link_to '', todo, class: :destroy, method: :delete, data: { confirm: 'Are you sure?' } %>
    </div>
  </li>
```

Become :

```
li(class: "#{params.todo.complete ? "completed" : ""}") do
  div(class: "view")do
    input(type: :checkbox, (params.todo.complete ? :defaultChecked : :unchecked) => true, :class => "toggle")
    label do
      params.todo.title
    end
    a(class: :destroy)
  end
end
```

And call it in app/views/index.html like so :

```
<% @todos.each do |todo| %>
  <%= react_component "TodoItem", todo: todo %>
<% end %>
```

So this code will display a todo, but it's not doing much for the moment... We even removed the `link_to edit_todo_url(todo)` since we want to do some inline editing and the data for the destroy link. So it's time to wire this new UI to work as expected. We will do that by adding some handlers on our HTML elements and calling some reactive-record call.

Let's start with the checkbox. We want it to actually change the complete value of the todo ! With react.rb it's super simple. Let's add an event handler :

```
input(type: :checkbox, (params.todo.complete ? :defaultChecked : :unchecked) => true, :class => "toggle").on(:click) do
  params.todo.complete = !params.todo.complete
  params.todo.save
end
```

See how easy that is ?! At the end of the input, we call .on(:event) and write the code we want to execute for this event.
Then we can easily change the value of our todo, and then call .save on it. This save method is executed by reactive-record. Do
you remember in chapter_1 when we moved the Todo model to the public directory? That is the reactive-record magic. All the models
in models/public are both available on the server and in our components. So now you don't have to worry about ajax calls or promises, reactive-record take care of all that for you.

OK, now let's do the same for the destroy link :

```
a(class: :destroy).on(:click) do
  params.todo.destroy
end
```

I'm sure you're getting the hang of it !

Time to get serious. We said we want to do some inline editing. When we double click the title label we want to have an input showing at its place so we can fiddle with the title. And then when we press enter, the new title should be saved.

OK first we have to be able to know when we are editing the title, and when we are not. To do that we will use a "state". In react a state is like an instance variable that notifies react when it changes. Anytime a state changes, react knows it needs to re-render the component.
So we will add an editing state, which will be false by default :

```
  define_state editing: false
```

Now that we have our state, we will add an editing class to the li when editing is true and when it is true we will display an input, otherwise we will display our old display code :

```
li(class: "#{params.todo.complete ? "completed" : ""} #{state.editing ? "editing" : ""}") do
  if state.editing
    input(class: "edit", defaultValue: params.todo.title)
  else
    div(class: "view")do
      input(type: :checkbox, (params.todo.complete ? :cdefaultChecked : :unchecked) => true, :class => "toggle").on(:click) do
        params.todo.complete = !params.todo.complete
        params.todo.save
      end
      label do
        params.todo.title
      end
      a(class: :destroy).on(:click) do
        params.todo.destroy
      end
    end
  end
end
```

OK, the ground work is ready. Now to activate the editing state, what will we do ?
Yeah you're right we are going to add an event listener to the label :

```
label do
  params.todo.title
end.on(:doubleClick) do
  state.editing! true
end
```

So now, when we double click the label, we enter the on(:doubleClick) block, which will change our state. Since we are changing the state, react will re-render the component, and this time when rendering the "editing" class will be added to our li, which will make our input shows !

But wait, what do you say? When we double click a label our element is not focused which is kind of annoying?
Hmm ... right. We should really take care of that. So the solution would be to put the focus on our label. And we probably want to do that right after the rendering. OK there is actually a callback that we can call : `after_update`. So let's do inside our component :

```
after_update do
  if state.editing
    edit_element = Element[".edit"]
    edit_element.focus
  end
end
```

First we select our input. Actually Element[".edit"] is the syntax for the opal-jquery wrapper, so it's the opal equivalent to `$(".edit")` in javacript. And then we call focus on it.

So now our element is focused when it appears... but the cursor is at the beginning of the input, not the end !
OK, so now in JS we would do `#{edit_element}[0].setSelectionRange(edit_element.val().length, edit_element.val().length)` so in opal we would like to do something like `edit_element[0].set_selection_range(edit_element.length(), edit_element.length())`. However it seems that the opal-jquery wraper does not support the `edit_element[0]` syntax. So it is the perfect opportunity to show you how to access any javascript from our opal code.
In opal any code inside `\` \`` is executed as javascript. So here we can do :

```
after_update do
  if state.editing
    edit_element = Element[".edit"]
    edit_element.focus
    `#{edit_element}[0].setSelectionRange(edit_element.val().length, edit_element.val().length)`
  end
end
```


OK, pretty good job so far.
Now they are some behaviour we want to attach to our newly shown input. Let's first make it hide when you click elsewhere :

```
input(class: "edit", value: params.todo.title).on(:blur) do
  state.editing! false if state.editing
end
```

Easy peasy !
Now let's make it actually save the new title when you press enter. We will actually do that in 2 steps. First we will save the new value inside our `params.todo` like so :

```
input(class: "edit", value: params.todo.title).on(:blur) do
  state.editing! false if state.editing
end.on(:change) do |e|
  params.todo.title = e.target.value
end
```

And now the actual save :

```
input(class: "edit", value: params.todo.title).on(:blur) do
  state.editing! false if state.editing
end.on(:change) do |e|
  params.todo.title = e.target.value
end.on(:key_down) do |e|
  if e.key_code == 13  # the 13 key_code is the return key
    params.todo.save
    state.editing! false
  end
end
```

And that's it, it actually allow us to do some easy inline editing ! and our final component look like :

```
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
            input(class: "edit", value: params.todo.title).on(:blur) do
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

```

#### How it works:

TODO