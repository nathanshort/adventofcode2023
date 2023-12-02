#!/usr/bin/env ruby

data = ARGF.read.split(/\n/)
p1sum = data.reduce(0) { |sum,string| sum + string.scan(/\d/).values_at(0,-1).join.to_i }
p p1sum

words = %w/one two three four five six seven eight nine/ 
p2sum = 0
data.each do |string|
  matches = []
  string.length.times do |t|
    matches << string[t] if ( string[t].ord >= 49 && string[t].ord <=57 )
    words.each_with_index do |w,i|
      matches << (i+1) if string[t..].start_with?(w)
    end
  end
  p2sum += matches.values_at( 0, -1 ).join.to_i
end
p p2sum
