/*
字符串压缩
对字符串做基本压缩，返回压缩后更短的字符串，否则返回原串。
*/

#include <iostream>
#include <string>

using namespace std;

class Solution {
public:
    string compressString(string s) {
        string ans;
        int i = 0;
        while (i < (int)s.size()) {
            int j = i;
            while (j < (int)s.size() && s[j] == s[i]) ++j;
            ans.push_back(s[i]);
            ans += to_string(j - i);
            i = j;
        }
        return ans.size() < s.size() ? ans : s;
    }
};

int main() {
    Solution s;
    cout << s.compressString("aabcccccaaa") << endl;  // a2b1c5a3
    cout << s.compressString("abc") << endl;           // abc
    return 0;
}
