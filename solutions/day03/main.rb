#!/usr/bin/ruby

DATA = File.read('data.txt').split

PART1 = DATA.map(&:chars).transpose.map(&:join).map do
    [ _1.count(?0), _1.count(?1) ]
end.map do
    _1 > _2 ? [ ?0, ?1 ] : [ ?1, ?0 ]
end.transpose.map(&:join).map{ _1.to_i(2) }.inject(:*)

def common_bit arr, n, op
    counts = arr.map{ _1[n] }.join.yield_self{ [ _1.count(?0), _1.count(?1) ] }
    counts[0].send(op, counts[1]) ? ?0 : ?1
end

def calc_val arr, op
    v1, v2 = 0, 0
    idx = 0
    loop do
        cb = common_bit arr, idx, op
        arr = arr.select{ _1[idx] == cb }
        break if arr.size < 2
        idx += 1
        raise :lol if idx > DATA.first.size
    end
    arr.first.to_i(2)
end

PART2 = calc_val(DATA, :<=) * calc_val(DATA, :>)

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
