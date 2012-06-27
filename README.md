Spidey
======

Spidey provides a bare-bones framework for crawling and scraping web sites.


Example
-------

This [non-working] example _spider_ crawls the ebay.com home page, follows links to auction pages, and finally records a few scraped item details as a _result_.

    class EbaySpider < Spidey::AbstractSpider
      handle "http://www.ebay.com", :process_home
      
      def process_home(page, default_data = {})
        page.links_with(href: /auction\.aspx/).each do |link|
          handle resolve_url(link.href, page), :process_auction, auction_title: link.text
        end
      end
      
      def process_auction(page, default_data = {})
        record default_data.merge(sale_price: page.search('.sale_price').text)
      end
    end
    
    spider = EbaySpider.new verbose: true
    spider.crawl max_urls: 100

Implement a _spider_ class extending `Spidey::AbstractSpider` for each target site. The class can declare starting URLs with class-level calls to `handle`. Spidey invokes each of the methods specified in those calls, passing in the resulting `page` (a [Mechanize](http://mechanize.rubyforge.org/) [Page](http://mechanize.rubyforge.org/Mechanize/Page.html) object) and, optionally, some scraped data. The methods can do whatever processing of the page is necessary, calling `handle` with additional URLs to crawl and/or `record` with scraped results.


Storage Strategies
----------

By default, the lists of URLs being crawled, results scraped, and errors encountered are stored as simple arrays in the spider (i.e., in memory):

    spider.urls     # => ["http://www.ebay.com", "http://www.ebay.com/...", ...]
    spider.results  # => [{auction_title: "...", sale_price: "..."}, ...]
    spider.errors   # => [{url: "...", handler: :process_home, error: FooException}, ...]

Add the [spidey-mongo](https://github.com/joeyAghion/spidey-mongo) gem and include `Spidey::Strategies::Mongo` in your spider to instead use MongoDB to persist these data. [See the docs](https://github.com/joeyAghion/spidey-mongo) for more information.


To Do
-----
* Add working examples
* Spidey works well for crawling public web pages, but since little effort is undertaken to preserve the crawler's state across requests, it works less well when particular cookies or sequences of form submissions are required. [Mechanize](http://mechanize.rubyforge.org/) supports this quite well, though, so Spidey could grow in that direction.


Copyright
---------
Copyright (c) 2012 Joey Aghion, Art.sy Inc. See [LICENSE.txt](LICENSE.txt) for further details.
