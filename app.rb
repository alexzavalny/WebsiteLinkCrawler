require './crawler.rb'

crawler = Crawler.new(url: ARGV[0])
crawler.crawl_all!
crawler.write_to_sitemap("sitemap.xml")