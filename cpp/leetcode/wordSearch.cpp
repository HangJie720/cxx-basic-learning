/*
单词搜索
在二维字符网格中搜索单词，每个格子只能用一次。
*/

#include <iostream>
#include <vector>
#include <string>

using namespace std;

class Solution {
public:
    bool exist(vector<vector<char>>& board, string word) {
        for (int i = 0; i < (int)board.size(); ++i)
            for (int j = 0; j < (int)board[0].size(); ++j)
                if (dfs(board, word, i, j, 0)) return true;
        return false;
    }
    bool dfs(vector<vector<char>>& b, string& w, int i, int j, int k) {
        if (k == (int)w.size()) return true;
        if (i < 0 || j < 0 || i >= (int)b.size() || j >= (int)b[0].size() || b[i][j] != w[k]) return false;
        char t = b[i][j]; b[i][j] = '#';
        bool ok = dfs(b, w, i + 1, j, k + 1) || dfs(b, w, i - 1, j, k + 1) ||
                  dfs(b, w, i, j + 1, k + 1) || dfs(b, w, i, j - 1, k + 1);
        b[i][j] = t;
        return ok;
    }
};

int main() {
    Solution s;
    vector<vector<char>> b = {{'A', 'B', 'C', 'E'}, {'S', 'F', 'C', 'S'}, {'A', 'D', 'E', 'E'}};
    cout << s.exist(b, "ABCCED") << endl;  // 1
    return 0;
}
