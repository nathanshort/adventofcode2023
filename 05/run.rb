

# input is array of seed data Ranges, and, the rules.
# seed data example: [ (79..93), (55..68) ]
#
# rules are an array of 2 Ranges like: [98..99, 50..51]
# where the first element is the src range, and, the last element is the dst range
# this was probably overkill - could have just stored it as the dst,start,len - as it was in the input. shrug.
#
# unmapped data, is data that we have yet to map to a destination. thus initial seeds start out as unmapped
# mapped data has been mapped to a destination for a rule.
# after each rule - all data is converted back to unmapped, to try and map against the next rule
#
# instead of passing individual numbers through the network ( input data was billions long ) - I am
# passing ranges, and then splitting the ranges when there is overlap ( partial or full ) - into
# newly mapped range, and, the 'remainder' unmapped - which will get run through any additional rulesets
# for the active rule

def run_network( unmapped, rules )

  mapped = []
  rules.each do |ruleset|
    ruleset.each do |rule|

      # deep copy
      unmapped_c = Marshal.load(Marshal.dump(unmapped))
      unmapped = []

      while unmapped_c.size != 0
        item = unmapped_c.pop
        src_range = rule.first
        dst_range = rule.last

        # full cover - the rule covers the full unmapped range
        if item.begin >= src_range.begin && item.end <= src_range.end
          src_offset = item.begin-src_range.begin
          mapped << ( dst_range.begin+src_offset..dst_range.begin+src_offset+item.size-1 )

        # left partial match - split into unmapped and mapped parts
        elsif src_range.begin <= item.begin && item.begin <= src_range.end && item.end >= src_range.end
          src_offset = item.begin-src_range.begin
          covered_size = src_range.end-item.begin
          mapped << ( dst_range.begin+src_offset..dst_range.begin+src_offset+covered_size)
          unmapped << ( src_range.end+1..item.end )

        # right partial match - split
        elsif item.begin <= src_range.begin && item.end >= src_range.begin && item.end <= src_range.end
          covered_size = item.end-src_range.begin
          unmapped << (item.begin..src_range.begin-1)
          mapped << (dst_range.begin..dst_range.begin+covered_size)

        # inner match - split into inner mapped part, and, left and right unmapped parts
        elsif src_range.begin >= item.begin && src_range.end <= item.end
          src_offset=src_range.begin-item.begin
          covered_size = src_range.size
          unmapped << (item.begin..src_range.begin-1)
          mapped << (dst_range.begin..dst_range.begin+covered_size)
          unmapped << (src_range.end+1..item.end)

        #none
        else
          unmapped << item
        end
      end
    end
    unmapped = mapped | unmapped
    mapped = []
  end
  (mapped | unmapped).map{ |x| x.begin }.min
end


data = ARGF.read.split(/\n\n/)

seeds = data[0].scan(/\d+/).map(&:to_i)
rules = []
data[1..].each do |lines|
  rule = []
  lines.split(/\n/)[1..].each do |line|
    dst, source, len = line.scan(/\d+/).map(&:to_i)
    rule << [(source..source+len-1), (dst..dst+len-1) ]
  end
  rules << rule
end

# part 1
input_ranges = seeds.each_slice(1).map{ |s| ( s.first..s.first ) }
p run_network( input_ranges, rules)

# part 2
input_ranges = seeds.each_slice(2).map{ |s| ( s.first..s.first+s.last ) }
p run_network( input_ranges, rules)
