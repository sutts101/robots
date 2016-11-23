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

  describe '#to_a' do
    it 'should output x and y in an array' do
      expect(Point.new(1,2).to_a).to eq [1,2]
    end
  end

end

describe Orientation do

  describe '#move' do
    it 'should return a new point transformed (by 1) in the appropriate direction' do
      p = Point.new 0,0
      expect(Orientation.north.move(p).to_a).to eq [0,1]
      expect(Orientation.south.move(p).to_a).to eq [0,-1]
      expect(Orientation.east.move(p).to_a).to eq [1,0]
      expect(Orientation.west.move(p).to_a).to eq [-1,0]
    end
  end

end
