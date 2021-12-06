#!/usr/bin/ruby

DATA = File.read('data.txt')
    .split(?,)
    .map(&:to_i)
    .group_by(&:itself)
    .map{ [_1, _2.size] }
    .to_h

def process_day h
    new_h = h.reject{ _1 == 0}.map{ [_1 - 1, _2] }.to_h
    new_h[6] = new_h.fetch(6, 0) + h[0] if h[0]
    new_h[8] = h[0] if h[0]
    new_h
end

def size_after_days n
    (0...n).reduce(DATA){ process_day _1 }.map{ _2 }.sum
end

PART1 = size_after_days 80
PART2 = size_after_days 256

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
