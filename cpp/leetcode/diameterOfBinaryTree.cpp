/*
二叉树的直径
返回二叉树任意两节点路径的最大长度（边数）。
*/

#include <iostream>
#include <algorithm>

using namespace std;

struct TreeNode {
    int val;
    TreeNode *left, *right;
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

class Solution {
public:
    int diameterOfBinaryTree(TreeNode* root) {
        int ans = 0;
        depth(root, ans);
        return ans;
    }
    int depth(TreeNode* root, int& ans) {
        if (!root) return 0;
        int l = depth(root->left, ans);
        int r = depth(root->right, ans);
        ans = max(ans, l + r);
        return 1 + max(l, r);
    }
};

int main() {
    TreeNode* root = new TreeNode(1);
    root->left = new TreeNode(2);
    root->right = new TreeNode(3);
    root->left->left = new TreeNode(4);
    root->left->right = new TreeNode(5);
    Solution s;
    cout << s.diameterOfBinaryTree(root) << endl;  // 3
    return 0;
}
