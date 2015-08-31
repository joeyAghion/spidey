$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'spidey'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.raise_errors_for_deprecations!
  config.filter_run :focus
end
