require 'redis'

module Recommendation
  @@redis = nil

  class << self
    def redis
      @@redis || @@redis = ::Redis.new
    end
  end
end
