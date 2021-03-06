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

  describe '#name' do
    context 'for points of the compass' do
      it 'should correspond to compass direction' do
        expect(Orientation.north.name).to eq :north
        expect(Orientation.east.name).to eq :east
        expect(Orientation.south.name).to eq :south
        expect(Orientation.west.name).to eq :west
        expect(Orientation.new(1,0).name).to eq :east
      end
    end
    context 'for all other orientations' do
      it 'should be nil' do
        expect(Orientation.new(1,1).name).to be_nil
      end
    end
  end

end

describe Robot do

  let (:point)        { Point.new 1,1 }
  let (:orientation)  { instance_double Orientation }
  subject             { Robot.new point, orientation }

  describe '#move' do
    it 'should return a new robot with same orientation and whatever point the current orientation says' do
      expect(orientation).to receive(:move).with(point).and_return :some_new_point
      moved = subject.move
      expect(moved.location).to eq :some_new_point
      expect(moved.orientation).to eq subject.orientation
    end
  end
  describe '#left / #right' do
    it 'should return a new robot with same point and whatever orientation the current orientation says' do
      [:left, :right].each do |left_or_right|
        expect(orientation).to receive(left_or_right).and_return :some_new_orientation
        moved = subject.send left_or_right
        expect(moved.location).to eq subject.location
        expect(moved.orientation).to eq :some_new_orientation
      end
    end
  end
  describe '#to_s' do
    it 'should return a string indicating location and orientation' do
      expect(orientation).to receive(:name).and_return :north
      expect(subject.to_s).to eq '1,1,NORTH'
    end
  end
  describe '#report' do
    it 'should output a string indicating location and orientation' do
      expect(orientation).to receive(:name).and_return :north
      stdout = spy 'stdout'
      subject.report stdout
      expect(stdout).to have_received(:puts).with('1,1,NORTH')
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
    context 'when the resulting tabletop would be VALID' do
      it 'should return the resulting tabletop' do
        expect(robot_1).to receive(:some_op).and_return robot_2
        expect(robot_2).to receive(:location).and_return good_location
        subject = TableTop.new(5, 5, robot_1).apply :some_op
        expect(subject.robot).to eq robot_2
      end
    end
    context 'when the resulting tabletop would NOT be valid' do
      it 'should return itself' do
        expect(robot_1).to receive(:some_op).and_return robot_2
        expect(robot_2).to receive(:location).and_return bad_location
        subject = TableTop.new(5, 5, robot_1).apply :some_op
        expect(subject.robot).to eq robot_1
      end
    end
    context 'when there is no robot to which the command could be applied' do
      it 'should return itself' do
        subject = TableTop.new(5, 5, nil).apply :some_op
        expect(subject).not_to be_nil
        expect(subject.robot).to be_nil
      end
    end
  end

end

describe Command do

  describe '.parse' do
    context 'when the command tokens string does NOT include PLACE' do
      it 'should just treat each token as a single command with no args' do
        subject = Command.parse 'APPLE BANANA orange KiWi'
        expect(subject.map(&:name)).to eq [:apple, :banana, :orange, :kiwi]
      end
    end
    context 'when the command tokens string DOES include PLACE' do
      it 'should skip over the folowing token' do
        subject = Command.parse 'MOVE RIGHT PLACE 1,1,NORTH LEFT'
        expect(subject.map(&:name)).to eq [:move, :right, :place, :left]
      end
      it 'should set the FIRST argument of the place command to be the corresponding LOCATION' do
        subject = Command.parse 'MOVE RIGHT PLACE 1,1,NORTH'
        place_command = subject.last
        expect(place_command.args.first).to eq Point.new(1,1)
      end
      it 'should set the SECOND argument of the place command to be the corresponding ORIENTATION' do
        subject = Command.parse 'MOVE RIGHT PLACE 1,1,NORTH'
        place_command = subject.last
        expect(place_command.args.last).to eq Orientation.north
      end
      it 'should explode if there are insufficient place tokens' do
        expect{ Command.parse 'MOVE RIGHT PLACE 1,1' }.to raise_error(/Bad place command arguments/)
      end
      it 'should explode if the place location is not valid' do
        expect{ Command.parse 'MOVE RIGHT PLACE apple,banana,NORTH' }.to raise_error(/Bad place command arguments/)
      end
      it 'should explode if the place orientation is not valid' do
        expect{ Command.parse 'MOVE RIGHT PLACE 1,1,SOUTHEAST' }.to raise_error(/Bad place command arguments/)
      end
    end
  end

  describe '#apply' do
    context 'for PLACE commands' do
      it 'should invoke place on the passed tabletop' do
        location = instance_double Point
        orientation = instance_double Orientation
        subject = Command.new :place, [location, orientation]
        tabletop = spy TableTop
        subject.apply tabletop
        expect(tabletop).to have_received(:place).with(location, orientation)
      end
    end
    context 'for all other commands' do
      it 'should invoke apply on the passed tabletop' do
        subject = Command.new :some_command
        tabletop = spy TableTop
        subject.apply tabletop
        expect(tabletop).to have_received(:apply).with(:some_command)
      end
    end
  end

end

def run_and_return_robot(command_string)
  Command.parse_and_apply(command_string, TableTop.new).robot
end

describe 'putting it all together' do

  it 'should handle declared scenario (a)' do
    robot = run_and_return_robot 'PLACE 0,0,NORTH MOVE'
    expect(robot.to_s).to eq '0,1,NORTH'
  end
  it 'should handle declared scenario (b)' do
    robot = run_and_return_robot 'PLACE 0,0,NORTH LEFT'
    expect(robot.to_s).to eq '0,0,WEST'
  end
  it 'should handle declared scenario (c)' do
    robot = run_and_return_robot 'PLACE 1,2,EAST MOVE MOVE LEFT MOVE'
    expect(robot.to_s).to eq '3,3,NORTH'
  end
  it 'should handle other scenarios like ignoring commands before a valid place' do
    robot = run_and_return_robot 'MOVE LEFT PLACE 3,-1,EAST MOVE PLACE 1,2,EAST MOVE MOVE LEFT MOVE'
    expect(robot.to_s).to eq '3,3,NORTH'
  end
  it 'should handle other scenarios like ignoring bad moves' do
    robot = run_and_return_robot 'PLACE 1,1,WEST MOVE MOVE'
    expect(robot.to_s).to eq '0,1,WEST'
  end

end

