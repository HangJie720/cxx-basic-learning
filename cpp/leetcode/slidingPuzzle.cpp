/*
滑动谜题（八数码/华容道 BFS）
返回从初始局面到目标 [[1,2,3],[4,5,0]] 的最少步数，不可达返回 -1。
*/

#include <iostream>
#include <vector>
#include <queue>
#include <unordered_set>
#include <string>

using namespace std;

class Solution {
public:
    int slidingPuzzle(vector<vector<int>>& board) {
        string target = "123450";
        string start;
        for (auto& r : board) for (int x : r) start.push_back('0' + x);
        if (start == target) return 0;
        vector<vector<int>> moves = {{1, 3}, {0, 2, 4}, {1, 5}, {0, 4}, {1, 3, 5}, {2, 4}};
        unordered_set<string> seen{start};
        queue<string> q; q.push(start);
        int step = 0;
        while (!q.empty()) {
            ++step;
            for (int sz = q.size(); sz > 0; --sz) {
                string cur = q.front(); q.pop();
                int z = cur.find('0');
                for (int nx : moves[z]) {
                    swap(cur[z], cur[nx]);
                    if (seen.insert(cur).second) {
                        if (cur == target) return step;
                        q.push(cur);
                    }
                    swap(cur[z], cur[nx]);
                }
            }
        }
        return -1;
    }
};

int main() {
    Solution s;
    vector<vector<int>> b = {{1, 2, 3}, {4, 0, 5}};
    cout << s.slidingPuzzle(b) << endl;  // 1
    return 0;
}
