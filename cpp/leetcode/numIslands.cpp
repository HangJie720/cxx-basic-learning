/*
岛屿数量
'1' 为陆地，'0' 为水，计算岛屿数量。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    int numIslands(vector<vector<char>>& grid) {
        int n = grid.size(), m = grid[0].size(), ans = 0;
        for (int i = 0; i < n; ++i)
            for (int j = 0; j < m; ++j)
                if (grid[i][j] == '1') { dfs(grid, i, j); ++ans; }
        return ans;
    }
    void dfs(vector<vector<char>>& g, int i, int j) {
        if (i < 0 || j < 0 || i >= (int)g.size() || j >= (int)g[0].size() || g[i][j] != '1') return;
        g[i][j] = '0';
        dfs(g, i + 1, j); dfs(g, i - 1, j); dfs(g, i, j + 1); dfs(g, i, j - 1);
    }
};

int main() {
    Solution s;
    vector<vector<char>> g = {
        {'1', '1', '0', '0', '0'},
        {'1', '1', '0', '0', '0'},
        {'0', '0', '1', '0', '0'},
        {'0', '0', '0', '1', '1'}
    };
    cout << s.numIslands(g) << endl;  // 3
    return 0;
}
