#!/usr/bin/ruby

DATA = File.read('data.txt').lines.map{ _1.strip.chars.map(&:to_i) }
X_SIZE = DATA[0].size
Y_SIZE = DATA.size

def points_around x, y
    [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]]
        .reject{ _1[0] < 0 }
        .reject{ _1[1] < 0 }
        .reject{ _1[0] >= X_SIZE }
        .reject{ _1[1] >= Y_SIZE }
end

def is_low_point x, y
    points_around(x, y).all?{ |x1, y1| DATA[y1][x1] > DATA[y][x] }
end

def get_basin_points x, y
    found = []
    to_add = points_around(x, y)
    loop do
        candidates = to_add.reject{ DATA.dig(*_1.reverse) == 9 }
            .reject{ found.include? _1 }
        found += candidates
        found = found.sort.uniq
        break if candidates.size == 0
        to_add = candidates.map{ points_around *_1 }.flatten(1).sort.uniq
    end
    found
end

LOW_POINTS = (0...Y_SIZE).map{ |y| (0...X_SIZE).map{ |x| [x, y] } }
    .flatten(1)
    .select{ is_low_point *_1 }

PART1 = LOW_POINTS.map{ DATA.dig(*_1.reverse) + 1 }.sum
PART2 = LOW_POINTS.map{ get_basin_points(*_1).size }.sort[-3..-1].reduce(:*)

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
