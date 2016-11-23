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

describe Robot do

  let (:point)        { Point.new 1,1 }
  let (:orientation1) { instance_double Orientation }
  let (:orientation2) { instance_double Orientation }
  subject             { Robot.new point, orientation1 }

  describe '#move' do
    it 'should return a new robot with same orientation and whatever point the current orientation says' do
      expect(orientation1).to receive(:move).with(point).and_return Point.new(3,3)
      moved = subject.move
      expect(moved.location).to eq Point.new 3,3
      expect(moved.orientation).to eq subject.orientation
    end
  end
  describe '#left / #right' do
    it 'should return a new robot with same point and whatever orientation the current orientation says' do
      [:left, :right].each do |left_or_right|
        expect(orientation1).to receive(left_or_right).and_return orientation2
        moved = subject.send left_or_right
        expect(moved.location).to eq subject.location
        expect(moved.orientation).to eq orientation2
      end
    end
  end

end

describe TableTop do

  let(:tabletop_5x5) { TableTop.new 5,5 }

  describe '#contains?' do
    it 'should be true if the passed point is within its bounds else false' do
      [ Point.new(0,0), Point.new(2,3), Point.new(4,4) ].each do |p|
        expect(tabletop_5x5.contains? p).to eq true
      end
      [ Point.new(-1,-1), Point.new(4,5), Point.new(5,4) ].each do |p|
        expect(tabletop_5x5.contains? p).to eq false
      end
    end
  end

  describe '#valid?' do
    it 'should be TRUE if there is no robot' do
      subject = TableTop.new 2, 2, nil
      expect(subject.valid?).to eq true
    end
    it 'should be TRUE if there is a robot and the robots location is contained' do
      robot = Robot.new Point.new(1,1), Orientation.east
      subject = TableTop.new 2, 2, robot
      expect(subject.valid?).to eq true
    end
    it 'should be FALSE if there is a robot and the robots location is NOT contained' do
      robot = Robot.new Point.new(3,3), Orientation.east
      subject = TableTop.new 2, 2, robot
      expect(subject.valid?).to eq false
    end
  end

  describe '#place' do
    context 'when the resulting tabletop would be VALID' do
      it 'should return the resulting tabletop (with robot)' do
        location = Point.new 1,1
        subject = tabletop_5x5.place location, Orientation.east
        expect(subject.robot.location).to eq location
        expect(subject.robot.orientation).to eq Orientation.east
      end
    end
    context 'when the resulting tabletop would NOT be valid?' do
      it 'should return itself' do
        location_1 = Point.new 1,1
        location_2 = Point.new 2,-1
        subject = tabletop_5x5
                      .place(location_1, Orientation.east)
                      .place(location_2, Orientation.west)
        expect(subject.robot.location).to eq location_1
        expect(subject.robot.orientation).to eq Orientation.east
      end
    end
  end

  describe '#apply' do
    let(:good_location) {Point.new 1,1}
    let(:bad_location)  {Point.new -1,-1}
    let(:robot_1)       {double 'Robot'}
    let(:robot_2)       {double 'Robot'}
    before do
      expect(robot_1).to receive(:some_op).and_return robot_2
    end
    context 'when the resulting tabletop would be VALID' do
      it 'should return the resulting tabletop' do
        expect(robot_2).to receive(:location).and_return good_location
        subject = TableTop.new(5, 5, robot_1).apply :some_op
        expect(subject.robot).to eq robot_2
      end
    end
    context 'when the resulting tabletop would NOT be valid' do
      it 'should return itself' do
        expect(robot_2).to receive(:location).and_return bad_location
        subject = TableTop.new(5, 5, robot_1).apply :some_op
        expect(subject.robot).to eq robot_1
      end
    end
  end

end

