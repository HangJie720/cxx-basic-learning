/*
路径总和 II
返回二叉树中从根到叶子和等于 targetSum 的所有路径。
*/

#include <iostream>
#include <vector>

using namespace std;

struct TreeNode {
    int val;
    TreeNode *left, *right;
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

class Solution {
public:
    vector<vector<int>> pathSum(TreeNode* root, int target) {
        vector<vector<int>> ans;
        vector<int> cur;
        dfs(root, target, cur, ans);
        return ans;
    }
    void dfs(TreeNode* root, int t, vector<int>& cur, vector<vector<int>>& ans) {
        if (!root) return;
        cur.push_back(root->val);
        if (!root->left && !root->right && t == root->val) ans.push_back(cur);
        dfs(root->left, t - root->val, cur, ans);
        dfs(root->right, t - root->val, cur, ans);
        cur.pop_back();
    }
};

int main() {
    TreeNode* root = new TreeNode(5);
    root->left = new TreeNode(4);
    root->right = new TreeNode(8);
    root->left->left = new TreeNode(11);
    root->left->left->left = new TreeNode(7);
    root->left->left->right = new TreeNode(2);
    root->right->left = new TreeNode(13);
    root->right->right = new TreeNode(4);
    root->right->right->left = new TreeNode(5);
    root->right->right->right = new TreeNode(1);
    Solution s;
    auto r = s.pathSum(root, 22);
    for (auto& v : r) {
        for (int x : v) cout << x << " ";
        cout << "| ";
    }
    cout << endl;  // 5 4 11 2 | 5 8 4 5
    return 0;
}
