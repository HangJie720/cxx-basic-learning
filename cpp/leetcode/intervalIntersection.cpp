/*
合并区间（区间列表交集）
返回两个无重叠闭区间列表的交集。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    vector<vector<int>> intervalIntersection(vector<vector<int>>& A, vector<vector<int>>& B) {
        vector<vector<int>> ans;
        int i = 0, j = 0;
        while (i < (int)A.size() && j < (int)B.size()) {
            int lo = max(A[i][0], B[j][0]);
            int hi = min(A[i][1], B[j][1]);
            if (lo <= hi) ans.push_back({lo, hi});
            if (A[i][1] < B[j][1]) ++i; else ++j;
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<vector<int>> A = {{0, 2}, {5, 10}, {13, 23}, {24, 25}};
    vector<vector<int>> B = {{1, 5}, {8, 12}, {15, 24}, {25, 26}};
    auto r = s.intervalIntersection(A, B);
    for (auto& v : r) cout << "[" << v[0] << "," << v[1] << "] ";
    cout << endl;  // [1,2] [5,5] [8,10] [15,23] [24,24] [25,25]
    return 0;
}
