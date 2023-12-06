

def play( times, distances)

  product = 1
  times.each_with_index do |time,i|
    beat = 0
    time.times do |tt|
      held = tt+1
      distance = ( (time-tt-1) * held )
      beat += 1 if distance > distances[i]
    end
    product *= beat
  end
  product
end

tt = ARGF.readline.scan(/\d+/).map(&:to_i)
dd = ARGF.readline.scan(/\d+/).map(&:to_i)

p play( tt, dd )
p play( [ tt.join.to_i ], [ dd.join.to_i ] )
