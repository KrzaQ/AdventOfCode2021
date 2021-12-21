#!/usr/bin/ruby

DATA = File.read('data.txt').scan(/: (\d+)/).flatten.map(&:to_i).map{ [_1, 0] }

class DeterministicDice
    attr_reader :rolls

    def initialize
        @rolls = 0
        @state = 0
    end

    def roll
        @rolls += 1
        @state = (@state >= 100) ? 1 : (@state+1)
    end

    def roll3
        roll + roll + roll
    end
end

class Game
    attr_reader :players

    def initialize players, max
        @players = players.freeze
        @max = max
    end

    def round roll
        p1, s1, p2, s2 = @players.flatten
        p1 = (p1 + roll - 1) % 10 + 1
        s1 += p1
        @players = [[p2, s2], [p1, s1]].freeze
        s1 >= @max
    end
end

def part1
    d = DeterministicDice.new
    g = Game.new DATA, 1000
    while not g.round d.roll3; end
    g.players.map(&:last).first * d.rolls
end

POSSIBLE_ROLLS = [1,2,3].product([1,2,3],[1,2,3])
    .map(&:sum).group_by(&:itself).map{ [_1, _2.size] }.to_h

def dfs game, depth = 1
    POSSIBLE_ROLLS.map do |roll, freq|
        g = game.clone
        if g.round roll
            (depth % 2 == 1) ? [freq, 0] : [0, freq]
        else
            dfs(g, depth+1).transpose.map{ _1.sum * freq }
        end
    end
end

def part2
    g = Game.new DATA, 21
    dfs(g).transpose.map(&:sum).max
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
