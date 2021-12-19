#!/usr/bin/ruby
require 'matrix'
require 'set'
def rotate_x point, phi
    sin = Math.sin(phi * Math::PI).round
    cos = Math.cos(phi * Math::PI).round
    rot = Matrix[[1,0,0],[0, cos, -sin], [0, sin, cos]]
    (rot * Matrix[point].transpose).to_a.flatten
end

def rotate_y point, phi
    sin = Math.sin(phi * Math::PI).round
    cos = Math.cos(phi * Math::PI).round
    rot = Matrix[[cos, 0, sin],[0,1,0],[-sin,0,cos]]
    (rot * Matrix[point].transpose).to_a.flatten
end

def rotate_z point, phi
    sin = Math.sin(phi * Math::PI).round
    cos = Math.cos(phi * Math::PI).round
    rot = Matrix[[cos, -sin, 0],[sin, cos, 0],[0,0,1]]
    (rot * Matrix[point].transpose).to_a.flatten
end

def rotate_xyz point, rots
    rx, ry, rz = *rots
    point = rotate_x point, rx
    point = rotate_y point, ry
    point = rotate_z point, rz
end

ROTATIONS = [*0..3].product([*0..3],[*0..3]).map{ _1.map{ |rot| rot * 0.5 } }
    .map do |rx,ry,rz|
        pt = rotate_xyz [1,2,3], [rx, ry, rz]
        [ pt, [rx, ry, rz] ]
    end.group_by(&:first).map{ _2.first.last }

NEGATED_ROTATIONS = ROTATIONS.map do |rot|
    found = ROTATIONS.find do
        x = rotate_xyz rotate_xyz([1,2,3], rot), _1
        x == [1,2,3]
    end
    [rot, found]
end.to_h
# p NEGATED_ROTATIONS
# p ROTATIONS
# exit
def dist point
    point.map{ _1 ** 2 }.sum
end

def sub_points a, b
    a.zip(b).map{ _1.inject(:-) }
end

def add_points a, b
    a.zip(b).map{ _1.inject(:+) }
end

def abs_point a
    a.map(&:abs)
end

def negate_rot a
    normalized = a
    # normalized = a.map{ _1 % 2 }
    ret = NEGATED_ROTATIONS[normalized]
    if not ret
        ret = ROTATIONS.find do
            x = rotate_xyz rotate_xyz([1,2,3], normalized), _1
            x == [1,2,3]
        end
        raise 123 unless ret
        NEGATED_ROTATIONS[normalized] = ret
    end
    ret
end

def add_rot a, b
    x = rotate_xyz [1,2,3], a
    x = rotate_xyz x, b
    ROTATIONS.find{ rotate_xyz([1,2,3], _1) == x }
end

def find_distances data
    data.each_with_index.map do |pt, idx|
        # p pt
        data[(idx+1)..data.size].map do |o|
            [pt, o]
        end.map do |p1, p2|
            dist = abs_point(sub_points(p1, p2)).sum
            {
                dist: dist,
                points: [p1, p2]
            }
        end
    end.flatten(1).group_by{ _1[:dist] }.to_h
end

DATA = File.read('data.txt').split("\n\n")
    .map{ _1.scan(/(-?\d+),(-?\d+),(-?\d+)/) }
    .map{ _1.map{ |point| point.map(&:to_i) }.sort_by{ |x| dist x } }
    .each_with_index.map do
    {
        index: _2,
        data: _1.to_set,
        distances: find_distances(_1),
    }
end

def find_common a, b
    # p a
    # p b
    potentials = a[:distances]
        .select{ b[:distances].has_key? _1 }
        .map{ |k, v| v.map{ |d| b[:distances][k].map{ |bd| [d, bd] } } }
        .flatten(2)
    # potentials.each{ p _1 }
    # p potentials
    # exit
    # hook = potentials.find{ _2.size == 1 and b[:distances][_1].size == 1 }[1][0]
    # bhook = b[:distances][hook[:dist]][0]
    # p hook
    # p bhook
    potentials.map do |hook, bhook|
        ROTATIONS.map{ [_1, hook, bhook] }
    end.flatten(1).map do |rot, hook, bhook|
        # p bhook[:points]
        # p [rot, hook, bhook]
        rotd = rotate_xyz bhook[:points].first, rot
        diff = sub_points hook[:points].first, rotd
        # p [rotd, diff]
        maybe = b[:data].map{ rotate_xyz _1, rot }.map{ add_points _1, diff }.to_set
        # p maybe
        # p b[:data]
        # p a[:data]
        # exit
        common = maybe & a[:data]
        # [common.size, common]
        {
            rot: rot,
            diff: diff,
            common: common
        }
    end.sort_by{ -_1[:common].size }.first
end

def find_all_scanners
    found = {
        0 => {rot: [0,0,0], diff: [0,0,0], common: nil}
    }

    todo = [*1...DATA.size].to_set
    tried = Set.new
    while todo.size > 0
        arr = found.map(&:first).reject{ tried.include? _1 }.product(todo.to_a)
        for known, t in arr do
            next if found.has_key? t
            # next if tried.include? known
            tried.add known
            print "#{known} -> #{t}..."
            common = find_common DATA[known], DATA[t]
            if common and common[:common].size >= 12
                puts ""
            else
                puts "nope"
            end
            next unless common and common[:common].size >= 12
            todo.delete t
            common.delete :common
            rel_zero = rotate_xyz(common[:diff], negate_rot(found[known][:rot]))
            # p [known, found[known][:rot], common, rel_zero, negate_rot(found[known][:rot])]
            common[:common] = known
            common[:rot] = add_rot(found[known][:rot], negate_rot(common[:rot]))
                # .map{ _1 % 2 }
            common[:diff] = add_points rel_zero, found[known][:diff]
            puts "found #{known} -> #{t}: #{common.inspect}"
            found[t] = common
            # break
        end
    end

    found
end

def get_nodes_from_scanners scanners
    scanners.map do |idx, data|
        p [idx, data]
        DATA[idx][:data].map{ rotate_xyz _1, negate_rot(data[:rot]) }
            .map{ add_points data[:diff], _1 }
    end.flatten(1).sort.uniq
end

# x = ROTATIONS.shuffle[0..5]
# r1 = x.reduce([1,2,3]){ rotate_xyz _1, _2 }
# tr = x.reduce{ add_rot _1, _2 }
# r2 = rotate_xyz [1,2,3], tr
# p x
# p tr
# # p x.transpose.map(&:sum).map{ _1 % 2 }
# p [r1, r2]
# exit

# ROTATIONS.each do
#     x = rotate_xyz [1,2,3], _1
#     y = rotate_xyz x, negate_rot(_1)
#     p [x, y]
# end

# exit
# p rotate_xyz [1,2,3], [1, 0, 1]
# p rotate_xyz(rotate_xyz([1,2,3], [1, 0, 2]), negate_rot([1, 0, 2]))
# p rotate_xyz [1,2,3], [1, 0, 2]

# p add_points([1105,-1205,1229], rotate_xyz([-889,563,-600], [0.5, 0, 1]))
# exit

scanners = find_all_scanners
# idx = 2
# # exit
# p scanners[idx]
# [*0..3].product([*0..3],[*0..3]).map{ _1.map{ |rot| rot * 0.5 } }.each do |r|
#     DATA[idx][:data].map{ rotate_xyz _1, r }
#         .map{ add_points _1, scanners[idx][:diff] }.sort
#         .select{  _1 == [1994,-1805,1792] }.each{ p [_1, r] }
# end

# # p scanners[idx][:diff]
# # exit
all = get_nodes_from_scanners scanners
all.each{ p _1 }
p all.size

places = scanners.map{ _2[:diff] }
p places
p places.product(places).reject{ _1 == _2 }
    .map{ abs_point(sub_points(_1, _2)).sum }.max

# p DATA[1]
# p add_points [-328, -685, 520], [335, 652, -591]
# x = find_common *DATA
# p x[:common].size

# p x

# def compare_scanners a, b
#     potentials = a[:distances]
#         .select{ b[:distances].has_key? _1 }
#         .map{ _2 }.flatten(1)
# end

# p (1..24).sum
# p DATA[0][:distances].map{ _2 }.flatten(1).size
# p compare_scanners *DATA

# p find_distances DATA[0]

# puts 'Part 1: %s' % PART1
# puts 'Part 2: %s' % PART2
