/*
买卖股票的最佳时机
一次买卖，求最大利润。维护历史最小价。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int maxProfit(vector<int>& prices) {
        if (prices.empty()) return 0;
        int minPrice = prices[0], ans = 0;
        for (int i = 1; i < (int)prices.size(); i++) {
            ans = max(ans, prices[i] - minPrice);
            minPrice = min(minPrice, prices[i]);
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> prices = {7, 1, 5, 3, 6, 4};
    cout << s.maxProfit(prices) << endl;
    return 0;
}
