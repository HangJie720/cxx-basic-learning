/*
颜色分类
对包含 0/1/2 的数组进行原地排序（荷兰国旗问题）。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    void sortColors(vector<int>& nums) {
        int l = 0, r = nums.size() - 1, i = 0;
        while (i <= r) {
            if (nums[i] == 0) swap(nums[i++], nums[l++]);
            else if (nums[i] == 2) swap(nums[i], nums[r--]);
            else ++i;
        }
    }
};

int main() {
    Solution s;
    vector<int> n = {2, 0, 2, 1, 1, 0};
    s.sortColors(n);
    for (int x : n) cout << x << " ";  // 0 0 1 1 2 2
    cout << endl;
    return 0;
}
