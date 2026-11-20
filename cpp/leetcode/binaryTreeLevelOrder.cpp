/*
二叉树的层序遍历
借助队列自顶向下逐层访问。
*/

#include <iostream>
#include <vector>
#include <queue>

using namespace std;

struct TreeNode {
    int val;
    TreeNode *left, *right;
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

class Solution {
public:
    vector<vector<int>> levelOrder(TreeNode* root) {
        vector<vector<int>> ans;
        if (!root) return ans;
        queue<TreeNode*> q;
        q.push(root);
        while (!q.empty()) {
            int sz = q.size();
            vector<int> level;
            for (int i = 0; i < sz; i++) {
                TreeNode* node = q.front(); q.pop();
                level.push_back(node->val);
                if (node->left) q.push(node->left);
                if (node->right) q.push(node->right);
            }
            ans.push_back(level);
        }
        return ans;
    }
};

int main() {
    TreeNode n1(3), n2(9), n3(20), n4(15), n5(7);
    n1.left = &n2; n1.right = &n3;
    n3.left = &n4; n3.right = &n5;
    Solution s;
    auto ans = s.levelOrder(&n1);
    for (auto& lv : ans) {
        for (int x : lv) cout << x << " ";
        cout << endl;
    }
    return 0;
}
