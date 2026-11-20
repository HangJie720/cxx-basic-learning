/*
多数元素
返回数组中出现次数超过 n/2 的元素。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    int majorityElement(vector<int>& nums) {
        int cand = 0, cnt = 0;
        for (int x : nums) {
            if (cnt == 0) { cand = x; cnt = 1; }
            else if (x == cand) ++cnt;
            else --cnt;
        }
        return cand;
    }
};

int main() {
    Solution s;
    vector<int> nums = {3, 2, 3};
    cout << s.majorityElement(nums) << endl;  // 3
    return 0;
}
