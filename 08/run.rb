
a,b = ARGF.read.split(/\n\n/)
ins = a.chars
map = {}
b.split(/\n/).map do |x|
  parent, l, r = x.scan(/[A-Z]+/)
  map[parent] = {'L'=>l, 'R'=>r}
end

parent = 'AAA'
count = 0
ins.cycle do |i| 
  count += 1
  parent = map[parent][i]
  break if parent == 'ZZZ'
end

p count

pmap = {}
map.keys.select{ |k| k[2] == 'A' }.each do |pp|
  parent = pp
  count = 0
  ins.cycle do |i| 
    count += 1
    parent = map[parent][i]
    if parent[2] == 'Z'
      pmap[pp] = count
      break
    end
  end
end

p pmap.values.reduce(1) { |a,v| a.lcm(v) }

