class Point

  attr_reader :x, :y

  def initialize(x, y)
    @x = Integer x
    @y = Integer y
  end

  def to_a
    [@x,@y]
  end

end

class Orientation

  def self.north
    @north ||= Orientation.new 0, 1
  end

  def self.east
    @east ||= Orientation.new 1, 0
  end

  def self.south
    @south ||= Orientation.new 0, -1
  end

  def self.west
    @west ||= Orientation.new -1, 0
  end

  def initialize(x_delta, y_delta)
    @x_delta, @y_delta = x_delta, y_delta
  end

  def move(point)
    Point.new point.x + @x_delta, point.y + @y_delta
  end

end

