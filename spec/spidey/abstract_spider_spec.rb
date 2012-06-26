require 'spec_helper'

describe Spidey::AbstractSpider do
  describe '#crawl' do
    before(:each) do
      @agent = double('agent')
      @page = double('page')
      @agent.stub(get: @page)
      Mechanize.stub(new: @agent)
    end
  
    describe "with handle declaration" do
      class TestSpider < Spidey::AbstractSpider
        handle "http://www.yahoo.com", :process_home
      end
    
      it "invokes handler" do
        @agent.should_receive(:get).with("http://www.yahoo.com").and_return(@page)
        spider = TestSpider.new request_interval: 0
        spider.should_receive(:process_home).with(@page, {})
        spider.crawl
      end
    
      it "records errors" do
        spider = TestSpider.new request_interval: 0
        spider.should_receive(:process_home).and_raise("Whoops - some error")
        spider.crawl
        spider.errors.size.should == 1
        spider.errors.last[:url].should == "http://www.yahoo.com"
        spider.errors.last[:handler].should == :process_home
        spider.errors.last[:error].message.should == "Whoops - some error"
      end
    
      describe "with follow-up URL handlers" do
        class TestSpider < Spidey::AbstractSpider
          def process_home(page, default_data = {})
            handle "http://www.yahoo.com/deep_page.html", :process_deep_page
          end
        end

        it "invokes configured handlers on follow-up URLs" do
          spider = TestSpider.new request_interval: 0
          page2 = double('page')
          @agent.should_receive(:get).with("http://www.yahoo.com/deep_page.html").and_return(page2)
          spider.should_receive(:process_deep_page).with(page2, {})
          spider.crawl
        end
      end
    end
  
    describe "with default_data" do
      class TestSpiderWithData < Spidey::AbstractSpider
        handle "http://www.yahoo.com", :process_home, a: 1, b: 2
      end
    
      it "passes default data through" do
        spider = TestSpiderWithData.new request_interval: 0
        spider.should_receive(:process_home).with(@page, a: 1, b: 2)
        spider.crawl
      end
    end
  end

  describe '#clean' do
    {
      "Untitled, " => "Untitled,",
      " Pahk the Cah" => "Pahk the Cah",
      "	Untitled	1999 " => "Untitled 1999",
      nil => nil
    }.each do |original, cleaned|
      it "replaces '#{original}' with '#{cleaned}'" do
        Spidey::AbstractSpider.new(request_interval: 0).send(:clean, original).should == cleaned
      end
    end
  end
end