#!/usr/bin/ruby
require 'set'
require 'pqueue'

DATA = File.read('data.txt').lines.map{ _1.strip.chars.map(&:to_i) }

X_SIZE = DATA[0].size
Y_SIZE = DATA.size

def points_around x, y, xsize, ysize
    [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]]
        .reject{ _1[0] < 0 }
        .reject{ _1[1] < 0 }
        .reject{ _1[0] >= xsize }
        .reject{ _1[1] >= ysize }
end

def dij map, from, to
    distances = {
        from => 0
    }

    visited = Set[]

    todos = PQueue.new([[from, 0]]){ _1[1] < _2[1] }

    xsize = map[0].size
    ysize = map.size

    loop do
        break if todos.size == 0
        node, dist = todos.pop
        next if visited.include? node

        visited.add node
        distances[node] = dist
        around = points_around(node[0], node[1], xsize, ysize)
            .reject{ visited.include? _1 }
        todos.concat around.map{ [_1, dist + map.dig(*_1.reverse)] }

        break if visited.include? to
    end
    distances
end

def find_distance map
    target = [map[0].size-1, map.size-1]
    distances = dij map, [0, 0], target
    distances[target]
end

def make_bigger_data
    lines = DATA.map do |line|
        (line * 5).each_with_index
            .map{ _1 + _2 / DATA.size }
            .map{ _1 > 9 ? _1 - 9 : _1 }
    end

    (lines * 5).each_with_index.map do |line, index|
        line.map{ _1 + index / DATA.size }
            .map{ _1 > 9 ? _1 - 9 : _1 }
    end
end

PART1 = find_distance DATA
PART2 = find_distance make_bigger_data

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
