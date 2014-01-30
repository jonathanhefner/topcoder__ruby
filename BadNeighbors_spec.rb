require './BadNeighbors.rb'
require 'rspec'


describe 'max_donations' do
  { [10, 3, 2, 5, 7, 8] => 19,
    [11, 15] => 15,
    [7, 7, 7, 7, 7, 7, 7] => 21,
    [1, 2, 3, 4, 5, 1, 2, 3, 4, 5] => 16,
    [94, 40, 49, 65, 21, 21, 106, 80, 92, 81, 679, 4, 61, 6, 237, 12, 72, 74, 29, 95, 
      265, 35, 47, 1, 61, 397, 52, 72, 37, 51, 1, 81, 45, 435, 7, 36, 57, 86, 81, 72] => 2926,
    [1, 2, 3] => 3,
    [1, 3, 2] => 3,
    [3, 2, 1] => 3,
    [1, 2, 3, 4] => 6,
    [4, 2, 3, 1] => 7,
  }.each do |input, expected|
  
    it "returns #{expected} for #{input}" do
      max_donations(input).should == expected
    end
  
  end
end
