
def do_count( ins, map, parent, end_with )
  count = 0
  ins.cycle do |i| 
    count += 1
    parent = map[parent][i]
    return count if parent.end_with?( end_with )
  end
end

a,b = ARGF.read.split(/\n\n/)
ins = a.chars
map = {}
b.split(/\n/).map do |x|
  parent, l, r = x.scan(/[A-Z]+/)
  map[parent] = {'L'=>l, 'R'=>r}
end
p do_count( ins, map, 'AAA', 'ZZZ')

counts =  map.keys.select{ |k| k[2] == 'A' }.map { |pp| do_count( ins, map, pp, 'Z') }
p counts.reduce(1) { |a,v| a.lcm(v) }

