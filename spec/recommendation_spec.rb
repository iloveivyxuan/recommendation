require 'spec_helper'

RSpec.describe Recommendation, 'recommendation' do
  it 'should connect with a redis database' do
    expect(Recommendation.redis.ping).to eq('PONG')
  end

  it 'chould save key-value data' do
    Recommendation.redis.set('user', 'item')
    expect(Recommendation.redis.get('user')).to eq('item')
  end
end
