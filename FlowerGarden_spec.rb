require './FlowerGarden.rb'
require 'rspec'


class Inputs < Struct.new(:height, :bloom, :wilt); end

describe 'get_ordering' do
  { Inputs.new([5, 4, 3, 2, 1], [1, 1, 1, 1, 1], [365, 365, 365, 365, 365]) => [1, 2, 3, 4, 5],
    Inputs.new([5, 4, 3, 2, 1], [1, 5, 10, 15, 20], [4, 9, 14, 19, 24]) => [5, 4, 3, 2, 1],
    Inputs.new([5, 4, 3, 2, 1], [1, 5, 10, 15, 20], [5, 10, 15, 20, 25]) => [1, 2, 3, 4, 5],
    Inputs.new([5, 4, 3, 2, 1], [1, 5, 10, 15, 20], [5, 10, 14, 20, 25]) => [3, 4, 5, 1, 2],
    Inputs.new([1, 2, 3, 4, 5, 6], [1, 3, 1, 3, 1, 3], [2, 4, 2, 4, 2, 4]) => [2, 4, 6, 1, 3, 5],
    Inputs.new([3, 2, 5, 4], [1, 2, 11, 10], [4, 3, 12, 13]) => [4, 5, 2, 3],
  }.each do |input, expected|
  
    it "returns #{expected} for heights #{input.height}, bloom days #{input.bloom}, and wilt days #{input.wilt}" do
      get_ordering(input.height, input.bloom, input.wilt).should == expected
    end
  
  end
end
