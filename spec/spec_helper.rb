RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  APP_ROOT = File.expand_path('../..', __FILE__)

  require 'rspec/its'
  require 'pry'
  require 'webmock/rspec'
  require 'vcr'

  WebMock.disable_net_connect!(allow_localhost: true)

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/vcr_cassettes' # Cassettes goes here.
    c.ignore_hosts '127.0.0.1', 'localhost'
    c.hook_into :webmock
    c.configure_rspec_metadata!
  end
end
