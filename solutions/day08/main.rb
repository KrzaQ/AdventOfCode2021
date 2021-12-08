#!/usr/bin/ruby

DATA = File.read('data.txt').lines

def decode_line l
    words = l.scan(/\w+/).map{ _1.chars.sort }.uniq.group_by(&:size)
    
    a = (words[3].first - words[2].first)
    cf = words[2].first
    bd = (words[4].first - words[2].first)
    g = words[6].map{ _1 - (a + cf + bd).sort }.find{ _1.size == 1 }
    d = words[5].select{ (cf - _1).size == 0 }.first - cf - a - g
    b = bd - d
    f = words[5].select{ (_1 - a - b - d - g).size == 1 }.first - a - b - d - g
    c = cf - f
    e = words[7].first - cf - bd - a - g

    one = (c + f).sort
    two = (a + c + d + e + g).sort
    three = (a + c + d + f + g).sort
    four = (b + c + d + f).sort
    five = (a + b + d + f + g).sort
    six = (a + g + b +d + e + f).sort
    seven = (a + c + f).sort
    eigth = (a + b + c + d + e + f + g).sort
    nine = (a + b + c + d + f + g).sort
    zero = (a + b + c + e + f + g).sort

    h = {
        one => 1,
        two => 2,
        three => 3,
        four => 4,
        five => 5,
        six => 6,
        seven => 7,
        eigth => 8,
        nine => 9,
        zero => 0,
    }

    l.scan(/\w+/).map{ h[_1.chars.sort] }
end

PART1 = DATA
    .map{ _1.split(?|).last.strip.split }
    .flatten(1)
    .select{ [2,3,4,7].include? _1.size }
    .count

PART2 = DATA
    .map{ decode_line(_1)[-4..-1].join.to_i }
    .sum

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
