require 'open-uri'
require 'nokogiri'

require 'craigslist/cities'
require 'craigslist/categories'
require 'craigslist/craigslist'

module Craigslist
  PERSISTENT = Persistent.new
end
