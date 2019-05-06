module Recommendation
  class JaccardInputMatrix
    def initialize(opts = {})
      @opts = opts
    end

    def redis_key(append = nil)
      [@opts.fetch(:redis_prefix), @opts.fetch(:action), append].flatten.compact.join(':')
    end

    def count_items_views_in_redis(item_ids)
      item_ids.each do |item_id|
        incr_item_views_count(item_id)
      end
      paris = get_all_pairs(item_ids)
      paris.each do |pair|
        incr_items_both_views_count(pair)
      end
    end

    def all_items
      Recommendation.redis.hkeys(redis_key('items'))
    end

    def get_all_pairs(item_ids)
      item_ids.map { |item| (item_ids - [item]).map { |another_item| [item, another_item].sort.join(':') } }
              .flatten.uniq
    end

    def incr_item_views_count(item_id)
      Recommendation.redis.hincrby(redis_key(:items), item_id, 1)
    end

    def incr_items_both_views_count(pair)
      Recommendation.redis.hincrby(redis_key(:item_pairs), pair, 1)
    end
  end
end
