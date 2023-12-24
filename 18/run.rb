require 'matrix'

def area( ins )

  vertices = [[0,0]]
  x,y = 0,0
  num_boundary_points = 0

  ins.each do |ii|
    dir,count = ii
    num_boundary_points += count
    x+= count if dir == 'R'
    x-= count if dir == 'L'
    y-= count if dir == 'U'
    y+=count  if dir == 'D'
    vertices << [x,y]
  end

  # from shoelace
  # sum up determinants of each 2 consecutive.  then do the determinant of the
  # vertices[] as the origin as the first and last element - which allows us to just cons(2) it
  dsum = vertices.each_cons(2).reduce(0) { |a,p| a + Matrix[[p[0][0],p[1][0]],[p[0][1],p[1][1]]].determinant }
  area = (dsum.to_f/2).abs.to_i

  # from picks
  interior_points = area - num_boundary_points / 2 + 1
  interior_points + num_boundary_points
end

p1ins, p2ins = [],[]

ARGF.each_line do |line|
  vals = line.chomp.split(/ /)
  p1ins << [vals[0],vals[1].to_i]

  ashex = vals[2].scan(/[a-f0-9]+/).first
  p2count = ashex[0..ashex.length-2].to_i(16)
  p2ins << [['R','D','L','U'][ashex[-1].to_i], p2count ]
end

p area( p1ins )
p area( p2ins )


