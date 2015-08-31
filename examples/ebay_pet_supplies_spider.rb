class EbayPetSuppliesSpider < Spidey::AbstractSpider
  handle 'http://pet-supplies.shop.ebay.com', :process_home

  def process_home(page, _default_data = {})
    page.search('#AllCats a[role=menuitem]').each do |a|
      handle resolve_url(a.attr('href'), page), :process_category, category: a.text.strip
    end
  end

  def process_category(page, default_data = {})
    page.search('#ResultSetItems table.li td.dtl a').each do |a|
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
