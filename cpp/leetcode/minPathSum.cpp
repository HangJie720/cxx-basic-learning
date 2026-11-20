/*
最小路径和
m x n 非负数网格，从左上到右下，返回路径上数字之和最小值。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int minPathSum(vector<vector<int>>& grid) {
        int m = grid.size(), n = grid[0].size();
        for (int i = 1; i < m; ++i) grid[i][0] += grid[i - 1][0];
        for (int j = 1; j < n; ++j) grid[0][j] += grid[0][j - 1];
        for (int i = 1; i < m; ++i)
            for (int j = 1; j < n; ++j)
                grid[i][j] += min(grid[i - 1][j], grid[i][j - 1]);
        return grid[m - 1][n - 1];
    }
};

int main() {
    Solution s;
    vector<vector<int>> g = {{1, 3, 1}, {1, 5, 1}, {4, 2, 1}};
    cout << s.minPathSum(g) << endl;  // 7
    return 0;
}
