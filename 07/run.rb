
# tally is a hash of cards grouped by count
# ex: {10=>1, 5=>3, 11=>1}
def do_rank( tally )

  if tally.count == 1
    6
  elsif tally.count == 2 && tally.count{ |k,v| v == 4 } == 1
    5
  elsif tally.count == 2
    4
  elsif tally.count == 3 && tally.count{ |k,v| v == 3 } == 1
    3
  elsif tally.count == 3
    2
  elsif tally.count == 4
    1
  else
    0
  end
end


def score( hands, with_jokers )

  sorted = hands.sort { |a,b|
    by_rank = b[:rank]<=>a[:rank]
    next by_rank if by_rank != 0

    if with_jokers
      b[:cards].map{ |x| x == 11 ? -1 : x } <=> a[:cards].map{ |x| x == 11 ? -1 : x }
    else
      b[:cards]<=>a[:cards]
    end
  }
  sorted.each_with_index.map { |v,i| (sorted.length-i)*v[:bid] }.sum
end

# turn face into numbers for easier comparison
card_map = {}
%w/A K Q J T/.zip( 14.downto(10).to_a ) { |a| card_map[a[0]] = a[1] }

hands = []
ARGF.each_line do |line|
  c, bid = line.split(/\s/)
  cards = c.each_char.map{ |cc| card_map[cc] || cc.to_i}
  rank = do_rank( cards.group_by{|v| v }.to_h {|k,vs| [ k,vs.count] } )
  hands << {:cards => cards, :rank => rank, :bid => bid.to_i }
end

p score( hands, with_jokers=false )

p2hands = []
hands.each do |hand|
  tally = hand[:cards].group_by{|v| v }.to_h {|k,vs| [ k,vs.count] }
  jokers = tally[card_map['J']] || 0
  if jokers != 0 && jokers != 5
    tally.delete(card_map['J'])
    best = tally.sort_by { |k,v| v }.reverse[0][0]
    tally[best] += jokers
  end
  rank = do_rank( tally )
  p2hands << {:cards => hand[:cards], :rank => rank, :bid => hand[:bid] }
end

p score( p2hands, with_jokers=true )

