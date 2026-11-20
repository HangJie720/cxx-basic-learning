/*
最小覆盖子串
返回 s 中涵盖 t 所有字符的最小子串，没有返回空串。
*/

#include <iostream>
#include <string>
#include <unordered_map>
#include <climits>

using namespace std;

class Solution {
public:
    string minWindow(string s, string t) {
        unordered_map<char, int> need, win;
        for (char c : t) ++need[c];
        int have = 0, total = need.size(), l = 0, start = 0, len = INT_MAX;
        for (int r = 0; r < (int)s.size(); ++r) {
            if (need.count(s[r])) {
                ++win[s[r]];
                if (win[s[r]] == need[s[r]]) ++have;
            }
            while (have == total) {
                if (r - l + 1 < len) { len = r - l + 1; start = l; }
                if (need.count(s[l])) {
                    if (win[s[l]] == need[s[l]]) --have;
                    --win[s[l]];
                }
                ++l;
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
