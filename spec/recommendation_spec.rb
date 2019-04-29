require 'spec_helper'

RSpec.describe Recommendation, 'recommendation' do
  it 'should connect with a redis database' do
    Recommendation.redis = Redis.new
    expect(Recommendation.redis.ping).to eq('PONG')
  end

  it 'chould save key-value data' do
    Recommendation.redis = Redis.new
    Recommendation.redis.set('user', 'item')
    expect(Recommendation.redis.get('user')).to eq('item')
  end

  it 'should raise error if redis has not been configured' do
    Recommendation.redis = nil
    expect { Recommendation.redis }.to raise_error
  end
end
