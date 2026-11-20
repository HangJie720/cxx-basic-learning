/*
反转链表 II
反转从位置 left 到 right 的链表节点。
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
    ListNode* reverseBetween(ListNode* head, int left, int right) {
        ListNode dummy(0); dummy.next = head;
        ListNode* pre = &dummy;
        for (int i = 1; i < left; ++i) pre = pre->next;
        ListNode* cur = pre->next;
        for (int i = 0; i < right - left; ++i) {
            ListNode* nx = cur->next;
            cur->next = nx->next;
            nx->next = pre->next;
            pre->next = nx;
        }
        return dummy.next;
    }
};

int main() {
    ListNode* a = new ListNode(1);
    ListNode* t = a;
    for (int v : {2, 3, 4, 5}) { t->next = new ListNode(v); t = t->next; }
    Solution s;
    ListNode* r = s.reverseBetween(a, 2, 4);
    while (r) { cout << r->val << " "; r = r->next; }
    cout << endl;  // 1 4 3 2 5
    return 0;
}
