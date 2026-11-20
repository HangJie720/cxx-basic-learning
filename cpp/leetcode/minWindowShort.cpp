/*
最小覆盖子串（双指针模板，含示例）
见 minWindow.cpp / minWindowTemplate.cpp，此处为最简实现。
*/

#include <iostream>
#include <string>
#include <unordered_map>

using namespace std;

class Solution {
public:
    string minWindow(string s, string t) {
        unordered_map<char, int> need;
        for (char c : t) ++need[c];
        int cnt = t.size(), l = 0, start = 0, len = INT_MAX;
        for (int r = 0; r < (int)s.size(); ++r) {
            if (need[s[r]]-- > 0) --cnt;
            while (cnt == 0) {
                if (r - l + 1 < len) { len = r - l + 1; start = l; }
                if (need[s[l++]]++ == 0) ++cnt;
            }
        }
        return len == INT_MAX ? "" : s.substr(start, len);
    }
};

int main() {
    Solution s;
    cout << s.minWindow("ADOBECODEBANC", "ABC") << endl;  // BANC
    return 0;
}
