# link
class Link
  attr_accessor :url, :priority

  def initialize(url:, priority:)
    @url = url
    @priority = priority
  end

  def to_s
    "#{url} [#{priority}]"
  end
end
