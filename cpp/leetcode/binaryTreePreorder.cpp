/*
二叉树的前序遍历
递归与迭代两种写法。
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
    // 递归
    vector<int> preorderRecursive(TreeNode* root) {
        vector<int> ans;
        dfs(root, ans);
        return ans;
    }

    void dfs(TreeNode* root, vector<int>& ans) {
        if (!root) return;
        ans.push_back(root->val);
        dfs(root->left, ans);
        dfs(root->right, ans);
    }

    // 迭代
    vector<int> preorderIterative(TreeNode* root) {
        vector<int> ans;
        stack<TreeNode*> st;
        TreeNode* cur = root;
        while (cur || !st.empty()) {
            while (cur) {
                ans.push_back(cur->val);
                st.push(cur);
                cur = cur->left;
            }
            cur = st.top(); st.pop();
            cur = cur->right;
        }
        return ans;
    }
};

int main() {
    TreeNode n1(1), n2(2), n3(3);
    n1.right = &n2; n2.left = &n3;
    Solution s;
    auto a = s.preorderIterative(&n1);
    for (int x : a) cout << x << " ";
    cout << endl;
    return 0;
}
