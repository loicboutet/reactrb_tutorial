require 'spec_helper'

describe 'chapter 2', :js => true do

  it 'the footer shows the items left' do
    5.times { FactoryGirl.create(:todo) }
    visit "/todos"
    page.should have_content("5 items left")
  end


  it 'the footer singularize item' do
    FactoryGirl.create(:todo)
    visit "/todos"
    page.should have_content("1 item left")
  end

  it 'has links toward the filters' do
    FactoryGirl.create(:todo)
    visit "/todos"
    page.should have_content("All")
    page.should have_content("Completed")
    page.should have_content("Active")
  end

end
