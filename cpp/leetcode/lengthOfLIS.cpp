/*
最长递增子序列
返回数组中最长严格递增子序列的长度。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int lengthOfLIS(vector<int>& nums) {
        vector<int> tails;
        for (int x : nums) {
            auto it = lower_bound(tails.begin(), tails.end(), x);
            if (it == tails.end()) tails.push_back(x);
            else *it = x;
        }
        return tails.size();
    }
};

int main() {
    Solution s;
    vector<int> nums = {10, 9, 2, 5, 3, 7, 101, 18};
    cout << s.lengthOfLIS(nums) << endl;  // 4
    return 0;
}
