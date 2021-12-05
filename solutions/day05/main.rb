#!/usr/bin/ruby

DATA = File.read('data.txt').scan(/(\d+),(\d+) -> (\d+),(\d+)/)
    .map{ _1.map(&:to_i) }

def make_line x1, y1, x2, y2
    x1, y1, x2, y2 = x2, y2, x1, y1 if x2 < x1
    dx, dy = [x1, x2].reduce(:-).abs, [y1, y2].sort.reduce(:-).abs
    return Range.new(*[y1, y2].sort).map{ [x1, _1] } if dx == 0
    return (x1..x2).map{ [_1, y1] } if dy == 0
    return (0..dx).map{ [x1 + _1, y1 + _1] } if y1 < y2
    return (0..dx).map{ [x1 + _1, y1 - _1] } if y1 > y2
end

def overlapping &pred
    DATA.select(&pred)
        .map{ make_line *_1 }
        .flatten(1)
        .group_by(&:itself)
        .count{ _2.size > 1 }
end

PART1 = overlapping { _1 == _3 or _2 == _4 }
PART2 = overlapping { _1 == _3 or _2 == _4 or (_1-_3).abs == (_2-_4).abs }

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
