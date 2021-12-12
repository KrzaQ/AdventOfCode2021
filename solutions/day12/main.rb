#!/usr/bin/ruby
require 'set'

DATA = File.read('data.txt').split
    .map{ _1.split ?- }
    .yield_self{ _1 + _1.map(&:reverse) }
    .group_by(&:first)
    .map{ [_1, _2.map(&:last)] }
    .to_h

def find_paths from = 'start', visited = ['start'].to_set
    return [['end']] if from == 'end'
    DATA[from]
        .reject{ visited.include?(_1) and _1.downcase == _1 }
        .reject{ _1 == 'start' }
        .map{ find_paths _1, visited.clone.add(from) }
        .map{ _1.map{ |path| [from] + path } }
        .flatten(1)
end

def find_paths_p2 from = 'start', visited = ['start'].to_set, twice = nil
    return [['end']] if from == 'end'
    DATA[from]
        .reject{ twice and visited.include?(_1) and _1.downcase == _1 }
        .reject{ _1 == 'start' }
        .map do
            tw = twice
            tw = _1 if not twice and visited.include?(_1) and _1.downcase == _1
            find_paths_p2(_1, visited.clone.add(from), tw)
        end.map{ _1.map{ |path| [from] + path } }
        .flatten(1)
end

puts 'Part 1: %s' % find_paths.size
puts 'Part 2: %s' % find_paths_p2.size
