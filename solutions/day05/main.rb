#!/usr/bin/ruby

DATA = File.read('data.txt').scan(/(\d+),(\d+) -> (\d+),(\d+)/)
    .map{ _1.map(&:to_i) }

def make_line x1, y1, x2, y2
    if x1 == x2
        Range.new(*[y1, y2].sort).map{ [x1, _1] }
    elsif y1 == y2
        Range.new(*[x1, x2].sort).map{ [_1, y1] }
    elsif (x2-x1).abs == (y2-y1).abs
        xmin = [x1, x2].min
        if (x2 > x1 and y2 > y1) or (x1 > x2 and y1 > y2)
            ymin = [y1, y2].min
            Range.new(*[x1, x2].sort).map{ [_1, ymin + _1 - xmin] }
        else
            ymax = [y1, y2].max
            Range.new(*[x1, x2].sort).map{ [_1, ymax - _1 + xmin] }
        end
    end
end

def overlapping &pred
    DATA.select(&pred)
        .map{ make_line *_1 }
        .flatten(1)
        .group_by(&:itself)
        .count{ _2.size > 1 }
end

part1 = -> { overlapping { _1 == _3 or _2 == _4 } }
part2 = -> { overlapping { _1 == _3 or _2 == _4 or (_1-_3).abs == (_2-_4).abs} }

puts 'Part 1: %s' % part1[]
puts 'Part 2: %s' % part2[]
