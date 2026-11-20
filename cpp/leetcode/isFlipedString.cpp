/*
字符串轮转
判断 s2 是否为 s1 的轮转字符串。
*/

#include <iostream>
#include <string>

using namespace std;

class Solution {
public:
    bool isFlipedString(string s1, string s2) {
        return s1.size() == s2.size() && (s1 + s1).find(s2) != string::npos;
    }
};

int main() {
    Solution s;
    cout << s.isFlipedString("waterbottle", "erbottlewat") << endl;  // 1
    cout << s.isFlipedString("aa", "aba") << endl;                   // 0
    return 0;
}
