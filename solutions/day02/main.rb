#!/usr/bin/ruby

DATA = File.read('data.txt').lines.map(&:split)

PART1 = DATA.map do
    {
        forward: [0, _2.to_i],
        down: [_2.to_i, 0],
        up: [-_2.to_i, 0]
    }[_1.to_sym]
end.transpose.map(&:sum).reduce(:*)

PART2 = DATA.reduce([0, 0, 0]) do
    h, d, a = *_1
    dir, val = *_2
    val = val.to_i
    {
        forward: [h + val, d + a * val, a],
        down: [h, d, a + val],
        up: [h, d, a - val]
    }[dir.to_sym]
end.yield_self{ _1 * _2 }

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
