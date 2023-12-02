#!/usr/bin/env ruby

# Games is hash keyed by id, with value of type array with 1 array element per handful
# ex: "5"=>[{"red"=>6, "blue"=>1, "green"=>3}, {"blue"=>2, "red"=>1, "green"=>2}]

games = Hash.new { |h, k| h[k] = [] }
data = ARGF.each_line do |line|
  id = line.match(/Game (\d+):/)[1]
  line.split(/;/).each do |handful| 
    rr = {}
    handful.scan(/\d+ \w+/).each do |draw|
      count,color = draw.split(/ /)
      rr[color] = count.to_i
    end
    games[id] << rr
  end
end

sum, power = 0,0
colors = {'red' => 12, 'green' => 13, 'blue' => 14 }
games.each do |id,handfulls|
  valid = true
  handfulls.each do |draw| 
    colors.each do |color,count| 
      valid = false if( draw.key?(color) && draw[color] > count )
    end
  end

  sum += id.to_i if valid 
  power += colors.keys.map{ |color| handfulls.map { |h| h[color] }.compact.max }.reduce( &:* )
end

p sum, power
