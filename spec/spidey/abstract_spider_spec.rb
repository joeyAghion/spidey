require 'spec_helper'

describe Spidey::AbstractSpider do
  describe '#crawl' do
    before(:each) do
      @agent = double('agent')
      @page = double('page')
      allow(@agent).to receive_messages(get: @page)
      allow(Mechanize).to receive_messages(new: @agent)
    end

    describe 'with handle declaration' do
      class TestSpider < Spidey::AbstractSpider
        handle 'http://www.yahoo.com', :process_home
      end

      it 'invokes handler' do
        expect(@agent).to receive(:get).with('http://www.yahoo.com').and_return(@page)
        spider = TestSpider.new request_interval: 0
        expect(spider).to receive(:process_home).with(@page, {})
        spider.crawl
      end

      it 'records errors' do
        spider = TestSpider.new request_interval: 0
        expect(spider).to receive(:process_home).and_raise('Whoops - some error')
        spider.crawl
        expect(spider.errors.size).to eq(1)
        expect(spider.errors.last[:url]).to eq('http://www.yahoo.com')
        expect(spider.errors.last[:handler]).to eq(:process_home)
        expect(spider.errors.last[:error].message).to eq('Whoops - some error')
      end

      describe 'with follow-up URL handlers' do
        class TestSpider < Spidey::AbstractSpider
          def process_home(_page, _default_data = {})
            handle 'http://www.yahoo.com/deep_page.html', :process_deep_page
          end
        end

        it 'invokes configured handlers on follow-up URLs' do
          spider = TestSpider.new request_interval: 0
          page2 = double('page')
          expect(@agent).to receive(:get).with('http://www.yahoo.com/deep_page.html').and_return(page2)
          expect(spider).to receive(:process_deep_page).with(page2, {})
          spider.crawl
        end
      end
    end

    describe 'with default_data' do
      class TestSpiderWithData < Spidey::AbstractSpider
        handle 'http://www.yahoo.com', :process_home, a: 1, b: 2
      end

      it 'passes default data through' do
        spider = TestSpiderWithData.new request_interval: 0
        expect(spider).to receive(:process_home).with(@page, a: 1, b: 2)
        spider.crawl
      end
    end
  end

  describe '#clean' do
    {
      'Untitled, ' => 'Untitled,',
      ' Pahk the Cah' => 'Pahk the Cah',
      '	Untitled	1999 ' => 'Untitled 1999',
      nil => nil
    }.each do |original, cleaned|
      it "replaces '#{original}' with '#{cleaned}'" do
        expect(Spidey::AbstractSpider.new(request_interval: 0).send(:clean, original)).to eq(cleaned)
      end
    end
  end
end
