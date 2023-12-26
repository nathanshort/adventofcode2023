
class FlipFlop

  def initialize(name,targets)
    @targets = targets
    @state = :off
    @name = name
  end

  def reset
    @state = :off
  end

  def pulse( signal,from )

    to_emit = nil
    if signal != :high
      if @state == :off
        @state = :on
        to_emit = :high
      else
        @state = :off
        to_emit = :low
      end
    end

    [ to_emit, @targets, @name ]
  end
end


class Broadcaster

  def initialize(name,targets)
    @targets = targets
    @name = name
  end

  def reset
  end

  def pulse( signal,from )
    [ signal, @targets, @name ]
  end
end


class Conjunction

  def initialize(name,targets)
    @targets = targets
    @name = name
    @input_count = 0
    @lasts = {}
  end

  def reset
    @lasts = {}
  end

  def pulse( signal, from )
    @lasts[from] = signal
    to_emit = @lasts.values.count{ |v| v == :high } == @input_count ? :low : :high
    [ to_emit, @targets, @name ]
  end

  def add_inputs(from)
    @input_count = from.count
  end
end


circuit = {}
fedby = Hash.new { |h, k| h[k] = [] }

ARGF.each_line do |line|
  data = line.scan(/\w+/)
  name = data[0]
  targets = data[1..]
  type = line[0]
  if type == 'b'
    circuit['broadcaster'] = Broadcaster.new(name, targets)
  elsif type == '%'
    circuit[name] = FlipFlop.new(name, targets)
  elsif type == '&'
    circuit[name] = Conjunction.new(name, targets)
  end

  # need this to tell conjunctions how many inputs
  # they have in the circuit
  targets.each { |t| fedby[t] << name }
end

fedby.each do |k,v|
  if circuit[k].is_a?(Conjunction)
    circuit[k].add_inputs(v)
  end
end

# next_pulses is array of
# [signal(possibly nil),[targets],from]
next_pulses = []
total_emitted = {:low=>0,:high=>0}


1000.times do

  next_pulses << circuit['broadcaster'].pulse(:low,:button)
  total_emitted[:low] += 1

  while ! next_pulses.empty?
    signal,targets,from = next_pulses.shift
    next if signal.nil?
    total_emitted[signal] += targets.count
    targets.each do |t|
      next if ! circuit.key?(t)
      next_pulses << circuit[t].pulse(signal,from)
    end
  end
end

p total_emitted.values.reduce(1){ |a,v| a*v }


# part 2
# &dr feeds rx
# &mp, &qt, &qb, &ng feeds dr
# want high out of all 4 of the above, so that &dr feeds rx with a low

circuit.each { |k,v| v.reset }

next_pulses = []
loop_counter = 0
mins = {}

loop do

  next_pulses << circuit['broadcaster'].pulse(:low,:button)
  loop_counter += 1

  while ! next_pulses.empty?
    signal,targets,from = next_pulses.shift
    next if signal.nil?
    targets.each do |t|
      next if ! circuit.key?(t)
      if signal == :high && ['mp','qt','qb','ng'].include?(from) && ! mins.key?(from)
        mins[from] = loop_counter
      end
      next_pulses << circuit[t].pulse(signal,from)
    end
  end
  break if mins.keys.count == 4
end

p mins.values.reduce(1) { |a,v| a.lcm(v) }
