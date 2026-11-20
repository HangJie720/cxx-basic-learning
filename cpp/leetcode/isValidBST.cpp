/*
验证二叉搜索树
判断二叉树是否为有效的二叉搜索树。
*/

#include <iostream>
#include <climits>

using namespace std;

struct TreeNode {
    int val;
    TreeNode *left, *right;
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

class Solution {
public:
    bool isValidBST(TreeNode* root) {
        return check(root, LONG_MIN, LONG_MAX);
    }
    bool check(TreeNode* root, long lo, long hi) {
        if (!root) return true;
        if (root->val <= lo || root->val >= hi) return false;
        return check(root->left, lo, root->val) && check(root->right, root->val, hi);
    }
};

int main() {
    TreeNode* root = new TreeNode(2);
    root->left = new TreeNode(1);
    root->right = new TreeNode(3);
    Solution s;
    cout << s.isValidBST(root) << endl;  // 1
    return 0;
}
