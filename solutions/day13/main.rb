#!/usr/bin/ruby
require 'set'

DATA = File.read('data.txt').split("\n\n")
POINTS = DATA.first.split.map{ _1.split(?,).map(&:to_i) }
FOLDS = DATA.last.scan(/(x|y)=(\d+)/).map{ [ _1[0], _1[1].to_i ] }

def fold_impl n, n_fold
    diff = (n - n_fold).abs
    n < n_fold ? n : n_fold - diff
end

def fold_point point, xy, n
    x, y = *point
    case xy
    when ?x
        [ fold_impl(x, n), y ]
    when ?y
        [ x, fold_impl(y, n) ]
    end
end

def fold points, xy, n
    points.map{ fold_point _1, xy, n }
        .reject{ |x, y| x < 0 or y < 0 }
        .reject{ |x, y| xy == ?x ? x >= n : y >= n }
        .to_set
end

def make_image points
    xmax, ymax = points.to_a.transpose.map{ _1.max + 1 }
    strings = (0...ymax).map{ ' ' * xmax }
    points.each{ x, y = *_1; strings[y][x] = ?* }
    strings.join ?\n
end

PART1 = fold(POINTS, *FOLDS.first).size
PART2 = make_image FOLDS.reduce(POINTS){ fold _1, *_2 }

puts "Part 1: %s" % PART1
puts "Part 2:\n%s" % PART2
