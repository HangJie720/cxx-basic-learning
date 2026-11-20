/*
只出现一次的数字 II
除一个元素外，其余都出现三次，找出那个只出现一次的元素。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    int singleNumber(vector<int>& nums) {
        int ones = 0, twos = 0;
        for (int x : nums) {
            ones = (ones ^ x) & ~twos;
            twos = (twos ^ x) & ~ones;
        }
        return ones;
    }
};

int main() {
    Solution s;
    vector<int> n = {2, 2, 3, 2};
    cout << s.singleNumber(n) << endl;  // 3
    return 0;
}
