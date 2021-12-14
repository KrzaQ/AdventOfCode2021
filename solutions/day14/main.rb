#!/usr/bin/ruby
require 'set'

POLYMER = File.read('data.txt').lines.first.strip.chars + [nil]

RULES = File.read('data.txt').lines.drop(2)
    .map{ _1.scan /(\w\w) -> (\w)/ }
    .map(&:first)
    .map{ [_1.chars, _2] }
    .to_h

POLYMER_HASH = POLYMER.each_cons(2).to_a
    .group_by(&:itself)
    .map{ [_1, _2.size] }
    .to_h

def do_step a
    ret = {}
    a.each do |pair, count|
        if pair.last == nil
            ret[pair] = 1
            next
        end
        c = RULES[pair]
        p1 = [pair[0], c]
        p2 = [c, pair[1]]
        ret[p1] = ret.fetch(p1, 0) + count
        ret[p2] = ret.fetch(p2, 0) + count
    end
    ret
end

def calc poly
    sorted = poly.map{ [_1.first, _2] }
        .group_by(&:first)
        .map{ [_1, _2.map(&:last).sum] }
        .map(&:reverse).sort
    sorted.last.first - sorted.first.first
end

PART1 = calc (1..10).reduce(POLYMER_HASH){ do_step _1 }
PART2 = calc (1..40).reduce(POLYMER_HASH){ do_step _1 }

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
