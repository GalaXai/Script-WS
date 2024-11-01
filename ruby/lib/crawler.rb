require 'nokogiri'
require 'httparty'
require_relative '../db/db_setup'
require 'dotenv'

class Crawler
  Dotenv.load
  BASE_URL = 'https://www.amazon.pl/'

  def initialize
    @headers = {
      'User-Agent' => 'AmazonCrawlerForUnivesity/1.0 (+https://github.com/galaxai)',
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

    # Find all product containers
    products = page.css('div[data-asin]:not([data-asin=""])').first(1)
    products.map do |product|
      product_url = ensure_full_url(product.css('h2 .a-link-normal').first['href'])

      # Extract for product_url
      product_page = fetch_page(product_url)
      product_details = scrape_product_details(product_page) if product_page

      {
        asin: product['data-asin'],
        title: product.css('h2 .a-link-normal span.a-text-normal').text.strip,
        price: product.css('.a-price .a-offscreen').first&.text,
        rating: product.css('i.a-icon-star-small .a-icon-alt').first&.text,
        reviews_count: product.css('span[aria-label*="ocen"]').text.strip,
        url: product_url,
        image_url: product.css('.s-image').first['src'],
        details: product_details || {}
      }
    end
  end

  private

  def scrape_product_details(product_page)
    product_details = {}

    tables_container = product_page.css('div#productDetails_expanderSectionTables')

    tables_container.css('.a-expander-container').each do |section|
      # Get section title
      section_title = section.css('.a-expander-prompt').text.strip

      next if section_title == 'Oceny klientów' ## Idc about this + contains a lot of ccs?

      # Get all rows from the table in this section
      details = {}
      section.css('table.prodDetTable tr').each do |row|
        key = row.css('th').text.strip
        value = row.css('td').text.strip
        details[key] = value unless key.empty?
      end

      product_details[section_title] = details unless details.empty?
    end

    product_details
  end
  def ensure_full_url(url)
    url.start_with?('http') ? url : "#{BASE_URL}#{url}"
  end
end

CATEGORY = 's?k=laptops'
crawler = Crawler.new

results = crawler.scrape_category(CATEGORY)
puts "Found #{results.length} products total"
puts "\nFirst 10 products:"
puts "-----------------"

results.first(10).each_with_index do |product, index|
  puts "\n#{index + 1}. #{product[:title]}"
  puts "   Price: #{product[:price]}"
  puts "   Rating: #{product[:rating]} (#{product[:reviews_count]} reviews)"
  puts "   URL: #{product[:url]}"
  puts "   ASIN: #{product[:asin]}"
  puts "\n   Product Details:"
  product[:details].each do |section_title, details|
    puts "   #{section_title}:"
    details.each do |key, value|
      puts "      #{key}: #{value}"
    end
  end
  puts "-----------------"
end
