require 'nokogiri'
require 'httparty'
require_relative '../db/db_setup'

class Crawler
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

  def scrape_category(category, keyword = nil, n_searches = -1)
    category_url = "#{BASE_URL}/#{category}"
    page = fetch_page(category_url)
    return [] unless page

      if n_searches == -1
        products = page.css('div[data-asin]:not([data-asin=""])')
      else
        products = page.css('div[data-asin]:not([data-asin=""])').first(n_searches)
      end

      products.map do |product|
        begin
          product_url = ensure_full_url(product.css('h2 .a-link-normal').first&.[]('href'))
          next unless product_url

          product_page = fetch_page(product_url)
          product_details = scrape_product_details(product_page) if product_page

          product_data = {
            asin: product['data-asin'],
            title: product.css('h2 .a-link-normal span.a-text-normal').text.strip,
            price: product.css('.a-price .a-offscreen').first&.text,
            rating: product.css('i.a-icon-star-small .a-icon-alt').first&.text,
            reviews_count: product.css('span[aria-label*="ocen"]').text.strip,
            url: product_url,
            image_url: product.css('.s-image').first&.[]('src'),
            details: product_details
          }

          # Only proceed if we have the minimum required data
          next if product_data[:asin].to_s.empty? || product_data[:title].to_s.empty?

          # Check if keyword matches and store
          result = keyword.nil? ? product_data : matches_keyword?(product_data, keyword)
          store_product(product_data) if result

          result
        rescue => e
          puts "Error processing product: #{e.message}"
          nil
        end
      end.compact
    end

  private

  def store_product(product_data)
    # Clean and validate the data
    cleaned_data = {
      asin: product_data[:asin],
      title: product_data[:title],
      price: product_data[:price].to_s.gsub(/[^\d,.]/, ''),  # Clean price string
      rating: product_data[:rating].to_f,  # Convert to float
      reviews_count: product_data[:reviews_count].to_i,  # Convert to integer
      url: product_data[:url],
      image_url: product_data[:image_url],
      created_at: Time.now,
      updated_at: Time.now
    }

    # Define the update data (excluding created_at)
    update_data = cleaned_data.dup
    update_data.delete(:created_at)

    # Only proceed if we have the required fields
    if cleaned_data[:asin] && cleaned_data[:title]
      DB[:products].insert_conflict(
        target: :asin,
        update: update_data
      ).insert(cleaned_data)
    else
      puts "Error: Missing required fields (ASIN or title)"
      nil
    end
  rescue => e
    puts "Error storing product: #{e.message}"
    nil
  end

  def matches_keyword?(product_data, keyword)
    keyword = keyword.downcase

    # Check in title
    return product_data if product_data[:title].downcase.include?(keyword)

    # Check in product details
    product_data[:details].each do |_section_title, details|
      details.each do |_key, value|
        return product_data if value.downcase.include?(keyword)
      end
    end

    nil
  end

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
KEYWORD = 'amd ryzen'
N = 2
crawler = Crawler.new

results = crawler.scrape_category(CATEGORY,nil, n_searches=N)
puts "Found #{results.length} products total"
puts "\nFirst #{N} products:"
puts "-----------------"

results.first(N).each_with_index do |product, index|
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
