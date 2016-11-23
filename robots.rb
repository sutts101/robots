class Point

  attr_reader :x, :y

  def initialize(x, y)
    @x = Integer x
    @y = Integer y
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def to_a
    [@x,@y]
  end

end

class Orientation

  attr_reader :x_delta, :y_delta

  def self.north
    Orientation.new 0, 1
  end

  def self.east
    Orientation.new 1, 0
  end

  def self.south
    Orientation.new 0, -1
  end

  def self.west
    Orientation.new -1, 0
  end

  def self.points_of_compass
    [north, east, south, west]
  end

  def initialize(x_delta, y_delta)
    @x_delta, @y_delta = x_delta, y_delta
  end

  def ==(other)
    x_delta == other.x_delta and y_delta == other.y_delta
  end

  def to_a
    [@x_delta, @y_delta]
  end

  def move(point)
    Point.new point.x + @x_delta, point.y + @y_delta
  end

  def right
    rotate 1
  end

  def left
    rotate -1
  end

  private

  def rotate(increment)
    compass = self.class.points_of_compass
    index = compass.index { |o| o.x_delta == @x_delta && o.y_delta == @y_delta }
    raise 'Sorry, Orientation.right / Orientation.left only works for predefined orientations' unless index
    compass[ (index + increment) % compass.count ]
  end

end

class Robot

  attr_reader :location, :orientation

  def initialize(location, orientation)
    @location, @orientation = location, orientation
  end

  def move
    Robot.new orientation.move(location), orientation
  end

  def left
    Robot.new location, orientation.left
  end

  def right
    Robot.new location, orientation.right
  end

end

class TableTop

  attr_reader :width, :height, :robot

  def initialize(width=5, height=5, robot=nil)
    @width, @height, @robot = width, height, robot
  end

  def contains?(point)
    (0...@width).include?(point.x) && (0...@height).include?(point.y)
  end

  def valid?
    @robot.nil? || contains?(@robot.location)
  end

  def place(point, orientation)
    result = TableTop.new width, height, Robot.new(point, orientation)
    result.valid? ? result : self
  end

  def apply(op_name)
    if @robot
      result = TableTop.new width, height, @robot.send(op_name)
      result.valid? ? result : self
    else
      self
    end
  end

end
