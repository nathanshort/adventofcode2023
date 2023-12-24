require_relative '../lib/common'
require_relative '../lib/pqueue'

def find_path( grid, minstep, maxstep )

  visited, distances, prev = {},{},{}
  pq = PQueue.new {|x,y| distances[y] <=> distances[x] }

  # a node is defied as [x,y,dir,steps]
  origins = [[0,0,'E',1],[0,0,'S',1]]
  origins.each do |oo| 
    pq.push(oo)
    visited[oo] = true
    distances[oo] = 0
  end

  while ! pq.empty?

    current = pq.pop
    visited[current] = true
    x,y,dir,steps = current

    neighbors = []

    if steps < maxstep
      c = Cursor.new(x:x,y:y,heading:dir,:ygrows=>:south)
      c.forward(by:1)
      neighbors << [c.location.x,c.location.y,c.heading,steps+1]
    end

    if steps >= minstep
      ['L','R'].each do |turn| 
        c = Cursor.new(x:x,y:y,heading:dir,:ygrows=>:south)
        c.turn(direction:turn)
        c.forward(by:1)
      neighbors << [c.location.x,c.location.y,c.heading,1]
      end
    end

    neighbors.each do |nn| 

      nnx,nny,nndir,nnsteps = nn
      nnpoint = Point.new(nnx,nny)
      next if ! grid[nnpoint] || visited.key?(nn)

      distance = grid[nnpoint] + distances[current]
      if ! distances.key?(nn) || distances[nn] > distance
        distances[nn] = distance
        prev[nn] = current
        pq.push(nn)
      end
    end
  end

  possible = []
  yy = distances.map do |d,v| 
    x,y,dir,steps = d
    possible << v if x == grid.width-1 && y == grid.height-1
  end

  possible.min
end


grid = Grid.new( :io => ARGF ) { |x,y,c| [x,y,c.to_i] }
p find_path( grid, 1, 3 )
p find_path( grid, 4, 10 )
