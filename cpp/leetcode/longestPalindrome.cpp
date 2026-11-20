/*
最长回文子串
返回字符串 s 中的最长回文子串。
*/

#include <iostream>
#include <string>

using namespace std;

class Solution {
public:
    string longestPalindrome(string s) {
        int n = s.size(), start = 0, maxLen = 1;
        auto expand = [&](int l, int r) {
            while (l >= 0 && r < n && s[l] == s[r]) { --l; ++r; }
            if (r - l - 1 > maxLen) { maxLen = r - l - 1; start = l + 1; }
        };
        for (int i = 0; i < n; ++i) {
            expand(i, i);
            expand(i, i + 1);
        }
        return s.substr(start, maxLen);
    }
};

int main() {
    Solution s;
    cout << s.longestPalindrome("babad") << endl;  // bab 或 aba
    return 0;
}
