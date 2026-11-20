/*
每日温度
返回数组，ans[i] 为下一次更高温度出现在几天后，没有则 0。
*/

#include <iostream>
#include <vector>
#include <stack>

using namespace std;

class Solution {
public:
    vector<int> dailyTemperatures(vector<int>& T) {
        int n = T.size();
        vector<int> ans(n);
        stack<int> st;
        for (int i = 0; i < n; ++i) {
            while (!st.empty() && T[i] > T[st.top()]) {
                int j = st.top(); st.pop();
                ans[j] = i - j;
            }
            st.push(i);
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> t = {73, 74, 75, 71, 69, 72, 76, 73};
    auto r = s.dailyTemperatures(t);
    for (int x : r) cout << x << " ";  // 1 1 4 2 1 1 0 0
    cout << endl;
    return 0;
}
