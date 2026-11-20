/*
二叉树的锯齿形层序遍历
先从左到右，再从右到左，交替进行。
*/

#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>

using namespace std;

struct TreeNode {
    int val;
    TreeNode *left, *right;
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

class Solution {
public:
    vector<vector<int>> zigzagLevelOrder(TreeNode* root) {
        vector<vector<int>> ans;
        if (!root) return ans;
        queue<TreeNode*> q; q.push(root);
        bool left = true;
        while (!q.empty()) {
            int sz = q.size();
            vector<int> level(sz);
            for (int i = 0; i < sz; ++i) {
                TreeNode* t = q.front(); q.pop();
                int idx = left ? i : sz - 1 - i;
                level[idx] = t->val;
                if (t->left) q.push(t->left);
                if (t->right) q.push(t->right);
            }
            ans.push_back(level);
            left = !left;
        }
        return ans;
    }
};

int main() {
    TreeNode* root = new TreeNode(3);
    root->left = new TreeNode(9);
    root->right = new TreeNode(20);
    root->right->left = new TreeNode(15);
    root->right->right = new TreeNode(7);
    Solution s;
    auto r = s.zigzagLevelOrder(root);
    for (auto& v : r) { for (int x : v) cout << x << " "; cout << "| "; }
    cout << endl;  // 3 | 20 9 | 15 7
    return 0;
}
