#!/usr/bin/ruby

DATA = File.read('data.txt').lines.map{ eval _1.strip }

# p DATA

def explode2 arr, d = 0
    return arr if arr.is_a?(Integer)
    if d < 2
        arr.map{ explode _1, d+1 }
    else
        arr.map do
            if _1.is_a?(Integer)
                _1
            else
                idx = _1.find_index{ |el| el.is_a? Array }
                if idx
                    prev = idx > 0 ? _1[idx-1] + _1[idx].first : 0
                    succ = idx < _1.size - 1 ? _1[idx+1] + _1[idx].last : 0
                    [ prev, succ ]
                else
                    _1
                end
            end
            # if _1.is_a?(Array)
            #     prev = _2 > 0 ? _1.first + arr[_2-1] : 0
            #     succ = _2 < arr.size - 1 ? _1.last + arr[_2+1] : 0
            #     [ :exploded, prev, succ ]
            # else
            #     _1
            # end
        end
        # arr.each_with_index.map do
        #     if _1.is_a?(Array)
        #         prev = _2 > 0 ? _1.first + arr[_2-1] : 0
        #         succ = _2 < arr.size - 1 ? _1.last + arr[_2+1] : 0
        #         [ :exploded, prev, succ ]
        #     else
        #         _1
        #     end
        # end
    end
end

def to_tree val, parent = nil
    return val if val.is_a? Integer

    node = {
        parent: parent
    }

    node[:elems] = val.map{ to_tree _1, node.object_id }
    node
end

def rightmost node
    right = node[:elems].last
    right.is_a?(Hash) ? rightmost(right) : right
end

def leftmost node
    raise 213
    left = node[:elems].first
    left.is_a?(Hash) ? leftmost(left) : left
end

def get_left_neighbour node, id
    idx = node[:elems].find_index{ _1.object_id == id }
    if idx == 0
        return nil if node[:parent] == nil
        parent = ObjectSpace._id2ref(node[:parent])
        get_left_neighbour parent, node.object_id
    else
        elem = node[:elems][idx-1]
        elem.is_a?(Integer) ? elem : rightmost(elem)
    end
end

def get_right_neighbour node, id
    idx = node[:elems].find_index{ _1.object_id == id }
    if idx == node[:elems].size - 1
        return nil if node[:parent] == nil
        parent = ObjectSpace._id2ref(node[:parent])
        get_right_neighbour parent, node.object_id
    else
        elem = node[:elems][idx+1]
        elem.is_a?(Integer) ? elem : leftmost(elem)
    end
end


def add_rightmost node, val
    right = node[:elems].last
    if right.is_a?(Hash)
        add_rightmost(right, val)
    else
        node[:elems][-1] += val
    end
end

def add_leftmost node, val
    left = node[:elems].first
    if left.is_a?(Hash)
        add_leftmost(left, val)
    else
        node[:elems][0] += val
    end
end

def add_left node, id, val
    idx = node[:elems].find_index{ _1.object_id == id }
    # p [node, id, val, idx]
    if idx == 0
        return nil if node[:parent] == nil
        parent = ObjectSpace._id2ref(node[:parent])
        add_left parent, node.object_id, val
    else
        elem = node[:elems][idx-1]
        if elem.is_a?(Integer)
            node[:elems][idx-1] = node[:elems][idx-1] + val
            # p :huj
            # p node.object_id
            # p node
        else
            add_rightmost(elem, val)
        end
    end
end

def add_right node, id, val
    idx = node[:elems].find_index{ _1.object_id == id }
    if idx == node[:elems].size - 1
        return nil if node[:parent] == nil
        parent = ObjectSpace._id2ref(node[:parent])
        add_right parent, node.object_id, val
    else
        elem = node[:elems][idx-1]
        if elem.is_a?(Integer)
            node[:elems][idx+1] += val
        else
            add_leftmost(elem, val)
        end
    end
end

$global_exploded = false
$global_split = false

def explode node, d = 0
    return node if node.is_a? Integer
    # return node[:elems].map{ explode _1, d+1 } if d < 3
    if d < 3
        # node[:elems] = node[:elems].map{ explode _1, d+1 }
        node[:elems].each_with_index.each do
            node[:elems][_2] = explode _1, d+1
        end
        return node
    end

    idx = node[:elems].find_index{ _1.is_a?(Hash) }
    if idx and not $global_exploded
        elem = node[:elems][idx]
        # right = get_right_neighbour node, elem.object_id
        # left = get_left_neighbour node, elem.object_id
        
        # left = left || 0
        # right = right || 0
        vals = elem[:elems]
        add_left node, elem.object_id, vals.first
        # p [:xxx, node]
        add_right node, elem.object_id, vals.last
        # p [left, right, vals]
        # [
        #     left ? left + vals.first : 0,
        #     right ? right + vals.last : 0
        # ]
        node[:elems] = node[:elems].each_with_index.map do
            _2 == idx ? 0 : _1
        end
        $global_exploded = true
        node
    else
        node
    end
    # node.each_with_index.map do
    #     l2 = _2 > 0
    # end
end

def xexplode node
    $global_exploded = false
    explode node
end

def from_tree node
    node.is_a?(Hash) ? node[:elems].map{ from_tree _1 } : node
end

t = to_tree  [[[[0, [4, 5]], [0, 0]], [[[4, 5], [2, 6]], [9, 5]]], [7, [[[3, 7], [4, 3]], [[6, 3], [8, 8]]]]]
# t = to_tree [[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]
# t = to_tree [[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]
# t = to_tree [7,[6,[5,[4,[3,2]]]]]
# t = to_tree [[[[[9,8],1],2],3],4]
# t = to_tree [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]
# p t
# p explode t
# p from_tree xexplode t
# p from_tree xexplode xexplode t
# p from_tree xexplode xexplode xexplode t
# p from_tree xexplode xexplode xexplode xexplode t
# p from_tree xexplode xexplode xexplode xexplode xexplode t

# exit
def split val
    if val.is_a?(Integer)
        half = val / 2
        plus_one = val % 2
        if val > 9 and not $global_split
            $global_split = true
            [ half, half + plus_one ]
        else
            val
        end
    else
        val.map{ split _1 }
    end
end

def xsplit val
    $global_split = false
    split val
end

# p explode [[[[[9,8],1],2],3],4]
# p split [[[[0,7],4],[15,[0,13]]],[1,1]]
def xreduce arr
    # p [:x, arr]
    c = 1
    loop do
        c+=1
        # exit if c > 5
        succ = from_tree xexplode to_tree arr
        if succ != arr
            # p [:explode, succ]
            arr = succ
            next
        end
        succ = xsplit arr
        if succ != arr
            # p [:split, succ]
            arr = succ
            next
        end
        break
    end
    arr
end

def magnitude val
    # p [:magnitude, val]
    return val if val.is_a? Integer
    a, b = val
    3 * magnitude(a) + 2 * magnitude(b)
end

x = xreduce [
    [
        [
            [
                0,
                [4,5]
            ],
            [
                0,
                0
            ]
        ],
        [
            [
                [4,5],
                [2,6]
            ],
            [
                9,5
            ]
        ]
    ],
    [
        7,
        [
            [
                [3,7],
                [4,3]
            ],
            [
                [6,3],
                [8,8]
            ]
        ]
    ]
]
# p DATA
p x
x = xreduce [x, [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]]
p x
# exit

# p magnitude [[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]



# x = DATA[1..-1].reduce(xreduce DATA[0]){ p _1; xreduce [_1, _2] }
x = DATA.reduce{ p _1; xreduce [_1, _2] }
# p 123
p x
p magnitude x
# puts 'Part 1: %s' % PART1
# puts 'Part 2: %s' % PART2

p DATA.product(DATA).reject{ _1 == _2 }
    .map{ magnitude xreduce [_1, _2] }
    .max
