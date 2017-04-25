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
      assert_equal expected, min_presses(input.start, input.finish, input.forbid)
    end
  end

  def test_to_id
    { 'aaaa' => 0,
      'baaa' => 1,
      'abaa' => 32, # 32 (not 26) b/c we're encoding as base-32 for convenience
      'aaba' => 32**2,
      'aaab' => 32**3,
      'bbbb' => 1 + 32 + 32**2 + 32**3,
    }.each do |input, expected|
      assert_equal expected, to_id(input)
    end
  end

  def test_preprocess_constraints
    { ['a a a a'] =>
        ({0 => {0 => {0 => {0 => true}}}}),
      ['a a a ab'] =>
        ({0 => {0 => {0 => {0 => true, 1 => true}}}}),
      ['a a a a', 'a a a b'] =>
        ({0 => {0 => {0 => {0 => true, 1 => true}}}}),
      ['a a ab a'] =>
        ({0 => {0 => {0 => {0 => true}, 1 => {0 => true}}}}),
      ['a a a a', 'a a b a'] =>
        ({0 => {0 => {0 => {0 => true}, 1 => {0 => true}}}}),
    }.each do |input, expected|
      assert_equal expected, preprocess_constraints(input)
    end
  end

  def test_neighbor
    { 'aaaa' => %w'aaab aaaz aaba aaza abaa azaa baaa zaaa',
      'bbbb' => %w'bbbc bbba bbcb bbab bcbb babb cbbb abbb',
      'zzzz' => %w'zzza zzzy zzaz zzyz zazz zyzz azzz yzzz',
    }.each do |input, expected|
      input_id = to_id(input)
      expected_ids = expected.map{|e| to_id(e) }
      actual_ids = DISPLAYS.reduce([]) do |ids, d|
        ids << neighbor(input_id, d, +1)
        ids << neighbor(input_id, d, -1)
        ids
      end

      assert_equal expected_ids.sort, actual_ids.sort
    end
  end

  def test_check_forbidden
    { ['aaaa', 'a a a a'] => true,
      ['aaaa', 'a a a b'] => false,
      ['late', 'lf a tc e'] => true,
      ['fate', 'lf a tc e'] => true,
      ['lace', 'lf a tc e'] => true,
      ['face', 'lf a tc e'] => true,
      ['fale', 'lf a tc e'] => false,
    }.each do |input, expected|
      input_id = to_id(input[0])
      input_constraints = preprocess_constraints([input[1]])

      assert_equal expected, check_forbidden(input_id, input_constraints)
    end
  end

end
