require 'open-uri'
require 'nokogiri'

require_relative 'craigslist/cities'
require_relative 'craigslist/categories'
require_relative 'craigslist/craigslist'

module Craigslist
  PERSISTENT = Persistent.new
end
