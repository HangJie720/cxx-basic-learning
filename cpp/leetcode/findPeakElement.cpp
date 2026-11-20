/*
寻找峰值
返回数组中任意一个峰值元素的下标，nums[-1]=nums[n]=-∞。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    int findPeakElement(vector<int>& nums) {
        int l = 0, r = nums.size() - 1;
        while (l < r) {
            int m = (l + r) / 2;
            if (nums[m] > nums[m + 1]) r = m;
            else l = m + 1;
        }
        return l;
    }
};

int main() {
    Solution s;
    vector<int> n = {1, 2, 3, 1};
    cout << s.findPeakElement(n) << endl;  // 2
    return 0;
}
