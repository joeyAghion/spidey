Spidey
======

[![Build Status](https://travis-ci.org/joeyAghion/spidey.svg?branch=master)](https://travis-ci.org/joeyAghion/spidey)
[![Gem Version](https://badge.fury.io/rb/spidey.svg)](http://badge.fury.io/rb/spidey)

Spidey provides a bare-bones framework for crawling and scraping web sites. Its goal is to keep boilerplate scraping logic out of your code.


Example
-------

This example _spider_ crawls an eBay page, follows links to category pages, continues to auction detail pages, and finally records a few scraped item details as a _result_.

```ruby
class EbayPetSuppliesSpider < Spidey::AbstractSpider
  handle "http://pet-supplies.shop.ebay.com", :process_home

  def process_home(page, default_data = {})
    page.search("#AllCats a[role=menuitem]").each do |a|
      handle resolve_url(a.attr('href'), page), :process_category, category: a.text.strip
    end
  end

  def process_category(page, default_data = {})
    page.search("#ResultSetItems table.li td.dtl a").each do |a|
      handle resolve_url(a.attr('href'), page), :process_auction, default_data.merge(title: a.text.strip)
    end
  end

  def process_auction(page, default_data = {})
    image_el = page.search('div.vi-ipic1 img').first
    price_el = page.search('span[itemprop=price]').first
    record default_data.merge(
      image_url: (image_el.attr('src') if image_el),
      price: price_el.text.strip
    )
  end

end

spider = EbayPetSuppliesSpider.new verbose: true
spider.crawl max_urls: 100

spider.results  # => [{category: "Aquarium & Fish", title: "5 Gal. Fish Tank"...
```

Implement a _spider_ class extending `Spidey::AbstractSpider` for each target site. The class can declare starting URLs by calling `handle` at the class level. Spidey invokes each of the methods specified in those calls, passing in the resulting `page` (a [Mechanize](http://mechanize.rubyforge.org/) [Page](http://mechanize.rubyforge.org/Mechanize/Page.html) object) and, optionally, some scraped data. The methods can do whatever processing of the page is necessary, calling `handle` with additional URLs to crawl and/or `record` with scraped results.


Storage Strategies
------------------

By default, the lists of URLs being crawled, results scraped, and errors encountered are stored as simple arrays in the spider (i.e., in memory):

```ruby
spider.urls     # => ["http://www.ebay.com", "http://www.ebay.com/...", ...]
spider.results  # => [{auction_title: "...", sale_price: "..."}, ...]
spider.errors   # => [{url: "...", handler: :process_home, error: FooException}, ...]
```

Add the [spidey-mongo](https://github.com/joeyAghion/spidey-mongo) gem and include `Spidey::Strategies::Mongo` in your spider to instead use MongoDB to persist these data. [See the docs](https://github.com/joeyAghion/spidey-mongo) for more information. Or, you can implement your own strategy by overriding the appropriate methods from `AbstractSpider`.


Logging
-------

You may set `Spidey.logger` to a logger of your choosing. When used in a Rails environment, the logger defaults to the Rails logger. Otherwise, it's directed to STDOUT.


Contributing
------------

Spidey is very much a work in progress. See [CONTRIBUTING](CONTRIBUTING.md) for details.

To Do
-----

* Spidey works well for crawling public web pages, but since little effort is undertaken to preserve the crawler's state across requests, it works less well when particular cookies or sequences of form submissions are required. [Mechanize](http://mechanize.rubyforge.org/) supports this quite well, though, so Spidey could grow in that direction.

Copyright
---------

Copyright (c) 2012-2015 [Joey Aghion](http://halfamind.aghion.com), [Artsy Inc](http://artsy.net). See [LICENSE.txt](LICENSE.txt) for further details.
