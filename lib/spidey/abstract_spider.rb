# encoding: utf-8
require 'mechanize'

module Spidey
  class AbstractSpider
    attr_accessor :urls, :handlers, :results, :request_interval, :errors

    DEFAULT_REQUEST_INTERVAL = 3 # seconds

    def self.handle(url, handler, default_data = {})
      start_urls << url
      handlers[url] = [handler, default_data]
    end

    # Accepts:
    #   request_interval: number of seconds to wait between requests (default: 3)
    def initialize(attrs = {})
      @urls = []
      @handlers = {}
      @results = []
      self.class.start_urls.each { |url| handle url, *self.class.handlers[url] }
      @request_interval = attrs[:request_interval] || DEFAULT_REQUEST_INTERVAL
    end

    # Iterates through URLs queued for handling, including any that are added in the course of crawling. Accepts:
    #   max_urls: maximum number of URLs to crawl before returning (optional)
    def crawl(options = {})
      @errors = []
      i = 0
      each_url do |url, handler, default_data|
        break if options[:max_urls] && i >= options[:max_urls]
        begin
          page = agent.get(url)
          Spidey.logger.info "Handling #{url.inspect}"
          send handler, page, default_data
        rescue => ex
          add_error url: url, handler: handler, error: ex
        end
        sleep request_interval if request_interval > 0
        i += 1
      end
    end

    protected

    # Override this for custom queueing of crawled URLs.
    def handle(url, handler, default_data = {})
      unless @handlers[url]
        @urls << url
        @handlers[url] = [handler, default_data]
      end
    end

    # Override this for custom storage or prioritization of crawled URLs.
    # Iterates through URL queue, yielding the URL, handler, and default data.
    def each_url(&_block)
      index = 0
      while index < urls.count # urls grows dynamically, don't use &:each
        url = urls[index]
        yield url, handlers[url].first, handlers[url].last
        index += 1
      end
    end

    # Override this for custom result storage.
    def record(data)
      results << data
      Spidey.logger.info "Recording #{data.inspect}"
    end

    # Override this for custom error-handling.
    def add_error(attrs)
      @errors << attrs
      Spidey.logger.error "Error on #{attrs[:url]}. #{attrs[:error].class}: #{attrs[:error].message}"
    end

    def resolve_url(href, page)
      agent.agent.resolve(href, page).to_s
    end

    # Strips ASCII/Unicode whitespace from ends and substitutes ASCII for Unicode internal spaces.
    def clean(str)
      return nil unless str
      str.gsub(/\p{Space}/, ' ').strip.squeeze(' ')
    end

    private

    def agent
      @agent ||= Mechanize.new
    end

    def self.start_urls
      @start_urls ||= []
    end

    def self.handlers
      @handlers ||= {}
    end
  end
end
