module Craigslist
  class Persistent
    attr_accessor :city, :category, :images

    def initialize
      @city = nil
      @category = nil
      @images = false
    end
  end

  class << self
    # Create city methods
    CITIES.each do |key, value|
      define_method(key.to_sym) do
        Craigslist::PERSISTENT.city = value
        self
      end
    end

    # Create category methods
    CATEGORIES.each do |key, value|
      if value['path']
        define_method(key.to_sym) do
          Craigslist::PERSISTENT.category = value['path']
          self
        end
      end

      if value['children']
        value['children'].each do |key, value|
          define_method(key.to_sym) do
            Craigslist::PERSISTENT.category = value
            self
          end
        end
      end
    end

    def cities
      CITIES.keys.sort
    end

    def categories
      categories = CATEGORIES.keys
      CATEGORIES.each do |key, value|
        categories.concat(value['children'].keys) if value['children']
      end
      categories.sort
    end

    def city?(city)
      CITIES.keys.include?(city)
    end

    def category?(category)
      return true if CATEGORIES.keys.include?(category)

      CATEGORIES.each do |key, value|
        if value['children'] && value['children'].keys.include?(category)
          return true
        end
      end

      return false
    end

    def images
      Craigslist::PERSISTENT.images = true
      self
    end

    def last(max_results=20)
      raise StandardError, "city and category must be part of the method chain" unless
        Craigslist::PERSISTENT.city && Craigslist::PERSISTENT.category

      uri = self.build_uri(Craigslist::PERSISTENT.city, Craigslist::PERSISTENT.category)
      search_results = []

      for i in 0..(max_results / 100)
        uri = self.more_results(uri, i) if i > 0
        doc = Nokogiri::HTML(open(uri))

        doc.xpath("//p[@class = 'row']").each do |node|
          search_result = {}

          inner = Nokogiri::HTML(node.to_s)
          inner.xpath("//a").each_with_index do |inner_node, index|
            if index.even?
              search_result['text'] = inner_node.text.strip
              search_result['href'] = inner_node['href']
            end
          end

          inner.xpath("//span[@class = 'itempp']").each do |inner_node|
            search_result['price'] = inner_node.text.strip
          end

          inner.xpath("//span[@class = 'itempn']/font").each do |inner_node|
            search_result['location'] = inner_node.text.strip[1..(inner_node.text.strip.length - 2)].strip
          end

          if Craigslist::PERSISTENT.images
            inner.xpath("//span[@class = 'itempx']/span[@class = 'p']").each do |inner_node|
              if inner_node.text.include?('img') || inner_node.text.include?('pic')
                search_result['has_image'] = true
                search_result['images'] = []
                doc_post = Nokogiri::HTML(open(search_result['href']))
                doc_post.css('div#thumbs a').each do |img|
                  search_result['images'] << img['href']
                end
              end
            end
          end

          search_results << search_result
          break if search_results.length == max_results
        end
      end

      search_results
    end
  end

  private
  def self.build_uri(city_path, category_path)
    "http://#{city_path}.craigslist.org/#{category_path}/"
  end

  def self.more_results(uri, result_count=0)
    uri + "index#{result_count.to_i * 100}.html"
  end
end
