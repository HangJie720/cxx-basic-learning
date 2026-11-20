/*
填充每个节点的下一个右侧节点
将二叉树每层节点通过 next 指针连成链表，O(1) 空间。
*/

#include <iostream>

using namespace std;

struct Node {
    int val;
    Node *left, *right, *next;
    Node(int x) : val(x), left(nullptr), right(nullptr), next(nullptr) {}
};

class Solution {
public:
    Node* connect(Node* root) {
        Node* head = root;
        while (head) {
            Node dummy(0);
            Node* tail = &dummy;
            for (Node* cur = head; cur; cur = cur->next) {
                if (cur->left) { tail->next = cur->left; tail = tail->next; }
                if (cur->right) { tail->next = cur->right; tail = tail->next; }
            }
            head = dummy.next;
        }
        return root;
    }
};

int main() {
    Node* root = new Node(1);
    root->left = new Node(2);
    root->right = new Node(3);
    root->left->left = new Node(4);
    root->left->right = new Node(5);
    root->right->right = new Node(7);
    Solution s;
    s.connect(root);
    cout << root->left->next->val << endl;  // 3
    return 0;
}
