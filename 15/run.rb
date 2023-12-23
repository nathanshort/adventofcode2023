
def hash( s )
  hash = 0
  s.each do |c|
    hash += c.ord
    hash *= 17
    hash %= 256
  end
  hash
end

data = ARGF.read.chomp

# part 1
p data.split(/,/).reduce(0){ |a,v| a+hash(v.chars) }

# part 2
boxes = Array.new( 256 ){Array.new}

data.split(/,/).each do |d|

  label = d.scan(/[a-z]+/).first
  hash = hash(label.chars)
  chars = d.chars
  op = chars[label.length]
  exists_index = boxes[hash].index{ |x| x.first == label }

  case op
  when '-'
    boxes[hash].delete_at(exists_index) if ! exists_index.nil?
  when '='
    flength = chars[label.length+1..].join.to_i
    value = [label,flength]
    boxes[hash] << value if exists_index.nil?
    boxes[hash][exists_index] = value if ! exists_index.nil?
  end
end

power = 0
boxes.each_with_index do |box,bindex|
  box.each_with_index do |lens,lindex|
    power += ( 1+bindex ) * ( (lindex+1)*lens.last )
  end
end

p power
