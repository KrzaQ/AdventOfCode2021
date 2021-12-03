#!/usr/bin/ruby

DATA = File.read('data.txt').split

PART1 = DATA.map(&:chars).transpose.map(&:join).map do
    _1.count(?0) > _1.count(?1) ? [ ?0, ?1 ] : [ ?1, ?0 ]
end.transpose.map(&:join).map{ _1.to_i(2) }.inject(:*)

def common_bit arr, n, op
    arr.map{ _1[n] }.join.yield_self do
        _1.count(?0).send(op, _1.count(?1)) ? ?0 : ?1
    end
end

def calc_val arr, op
    for idx in 0...DATA.first.size
        cb = common_bit arr, idx, op
        arr = arr.select{ _1[idx] == cb }
        break if arr.size == 1
        raise :lol unless arr.size > 1
    end
    arr.first.to_i(2)
end

oxygen_generator_rating = -> arr { calc_val arr, :> }
co2_scrubber_rating = -> arr { calc_val arr, :<= }

PART2 = oxygen_generator_rating[DATA] * co2_scrubber_rating[DATA]

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
