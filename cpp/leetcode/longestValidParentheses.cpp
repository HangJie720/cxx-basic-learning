/*
最长有效括号
返回字符串中最长有效（正确闭合）括号子串长度。
*/

#include <iostream>
#include <string>
#include <stack>
#include <algorithm>

using namespace std;

class Solution {
public:
    int longestValidParentheses(string s) {
        stack<int> st;
        st.push(-1);
        int ans = 0;
        for (int i = 0; i < (int)s.size(); ++i) {
            if (s[i] == '(') st.push(i);
            else {
                st.pop();
                if (st.empty()) st.push(i);
                else ans = max(ans, i - st.top());
            }
        }
        return ans;
    }
};

int main() {
    Solution s;
    cout << s.longestValidParentheses(")()())") << endl;  // 4
    return 0;
}
