$:<< File.dirname(__FILE__) << "#{File.dirname(__FILE__)}/.."
require 'QuizShow'
require 'rspec'


describe 'wager' do
  data = Struct.new(:scores, :wagers)

  { data.new([100, 100, 100], [25, 75]) => 76,
    data.new([10, 50, 60], [30, 41]) => 0,
    data.new([10, 50, 60], [31, 41]) => 10,
    data.new([2, 2, 12], [0, 10]) => 1,
    data.new([10000, 10000, 10000], [9998, 9997]) => 9999,
    data.new([5824, 4952, 6230], [364, 287]) => 694,
    data.new([1, 0, 0], [0, 0]) => 0,
    data.new([0, 1, 1], [1, 1]) => 0,
    data.new([1, 1, 1], [0, 0]) => 1,
    data.new([1, 1, 1], [0, 1]) => 1,
    data.new([1, 1, 1], [1, 1]) => 0,
  }.each do |input, expected|
  
    it "returns #{expected} for scores #{input.scores} and opponent wagers #{input.wagers}" do
      expect(wager(input.scores, *input.wagers)).to eq(expected)
    end
  
  end

end
