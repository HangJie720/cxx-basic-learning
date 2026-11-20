/*
相交链表
找到两个单链表相交的起始节点，不相交返回 nullptr。
*/

#include <iostream>

using namespace std;

struct ListNode {
    int val;
    ListNode *next;
    ListNode(int x) : val(x), next(nullptr) {}
};

class Solution {
public:
    ListNode *getIntersectionNode(ListNode *headA, ListNode *headB) {
        ListNode *a = headA, *b = headB;
        while (a != b) {
            a = a ? a->next : headB;
            b = b ? b->next : headA;
        }
        return a;
    }
};

int main() {
    ListNode* common = new ListNode(8);
    common->next = new ListNode(4);
    common->next->next = new ListNode(5);
    ListNode* a = new ListNode(4);
    a->next = new ListNode(1);
    a->next->next = common;
    ListNode* b = new ListNode(5);
    b->next = new ListNode(6);
    b->next->next = new ListNode(1);
    b->next->next->next = common;
    Solution s;
    cout << s.getIntersectionNode(a, b)->val << endl;  // 8
    return 0;
}
