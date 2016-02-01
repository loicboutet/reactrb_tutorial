require 'spec_helper'

describe 'chapter 4', :js => true do

  it 'should create a new todo when using the top bar' do
    visit "/todos"

    input = find(".new-todo")
    input.set("new todo")
    input.native.send_keys(:return)

    Todo.first.title.should eq("new todo")
    page.should have_content("new capybara title")
  end

end
