/*
有效的括号
判断字符串中的括号是否正确配对。'(', ')', '{', '}', '[', ']'
*/

#include <iostream>
#include <string>
#include <stack>

using namespace std;

class Solution {
public:
    bool isValid(string s) {
        stack<char> st;
        for (char c : s) {
            if (c == '(' || c == '{' || c == '[') st.push(c);
            else {
                if (st.empty()) return false;
                char t = st.top(); st.pop();
                if ((c == ')' && t != '(') || (c == '}' && t != '{') ||
                    (c == ']' && t != '[')) return false;
            }
        }
        return st.empty();
    }
};

int main() {
    Solution s;
    cout << s.isValid("()[]{}") << endl;  // 1
    cout << s.isValid("(]") << endl;      // 0
    return 0;
}
