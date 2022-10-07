require 'mechanize'
require 'csv'
require './stats.rb'

# Web Crawler Class
class Crawler
  attr_accessor :url
  attr_reader :stats

  ERROR_LOG = "errorlog.txt"

  def initialize(url:)
    @url = url
    @stats = Stats.new
  end

  def crawl_to_csv(csv)
    write_to_csv(csv, crawl_all)
  end

  def error_to_log(error)
    CSV.open(ERROR_LOG, "a") do |csv|
      csv << [error]
    end
  end

  def write_to_csv(filename, links)
    CSV.open(filename, "w") do |csv|
      links.each do |link|
        csv << [link]
      end
    end
  end

  def crawl_all
    links = [@url]
    index = 0

    while index < links.length
      if under_domain?(links[index])
        new_links = crawl_links_from_page(links[index])
        @stats.crawled += 1
        new_links.each do |new_link|
          clean_link = clean_url(new_link)
          links << clean_link unless links.include?(clean_link) || broken_url?(clean_link)
        end
        @stats.collected = links.size
      end

      index += 1
      puts @stats
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

  def mechanize
    @mechanize ||= begin
      new_mech = Mechanize.new
      new_mech.user_agent = 'Googlebot'
      new_mech
    end
  end

  def crawl_links_from_page(url)
    puts "Crawling page: #{url}"
    page = mechanize.get(url)
    page.links.map(&:href)
  rescue
    error_to_log(url)
    []
  end

  def under_domain?(link)
    domain = get_domain(@url)
    link.start_with?(domain)
  end

  def get_domain(url)
    url
  end
end

Crawler.new(url: "https://oneride.eu/").crawl_to_csv("output_oneride.csv")
#Crawler.new(url: "https://viensrats.lv/").crawl_to_csv("output_viensrats.csv")