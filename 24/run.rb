require 'matrix'

points = []
ARGF.each_line do |line|
  points << line.chomp.scan(/-?\d+/).map(&:to_i)
end

xrange = (200000000000000..400000000000000)
yrange = (200000000000000..400000000000000)

overlaps = 0
points.combination(2).each do |a,b| 

  x1,y1,z1,dx1,dy1,dz1 = a
  x3,y3,z3,dx3,dy3,dz3 = b

  x2,y2 = x1+dx1,y1+dy1
  x4,y4 = x3+dx3,y3+dy3

  # https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection

  xint = ((x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4)).to_f
  yint = ((x1*y2-y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4)).to_f

  next if ! xint.finite? || xint.nan? || ! yint.finite? || yint.nan?
  next if ! xrange.cover?(xint) || ! yrange.cover?(yint)

  next if ( xint > x1 && dx1 < 0 ) || ( xint > x3 && dx3 < 0 ) ||
          ( xint < x1 && dx1 > 0 ) || ( xint < x3 && dx3 > 0 ) ||
          ( yint > y1 && dy1 < 0 ) || ( yint > y3 && dy3 < 0 ) ||
          ( yint < y1 && dy1 > 0 ) || ( yint < y3 && dy3 > 0 ) 

  overlaps += 1
end
p overlaps



# matrix solve of simultaneous linear equations, after some internet help to reduce into
# a linear system

# For a rock with X,Y,Z,VX,VY,VZ and hailstone with x,y,z,vx,vy,vz
# At the time t of collision:
#     X + tVX = x + tvx
#  -> (X-x) = (tvx-tVX)
#  -> (X-x) = t(vx-VX)
#  -> (X-x)/(vx-VX) = t
#
#  Same is true for the Y and Z, so at t:
#  (X-x)/(vx-VX) = (Y-y)/(vy-VY) = (Z-z)/(vz-VZ)
#
#  Isolate to just x and y first and get to a multiplication so we can FOIL!
#
#      (X-x)/(vx-VX) = (Y-y)/(vy-VY)
#   -> (X-x)(vy-VY) = (Y-y)(vx-VX )
#   -> Xvy - XVY -xvy + xVY = Yvx - YVX - yvx + yVX
#   -> YVX - XVY = -Xvy + xvy -xVY + Yvx - yvx + yVX
#
#   YVX - XVY is equal for each hailstone - i think because they are the stone's pos + coefficients,
#   thus plug in another hailstone (x',y',z') and form the equality
#
#  -Xvy + xvy - xVY + Yvx - yvx + yVX = -Xvy' + x'vy' - x'VY + Yvx' - y'vx' + y'VX
#
# factor a bit and - linear equation with 4 unknowns: X,Y,VX,VY
# (vy'-vy)X + (vx-vx')Y + (y-y')VX + (x'-x)VY = - xvy + yvx + x'vy' - y'vx'

pairs_needed = 4
lhs = []
rhs = []
points.each_cons(2) do |p1,p2|

  x1,y1,z1,dx1,dy1,dz1 = p1
  x2,y2,z2,dx2,dy2,dz2 = p2

  lhs << [dy2-dy1,dx1-dx2,y1-y2,x2-x1]
  rhs << -x1*dy1 + y1*dx1 + x2*dy2 - y2*dx2

  pairs_needed -= 1
  break if pairs_needed == 0

end


l = Matrix[ *lhs ]
r = Matrix.column_vector( rhs )
inv = l.inverse
res = inv * r

# Matrix returns these as Rationals.
stonex = res.element(0,0).to_i
stoney = res.element(1,0).to_i
stonevx = res.element(2,0).to_i
stonevy = res.element(3,0).to_i

# same as above, this time we are solving for Z
# linear equation with 4 unknowns:
# (vz'-vz)X + (vx-vx')Z + (z-z')VX + (x'-x)VZ = - xvz + zvx + x'vz' - z'vx'
#
# or as we know VX and X from the equations above - turn into
# linear equation with 2 unknowns:
# (vx-vx')Z + (x'-x)VZ = - xvz + zvx + x'vz' - z'vx' - (vz'-vz)X - (z-z')VX

pairs_needed = 2
lhs = []
rhs = []

points.each_cons(2) do |p1,p2| 

  x1,y1,z1,dx1,dy1,dz1 = p1
  x2,y2,z2,dx2,dy2,dz2 = p2

  lhs << [dx1-dx2,x2-x1]
  rhs << -x1*dz1 + z1*dx1 + x2*dz2 - z2*dx2 - (dz2-dz1)*stonex - (z1-z2)*stonevx

  pairs_needed -= 1
  break if pairs_needed == 0
end

l = Matrix[ *lhs ]
r = Matrix.column_vector( rhs )
inv = l.inverse
res = inv * r
stonez = res.element(0,0).to_i

p stonez + stoney + stonex
