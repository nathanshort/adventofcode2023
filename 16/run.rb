
require_relative '../lib/common.rb'


def traverse( start, grid )

  egrid = grid.clone
  cursors = [start]
  splits_seen = {}

  while cursors.length != 0

    new_cursors = []
    cursors.each do |c|

      spot = grid[c.location]
      if spot == '.'
        egrid[c.location] = '#'
        c.forward(:by=>1)
        new_cursors << c
      elsif ( spot == '|' && ['N','S'].include?(c.heading) )
        egrid[c.location] = '#'
        c.forward(:by=>1)
        new_cursors << c
      elsif spot == '|' && ! splits_seen.key?(c.location)
        splits_seen[c.location] = true
        egrid[c.location] = '#'
        new_cursors <<
          Cursor.new( :heading=>'N',:x=>c.location.x,:y=>c.location.y-1,:ygrows=>:south)
        new_cursors <<
          Cursor.new( :heading=>'S',:x=>c.location.x,:y=>c.location.y+1,:ygrows=>:south)
      elsif ( spot == '-' && ['E','W'].include?(c.heading) )
        egrid[c.location] = '#'
        c.forward(:by=>1)
        new_cursors << c
      elsif spot == '-' && ! splits_seen.key?(c.location)
        splits_seen[c.location] = true
        egrid[c.location] = '#'
        new_cursors <<
          Cursor.new( :heading=>'W',:x=>c.location.x-1,:y=>c.location.y,:ygrows=>:south)
        new_cursors <<
          Cursor.new( :heading=>'E',:x=>c.location.x+1,:y=>c.location.y,:ygrows=>:south)
      elsif spot == '/'
        egrid[c.location] = '#'
        c.heading = {'E'=>'N','W'=>'S','N'=>'E','S'=>'W'}[c.heading]
        c.forward(:by=>1)
        new_cursors << c
      elsif spot == '\\'
        egrid[c.location] = '#'
        c.heading = {'E'=>'S','W'=>'N','N'=>'W','S'=>'E'}[c.heading]
        c.forward(:by=>1)
        new_cursors << c
      end
    end
    cursors = new_cursors
  end

  count = 0
  egrid.each do |point,v|
    count += 1 if v == '#'
  end

  count
end


grid = Grid.new( :io => ARGF.read.chomp )

# part 1
p traverse( Cursor.new(:heading=>'E',:x=>0,:y=>0,:ygrows=>:south), grid )

# part 2

starting_cursors = []
(0..grid.width-1).each { |x|  starting_cursors << Cursor.new( :heading=>'S',:x=>x,:y=>0,:ygrows=>:south) }
(0..grid.width-1).each { |x|  starting_cursors << Cursor.new( :heading=>'N',:x=>x,:y=>grid.width-1,:ygrows=>:south) }
(0..grid.height-1).each { |y|  starting_cursors << Cursor.new( :heading=>'E',:x=>0,:y=>y,:ygrows=>:south) }
(0..grid.height-1).each { |y|  starting_cursors << Cursor.new( :heading=>'W',:x=>grid.width-1,:y=>y,:ygrows=>:south) }

p starting_cursors.map{ |c| traverse( c, grid ) }.max
