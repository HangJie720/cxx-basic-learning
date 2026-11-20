/*
二叉树的中序遍历
返回二叉树的中序遍历结果。
*/

#include <iostream>
#include <vector>
#include <stack>

using namespace std;

struct TreeNode {
    int val;
    TreeNode *left, *right;
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

class Solution {
public:
    vector<int> inorderTraversal(TreeNode* root) {
        vector<int> ans;
        stack<TreeNode*> st;
        while (root || !st.empty()) {
            while (root) { st.push(root); root = root->left; }
            root = st.top(); st.pop();
            ans.push_back(root->val);
            root = root->right;
        }
        return ans;
    }
};

int main() {
    TreeNode* root = new TreeNode(1);
    root->right = new TreeNode(2);
    root->right->left = new TreeNode(3);
    Solution s;
    auto r = s.inorderTraversal(root);
    for (int x : r) cout << x << " ";  // 1 3 2
    cout << endl;
    return 0;
}
