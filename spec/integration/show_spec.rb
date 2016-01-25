require 'spec_helper'

describe 'the todo app', :js => true do

    it 'shows the active todos' do
      5.times { FactoryGirl.create(:todo) }
      visit "/todos/active"
      Todo.active do |todo|
        page.should have_content(todo.title)
      end
    end

end
