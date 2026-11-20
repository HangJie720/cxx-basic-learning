/*
矩阵中的最长递增路径
返回矩阵中允许上下左右移动的最长递增路径长度。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int longestIncreasingPath(vector<vector<int>>& m) {
        int n = m.size(), k = m[0].size(), ans = 0;
        vector<vector<int>> dp(n, vector<int>(k, 0));
        for (int i = 0; i < n; ++i)
            for (int j = 0; j < k; ++j)
                ans = max(ans, dfs(m, dp, i, j));
        return ans;
    }
    int dfs(vector<vector<int>>& m, vector<vector<int>>& dp, int i, int j) {
        if (dp[i][j]) return dp[i][j];
        int best = 1;
        int dx[] = {1, -1, 0, 0}, dy[] = {0, 0, 1, -1};
        for (int d = 0; d < 4; ++d) {
            int x = i + dx[d], y = j + dy[d];
            if (x >= 0 && y >= 0 && x < (int)m.size() && y < (int)m[0].size() && m[x][y] > m[i][j])
                best = max(best, 1 + dfs(m, dp, x, y));
        }
        return dp[i][j] = best;
    }
};

int main() {
    Solution s;
    vector<vector<int>> m = {{9, 9, 4}, {6, 6, 8}, {2, 1, 1}};
    cout << s.longestIncreasingPath(m) << endl;  // 4
    return 0;
}
