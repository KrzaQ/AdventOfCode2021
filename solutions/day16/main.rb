#!/usr/bin/ruby

DATA = File.read('data.txt').strip.chars.map{ _1.to_i(16).to_s(2) }
    .map{ '%04d' % _1.to_i }.join.chars

def parse_packet data
    v = data[0...3].join.to_i(2)
    id = data[3...6].join.to_i(2)
    data = data[6..-1]
    len = 6
    case id
    when 4
        val = []
        loop do
            first, *d = data[0...5]
            val += d
            len += 5
            data = data[5..-1]
            break if first == ?0
        end
        return [len, v, id, val]
    else
        len_type_id = data[0]
        if len_type_id == ?0
            sub_packets_bits = data[1...16].join.to_i(2)
            read = 0
            sub_packets = []
            arr = nil
            data = data[16..-1]
            len += 16
            loop do
                arr = parse_packet data
                read += arr[0]
                len += arr[0]
                data = data[arr[0]..-1]
                sub_packets.push arr
                break if read >= sub_packets_bits
            end
            return [len, v, id, sub_packets]
        elsif len_type_id == ?1
            num_sub_packets = data[1...12].join.to_i(2)
            read = 0
            sub_packets = []
            arr = nil
            data = data[12..-1]
            len += 12
            loop do
                arr = parse_packet data
                read += 1
                data = data[arr[0]..-1]
                len += arr[0]
                sub_packets.push arr
                break if read >= num_sub_packets
            end
            return [len, v, id, sub_packets]
        else
            raise :lol
        end
    end
end

def sum_versions data
    _, v, id, o = data
    if id == 4
        return v
    else
        return v + o.map{ sum_versions _1 }.sum
    end
end

def evalx packet
    _, v, id, o = packet
    case id
    when 0
        o.map{ evalx _1 }.sum
    when 1
        o.map{ evalx _1 }.reduce(:*)
    when 2
        o.map{ evalx _1 }.min
    when 3
        o.map{ evalx _1 }.max
    when 4
        o.join.to_i(2)
    when 5
        a, b = o.map{ evalx _1 }
        a > b ? 1 : 0
    when 6
        a, b = o.map{ evalx _1 }
        a < b ? 1 : 0
    when 7
        a, b = o.map{ evalx _1 }
        a == b ? 1 : 0
    end
end

PART1 = sum_versions parse_packet DATA
PART2 = evalx parse_packet DATA

puts 'Part 1: %s' % PART1
puts 'Part 2: %s' % PART2
