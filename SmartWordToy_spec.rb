require './SmartWordToy.rb'
require 'rspec'

class Inputs < Struct.new(:start, :finish, :forbid); end

describe 'min_presses' do
  { Inputs.new('aaaa', 'zzzz', ['a a a z', 'a a z a', 'a z a a', 'z a a a', 
                                'a z z z', 'z a z z', 'z z a z', 'z z z a']) => 8,
    Inputs.new('aaaa', 'bbbb', []) => 4,
    Inputs.new('aaaa', 'mmnn', []) => 50,
    Inputs.new('aaaa', 'zzzz', ['bz a a a', 'a bz a a', 'a a bz a', 'a a a bz']) => -1,
    Inputs.new('aaaa', 'zzzz', ['cdefghijklmnopqrstuvwxyz a a a', 'a cdefghijklmnopqrstuvwxyz a a', 
                                'a a cdefghijklmnopqrstuvwxyz a', 'a a a cdefghijklmnopqrstuvwxyz']) => 6,
    Inputs.new('aaaa', 'bbbb', ['b b b b']) => -1,
    Inputs.new('zzzz', 'aaaa', ['abcdefghijkl abcdefghijkl abcdefghijkl abcdefghijk'] * 50) => -1,
  }.each do |input, expected|
  
    it "returns #{expected} for #{input.start} -> #{input.finish} (#{input.forbid.length} forbidden)" do
      min_presses(input.start, input.finish, input.forbid).should == expected
    end
  
  end
end


describe 'to_id' do
  { 'aaaa' => 0,
    'baaa' => 1,
    'abaa' => 32, # 32 (not 26) b/c we're encoding as base-32 for convenience
    'aaba' => 32**2,
    'aaab' => 32**3,
    'bbbb' => 1 + 32 + 32**2 + 32**3,
  }.each do |input, expected|
  
    it "returns #{expected} for #{input}" do
      to_id(input).should == expected
    end
  
  end
end


describe 'preprocess_constraints' do
  { ['a a a a'] => ({0 => {0 => {0 => {0 => true}}}}),
    ['a a a ab'] => ({0 => {0 => {0 => {0 => true, 1 => true}}}}),
    ['a a a a', 'a a a b'] => ({0 => {0 => {0 => {0 => true, 1 => true}}}}),
    ['a a ab a'] => ({0 => {0 => {0 => {0 => true}, 1 => {0 => true}}}}),
    ['a a a a', 'a a b a'] => ({0 => {0 => {0 => {0 => true}, 1 => {0 => true}}}}),
  }.each do |input, expected|
  
    it "returns #{expected} for #{input}" do
      preprocess_constraints(input).should == expected
    end
  
  end
end


describe 'neighbor' do
  { 'aaaa' => %w'aaab aaaz aaba aaza abaa azaa baaa zaaa',
    'bbbb' => %w'bbbc bbba bbcb bbab bcbb babb cbbb abbb',
    'zzzz' => %w'zzza zzzy zzaz zzyz zazz zyzz azzz yzzz',
  }.each do |input, expected|
  
    it "yields all neighbors #{expected} for #{input}" do
      input_id = to_id(input)
      expected_ids = expected.map{|e| to_id(e) }
    
      actual_ids = DISPLAYS.inject([]) do |n, d|
        n += [1, -1].map{|i| neighbor(input_id, d, i) }
      end
      
      actual_ids.should =~ expected_ids
    end
  
  end
end


describe 'check_forbidden' do
  { ['aaaa', 'a a a a'] => true,
    ['aaaa', 'a a a b'] => false,
    ['late', 'lf a tc e'] => true,
    ['fate', 'lf a tc e'] => true,
    ['lace', 'lf a tc e'] => true,
    ['face', 'lf a tc e'] => true,
    ['fale', 'lf a tc e'] => false,
  }.each do |input, expected|
  
    it "returns #{expected} for #{input.first} with constraint \"#{input.last}\"" do
      id = to_id(input.first)
      constraints = preprocess_constraints([input.last])
      
      check_forbidden(id, constraints).should == expected
    end
  
  end
end
