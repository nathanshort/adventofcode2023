
sump1, sump2 = 0,0

ARGF.each_line do |line|

  firsts = []
  items = line.split.map( &:to_i )

  loop do
    sump1 += items.last
    firsts << items.first
    break if items.count{ |x| x==0 } == items.count
    items = items.each_cons(2).map{|a,b| b-a }
  end

  sump2 += firsts.reverse[1..].reduce(0) { |accum,val| val-accum }
end

p sump1
p sump2
