== README

# Getting started with React.rb and Rails

## How this tutorial works.

This tutorial will cover the steps in adding [react.rb](http://reactrb.org) and react components (written in Ruby of course) to a simple rails Todo app.

The tutorial is organized as a series of tagged branches in this repo.  You are currently on the `01-introduction` branch.

In each branch the `README` file will be the next chapter of the tutorial.

At the end of each chapter you can move to the next branch, where the changes described in the previous chapter will be stored.

For example in this chapter we are going to add the `reactive_ruby_generator` gem to the app, and use it to install react.rb, reactive-record and reactive-record.

To see the results of these changes you can view the `02-adding-a-react-component` chapter.

Of course for best results simply clone this repo to computer, follow the instructions for each chapter, and make the changes yourself.

## Chapter 1 - Introduction

To update your new or existing Rails 4 app, you can use the `reactive_rails_generator` gem.

1. add `gem reactive_rails_generator` to the development section of your app Gemfile.
2. run `bundle install`
3. run `bundle exec rails g reactrb:install --all`
4. run `bundle update`

You will now find that you have

* a `components` directory inside of `app/views` where your react components (which are simply react views written in ruby) will live, and

* a `public` directory inside of `app/models` where any models that you want accessible to your components (which will run on the browser) will live.
*Don't worry!  Access to model data is protected by a [Hobo style permissions system](http://hobocentral.net/manual/permissions).*

In our case we are going to make the `Todo` model public by moving it from  `app/models` to `app/models/public/`.

next: [Chapter 2 - Our first React.rb Component](/blob/02-our-first-react.rb-component)
