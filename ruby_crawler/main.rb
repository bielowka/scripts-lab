require 'nokogiri'
require 'open-uri'

def list_nodes(base_url, total_pages = 1)
  combined_results = []
  (1..total_pages).each do |page|
    url = "#{base_url}&page=#{page}"

    headers = {
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
    }
    document = Nokogiri::HTML(URI.open(url, headers))
    div_nodes = document.css('div[data-asin][data-index][data-uuid][data-component-type="s-search-result"]')

    results = []
    # unique_links = Set.new

    div_nodes.each do |node|
      # link = node.at_css('a.a-link-normal.s-line-clamp-2.s-link-style.a-text-normal')&.[]('href')
      # next if unique_links.include?(link)
      # uuid = node['data-uuid']
      product_title = node.at_css('h2 span')&.text&.strip
      image_url = node.at_css('img.s-image')&.[]('src')
      rating = node.at_css('.a-icon-alt')&.text&.strip
      rating_count = node.at_css('span.s-underline-text')&.text&.strip
      price = node.at_css('.a-price .a-offscreen')&.text&.strip
      # item_id = node['data-csa-c-item-id']
      item_id = node['data-asin']


      results << {
        product_title: product_title,
        image_url: image_url,
        rating: rating,
        rating_count: rating_count,
        price: price,
        item_id: item_id
      }

      # unique_links.add(link)
    end
    combined_results += results
  end
  combined_results
end

def monitor_changes(base_url, total_pages = 1, interval = 600)
  previous_results = Set.new

  loop do
    current_results = list_nodes(base_url, total_pages).to_set

    new_items = current_results.reject { |item| previous_results.any? { |prev_item| prev_item[:item_id] == item[:item_id] } }
    changed_items = current_results.select do |item|
      previous_results.any? { |prev_item| prev_item[:item_id] == item[:item_id] && !prev_item.eql?(item) }
    end

    new_items.each { |item| puts "New item: #{item}" }
    changed_items.each { |item| puts "Changed item: #{item}" }

    previous_results = current_results
    sleep(interval)
    puts "-------"
  end
end

# puts list_nodes("https://www.amazon.com/s?k=iphone+13", 3)
monitor_changes("https://www.amazon.com/s?k=iphone+12", 3, 60)
#