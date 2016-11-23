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

  attr_reader :x_delta, :y_delta, :name

  def self.north
    Orientation.new 0, 1, :north
  end

  def self.east
    Orientation.new 1, 0, :east
  end

  def self.south
    Orientation.new 0, -1, :south
  end

  def self.west
    Orientation.new -1, 0, :west
  end

  def self.points_of_compass
    [north, east, south, west]
  end

  def initialize(x_delta, y_delta, name=nil)
    @x_delta, @y_delta, @name = x_delta, y_delta, name
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

  def to_s
    "#{location.x},#{location.y},#{orientation.name.to_s.upcase}"
  end

  def report(out=STDOUT)
    out.puts self.to_s
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

class Command

  attr_reader :name, :args

  def initialize(name, args=[])
    @name, @args = name, args
  end

  def self.parse(commands_string)
    parse_tokenized commands_string.split(' '), []
  end

  def self.parse_and_apply(commands_string, tabletop=TableTop.new)
    parse(commands_string).each do |cmd|
      tabletop = cmd.apply tabletop
    end
    tabletop
  end

  def apply(tabletop)
    if name == :place
      tabletop.place *args
    else
      tabletop.apply name
    end
  end

  private

  def self.parse_tokenized(tokens, commands)
    unless tokens.empty?
      name = tokens.first
      num_tokens_to_consume = 1
      command = Command.new name.downcase.to_sym
      if name == 'PLACE'
        num_tokens_to_consume = 2
        command = create_place_command tokens[1]
      end
      commands << command
      parse_tokenized tokens[num_tokens_to_consume..-1], commands
    end
    commands
  end

  def self.create_place_command(arg_string)
    begin
      tokens = arg_string.split ','
      location = Point.new tokens[0], tokens[1]
      orientation = Orientation.send tokens[2].downcase.to_sym
      Command.new :place, [location, orientation]
    rescue
      raise "Bad place command arguments. Want e.g. '1,1,NORTH'. Got '#{arg_string}'"
    end
  end

end