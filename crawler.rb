require 'mechanize'
require 'csv'
require 'xml-sitemap'
require './stats.rb'

# Web Crawler Class
class Crawler
  attr_accessor :url
  attr_reader :stats
  attr_reader :links

  USER_AGENT = 'Googlebot'
  ERROR_LOG = 'errorlog.txt'

  def initialize(url:)
    @url = url
    @stats = Stats.new
  end

  def error_to_log(error)
    CSV.open(ERROR_LOG, "a") do |csv|
      csv << [error]
    end
  end

  def without_domain(link)
    link[@url.size - 1, -1]
  end

  def write_to_sitemap(filename)
    map = XmlSitemap::Map.new('oneride.eu', :secure => true) do |m|
      CSV.open(filename, "w") do |csv|
        @links.each do |link|
          m.add without_domain(link), :updated => Date.today, :period => :weekly
        end
      end
    end

    map.render_to('./sitemap_new.xml')
  end

  def write_to_csv(filename)
    CSV.open(filename, "w") do |csv|
      @links.each do |link|
        csv << [link]
      end
    end
  end

  def crawl_all!
    @links = [@url]
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
  end

  def clean_url(url)
    return "" if url.nil?
    return url if url.index("?") == -1
    url[0...url.index("?")]
  end

  def broken_url?(new_link)
    return true unless new_link.start_with?("http")
    return true if new_link.end_with?(".jpg") || new_link.end_with?(".mp4")
    return true if new_link.nil?
    false
  end

  def mechanize
    @mechanize ||= begin
      new_mech = Mechanize.new
      new_mech.user_agent = USER_AGENT
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
