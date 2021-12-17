#!/usr/bin/ruby

TARGET = File.read('data.txt').scan(/-?\d+/).map(&:to_i)

def step x, y, dx, dy
    [x+dx, y+dy, [0, dx-1].max, dy-1]
end

def still_can_win target, point
    tx, ty = target
    x, y = point
    x <= tx and y >= ty
end

def match point, target_box
    x, y = point
    min_x, max_x, min_y, max_y = target_box
    x >= min_x and x <= max_x and y >= min_y and y <= max_y
end

def try_values dx, dy, target_box
    min_x, max_x, min_y, max_y = target_box
    target = [max_x, min_y]
    ball = [0, 0, dx, dy]
    top_y = 0
    while still_can_win target, ball[0...2]
        ball = step *ball
        top_y = [top_y, ball[1]].max
        if match ball[0...2], target_box
            return [true, ball[0] <=> min_x, top_y]
        end
    end
    [false, ball[0] <=> min_x, top_y]
end

def find_best target_box
    dx, dy = 1, 1000
    loop do
        success, diff, top = try_values dx, dy, target_box
        if diff < 0
            dx += 1
        else
            dy -= 1
        end
        return top if success
    end
end

def find_all target_box
    min_x, max_x, min_y, max_y = target_box
    [*1..max_x].product((min_y..(min_y*5).abs).to_a).select do
        s, a, b  = try_values *_1, target_box
        s
    end.size
end

PART1 = find_best TARGET
PART2 = find_all TARGET

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
