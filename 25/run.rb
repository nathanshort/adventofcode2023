

class Edge

  attr_accessor :src, :dst, :osrc, :odst
  def initialize(src,dst)
    @src,@dst = src,dst
    @osrc,@odst = src,dst
  end

  def ==(other)
    ( other.src == @src && other.dst == @dst ) ||
      ( other.dst == @src && other.src == @dst )
  end
end

class Graph

  attr_accessor :vertices
  attr_reader :edges

  def initialize
    @edges = []
    @vertices = {}
  end

  def add_edge(e)
    @edges << e
    @vertices[e.src] ||= []
    @vertices[e.src] << e.dst
    @vertices[e.dst] ||= []
    @vertices[e.dst] << e.src
  end

  # https://en.wikipedia.org/wiki/Karger%27s_algorithm
  def contract( edge )
    vtk = edge.src
    vtd = edge.dst

    @edges.delete(edge)
    @vertices[vtd].each do |v|
      @vertices[vtk] << v if v != vtk && @vertices[vtk].index(v).nil?
      @vertices[v] << vtk if v != vtk && @vertices[v].index(vtk).nil?
      @vertices[v].delete(vtd)
    end
    @vertices.delete(vtd)

    # very inefficient. I should have stored edges tied to the vertices
    @edges.each do |e|
      e.src = vtk if e.src == vtd && e.dst != vtk
      e.dst = vtk if e.dst == vtd && e.src != vtk
    end
  end

end


graph = Graph.new

ARGF.each_line do |line|
  data = line.scan(/\w+/)
  from = data[0]
  data[1..].each do |to|
    graph.add_edge( Edge.new( from, to ) )
  end
end

pairs_to_cut = []
loop do

  graphc = Marshal.load(Marshal.dump(graph))

  while graphc.vertices.keys.count > 2
    etr = graphc.edges[rand(graphc.edges.length)]
    graphc.contract( etr )
  end

  p graphc.edges.count
  if graphc.edges.count == 3
    graphc.edges.each { |x| pairs_to_cut << [x.osrc,x.odst] }
    break
  end
end

# cut the pairs from the graph
pairs_to_cut.each { |a,b| graph.vertices[a].delete(b) && graph.vertices[b].delete(a)}

# now bfs from each vertex until we find 2 different depths
depths_found = {}
graph.vertices.each do |startv,_|

  queue = [[startv, {startv=>1}]]
  max_len = 0
  while ! queue.empty?
    nextp, visited = queue.pop
    visited[nextp] = true
    max_len = [visited.keys.length,max_len].max
    graph.vertices[nextp].each do |neighbor|
      queue << [neighbor,visited] if ! visited.key?(neighbor)
    end
  end

  depths_found[max_len] = 1
  break if depths_found.keys.size == 2
end

p depths_found.keys.reduce(1) { |accum,v| accum*v }
