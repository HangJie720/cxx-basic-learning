/*
拓扑排序（课程表）
判断能否完成所有课程，课程有先修关系。
*/

#include <iostream>
#include <vector>
#include <queue>

using namespace std;

class Solution {
public:
    bool canFinish(int numCourses, vector<vector<int>>& prerequisites) {
        vector<vector<int>> g(numCourses);
        vector<int> indeg(numCourses, 0);
        for (auto& p : prerequisites) { g[p[1]].push_back(p[0]); ++indeg[p[0]]; }
        queue<int> q;
        for (int i = 0; i < numCourses; ++i) if (indeg[i] == 0) q.push(i);
        int cnt = 0;
        while (!q.empty()) {
            int c = q.front(); q.pop();
            ++cnt;
            for (int nx : g[c]) if (--indeg[nx] == 0) q.push(nx);
        }
        return cnt == numCourses;
    }
};

int main() {
    Solution s;
    vector<vector<int>> pre = {{1, 0}};
    cout << s.canFinish(2, pre) << endl;  // 1
    return 0;
}
