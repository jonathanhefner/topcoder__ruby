require './QuizShow.rb'
require 'rspec'


class Inputs < Struct.new(:scores, :wagers); end

describe 'wager' do
  { Inputs.new([100, 100, 100], [25, 75]) => 76,
    Inputs.new([10, 50, 60], [30, 41]) => 0,
    Inputs.new([10, 50, 60], [31, 41]) => 10,
    Inputs.new([2, 2, 12], [0, 10]) => 1,
    Inputs.new([10000, 10000, 10000], [9998, 9997]) => 9999,
    Inputs.new([5824, 4952, 6230], [364, 287]) => 694,
    Inputs.new([1, 0, 0], [0, 0]) => 0,
    Inputs.new([0, 1, 1], [1, 1]) => 0,
    Inputs.new([1, 1, 1], [0, 0]) => 1,
    Inputs.new([1, 1, 1], [0, 1]) => 1,
    Inputs.new([1, 1, 1], [1, 1]) => 0,
  }.each do |input, expected|
  
    it "returns #{expected} for scores #{input.scores} and opponent wagers #{input.wagers}" do
      wager(input.scores, *input.wagers).should == expected
    end
  
  end

end
