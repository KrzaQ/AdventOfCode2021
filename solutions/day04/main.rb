#!/usr/bin/ruby

FIRST_LINE, *OTHER_LINES = File.read('data.txt').lines
NUMBERS = FIRST_LINE.split(?,).map(&:to_i)
BOARDS = OTHER_LINES.join.scan(/\d+/).map(&:to_i).each_slice(25).to_a

def is_winning arr, numbers
    bools = arr.map{ numbers.include? _1 }
    for i in 0...5
        return true if bools[(i*5)...(i*5+5)].all?
        return true if (0...5).map{ _1 * 5 + i}.all?{ bools[_1] }
    end
    false
end

def part1
    for i in 5...NUMBERS.size
        b = BOARDS.find{ is_winning _1, NUMBERS[0..i] }
        if b
            return (b - NUMBERS[0..i]).sum * NUMBERS[i]
        end
    end
end

def part2
    bs = BOARDS.map(&:clone)

    for i in 5...NUMBERS.size
        bs = bs.reject{ is_winning _1, NUMBERS[0..i] } if bs.size > 1
        if bs.size == 1 and is_winning(bs.first, NUMBERS[0..i])
            b = bs.first
            return (b - NUMBERS[0..i]).sum * NUMBERS[i]
        end
    end
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
