require 'spec_helper'

describe 'the todo app', :js => true do

    it 'shows the active todos' do
      5.times { FactoryGirl.create(:todo) }
      2.times { FactoryGirl.create(:todo, complete: true) }
      visit "/todos?scope=active"
      byebug
      Todo.active do |todo|
        page.should have_content(todo.title)
      end
      Todo.complete do |todo|
        page.should_not have_content(todo.title)
      end
    end

end
