#link
class Link
  attr_accessor :url, :priority

  def initialize(url:, priority:)
    @url = url
    @priority = priority
  end
end
