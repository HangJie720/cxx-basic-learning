/*
最大矩形
返回由 '1' 组成的矩阵中最大只含 '1' 的矩形面积。
*/

#include <iostream>
#include <vector>
#include <stack>
#include <algorithm>

using namespace std;

class Solution {
public:
    int maximalRectangle(vector<vector<char>>& m) {
        if (m.empty()) return 0;
        int n = m[0].size(), ans = 0;
        vector<int> h(n, 0);
        for (auto& row : m) {
            for (int j = 0; j < n; ++j) h[j] = row[j] == '1' ? h[j] + 1 : 0;
            ans = max(ans, largest(h));
        }
        return ans;
    }
    int largest(vector<int>& h) {
        stack<int> st; h.push_back(0);
        int ans = 0;
        for (int i = 0; i < (int)h.size(); ++i) {
            while (!st.empty() && h[i] < h[st.top()]) {
                int x = h[st.top()]; st.pop();
                int w = st.empty() ? i : i - st.top() - 1;
                ans = max(ans, x * w);
            }
            st.push(i);
        }
        h.pop_back();
        return ans;
    }
};

int main() {
    Solution s;
    vector<vector<char>> m = {
        {'1','0','1','0','0'},
        {'1','0','1','1','1'},
        {'1','1','1','1','1'},
        {'1','0','0','1','0'}
    };
    cout << s.maximalRectangle(m) << endl;  // 6
    return 0;
}
