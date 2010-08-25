ENV['RAILS_ENV'] = 'test'
require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
require Rails.root.join('test', 'blueprints')
require 'cucumber/rails/world'
require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support

ActionController::Base.allow_rescue = false

require 'webrat/selenium'
require 'selenium_rc' # includes a newer-than-Webrat's Selenium RC jar file.

Webrat.configure do |config|
  config.mode = :selenium
  config.application_environment = Rails.env
end

class Webrat::Selenium::SeleniumRCServer
  # Use a newer Selenium RC server than Webrat bundles.
  def jar_path
    SeleniumRC::Server.new('IRRELEVANT HOSTNAME').jar_path
  end
end

# Monkey-patch so Webrat will use script/server instead of mongrel_rails.
# Some problem with mongrel_rails, at least at version 1.1.5, somehow results
# in the selenium browser not following redirects: so we see page after page of
# "You are being redirected." Perhaps mongrel 1.2.0 will fix this? Perhaps it
# has something to do with hoe gem_plugin interacts with bundler?
require 'webrat/selenium/application_servers/rails'

module Webrat
  module Selenium
    module ApplicationServers
      class Rails < Webrat::Selenium::ApplicationServers::Base
        def pid_file
          prepare_pid_file("#{RAILS_ROOT}/tmp/pids", 'server.pid')
        end

        def start_command
          "script/server --daemon --port=#{Webrat.configuration.application_port} --environment=#{Webrat.configuration.application_environment} > log/selenium.log"
        end

        def stop_command
          "kill -9 #{File.read(pid_file).strip}"
        end
      end
    end
  end
end

# Running features via Selenium involves a number of processes: the initial
# cucumber process (in which Before and After hooks are called), the Selenium
# server, the database, Firefox (with the Selenium plugin), and a mongrel
# running our application.
#
# Note that our Before and After hooks happen in a separate process from the
# mongrel application server, and so any changes they make to the database
# will be isolated from the application server until any transactions they
# occur in are committed. Which we don't want, as we rely on them to clean up
# the database for us. So we force cucumber to disable database transactions.
#
# Another way around this might be to put a special "clean up the database"
# hook in the app that we can trigger during testing. Maybe another would be
# to reconsider what we do in our Background steps?
class Cucumber::Rails::World
  def self.use_transactional_fixtures
    false
  end
end

Before { fake_transactional_fixtures }
After  { fake_transactional_fixtures }

def fake_transactional_fixtures
  [Caregiver, Child, Event, ScheduledVisit].each(&:delete_all)
end

def human_date(day)
  I18n.localize(Chronic.parse(day).to_date, :format => :human, :locale => 'en').strip
end
