require 'spec_helper'

describe 'chapter 3', :js => true do

  it 'should update the complete attribute when clicking on the checkbox' do
    FactoryGirl.create(:todo)
    visit "/todos"

    page.should have_content(Todo.first.title)
    find("[type=checkbox]").click
    find("li.completed")
    Todo.first.complete.should be_equal(true)
  end


  it 'should be able to inline edit the title of a todo' do
    FactoryGirl.create(:todo)
    visit "/todos"

    page.should have_content(Todo.first.title)
    find("label").double_click
    input = find(".edit")
    input.set("new capybara title")
    input.native.send_keys(:return)

    page.should have_content("new capybara title")
    Todo.first.title.should eq("new capybara title")
  end

  it "should destroy the todo if you click on the destroy link" do
    FactoryGirl.create(:todo)
    visit "/todos"
    first_title = Todo.first.title
    page.should have_content(first_title)
    find(".destroy").click

    Todo.first.should be_nil
    page.should_not have_content(first_title)
  end
end
