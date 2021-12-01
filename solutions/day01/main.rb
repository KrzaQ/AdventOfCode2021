#!/usr/bin/ruby

class Array
    def sonar_count
        self.each_cons(2).map{ _2 - _1 }.select{ _1 > 0 }.count
    end
end

DATA = File.read('data.txt').split.map(&:to_i)
PART1 = DATA.sonar_count
PART2 = DATA.each_cons(3).map(&:sum).sonar_count

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
