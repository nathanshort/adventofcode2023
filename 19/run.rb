
w,r= ARGF.read.split(/\n\n/)
all_workflows = {}

w.split(/\n/).each do |ww|
  m = ww.match(/(?<name>\w+){(?<rules>.*)}/)
  name = m['name']
  rules = m['rules'].split(/,/)

  workflows = []
  rules.each do |rule|
    rr = rule.split(/:/)
    if rr.length == 1
      workflows << ->(rating){ rr.first }
    else
      a = rr.first.scan(/\w+/).first
      b = rr.first.scan(/[^\w\d]/).first
      c = rr.first.scan(/\d+/).first.to_i
      d = rr.last
      workflows << ->(rating){ rating[a].send(b,c) ? d : false; }
    end
  end
  all_workflows[name] = workflows
end

ratings = []
r.split(/\n/).each do |rs|
  rating = {}
  rs.gsub(/[{}]/,'').split(/,/).each do |pair|
    k,v = pair.split(/=/)
    rating[k] = v.to_i
  end
  ratings << rating
end

accepts, rejects = [],[]
ratings.each do |rating|
  wfn = 'in'
  done = false

  while ! done
    all_workflows[wfn].each do |wf|
      res = wf.call(rating)
      next if res == false
      if res == 'A'
        accepts << rating
        done = true
        break
      elsif res == 'R'
        done = true
        rejects << rating
        break
      else
        wfn = res
        break
      end
    end
  end
end

p accepts.reduce(0) { |accum,a| accum+a.values.sum }



#
# arg...rewrite for part 2

def split_range( r, point )
  low, high = nil,nil
  high = (point+1..r.max) if r.max > point
  low = ( r.min..( r.max < point ? r.max : point ) )   if( r.min <= point)
  return low,high
end

$accepts = []
$rejects = []

all_workflows2 = {}
w.split(/\n/).each do |ww|
  m = ww.match(/(?<name>\w+){(?<rules>.*)}/)
  name = m['name']
  rules = m['rules'].split(/,/)

  workflows = []
  rules.each do |rule|
    rr = rule.split(/:/)
    if rr.length == 1
      workflows << ->(rating, all_workflows2, current, current_index ){
        if rr.first == 'A'
          $accepts << rating.dup 
        elsif rr.last == 'R'
          $rejects << rating.dup
        else
          all_workflows2[rr.first][0].call( rating, all_workflows2, rr.first, 0 )
        end
      }
    else
      variable = rr.first.scan(/\w+/).first
      operator = rr.first.scan(/[^\w\d]/).first
      target = rr.first.scan(/\d+/).first.to_i
      success = rr.last
      workflows << ->(rating, all_workflows2, current, current_index ){

        low, high = rating.dup, rating.dup
        splits = nil
        if ! rating[variable].nil?
          splits = split_range( rating[variable], operator == '<' ? target - 1 : target )
          low[variable] = splits[0]
          high[variable] = splits[1]
        end

        success_range =  operator == '<' ? low.dup : high.dup
        next_range = operator == '<' ? high : low

        if success == 'A'
          $accepts << success_range
        elsif success == 'R'
          $rejects << success_range
        else
          all_workflows2[success][0].call( success_range, all_workflows2, success, 0 )
        end

        all_workflows2[current][current_index+1].call( next_range, all_workflows2, current, current_index + 1 )
      }
    end
  end
  all_workflows2[name] = workflows
end


xmas = {'x'=>(1..4000), 'm'=>(1..4000), 'a'=>(1..4000), 's'=>(1..4000) }
all_workflows2['in'][0].call( xmas, all_workflows2, 'in', 0 )
p $accepts.reduce(0){ | aaccum,accept| aaccum += accept.values.reduce(1){ |paccum,v| paccum*v.size } }
