
class Range

  def intersects?(other)

    return ( first > other.first && first <= other.last ) || # left match
           ( last >= other.first && last < other.last ) || # right match
           ( first <= other.first && last >= other.last ) || # inner match
           ( first >= other.first && last <= other.last )  #outer match
  end
end

bricks = []

ARGF.each_line do |line|
  data = line.chomp.scan(/\d+/).map(&:to_i)
  bricks << [ data[0]..data[3], data[1]..data[4], data[2]..data[5]]
end


def drop( bricks )

  # sort bricks by lowest starting z position
  # for each brick - let it fall till it overlaps with a brick that has already fallen.
  # prob could make this a lot faster by not dropping the z one value at a time, and instead
  # immediately dropping it down to the last seen max z
  bricks.sort!{ |a,b| a[2].first <=> b[2].first}

  max_z_seen = 1
  num_dropped = 0
  bricks.each_with_index do |brick,index|

    xr,yr,zr = brick
    z = zr.first
    hit = false

    while z > 0 && ! hit
      dindex = index - 1
      while dindex >= 0
        if bricks[dindex][2].cover?( z-1 ) && ( bricks[dindex][0].intersects?(xr) && bricks[dindex][1].intersects?(yr) )
          hit = true
          break
        end
        dindex -= 1
      end
      z -= 1
    end
    if zr.first != z+1
      bricks[index][2] = ((z+1)..(z+bricks[index][2].size))
      num_dropped += 1
    end
  end
  num_dropped
end


def get_disintegratable( bricks )

  bricks_by_z_start = Hash.new { |h, k| h[k] = [] }
  bricks.each_with_index { |brick,index|  bricks_by_z_start[brick[2].first] << index }

  bricks_by_z_end = Hash.new { |h, k| h[k] = [] }
  bricks.each_with_index { |brick,index| bricks_by_z_end[brick[2].last] << index }

  can_disintegrate = {}
  bricks.each_with_index do |brick,index|

    nextz = brick[2].last+1
    if ! bricks_by_z_start.key?(nextz)
      can_disintegrate[index] = true
      next
    end

    bricks_above, bricks_covered = 0,0
    bricks_by_z_start[nextz].each do |above|
      babove = bricks[above]
      next if ! babove[0].intersects?(brick[0]) && ! babove[1].intersects?(brick[1])
      bricks_above += 1
      bricks_by_z_end[nextz-1].each do |under|
        next if under == index
        bunder = bricks[under]
        if ( bunder[0].intersects?(babove[0]) && bunder[1].intersects?(babove[1]) )
          bricks_covered += 1
          break
        end
      end
    end
    can_disintegrate[index] = true if bricks_above == bricks_covered
  end
  can_disintegrate
end

drop(bricks)
can_disintegrate = get_disintegratable( bricks )
p can_disintegrate.keys.count

# can_disintegrate is a hash keyed by indices into bricks, for bricks that can disentegrate
sum = 0
bricks.each_with_index do |_,index|
  next if can_disintegrate.key?(index)

  # deep copy as bricks is array of array of Range
  copy = Marshal.load(Marshal.dump(bricks))
  copy.delete_at(index)
  dropped = drop( copy )
  sum += dropped
end

p sum

