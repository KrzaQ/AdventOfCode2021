#include <algorithm>
#include <iostream>
#include <unordered_map>
#include <map>
#include <vector>
#include <cstdint>
#include <tuple>
#include <queue>
#include <array>
#include <iomanip>
#include <fstream>

struct map;
struct bigmap;
using point = std::tuple<int, int>;

using puzzle_data = std::tuple<std::vector<int>, size_t>;

template<typename M>
std::map<point, int>
find_distances(M const& map, point from, point to);

template<typename M>
int compute_across_distance(puzzle_data const&);

puzzle_data load_data();

int main()
{
    auto data = load_data();
    std::cout << "Part 1: " << compute_across_distance<map>(data) << '\n';
    std::cout << "Part 2: " << compute_across_distance<bigmap>(data) << '\n';
}

puzzle_data load_data()
{
    std::ifstream f("data.txt");
    std::string line;
    std::vector<int> numbers;
    size_t size = 0;
    while(std::getline(f, line)) {
        auto not_digit = [](char c){ return !isdigit(c); };
        auto rem_it = std::remove_if(line.begin(), line.end(), not_digit);
        line.erase(rem_it, line.end());
        if (line.size() > 0)
            size = line.size();
        auto digit_to_int = [](char c){ return c - '0'; };
        std::transform(line.cbegin(), line.cend(),
            std::back_inserter(numbers), digit_to_int);
    }

    return {numbers, size};
}

template<typename M>
std::map<point, int>
find_distances(M const& map, point from, point to)
{
    std::map<point, int> distances;

    using pq_elem = std::tuple<point, int>;
    using cmp = decltype([](pq_elem const& l, pq_elem const& r){
        return std::get<1>(l) > std::get<1>(r);
    });
    std::priority_queue<pq_elem, std::vector<pq_elem>, cmp> queue;
    queue.push({{0, 0}, 0});

    auto valid_point = [&](point p){
        auto &[x, y] = p;
        return x >= 0 && x < map.size() && y >= 0 && y < map.size();
    };

    while(queue.size()) {
        auto [p, dist] = queue.top();
        auto &[x, y] = p;
        queue.pop();
        if (distances.find(p) != distances.end())
            continue;
        distances.emplace(p, dist);
        if (p == to)
            break;

        std::array<point, 4> next = {
            point{x-1, y}, point{x+1, y}, point{x, y-1}, point{x, y+1}
        };
        for (point const& p : next) {
            if (valid_point(p) && distances.find(p) == distances.cend())
                queue.push({p, dist+map(p)});
        }
    }

    return distances;
}

template<typename M>
int compute_across_distance(puzzle_data const& pd)
{
    auto const&[data, size] = pd;
    M map(data, size);
    auto final_point = point{map.size()-1, map.size()-1};
    auto distances = find_distances(map, {0, 0}, final_point);
    return distances[final_point];
}

struct map
{
    map(std::vector<int> const& data, size_t size) : data_{data}, s_{size} {}
    map(map const&)=delete;
    map& operator=(map const&)=delete;
    ~map()=default;

    int operator()(point p) const {
        auto&& [x, y] = p;
        return data_[y * s_ + x];
    };

    size_t size() const { return s_; }

private:
    std::vector<int> const& data_;
    size_t s_;
};

struct bigmap
{
    bigmap(std::vector<int> const& data, size_t size) : data_{data}, s_{size} {}
    bigmap(bigmap const&)=delete;
    bigmap& operator=(map const&)=delete;
    ~bigmap()=default;

    int operator()(point p) const {
        auto&& [x, y] = p;
        map m(data_, s_);
        int ret = m({x % s_, y % s_});
        ret += x / s_ + y / s_;
        return ret > 9 ? ret - 9 : ret;
    };

    size_t size() const { return s_ * 5; }

private:
    std::vector<int> const& data_;
    size_t s_;
};