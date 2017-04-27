require_relative 'test_helper'
require 'smart_word_toy'


class SmartWordToyTest < Minitest::Test
  Inputs = Struct.new(:start, :finish, :forbid)

  SOLUTIONS = {
    Inputs.new('aaaa', 'zzzz', ['a a a z', 'a a z a', 'a z a a',
      'z a a a', 'a z z z', 'z a z z', 'z z a z', 'z z z a']) => 8,

    Inputs.new('aaaa', 'bbbb', []) => 4,

    Inputs.new('aaaa', 'mmnn', []) => 50,

    Inputs.new('aaaa', 'zzzz', ['bz a a a', 'a bz a a', 'a a bz a',
      'a a a bz']) => -1,

    Inputs.new('aaaa', 'zzzz', ['cdefghijklmnopqrstuvwxyz a a a',
      'a cdefghijklmnopqrstuvwxyz a a', 'a a cdefghijklmnopqrstuvwxyz a',
      'a a a cdefghijklmnopqrstuvwxyz']) => 6,

    Inputs.new('aaaa', 'bbbb', ['b b b b']) => -1,

    Inputs.new('zzzz', 'aaaa',
      ['abcdefghijkl abcdefghijkl abcdefghijkl abcdefghijk'] * 50) => -1,
  }

  def test_solution
    SOLUTIONS.each do |input, expected|
      assert_equal expected, SmartWordToy.solve(input.start, input.finish, input.forbid)
    end
  end

end
