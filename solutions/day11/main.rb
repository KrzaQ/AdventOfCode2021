#!/usr/bin/ruby
require 'set'

DATA = File.read('data.txt').split.map{ _1.chars.map(&:to_i) }
X_SIZE = 10
Y_SIZE = 10

def points_around x, y
    [
        [x - 1, y - 1], [x, y - 1], [x + 1, y - 1],
        [x - 1, y    ],             [x + 1, y    ],
        [x - 1, y + 1], [x, y + 1], [x + 1, y + 1],
    ]
        .reject{ _1[0] < 0 }
        .reject{ _1[1] < 0 }
        .reject{ _1[0] >= X_SIZE }
        .reject{ _1[1] >= Y_SIZE }
end

def increment_all cavern
    cavern.map{ _1.map{ |x| x + 1 } }
end

def do_step cavern
    ret = increment_all(cavern)
    
    flashed = [].to_set
    
    cavern = increment_all(cavern).each_with_index.map do |line, y|
        line.each_with_index.map{ |v, x| [[x, y], v] }
    end.flatten(1).to_h
    
    loop do
        flashed_this_round = cavern.select{ _2 > 9 }.map{ _1[0] }
        flashed += flashed_this_round

        break if flashed_this_round.size == 0

        adj = flashed_this_round.map{ points_around *_1 }.flatten(1)
            .reject{ flashed.include? _1 }
            .each do
            cavern[_1] += 1
        end

        flashed_this_round.each{ cavern[_1] = 0 }
    end
    (0..9).map{ |y| (0..9).map{ |x| cavern[[x, y]] }}
end

def part1
    (0...100).reduce([0, DATA]) do
        flashes, data = _1
        data = do_step data
        [ flashes + data.flatten.count{ |x| x == 0 }, data ]
    end
end

def part2
    data = DATA
    for n in 1.. do
        data = do_step data
        return n if data.flatten.all?{ _1 == 0 }
    end
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
