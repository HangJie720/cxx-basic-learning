/*
矩阵置零
若矩阵某元素为 0，则将其所在行和列全部置 0，原地修改。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    void setZeroes(vector<vector<int>>& m) {
        int r = m.size(), c = m[0].size();
        bool row0 = false, col0 = false;
        for (int j = 0; j < c; ++j) if (m[0][j] == 0) row0 = true;
        for (int i = 0; i < r; ++i) if (m[i][0] == 0) col0 = true;
        for (int i = 1; i < r; ++i)
            for (int j = 1; j < c; ++j)
                if (m[i][j] == 0) { m[i][0] = 0; m[0][j] = 0; }
        for (int i = 1; i < r; ++i)
            for (int j = 1; j < c; ++j)
                if (m[i][0] == 0 || m[0][j] == 0) m[i][j] = 0;
        if (row0) for (int j = 0; j < c; ++j) m[0][j] = 0;
        if (col0) for (int i = 0; i < r; ++i) m[i][0] = 0;
    }
};

int main() {
    Solution s;
    vector<vector<int>> m = {{1, 1, 1}, {1, 0, 1}, {1, 1, 1}};
    s.setZeroes(m);
    for (auto& r : m) { for (int x : r) cout << x << " "; cout << "| "; }
    cout << endl;  // 1 0 1 | 0 0 0 | 1 0 1
    return 0;
}
