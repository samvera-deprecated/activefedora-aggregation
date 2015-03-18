$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_fedora/aggregation'
require 'active_fedora/cleaner'
require 'byebug' unless ENV['CI']
ENV['environment'] = 'test'

RSpec.configure do |config|
  config.before(:each) do
    ActiveFedora::Cleaner.clean! if ActiveFedora::Base.count > 0
  end

end
