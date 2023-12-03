require_relative '../lib/common.rb'

class String
  def is_digit?
    self.ord >= 48 && self.ord <=57
  end
end

g = Grid.new( :io => ARGF.read.chomp )

current_row, seen_symbol = nil, nil
current_part_number, part_number_sum = 0, 0

g.each do | point, value |

  # at a new row.  add current part number from prev row if it was adjacent to a symbol
  if point.y != current_row
    part_number_sum += current_part_number if seen_symbol
    current_part_number, seen_symbol = 0, nil
    current_row = point.y
  end

  if value.is_digit?
    current_part_number = current_part_number == 0 ? value.to_i : current_part_number * 10 + value.to_i

    if ! seen_symbol
      point.adjacent.each do |adj|
        adj_value = g[adj]
        seen_symbol = ! adj_value.nil? && adj_value != '.' && ! adj_value.is_digit?
        break if seen_symbol
      end
    end

  # at a non number.  add previously seen part number if it was adjacent to a symbol
  else
    part_number_sum += current_part_number if seen_symbol
    seen_symbol = false
    current_part_number = 0
  end
end

# incase last value of last row was a valid number
part_number_sum += current_part_number if seen_symbol
p part_number_sum



gear_ratio = 0
g.each do | point, value |

  if value == '*'
    adj_parts = []
    prev_adj_number = false

    point.adjacent.each do |adj|
      adj_value = g[adj]

      if ! prev_adj_number && ! adj_value.nil? && adj_value.is_digit?
        prev_adj_number = true
        part_number = adj_value

        # walk the digit to the left 
        x = adj.x
        loop do
          x-=1
          pp = g[Point.new(x,adj.y)]
          break if pp.nil? || ! pp.is_digit?
          part_number.prepend(pp)
        end

        # walk the digit to the right
        x = adj.x
        loop do
          x+=1
          pp = g[Point.new(x,adj.y)]
          break if pp.nil? || ! pp.is_digit?
          part_number.concat(pp)
        end

        adj_parts << part_number.to_i
      end

      prev_adj_number = false if ! adj_value.nil? && ! adj_value.is_digit?
    end

    gear_ratio += adj_parts.reduce(&:*) if adj_parts.count == 2
  end
end

p gear_ratio






















