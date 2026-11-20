/*
只出现一次的数字
数组中除一个元素外，其余都出现两次，找出那个只出现一次的元素。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    int singleNumber(vector<int>& nums) {
        int x = 0;
        for (int n : nums) x ^= n;
        return x;
    }
};

int main() {
    Solution s;
    vector<int> nums = {4, 1, 2, 1, 2};
    cout << s.singleNumber(nums) << endl;  // 4
    return 0;
}
