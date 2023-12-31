
require_relative '../lib/common.rb'

def find_plots( start, grid, max_steps )

  queue = [[start,0]]
  visited = {}
  terminals = []

  while ! queue.empty?

    val = queue.pop
    next if visited.key?(val)
    visited[val] = true
    pos,steps = val

    terminals << pos if steps == max_steps
    next if steps == max_steps

    pos.hvadjacent.each do |adj|
      next if visited.key?([adj,steps+1]) || grid[adj].nil? || ! ['S','.'].include?(grid[adj])
      queue << [adj,steps+1]
    end
  end

  terminals.count
end

# quadratic interpolation via Lagrange
# https://users.rowan.edu/~hassen/NumerAnalysis/Interpolation_and_Approximation.pdf
def lagrange( xs, ys, x )

  x0,x1,x2 = xs
  y0,y1,y2 = ys

  l0 = ((x-x1)*(x-x2))/((x0-x1)*(x0-x2))
  l1 = ((x-x0)*(x-x2))/((x1-x0)*(x1-x2))
  l2 = ((x-x0)*(x-x1))/((x2-x0)*(x2-x1))

  y0*l0 + y1*l1 + y2*l2
end


grid = RepeatingGrid.new( :io => ARGF )
width = grid.width
start = grid.each.select { |p,v| v == 'S' }.first.first

# as there is a straight left/right, top/bottom, path from origin to edge,
# find 3 data points:
#  plots reached in starting grid
#  plots reached in starting grid + surrounded by another set of grids
#  plots reached in starting grid + surrounded by 2 sets of grids
#
# then use those 3 points to interpolate a polynomial to goal surrounding grids
xs = [ width/2,width/2+width,width/2+width*2]
ys = xs.map { |steps| p steps; find_plots( start, grid, steps ) }
target = 26_501_365
p lagrange( xs, ys, target )

