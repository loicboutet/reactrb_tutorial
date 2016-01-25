require 'rails_helper'
require 'rspec'
require 'rspec/expectations'
require 'factory_girl_rails'
require 'shoulda/matchers'
require 'database_cleaner'
require 'capybara/rspec'
require 'capybara/rails'
require 'component_helpers'
require 'capybara/poltergeist'

module React
  module IsomorphicHelpers
    def self.load_context(ctx, controller, name = nil)
      @context = Context.new("#{controller.object_id}-#{Time.now.to_i}", ctx, controller, name)
    end
  end
end

module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax
end

# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause this
# file to always be loaded, without a need to explicitly require it in any files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
    expectations.syntax = [:should, :expect]
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end

  config.include FactoryGirl::Syntax::Methods

  config.use_transactional_fixtures = false

  # DatabaseCleaner.strategy = :truncation

  # config.before(:suite) do
  #   begin
  #   DatabaseCleaner.clean
  #   DatabaseCleaner.start
  #   FactoryGirl.lint
  #   ensure
  #     DatabaseCleaner.clean
  #   end
  # end

  # config.after(:suite) do
  #   DatabaseCleaner.clean
  # end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    # Clear session data
    Capybara.reset_sessions!
    # Rollback transaction
    DatabaseCleaner.clean
  end

  config.after(:all, :js => true) do
    #size_window(:default)
  end

  config.after(:each, :js => true) do
    #sleep(3)
  end if ENV['DRIVER'] == 'ff'

  config.include Capybara::DSL

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end

  options = {js_errors: false,
             timeout: 180,
             phantomjs_logger: StringIO.new,
             logger: StringIO.new,
             phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes']}
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, options)
  end

  class Selenium::WebDriver::Firefox::Profile

    def self.firebug_version
      @firebug_version ||= '2.0.13-fx'
    end

    def self.firebug_version=(version)
      @firebug_version = version
    end

    def frame_position
      @frame_position ||= 'bottom'
    end

    def frame_position=(position)
      @frame_position = ["left", "right", "top", "detached"].detect do |side|
        position && position[0].downcase == side[0]
      end || "bottom"
    end

    def enable_firebug(version = nil)
      version ||= Selenium::WebDriver::Firefox::Profile.firebug_version
      add_extension(File.expand_path("../bin/firebug-#{version}.xpi", __FILE__))

      # For some reason, Firebug seems to trigger the Firefox plugin check
      # (navigating to https://www.mozilla.org/en-US/plugincheck/ at startup).
      # This prevents it. See http://code.google.com/p/selenium/issues/detail?id=4619.
      self["extensions.blocklist.enabled"] = false

      # Prevent "Welcome!" tab
      self["extensions.firebug.showFirstRunPage"] = false

      # Enable for all sites.
      self["extensions.firebug.allPagesActivation"] = "on"

      # Enable all features.
      ['console', 'net', 'script'].each do |feature|
        self["extensions.firebug.#{feature}.enableSites"] = true
      end

      # Closed by default, will open detached.
      self["extensions.firebug.framePosition"] = frame_position
      self["extensions.firebug.previousPlacement"] = 3

      # Disable native "Inspect Element" menu item.
      self["devtools.inspector.enabled"] = false
      self["extensions.firebug.hideDefaultInspector"] = true
    end
  end

  Capybara.register_driver :selenium_with_firebug do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.frame_position = ENV['DRIVER'][2]
    profile.enable_firebug
    Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
  end

  Capybara.javascript_driver = :poltergeist

  Capybara.default_max_wait_time = 20.seconds

  if ENV['DRIVER'] =~ /^ff/
    Capybara.javascript_driver = :selenium_with_firebug
  else
    Capybara.javascript_driver = :poltergeist
  end

  config.include ComponentHelpers

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  # For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end

end

FactoryGirl.define do

  sequence :seq_number do |n|
    " #{n}"
  end

end