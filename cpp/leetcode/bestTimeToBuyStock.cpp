/*
买卖股票的最佳时机
一次买卖，返回最大利润。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int maxProfit(vector<int>& prices) {
        int minp = INT_MAX, ans = 0;
        for (int p : prices) {
            minp = min(minp, p);
            ans = max(ans, p - minp);
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> p = {7, 1, 5, 3, 6, 4};
    cout << s.maxProfit(p) << endl;  // 5
    return 0;
}
