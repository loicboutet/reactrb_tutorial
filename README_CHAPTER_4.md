# Getting started with React.rb and Rails

## Chapter 4 - Re-using component

So now that we are more familiar with components, one of main advantage of using components is to re-use them. We will see that here by extracting the editing input from chapter_3 into a separate component, and then re-use it at the top of our app to create new todos directly from our main page.

OK, let's go ahead and use the generator to create a new component :

```
rails g reactrb:component todos::title_input
```

Now that this is out of the way, let's look at our input code from last chapter :

```
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

```

Ok, what we can notice here is that the code seem to pretty tied to the TodoItem component, we have `params.todo.title` which would not work outside the todo component, we actually even change the state of the todo component inside the event blur and key_down handlers.
But do not panic, all of this is very manageable. All the references to params.todo are pretty easy to port. Actually let's handle them right now by adding :

```
param :todo, type: Todo
```

Inside our TitleInput component. This way the component will know on which todo it needs to handle the title edit.

Now the handlers are more tricky because firstly has we have seen they change the state of the todo component, and secondly because we now want to re-use the component at the top of our app, in a place where there will be no state to change on blur and key_down. The best way to solve that and a very common practice is to pass a proc as param. Let's add these new params :

```
param :on_blur, type: Proc
param :on_enter, type: Proc
```

And now let's put our input code inside the render function, and calling the right procs :

```
def render
  input(class: "edit", value: params.todo.title).on(:blur) do
    params.on_blur
  end.on(:change) do |e|
    params.todo.title = e.target.value
  end.on(:key_down) do |e|
    if e.key_code == 13

      params.on_enter
    end
  end
end
```

And now, let's call this new component from the inside of the TodoItem component :

```
TitleInput todo: params.todo, on_blur: -> {handle_blur}, on_enter: -> {handle_enter}
```

Here we are using the lambda litteral to pass some proc as params. You'll notice we called to method, handle_blur and handle_enter that we have to define in our TodoItem component :

```
def handle_blur
  state.editing! false if state.editing
end

def handle_enter
  state.editing! false
end
```

Now if we test things out, we can see that everything is working as expected with our new component.
So now let's re-use it at he bottom of our page ! In app/views/todos/index.html :


```
<h1>todos</h1>
<%= react_component "TitleInput", todo: Todo.new %>
```




#### How it works:

TODO