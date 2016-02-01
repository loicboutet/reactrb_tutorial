# Getting started with React.rb and Rails

## Chapter 4 - Re-using component

So now that we are more familiar with components, one of main advantage of using components is to re-use them. We will see that here by extracting the editing input from chapter_3 into a separate component, and then re-use it at the top of our app to create new todos directly from our main page.

OK, let's go ahead and use the generator to create a new component :

```
rails g reactrb:component todos::title_edit
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
But do not panic, all of this is very manageable. All the references to params.todo are pretty easy to port. Actually let's handle them right now by adding inside our TitleInput component :

```
param :todo, type: Todo
```

This way the component will know on which todo it needs to handle the title edit.

Now the handlers are more tricky because firstly as we have seen they change the state of the todo component, and secondly because we now want to re-use the component at the top of our app, in a place where there will be no state to change on blur and key_down. The best way to solve that and a very common practice is to pass a proc as param. Let's add these new params :

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
      params.todo.save
    end
  end
end
```

And now, let's call this new component from the inside of the TodoItem component :

```
TitleInput todo: params.todo, on_blur: -> {on_cancel}, on_enter: -> {on_cancel}
```

Here we are using the lambda litteral to pass some proc as params. You'll notice we called the method on_cancel that we have to define in our TodoItem component :

```
def cancel_edit
  state.editing! false if state.editing
end
```

Now if we test things out, we can see that everything is working as expected with our new component.
So now we are almost ready to re-use it. Time do some thinking. We have a TitleEdit component, when we use it inside the TodoItem we pass it 3 things : a todo, 1 proc executed when the user leave the input, and 1 proc executed when the user press enter. So where we will use it at the top of our page, what exactly do we need to pass ?
First we will pass it a new todo instance, this way when on enter the component will execute a todo.save, it will create a new todo. However, when a save is done, we need to re-provide a new todo instance, otherwise our TitleInput will just change the title of the original instance over and over again. Todo that, let's encapsulate the TitleEdit component inside a top bar component.

```
rails g reactrb:component todos::top_bar

```

In this TopBar component we will need a todo state where we will store the new todos :

```
define_state :todo, type: Todo
```

And now we can define the render :

```
def render
  TitleEdit todo: state.todo, on_enter: -> { renew_todo }
end
```

We need to define renew_todo :

```
def renew_todo
  state.todo! Todo.new
end
```

OK, everythng is ready, let's now call the component inside our index.html.erb :

```
<h1>todos</h1>
<%= react_component "TopBar" %>
```

Let's test it... And it fails ! It says :

```
Exception raised while rendering #<TitleEdit:0x2de>
    NoMethodError: undefined method `title' for nil
```

OK, we forgot to initialize the todo state of our new TopBar component. An esay way to do it is to use the callback before_mount, which is called once before the first render (or when the component is mounted if you prefer) :

```
before_mount do
  renew_todo
end
```

OK, now everything works as expected !

Just for fun we can see that our top bar as the same css as when you edit a todo since it has the .edit class. This is not very nice, so let's add a new params to our TitleEdit, which will have the default value 'edit' :

```
param css_class: "edit"
```

And do :

```
input(class: param.css_class, defaultValue: params.todo.title).on(:blur) do
...
end
```

and change our call to TitleEdit accordingly in the TopBar component :

```
TitleEdit todo: state.todo, on_enter: -> { renew_todo }, css_class: "new-todo"
```


Now that we have transformed most of our UI using React components, we'll see how to go full React for our view.



#### How it works:

TODO
