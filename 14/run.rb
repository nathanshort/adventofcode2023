
require_relative '../lib/common.rb'

ROCK = 'O'.freeze
EMPTY = '.'.freeze


def load( grid )
  load = 0
  grid.each do |point,val|
    load += grid.height - point.y if val == ROCK
  end
  load
end


def north( point, grid )
  newx,newy = point.x,point.y
  (point.y-1).downto(0) do |nexty|
    existing = grid[Point.new(point.x,nexty)]
    break if existing != EMPTY
    newy = nexty
  end
  return Point.new(newx,newy)
end

def south( point, grid )
  newx,newy = point.x,point.y
  (point.y+1).upto(grid.height-1) do |nexty|
    existing = grid[Point.new(point.x,nexty)]
    break if existing != EMPTY
    newy = nexty
  end
  return Point.new(newx,newy)
end

def east( point, grid )
  newx,newy = point.x,point.y
  (point.x+1).upto(grid.width-1) do |nextx|
    existing = grid[Point.new(nextx,point.y)]
    break if existing != EMPTY
    newx = nextx
  end
  return Point.new(newx,newy)
end

def west( point, grid )
  newx,newy = point.x,point.y
  (point.x-1).downto(0) do |nextx|
    existing = grid[Point.new(nextx,point.y)]
    break if existing != EMPTY
    newx = nextx
  end
  return Point.new(newx,newy)
end


def move2( grid, which )

  moves = { :north => [:each,->(p,g){return north(p,g)}],
            :west => [:each,->(p,g){return west(p,g)}],
            :south => [:sneach,->(p,g){return south(p,g)}],
            :east => [:eweach,->(p,g){return east(p,g)}] }

  which.each do |w|
    grid.send(moves[w].first) do |point,val|
      next if val != ROCK
      newp = moves[w].last.call(point,grid)
      if newp != point
        grid[newp] = ROCK
        grid[point] = EMPTY
      end
    end
  end
end


grid = Grid.new( :io => ARGF.read.chomp )

# part 1
p1grid = grid.clone
move2( p1grid, [ :north ] )
p load( p1grid )


# part 2
seen = {}
counter = 0
cycle_start, cycle_length = nil,nil

loop do

  counter += 1
  move2( grid, [:north,:west,:south,:east] )

  if seen.key?(grid.hash)
    cycle_start = seen[grid.hash]
    cycle_length = counter - seen[grid.hash]
    break
  end
  seen[grid.hash] = counter
end

( ( 1_000_000_000 - cycle_start ) % cycle_length).times do
  move2(grid,[:north,:west,:south,:east] )
end

p load(grid)
