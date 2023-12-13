
$cache = {}

def solve( pattern, splits, num_matched = 0 )

  # if there is nothing left to consume 
  #   if no splits left and num_matched == 0 - means we ended with (one or more ) . - and matched all
  #   if num_matched is equal to the last split - we ended on a match
  #   else no match
  if pattern.nil? || pattern.empty? 
    if num_matched == 0
      return 1 if ( splits.nil? || splits.empty? )
    end
    if num_matched != 0 && ! splits.nil? && splits.length == 1 && num_matched == splits.first
      return 1
    end
    return 0
  end

  # no more possible solutions - bail early
  return 0 if splits.sum-num_matched > pattern.length

  cache_key = pattern.hash + splits.hash + ['|',num_matched].hash
  return $cache[cache_key] if $cache.key?(cache_key)

  ways = 0
  options = pattern[0] == '?' ? ['#','.'] : [ pattern[0] ]

  options.each do |option|
    if option == "#"
      ways += solve( pattern[1..], splits, num_matched+1 )
    else
      if num_matched != 0
        if ! splits.empty? && splits[0] == num_matched
          ways += solve( pattern[1..], splits[1..] )
        end
      else
        ways += solve( pattern[1..], splits )
      end
    end
  end

  $cache[cache_key] = ways
  return ways
end


p1sum, p2sum = 0,0
ARGF.each_line do |line|
  p,s = line.split(/ /)
  splits = s.split(/,/).map(&:to_i)

  p1sum += solve( p.chars, splits )
  p2sum += solve( 5.times.map{p}.join('?').chars, 5.times.map{splits}.flatten)
end

p p1sum, p2sum
