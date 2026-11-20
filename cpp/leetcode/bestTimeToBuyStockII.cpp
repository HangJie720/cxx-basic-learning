/*
买卖股票的最佳时机 II
可以多次买卖，返回最大利润总和。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    int maxProfit(vector<int>& prices) {
        int ans = 0;
        for (int i = 1; i < (int)prices.size(); ++i) {
            if (prices[i] > prices[i - 1]) ans += prices[i] - prices[i - 1];
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> p = {7, 1, 5, 3, 6, 4};
    cout << s.maxProfit(p) << endl;  // 7
    return 0;
}
