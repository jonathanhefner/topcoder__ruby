$:<< File.dirname(__FILE__) << "#{File.dirname(__FILE__)}/.."
require 'SmartWordToy'
require 'rspec'


describe 'min_presses' do
  data = Struct.new(:start, :finish, :forbid)

  { data.new('aaaa', 'zzzz', ['a a a z', 'a a z a', 'a z a a', 'z a a a', 
                                'a z z z', 'z a z z', 'z z a z', 'z z z a']) => 8,
    data.new('aaaa', 'bbbb', []) => 4,
    data.new('aaaa', 'mmnn', []) => 50,
    data.new('aaaa', 'zzzz', ['bz a a a', 'a bz a a', 'a a bz a', 'a a a bz']) => -1,
    data.new('aaaa', 'zzzz', ['cdefghijklmnopqrstuvwxyz a a a', 'a cdefghijklmnopqrstuvwxyz a a', 
                                'a a cdefghijklmnopqrstuvwxyz a', 'a a a cdefghijklmnopqrstuvwxyz']) => 6,
    data.new('aaaa', 'bbbb', ['b b b b']) => -1,
    data.new('zzzz', 'aaaa', ['abcdefghijkl abcdefghijkl abcdefghijkl abcdefghijk'] * 50) => -1,
  }.each do |input, expected|
  
    it "returns #{expected} for #{input.start} -> #{input.finish} (#{input.forbid.length} forbidden)" do
      expect(min_presses(input.start, input.finish, input.forbid)).to eq(expected)
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
      expect(to_id(input)).to eq(expected)
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
      expect(preprocess_constraints(input)).to eq(expected)
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
      
      expect(actual_ids).to match_array(expected_ids)
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
      
      expect(check_forbidden(id, constraints)).to eq(expected)
    end
  
  end
end
