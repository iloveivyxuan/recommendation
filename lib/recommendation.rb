require 'redis'

module Recommendation
  DEFAULT_MAX_NEIGHBORS = 50

  @@redis = nil

  class << self
    def redis=(redis)
      @@redis = redis
    end

    def redis
      return @@redis unless @@redis.nil?

      raise 'redis not configured! - Recommendify.redis = Redis.new'
    end
  end
end
