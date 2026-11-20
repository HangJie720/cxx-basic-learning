/*
LRU 缓存
设计并实现 LRU 缓存，get/put 均 O(1)。
*/

#include <iostream>
#include <list>
#include <unordered_map>

using namespace std;

class LRUCache {
public:
    LRUCache(int capacity) : cap(capacity) {}

    int get(int key) {
        auto it = mp.find(key);
        if (it == mp.end()) return -1;
        lst.splice(lst.begin(), lst, it->second);
        return it->second->second;
    }

    void put(int key, int value) {
        auto it = mp.find(key);
        if (it != mp.end()) {
            it->second->second = value;
            lst.splice(lst.begin(), lst, it->second);
            return;
        }
        if ((int)mp.size() == cap) {
            mp.erase(lst.back().first);
            lst.pop_back();
        }
        lst.push_front({key, value});
        mp[key] = lst.begin();
    }

private:
    int cap;
    list<pair<int, int>> lst;
    unordered_map<int, list<pair<int, int>>::iterator> mp;
};

int main() {
    LRUCache c(2);
    c.put(1, 1);
    c.put(2, 2);
    cout << c.get(1) << endl;  // 1
    c.put(3, 3);              // 淘汰 2
    cout << c.get(2) << endl;  // -1
    return 0;
}
