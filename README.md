# Getting started with React.rb and Rails

## How this tutorial works.

This tutorial will cover the steps in adding [react.rb](http://reactrb.org) and react components (written in Ruby of course) to a simple rails Todo app.

The tutorial is organized as a series of tagged branches in this repo.  You are currently on the `01-introduction` branch.

In each branch the `README` file will be the next chapter of the tutorial.

At the end of each chapter you can move to the next tagged branch, where the changes described in the previous chapter will be stored.

For example in this chapter we are going to add the `reactive_ruby_generator` gem to the app, and use it to install react.rb, reactive-record and reactive-router.

To see the results of these changes you can view the `02-adding-a-react-component` chapter.

Of course for best results clone this repo to your computer, follow the instructions for each chapter, and make the changes yourself.  Then run the test specs for the chapter:

`bundle exec rspec chapter-xx/ -f d`

Some chapters (like this one) have extra notes at the end of the page with details you may be interested in.

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

If you are following along on your computer run

`bundle exec rspec chapter-1/`

next: [Chapter 2 - Our first React.rb Component](/blob/02-our-first-react.rb-component)

### Chapter 1 Notes:

#### `rails g reactrb:install` options:


`--reactive-router` to install reactive-router  
`--reactive-record` to install reactive-record  
`--opal-jquery` to install opal-jquery in the js application manifest  
`--all` to do all the above

Its recommend to install `--all`.  You can easily remove things later!

#### How it works:

In case you are interested, or perhaps want to customize the install here is what happens:

1. It requires `'components'` and `'react_ujs'` at the start of your `application.js` file.  `components` is your manifest of react.rb components, and `react_ujs` is part of the react-rails prerendering system.  

2. It adds the js code `Opal.load('components')` to the end of the `application.js` file.  This code will initialize all the ruby (opal) code referenced in the `components` manifest.

3. If you are using reactive-record it adds  
`route "mount ReactiveRecord::Engine => "/rr"`  
to your routes file.  This is how reactive record will send and receive active record model updates from the client.  *Note - you can change the mount path from `rr` to whatever you want if necessary*.

4. It adds the `components` directory to `app/views`.  This is the directory that all your components will be stored in.

5. If you are using reactive-record, then it also adds the `public` directory to `app/models`.  Any models in this directory will have reactive-record proxies loaded on the client.

6. It creates the `app/views/components.rb` manifest file.  This file is a set of requires for all your ruby component code.  It ends with a  
`require_tree './components'`   
which in most cases should be sufficient to load all your component code from the `views/components` directory.  If you have specific component load ordering needs (which is rare) you can simply require specific files before the require_tree.  *Note - this manifest is loaded both on the client and in the prerendering engine.  Code that depends on browser specific data and functions can be conditionally loaded in the manifest so it will **not** load during prerendering.*

7. If you are using reactive-record the `components.rb` file will also require `app/models/_react_public_models.rb` which is the manifest file for the public models, and simply contains a `require_tree './public'` directive. If you need to order how the models are loaded you can add explicit requires to this file before the require_tree.

8. It adds the following gems to your `Gemfile`:  
  `gem 'reactive-ruby'`  
  `gem 'react-rails', '~> 1.3.0'`  
  `gem 'opal-rails', '>= 0.8.1' `   
  `gem 'therubyracer', platforms: :ruby`    
  `gem 'react-router-rails', '~>0.13.3' ` (if using reactive-router)  
  `gem 'reactive-router'` (if using reactive router)  
  `gem 'reactive-record'` (if using reactive-record)
