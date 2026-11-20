/*
最小覆盖子串（滑动窗口模板）
通用模板，便于对比 minWindow.cpp。
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
        int total = need.size(), have = 0, l = 0, start = 0, len = INT_MAX;
        unordered_map<char, int> win;
        for (int r = 0; r < (int)s.size(); ++r) {
            char c = s[r];
            if (need.count(c)) {
                if (++win[c] == need[c]) ++have;
            }
            while (have == total) {
                if (r - l + 1 < len) { len = r - l + 1; start = l; }
                char d = s[l++];
                if (need.count(d)) {
                    if (win[d]-- == need[d]) --have;
                }
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
