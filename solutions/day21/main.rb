#!/usr/bin/ruby

DATA = File.read('data.txt').split.map(&:to_i)

$state = 0
$rolls = 0
def roll
    $state += 1
    $rolls += 1
    $state = 1 if $state > 100
    $state
end

POSSIBLE_ROLLS = [1,2,3].product([1,2,3],[1,2,3])
    .map(&:sum).group_by(&:itself).map{ [_1, _2.size] }.to_h
p POSSIBLE_ROLLS
exit

$cnt = 0
def seek data, player, d
    $cnt += 1
    p [data, player, d] if $cnt % 100000 == 0
    if player == 1
        POSSIBLE_ROLLS.map do |roll, freq|
            p1 = data[:p1] + roll
            p1 = p1 % 10 if p1 > 10
            sc = p1 + data[:s1]
            if sc >= 21
                [ freq, 0 ]
            else
                x = data.to_a.to_h
                x[:p1] = p1
                x[:s1] = sc
                seek(x, 2, d+1).transpose.map{ _1.sum * freq }
            end
        end
    else
        POSSIBLE_ROLLS.map do |roll, freq|
            p2 = data[:p2] + roll
            p2 = p2 % 10 if p2 > 10
            sc = p2 + data[:s2]
            if sc >= 21
                [ 0, freq ]
            else
                x = data.to_a.to_h
                x[:p2] = p2
                x[:s2] = sc
                seek(x, 1, d+1).transpose.map{ _1.sum * freq }
            end
        end
    end
end

INITIAL = {
    p1: 7,
    s1: 0,
    p2: 10,
    s2: 0,
}

x = seek INITIAL, 1, 0
p x.transpose.map(&:sum)

# def 

# p1, p2 = 7,10
# s1, s2 = 0, 0
# loop do
#     p1 += roll + roll + roll
#     sc = p1 % 10
#     sc = 10 if sc == 0
#     s1 += sc

#     if s1 >= 1000
#         p [s1, $rolls, s2*$rolls]
#         exit
#     end
    
#     p2 += roll + roll + roll
#     sc = p2 % 10
#     sc = 10 if sc == 0
#     s2 += sc
    
#     if s2 >= 1000
#         p [s2, $rolls, s1*$rolls]
#         exit
#     end
# end

# puts 'Part 1: %s' % PART1
# puts 'Part 2: %s' % PART2
