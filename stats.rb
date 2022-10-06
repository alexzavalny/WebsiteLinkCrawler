# Stats
class Stats
  attr_accessor :crawled, :collected

  def initialize
    @crawled = 0
    @collected = 0
  end

  def to_s
    "Crawled pages: #{crawled}, Collected: #{collected}"
  end
end
