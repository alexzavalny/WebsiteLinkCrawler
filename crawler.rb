require 'mechanize'
require "csv"

# Web Crawler Class
class Crawler
  attr_accessor :url

  def initialize(url:)
    @url = url
  end

  def crawl_to_csv(csv)
    write_to_csv(csv, crawl_all)
  end

  def write_to_csv(filename, links)
    CSV.open(filename, "w") do |csv|
      links.each do |link|
        csv << [link.url, link.priority]
      end
    end
  end

  def crawl_all
    links = [@url]
    index = 0

    while index < links.length
      break if links.length > 100
      if under_domain?(links[index])

        new_links = crawl_links_from_page(links[index])
        new_links.each do |new_link|
          clean_link = clean_url(new_link)
          links << clean_link unless links.include?(clean_link) || broken_url?(clean_link)
        end
        puts links
      end

      index += 1
    end

    links
  end

  def clean_url(url)
    return url if url.index("?") == -1

    url[0...url.index("?")]
  end

  def broken_url?(new_link)
    return true unless new_link.start_with?("http")
  end

  def crawl_links_from_page(url)
    mechanize = Mechanize.new
    page = mechanize.get(url)
    page.links.map(&:href)
  end

  def under_domain?(link)
    domain = get_domain(@url)
    link.start_with?(domain)
  end

  def get_domain(url)
    url
  end
end

Crawler.new(url: "https://oneride.eu/").crawl_to_csv("output.csv")