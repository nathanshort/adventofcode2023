

def findit2( values, exclude  )

  found = nil

  values.each_cons(2).with_index do |pairs,i|

    next if i == exclude

    used_smudge = false

    possible = false
    if pairs.first == pairs.last
      possible = true
    elsif pairs.first.zip(pairs.last).count {|a| a.first == a.last } == pairs.first.length-1
      possible = true
      used_smudge = true
    end

    next  if !possible
      off = 1
      loop do
        if (i-off) < 0 || (i+off+1) >= values.length
          found = i
          break
        end
        if values[i-off] == values[i+off+1]
          off+=1
          next
        end

        if used_smudge == false && (values[i-off].zip(values[i+off+1]).count {|a| a.first == a.last } == values[i-off].length-1)
          used_smudge = true
        else
          break
        end

        off+= 1
      end
      break if found
  end

  found
end


def findit( values )

  found = nil
  values.each_cons(2).with_index do |pairs,i|

    if pairs.first == pairs.last
      off = 1
      loop do
        if (i-off) < 0 || (i+off+1) >= values.length
          found = i
          break
        end
        break if values[i-off] != values[i+off+1]
        off+= 1
      end
    end

    break if found
  end
  found
end


p1score, p2score = 0,0

ARGF.read.split(/\n\n/).each do |g|

  xa, ya = [],[]
  yi = 0

  g.split(/\n/).each do |line|
    xa << line.chars
    line.chars.each_with_index do |xx,i| 
      ya[i] ||= []
      ya[i] << xx
    end
  end

  xr = findit( xa )
  p1score += (xr+1)*100 if !xr.nil?
  xrr = findit2( xa, xr)
  p2score+= (xrr+1)*100 if !xrr.nil?

  yr = findit( ya )
  p1score += (yr+1) if !yr.nil?
  yrr = findit2( ya, yr )
  p2score += (yrr+1) if !yrr.nil?

end

p p1score
p p2score
