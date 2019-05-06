require 'redis'

module Recommendation
  autoload :Base,                  'recommendation/base'
  autoload :JaccardInputMatrix,    'recommendation/jaccard_input_matrix'

  DEFAULT_MAX_NEIGHBORS = 50

  @@redis = nil

  class << self
    def redis=(redis)
      @@redis = redis
    end

    def redis
      return @@redis unless @@redis.nil?

      raise 'redis not configured! - Recommendation.redis = Redis.new'
    end
  end
end
