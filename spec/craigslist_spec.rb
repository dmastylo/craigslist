require 'craigslist'

describe "Craigslist" do
  context "#cites" do
    it "should return an Array of cities" do
      cities = Craigslist.cities
      cities.should be_a Array
      cities.length.should be > 10
    end
  end

  context "#categories" do
    it "should return an Array of categories" do
      categories = Craigslist.categories
      categories.should be_a Array
      categories.length.should be > 10
    end
  end

  context "#city?" do
    it "should return true for cities that exist" do
      Craigslist.city?('seattle').should be true
      Craigslist.city?('new_york').should be true
    end

    it "should return false for a city that does not exist" do
      Craigslist.city?('asfssdf').should be false
    end
  end

  context "#category?" do
    it "should return true for categories that exist" do
      Craigslist.category?('for_sale').should be true
      Craigslist.category?('travel_vac').should be true
    end

    it "should return false for a category that does not exist" do
      Craigslist.category?('assdfaff').should be false
    end
  end

  context "a city method" do
    it "should return its receiver so that method calls can be chained" do
      craigslist = Craigslist
      craigslist.seattle.should be craigslist
    end
  end

  context "a category method" do
    it "should return its receiver so that method calls can be chained" do
      craigslist = Craigslist
      craigslist.for_sale.should be craigslist
    end
  end

  context "#images" do
    it "should return its receiver so that method calls can be chained" do
      craigslist = Craigslist
      craigslist.images.should be craigslist
    end
  end

  context "#last" do
    it "should return the default number of last posts for seattle and
      for_sale" do
      posts = Craigslist.seattle.for_sale.last
      posts.should be_a Array
      posts.length.should eq 20
    end

    it "should return a specific number of last posts for seattle and
      for_sale" do
      max_results = 2
      posts = Craigslist.seattle.for_sale.last(max_results)
      posts.should be_a Array
      posts.length.should eq max_results
    end

    it "should be able to handle a request for over 100 results" do
      max_results = 150
      posts = Craigslist.new_york.bikes.last(max_results)
      posts.should be_a Array
      posts.length.should eq max_results
    end

    it "should have content in each result" do
      max_results = 10
      posts = Craigslist.new_york.bikes.last(max_results)
      posts.each do |post|
        post['text'].should_not be nil
        post['href'].should_not be nil
      end
    end

    it "should have image urls if has_image is true" do
      max_results = 10
      posts = Craigslist.new_york.bikes.images.last(max_results)
      posts.each do |post|
        post['images'].should_not be nil if post['has_image']
      end
    end
  end
end
