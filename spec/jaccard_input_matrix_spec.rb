require 'spec_helper'

RSpec.describe Recommendation::JaccardInputMatrix, 'jaccard_input_matrix' do
  before(:all) do
    @matrix = Recommendation::JaccardInputMatrix.new(
      redis_prefix: 'recommendation_test',
      action: 'views'
    )
  end

  before(:each) { initialize_redis! }

  it 'should have a correct redis_key to save & retrieve the views count' do
    expect(@matrix.redis_key).to eq('recommendation_test:views')
  end

  it 'should save views_count of a certain item in redis' do
    Recommendation.redis.hset('recommendation_test:views:items', 'article_1', 2)
    @matrix.set_to_redis(%w[article_1 article_2])
    expect(Recommendation.redis.hget('recommendation_test:views:items', 'article_1')).to eq('3')
    expect(Recommendation.redis.hget('recommendation_test:views:items', 'article_2')).to eq('1')
  end

  it 'should save views_count of certain pair of items in redis' do
    Recommendation.redis.hset('recommendation_test:views:item_pairs', 'article_1:article_2', 2)
    @matrix.set_to_redis(%w[article_1 article_2])
    expect(
      Recommendation.redis.hget('recommendation_test:views:item_pairs', 'article_1:article_2')
    ).to eq('3')
  end

  it 'should return all items as an array' do
    @matrix.set_to_redis(%w[article_1 article_2])
    @matrix.set_to_redis(%w[article_1 article_3])
    expect(@matrix.all_items).to eq(%w[article_1 article_2 article_3])
  end

  it 'should get all pairs of tiems viewed by one user' do
    pairs = @matrix.get_all_pairs(%w[article_1 article_2 article_3])
    expect(pairs.count).to eq(3)
  end
end
