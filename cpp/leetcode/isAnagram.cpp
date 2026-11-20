/*
有效的字母异位词
判断两个字符串是否由相同字母（数量相同）组成。
*/

#include <iostream>
#include <string>
#include <array>

using namespace std;

class Solution {
public:
    bool isAnagram(string s, string t) {
        if (s.size() != t.size()) return false;
        array<int, 26> cnt{};
        for (char c : s) ++cnt[c - 'a'];
        for (char c : t) if (--cnt[c - 'a'] < 0) return false;
        return true;
    }
};

int main() {
    Solution s;
    cout << s.isAnagram("anagram", "nagaram") << endl;  // 1
    cout << s.isAnagram("rat", "car") << endl;           // 0
    return 0;
}
