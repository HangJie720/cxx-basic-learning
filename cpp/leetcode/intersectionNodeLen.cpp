/*
相交链表（链表相交节点）
见 getIntersectionNode.cpp，此文件为同名题目的另一写法（先求长度再对齐）。
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
        int la = len(headA), lb = len(headB);
        int d = abs(la - lb);
        if (la > lb) while (d--) headA = headA->next;
        else while (d--) headB = headB->next;
        while (headA && headB) {
            if (headA == headB) return headA;
            headA = headA->next; headB = headB->next;
        }
        return nullptr;
    }
    int len(ListNode* h) {
        int n = 0;
        while (h) { ++n; h = h->next; }
        return n;
    }
};

int main() {
    ListNode* c = new ListNode(8);
    c->next = new ListNode(4);
    ListNode* a = new ListNode(4); a->next = new ListNode(1); a->next->next = c;
    ListNode* b = new ListNode(5); b->next = new ListNode(6); b->next->next = new ListNode(1); b->next->next->next = c;
    Solution s;
    cout << s.getIntersectionNode(a, b)->val << endl;  // 8
    return 0;
}
