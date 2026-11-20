/*
岛屿的最大面积
返回矩阵中值为 1 的连通区域最大面积。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int maxAreaOfIsland(vector<vector<int>>& g) {
        int n = g.size(), m = g[0].size(), ans = 0;
        for (int i = 0; i < n; ++i)
            for (int j = 0; j < m; ++j)
                if (g[i][j] == 1) ans = max(ans, dfs(g, i, j));
        return ans;
    }
    int dfs(vector<vector<int>>& g, int i, int j) {
        if (i < 0 || j < 0 || i >= (int)g.size() || j >= (int)g[0].size() || g[i][j] != 1) return 0;
        g[i][j] = 0;
        return 1 + dfs(g, i + 1, j) + dfs(g, i - 1, j) + dfs(g, i, j + 1) + dfs(g, i, j - 1);
    }
};

int main() {
    Solution s;
    vector<vector<int>> g = {
        {0,0,1,0,0,0,0,1,0,0,0,0,0},
        {0,0,0,0,0,0,0,1,1,1,0,0,0},
        {0,1,1,0,1,0,0,0,0,0,0,0,0},
        {1,1,0,0,1,1,0,0,1,0,1,0,0},
        {1,1,0,0,1,1,0,0,1,1,1,0,0}
    };
    cout << s.maxAreaOfIsland(g) << endl;  // 6
    return 0;
}
