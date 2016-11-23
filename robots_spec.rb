require './robots.rb'

describe Point do

  describe '#new' do
    it 'should be happy if you give it integer values for x and y' do
      p = Point.new 2,3
      expect(p.x).to eq 2
      expect(p.y).to eq 3
    end
    it 'should also be happy if you give it string integer values for x and y' do
      p = Point.new '2','3'
      expect(p.x).to eq 2
      expect(p.y).to eq 3
    end
    it 'should complain if coords are not ints' do
      expect{Point.new 'apple', 'banana'}.to raise_error(ArgumentError)
    end
  end

end