
require_relative '../lib/common.rb'

data = ARGF.read.chomp

p Grid.new(:io=>data,:spotsonly=>['#'],:expandemptyy=>1,:expandemptyx=>1).
    points.keys.combination(2).map { |a,b| (a.x-b.x).abs + (a.y-b.y).abs }.reduce(&:+)

p Grid.new(:io=>data,:spotsonly=>['#'],:expandemptyy=>999999,:expandemptyx=>999999).
    points.keys.combination(2).map { |a,b| (a.x-b.x).abs + (a.y-b.y).abs }.reduce(&:+)
