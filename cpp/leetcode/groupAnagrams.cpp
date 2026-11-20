/*
字母异位词分组
将字母异位词组合在一起。
*/

#include <iostream>
#include <vector>
#include <string>
#include <unordered_map>
#include <algorithm>

using namespace std;

class Solution {
public:
    vector<vector<string>> groupAnagrams(vector<string>& strs) {
        unordered_map<string, vector<string>> mp;
        for (auto& s : strs) {
            string key = s;
            sort(key.begin(), key.end());
            mp[key].push_back(s);
        }
        vector<vector<string>> ans;
        for (auto& p : mp) ans.push_back(p.second);
        return ans;
    }
};

int main() {
    Solution s;
    vector<string> in = {"eat", "tea", "tan", "ate", "nat", "bat"};
    auto r = s.groupAnagrams(in);
    for (auto& v : r) {
        for (auto& x : v) cout << x << " ";
        cout << "| ";
    }
    cout << endl;
    return 0;
}
