
require_relative '../lib/common.rb'

# BFS through the maze
def find_path( grid, the_start, the_end )

  queue = []
  queue << [ the_start, {the_start => 1} ]
  all_lengths = []

  while ! queue.empty?

    current, path = queue.shift
    if current == the_end
      all_lengths << path.keys.count
      next
    end

   neighbors = []

   if grid[current] == '>'
     neighbors << Point.new(current.x+1,current.y)
   elsif grid[current] == '<'
     neighbors << Point.new(current.x-1,current.y)
   elsif grid[current] == '^'
     neighbors << Point.new(current.x,current.y-1)
   elsif grid[current] == 'v'
     neighbors << Point.new(current.x,current.y+1)
   else
     { [-1,0]=>['.','<'],[1,0]=>['.','>'],[0,-1]=>['.','^'],[0,1]=>['.','v'] }.each do |k,v| 
       pp = Point.new( current.x+k[0], current.y+k[1])
       neighbors << pp if ! grid[pp].nil? && v.include?(grid[pp])
     end
   end

   neighbors.each do |nn|
     next if grid[nn].nil? || grid[nn] == '#' || path.key?(nn)
     new_path = path.dup
     new_path[nn] = 1
     queue << [nn, new_path ]
   end
  end
  all_lengths.max - 1
end

grid = Grid.new( :io => ARGF )
the_start = Point.new(1,0)
the_end = Point.new(grid.width-2, grid.height-1)

# part 1
#p find_path( grid, the_start, the_end )


# part 2

all_points_to_neighbors = {}

grid.each do |point,value|
  next if value == '#'
  outletcount = point.hvadjacent.count { |adj| %w/. < > ^ v/.include?(grid[adj]) }
  all_points_to_neighbors[point] = outletcount
end

intersections = all_points_to_neighbors.select{ |k,v| v > 2 }.keys

adjacent = Hash.new { |h, k| h[k] = [] }
distances = {}
start_adj = []
intersections.each do |ipoint|

  ipoint.hvadjacent.each do |adj|
    next if grid[adj] == '#'
    path = [ ipoint, adj ]

    while path.last != the_end && path.last != the_start && all_points_to_neighbors[path.last] < 3

      # find the adjacent outlet that isnt where we just came from.  there should
      # only be one - otherwise we would have broken out of this loop
      next_point = path.last.hvadjacent.select {|adj| adj != path[-2] && ! grid[adj].nil? && grid[adj] != '#' }.first
      path << next_point

    end

    adjacent[path.first] << path.last

    # add an adjacency for start
    if path.last == the_start
      start_adj << path.first
    end

    # now create mapping of <start,end> -> distance for all pairs
    distances[[path.first,path.last]] = path.length - 1
    distances[[path.last,path.first]] = path.length - 1
  end
end

# now BFS the graph
queue = []
queue << [ the_start, {the_start => 1} ]
all_paths = []

max_path = 0
while ! queue.empty?

  current, path = queue.pop

  if current == the_end

    # my adjacents have some sort of loop or something that i dont feel like debugging.
    # this BFS never completes ( it does for the test input ) - so i just print out
    # the max observed so far each time there is a new max.  after a while - we get
    # no more new maxes ( even though the loop continues ).  tried that for an answer :shrug:
    max =  path.keys.each_cons(2).reduce(0) { |accum,pair| accum + distances[[pair.first,pair.last]] }
    if max > max_path
      p max
      max_path = max
    end
    all_paths << path.keys
    next
  end

  neighbors = current == the_start ? start_adj : adjacent[current]
  neighbors.each do |nn|
    next if path.key?(nn)
    new_path = path.dup
    new_path[nn] = 1
    queue << [nn, new_path ]
  end
end

# for each path found - sum up the distances.  take the max
p all_paths.map { |path| path.each_cons(2).reduce(0) { |accum,pair| accum + distances[[pair.first,pair.last]] } }.max




