
mc = []
ARGF.each_line do |line|
  data = line.split(/:/).last.split(/\|/)
  mc << ( data.first.split & data.last.split ).count
end

p mc.map{ |x| x > 0 ? 2**(x-1) : 0 }.reduce( &:+ )

cards = Array.new( mc.length, 1)
cards.count.times do |ci|
  mc[ci].times do |mi| 
    cards[ci].times do |oi|
      ii = ci+mi+1
      break if ii == mc.count
      cards[ii] += 1
    end
  end
end

p cards.reduce(&:+)
