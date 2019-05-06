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
        incr_item_pair_views_count(pair)
      end
    end

    def similarity_between(item1, item2)
      val = item_pair_views_count(item1, item2)
      val / (item_views_count(item1) + item_views_count(item2) - val).to_f
    end

    def similarities_for(item)
      (all_items - [item]).map do |another_item|
        [another_item, similarity_between(item, another_item)]
      end
    end

    def item_pair_views_count(item1, item2)
      Recommendation.redis.hget(redis_key(:item_pairs), [item1, item2].sort.join(':')).to_f
    end

    def item_views_count(item)
      Recommendation.redis.hget(redis_key(:items), item).to_f
    end

    def all_items
      Recommendation.redis.hkeys(redis_key(:items))
    end

    def get_all_pairs(item_ids)
      item_ids.map { |item| (item_ids - [item]).map { |another_item| [item, another_item].sort.join(':') } }
              .flatten.uniq
    end

    def incr_item_views_count(item_id)
      Recommendation.redis.hincrby(redis_key(:items), item_id, 1)
    end

    def incr_item_pair_views_count(pair)
      Recommendation.redis.hincrby(redis_key(:item_pairs), pair, 1)
    end
  end
end
