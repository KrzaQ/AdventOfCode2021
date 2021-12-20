#!/usr/bin/ruby

DATA = File.read('data.txt').split("\n\n")

ALGO = DATA.first
IMAGE = DATA.last.split.map(&:strip)
# puts IMAGE.join("\n")
raise :oops unless ALGO.size == 512

def get img, x, y
    return ?. if x < 0 or y < 0 or x >= img[0].size or y >= img.size
    # p [img[y][x], x, y]
    img[y][x]
end

def get_pixel img, x, y
    idx = [-1,0,1].product([-1,0,1])
        .map{ |dy, dx| (get(img, x + dx, y + dy) == ?#) ? ?1 : ?0 }
        .join
        .to_i(2)
    ALGO[idx]
end

def get_pixel_2 img, x, y
idx = [-1,0,1].product([-1,0,1])
    .map{ |dy, dx| (get_pixel(img, x + dx, y + dy) == ?#) ? ?1 : ?0 }
    .join
    .to_i(2)
ALGO[idx]
end

# puts [*-2..3].product([*-2..3]).map{ get_pixel IMAGE, _1, _2 }
#     .join.chars.each_slice(6).to_a.map(&:join)
# exit
BORDER = 2

def next_step img
    ((-BORDER)..(img.size+BORDER)).map do |y|
        ((-BORDER)..(img[0].size+BORDER)).map do |x|
            get_pixel img, x, y
        end.join
    end
end

def next_double_step img
    ((-BORDER)..(img.size+BORDER)).map do |y|
        ((-BORDER)..(img[0].size+BORDER)).map do |x|
            get_pixel_2 img, x, y
        end.join
    end
end

# x = next_step next_step IMAGE
# puts x[20..-20].map{ _1[20..-20] }
# p x[20..-20].map{ _1[20..-20] }.join.count(?#)

x = (1..25).reduce(IMAGE) do |img, n|
    img = next_double_step(img)
    p [n, img.size]
    # puts img
    # n > 3 ? img[15..-15].map{ |l| l[15..-15] } : img
    img
end
# puts x
# File.write "huj.x", x.join("\n")
puts x.join.count(?#)

# puts 'Part 1: %s' % PART1
# puts 'Part 2: %s' % PART2
