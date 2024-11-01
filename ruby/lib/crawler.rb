require 'nokogiri'
require 'httparty'
require_relative '../db/db_setup'
# require 'api_2captcha'
require 'dotenv'

class Crawler
  Dotenv.load
  # client = Api2Captcha.new(ENV['2CAPTCHA'])
  BASE_URL = 'https://www.amazon.pl/'

  def initialize
    @headers = {
      'User-Agent' => 'AllegroCrawlerForUnivesity/1.0 (+https://github.com/galaxai)',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language' => 'en-US,en;q=0.5',
      'Accept-Encoding' => 'gzip, deflate, br',
      'DNT' => '1',
      'Connection' => 'keep-alive'
    }
  end

  def fetch_page(url)
    response = HTTParty.get(url, headers: @headers)

    # Check if we hit a captcha
    if response.body.include?('captcha-delivery.com')
      puts response.body
      puts "Warning: Captcha detected!"
      return nil
    end

    Nokogiri::HTML(response.body)
  rescue => e
    puts "Error fetching page: #{e.message}"
    nil
  end

  def scrape_category(category)
    category_url = "#{BASE_URL}/#{category}"
    page = fetch_page(category_url)
    return [] unless page
    print(page)
  end

  private

  def ensure_full_url(url)
    url.start_with?('http') ? url : "#{BASE_URL}#{url}"
  end
end

CATEGORY = 's?k=laptops'
crawler = Crawler.new

crawler.scrape_category(CATEGORY)
