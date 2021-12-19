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

def dist point
    point.map{ _1 ** 2 }.sum
end

def manhattan_distance p1, p2
    p1.zip(p2).map{ _1.inject(:-).abs }.sum
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

def negate_rot rot
    ret = NEGATED_ROTATIONS[rot]
    if not ret
        ret = ROTATIONS.find do
            x = rotate_xyz rotate_xyz([1,2,3], rot), _1
            x == [1,2,3]
        end
        raise 123 unless ret
        NEGATED_ROTATIONS[rot] = ret
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
        data[(idx+1)..data.size].map do |o|
            [pt, o]
        end.map do |p1, p2|
            {
                dist: manhattan_distance(p1, p2),
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

ROT_CACHE = {}

def find_common a, b
    return nil if (a[:distances].keys & b[:distances].keys).size < 12

    potentials = a[:distances]
        .select{ b[:distances].has_key? _1 }
        .map{ |k, v| v.map{ |d| b[:distances][k].map{ |bd| [d, bd] } } }
        .flatten(2)

    potentials.map do |hook, bhook|
        ROTATIONS.map{ [_1, hook, bhook] }
    end.flatten(1).lazy.map do |rot, hook, bhook|
        rotd = rotate_xyz bhook[:points].first, rot
        diff = sub_points hook[:points].first, rotd
        points = ROT_CACHE[[b[:index], rot]]
        if not points
            points = b[:data].map{ rotate_xyz _1, rot }
            ROT_CACHE[[b[:index], rot]] = points
        end
        maybe = points.map{ add_points(_1, diff) }.to_set
        common = maybe & a[:data]
        {
            rot: rot,
            diff: diff,
            common: common
        }
    end.find{ _1[:common].size >= 12 }
end

def find_all_scanners
    found = { 0 => {rot: [0,0,0], diff: [0,0,0], prev: nil} }
    todo = Set[*1...DATA.size]
    tested = Set[]

    while todo.size > 0
        arr = found.map(&:first).reject{ tested.include? _1 }.product(todo.to_a)
        for known, t in arr do
            next if found.has_key? t
            tested.add known
            print "#{known} -> #{t}..."
            common = find_common DATA[known], DATA[t]
            match = (common and common[:common].size >= 12) ? true : false
            puts (match ? "yes" : "no")
            next unless match
            todo.delete t
            common.delete :common
            rel_zero = rotate_xyz(common[:diff], negate_rot(found[known][:rot]))
            common[:prev] = known
            common[:rot] = add_rot(found[known][:rot], negate_rot(common[:rot]))
            common[:diff] = add_points rel_zero, found[known][:diff]
            found[t] = common
        end
        puts "Progress: #{found.size} / #{DATA.size}"
    end

    found
end

def get_nodes_from_scanners scanners
    scanners.map do |idx, data|
        DATA[idx][:data].map{ rotate_xyz _1, negate_rot(data[:rot]) }
            .map{ add_points data[:diff], _1 }
    end.flatten(1).sort.uniq
end

SCANNERS = find_all_scanners

def part1
    get_nodes_from_scanners(SCANNERS).size
end

def part2
    scanner_placement = SCANNERS.map{ _2[:diff] }
    scanner_placement.product(scanner_placement).reject{ _1 == _2 }
        .map{ manhattan_distance _1, _2 }.max
end

puts 'Part 1: %s' % part1
puts 'Part 2: %s' % part2
