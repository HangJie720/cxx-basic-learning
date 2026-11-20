/*
旋转图像
将 n x n 矩阵顺时针旋转 90 度，原地修改。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    void rotate(vector<vector<int>>& m) {
        int n = m.size();
        for (int i = 0; i < n; ++i)
            for (int j = 0; j < i; ++j)
                swap(m[i][j], m[j][i]);
        for (auto& row : m) reverse(row.begin(), row.end());
    }
};

int main() {
    Solution s;
    vector<vector<int>> m = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
    s.rotate(m);
    for (auto& r : m) { for (int x : r) cout << x << " "; cout << "| "; }
    cout << endl;  // 7 4 1 | 8 5 2 | 9 6 3
    return 0;
}
