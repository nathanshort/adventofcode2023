
require_relative '../lib/common.rb'

grid = Grid.new( :io => ARGF.read.chomp )
start = grid.select { |p,v| v == 'S'}.first.first

turns = {'N|'=>:none,'N7'=>'W','NF'=>'E','E-'=>:none,'E7'=>'S','EJ'=>'N',
         'S|'=>:none,'SL'=>'E','SJ'=>'W','W-'=>:none,'WL'=>'N','WF'=>'S' }

# visually determine starting heading of the cursor from the input file
cursor = Cursor.new(:heading => 'W',:x=>start.x,:y=>start.y,:ygrows => :south )

path = {}
moves = 0
loop do
  path[cursor.location.dup] = true
  turn = turns[cursor.heading + grid[cursor.next_forward(:by=>1)]]
  cursor.forward(:by=>1)
  moves += 1
  cursor.heading = turn if turn != :none
  break if cursor.location == start
end
p moves/2

# now raytrace a horizontal from each point not in the path, to see how many times it
# intersects the polygon.  If the ray overlaps a horizontal edge, determine
# if the edge verticals coming into the edge and leaving the edge are the
# same direction.  If they are not, then that is an additional intersection.
#
# this could probably use some caching - to not try every point multiple times

# map of vertical coming into a horizontal back to vertical in the same direction
start_pipe_to_end_pipe = { 'F'=>'7','L' =>'J' }

pip = 0
grid.each do |p,v|
  next if path.key?(p)
  x = p.x
  intersections = 0
  loop do
    x+=1
    newp = Point.new(x,p.y)
    break if grid[newp].nil?

    # this is a horizontal edge.  now walk it until it
    # becomes vertical again
    if start_pipe_to_end_pipe.keys.include?(grid[newp]) && path.key?(newp)
      edge_start_pipe = grid[newp]
      loop do
        x+=1
        newp = Point.new(newp.x+1,p.y)
        break if start_pipe_to_end_pipe.values.include?(grid[newp])
      end
      intersections += 1 if start_pipe_to_end_pipe[edge_start_pipe] != grid[newp]
    else
      intersections += 1 if path.key?(newp)
    end
  end
    pip += 1 if intersections.odd?
end
p pip


