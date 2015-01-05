$:<< File.dirname(__FILE__) << "#{File.dirname(__FILE__)}/.."
require 'BridgeCrossing'
require 'rspec'


describe 'brute_min_time' do
  { [1, 2, 5, 10] => 17,
    [1, 2, 3, 4, 5] => 16,
    [100] => 100,
    [1, 2, 3, 50, 99, 100] => 162,
    [1, 1] => 1,
    [1, 2] => 2,
    [1, 1, 1] => 3,
    [1, 1, 2] => 4,
    [1, 1, 1, 1] => 5,
    [1, 1, 1, 2] => 6,
  }.each do |input, expected|
  
    it "returns #{expected} for #{input}" do
      brute_min_time(input).should == expected
    end
  
  end
end


describe 'min_time' do
  [ [1, 2, 5, 10],
    [1, 2, 3, 4, 5],
    [100],
    [1, 2, 3, 50, 99, 100],
    [1, 1],
    [1, 2],
    [1, 1, 1],
    [1, 1, 2],
    [1, 1, 1, 1],
    [1, 1, 1, 2],
    (1..7).to_a,
  ].each do |input|
  
    it "returns the same as brute_min_time for #{input}" do
      min_time(input).should == brute_min_time(input)
    end
  
  end
end
