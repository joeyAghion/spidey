module Spidey
  class Railtie < ::Rails::Railtie
    initializer 'spidey.configure_rails_logger' do
      Spidey.logger = ::Rails.logger
    end
  end
end
