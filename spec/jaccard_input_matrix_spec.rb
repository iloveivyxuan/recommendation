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
    @matrix.count_items_views_in_redis(%w[article_1 article_2])
    expect(Recommendation.redis.hget('recommendation_test:views:items', 'article_1')).to eq('3')
    expect(Recommendation.redis.hget('recommendation_test:views:items', 'article_2')).to eq('1')
  end

  it 'should save views_count of certain pair of items in redis' do
    Recommendation.redis.hset('recommendation_test:views:item_pairs', 'article_1:article_2', 2)
    @matrix.count_items_views_in_redis(%w[article_1 article_2])
    expect(
      Recommendation.redis.hget('recommendation_test:views:item_pairs', 'article_1:article_2')
    ).to eq('3')
  end

  it 'should return all items as an array' do
    @matrix.count_items_views_in_redis(%w[article_1 article_2])
    @matrix.count_items_views_in_redis(%w[article_1 article_3])
    expect(@matrix.all_items).to eq(%w[article_1 article_2 article_3])
  end

  it 'should get all pairs of tiems viewed by one user' do
    pairs = @matrix.get_all_pairs(%w[article_1 article_2 article_3])
    expect(pairs.count).to eq(3)
  end

  it 'should calculate the correct similarity between two items' do
    add_two_item_test_data!(@matrix)
    expect(@matrix.similarity_between('article_4', 'article_5')).to eq(0.4)
    expect(@matrix.similarity_between('article_5', 'article_4')).to eq(0.4)
  end

  it 'should calculate all similarities of a certain item to other items' do
    add_three_item_test_data!(@matrix)
    result = @matrix.similarities_for('article_4')
    expect(result).to include(['article_5', 0.4])
    expect(result).to include(['article_6', 0.75])
  end

  private

  def add_two_item_test_data!(matrix)
    matrix.count_items_views_in_redis(%w[article_4 article_5])
    matrix.count_items_views_in_redis(%w[article_5])
    matrix.count_items_views_in_redis(%w[article_4])
    matrix.count_items_views_in_redis(%w[article_4 article_5])
    matrix.count_items_views_in_redis(%w[article_4])
  end

  def add_three_item_test_data!(matrix)
    matrix.count_items_views_in_redis(%w[article_4 article_5 article_6])
    matrix.count_items_views_in_redis(%w[article_5])
    matrix.count_items_views_in_redis(%w[article_4 article_6])
    matrix.count_items_views_in_redis(%w[article_4 article_5])
    matrix.count_items_views_in_redis(%w[article_4 article_6])
  end
end
