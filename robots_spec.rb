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

  describe '#to_a' do
    it 'should output deltas for x and y in an array' do
      expect(Orientation.new(1,1).to_a).to eq [1,1]
    end
  end

  describe '#==' do
    it 'should be true if x and y deltas are identical' do
      o1 = Orientation.new 1,1
      o2 = Orientation.new 1,1
      o3 = Orientation.new 1,2
      expect(o1 == o2).to eq true
      expect(o1 == o3).to eq false
    end
  end

  describe '#move' do
    it 'should return a new point transformed by the deltas for x and y' do
      o = Orientation.new -2,-3
      p = Point.new 1,1
      expect(o.move(p).to_a).to eq [-1,-2]
    end
  end

  describe 'predefined orientations' do
    it 'should correspond to points of the compass with a magnitude of 1' do
      expect(Orientation.north.to_a).to eq [0,1]
      expect(Orientation.south.to_a).to eq [0,-1]
      expect(Orientation.east.to_a).to eq [1,0]
      expect(Orientation.west.to_a).to eq [-1,0]
    end
  end

  describe 'rotations' do
    describe '#right' do
      it 'should return the next (clockwise) orientation' do
        expect(Orientation.north.right).to eq Orientation.east
        expect(Orientation.east.right).to eq Orientation.south
        expect(Orientation.south.right).to eq Orientation.west
        expect(Orientation.west.right).to eq Orientation.north
      end
    end
    describe '#left' do
      it 'should return the previous (anti-clockwise) orientation' do
        expect(Orientation.north.left).to eq Orientation.west
        expect(Orientation.west.left).to eq Orientation.south
        expect(Orientation.south.left).to eq Orientation.east
        expect(Orientation.east.left).to eq Orientation.north
      end
    end
    it 'should explode for non-predefined orientations' do
      o = Orientation.new 2,2
      expect{o.right}.to raise_error(/only works for predefined/)
      expect{o.left}.to raise_error(/only works for predefined/)
    end
  end

end
