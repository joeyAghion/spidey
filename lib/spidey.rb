require "logger"
require "spidey/version"
require "spidey/abstract_spider"

module Spidey
  extend self
  attr_accessor :logger
end

Spidey.logger = Logger.new(STDOUT)
