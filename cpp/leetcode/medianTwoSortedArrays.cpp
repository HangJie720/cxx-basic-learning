/*
寻找两个正序数组的中位数
O(log(m+n)) 求两个有序数组的中位数。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    double findMedianSortedArrays(vector<int>& a, vector<int>& b) {
        if (a.size() > b.size()) swap(a, b);
        int m = a.size(), n = b.size(), lo = 0, hi = m, half = (m + n + 1) / 2;
        while (lo <= hi) {
            int i = (lo + hi) / 2, j = half - i;
            if (i < m && b[j - 1] > a[i]) lo = i + 1;
            else if (i > 0 && a[i - 1] > b[j]) hi = i - 1;
            else {
                int maxL = i == 0 ? b[j - 1] : (j == 0 ? a[i - 1] : max(a[i - 1], b[j - 1]));
                if ((m + n) % 2) return maxL;
                int minR = i == m ? b[j] : (j == n ? a[i] : min(a[i], b[j]));
                return (maxL + minR) / 2.0;
            }
        }
        return 0.0;
    }
};

int main() {
    Solution s;
    vector<int> a = {1, 3}, b = {2};
    cout << s.findMedianSortedArrays(a, b) << endl;  // 2
    return 0;
}
