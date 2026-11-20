/*
柱状图中最大的矩形
返回柱状图中能勾勒出的最大矩形面积。
*/

#include <iostream>
#include <vector>
#include <stack>

using namespace std;

class Solution {
public:
    int largestRectangleArea(vector<int>& heights) {
        stack<int> st;
        int ans = 0;
        heights.push_back(0);
        for (int i = 0; i < (int)heights.size(); ++i) {
            while (!st.empty() && heights[i] < heights[st.top()]) {
                int h = heights[st.top()]; st.pop();
                int w = st.empty() ? i : i - st.top() - 1;
                ans = max(ans, h * w);
            }
            st.push(i);
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> h = {2, 1, 5, 6, 2, 3};
    cout << s.largestRectangleArea(h) << endl;  // 10
    return 0;
}
