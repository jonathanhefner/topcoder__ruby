require_relative 'test_helper'
require 'bridge_crossing'


class BridgeCrossingTest < Minitest::Test
  SOLUTIONS = {
    [1, 2, 5, 10] => 17,
    [1, 2, 3, 4, 5] => 16,
    [100] => 100,
    [1, 2, 3, 50, 99, 100] => 162,
    [1, 1] => 1,
    [1, 2] => 2,
    [1, 1, 1] => 3,
    [1, 1, 2] => 4,
    [1, 1, 1, 1] => 5,
    [1, 1, 1, 2] => 6,
  }

  def test_solution
    SOLUTIONS.each do |input, expected|
      assert_equal expected, min_time(input)
    end
  end

  def test_brute_force_solution
    SOLUTIONS.each do |input, expected|
      assert_equal expected, brute_min_time(input)
    end
  end

end
