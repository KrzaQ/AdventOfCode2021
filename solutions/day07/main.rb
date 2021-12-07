#!/usr/bin/ruby

DATA = File.read('data.txt').split(?,).map(&:to_i)

def calculate cost
    (DATA.min..DATA.max).map{ |n| DATA.map{ cost[n, _1] }.sum }.min
end

PART1 = calculate ->(a, b) { (a - b).abs }
PART2 = calculate ->(a, b) { (1..(a - b).abs).sum }

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
