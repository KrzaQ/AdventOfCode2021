#!/usr/bin/ruby

DATA = File.read('data.txt').split.map(&:strip)
EPARENS = %w(\) ] } >)
BPARENS = [?(, ?[, ?{, ?<] 
PARENS = BPARENS.zip(EPARENS).to_h
SCORE1 = EPARENS.zip([3, 57, 1197, 25137]).to_h
SCORE2 = EPARENS.zip([*1..4]).to_h

def get_corrupted_char line
    line.chars.reduce([]) do
        if EPARENS.include? _2
            if _2 != PARENS[_1.pop]
                return _2
            end
            _1
        else
            _1.append _2
        end
    end
    return nil
end

def complete_line line
    line.chars.reduce([]) do
        if EPARENS.include? _2
            _1[0...-1]
        else
            _1.append _2
        end
    end.map{ PARENS[_1] }.reverse
end

def score_completed_line completion
    completion.reduce(0) do
        _1 * 5 + SCORE2[_2]
    end
end

PART1 = DATA.map{ get_corrupted_char _1 }.select(&:itself).map{ SCORE1[_1] }.sum

PART2 = DATA.reject{ get_corrupted_char _1 }
    .map{ score_completed_line complete_line(_1) }
    .sort
    .yield_self{ _1[_1.size/2] }

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
