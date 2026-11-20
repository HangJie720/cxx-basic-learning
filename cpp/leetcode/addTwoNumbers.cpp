/*
两数相加
两个非空链表表示两个非负整数，按逆序存储，返回相加后的链表。
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
    ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
        ListNode dummy(0);
        ListNode* cur = &dummy;
        int carry = 0;
        while (l1 || l2 || carry) {
            int sum = carry;
            if (l1) { sum += l1->val; l1 = l1->next; }
            if (l2) { sum += l2->val; l2 = l2->next; }
            carry = sum / 10;
            cur->next = new ListNode(sum % 10);
            cur = cur->next;
        }
        return dummy.next;
    }
};

int main() {
    ListNode* a = new ListNode(2);
    a->next = new ListNode(4);
    a->next->next = new ListNode(3);
    ListNode* b = new ListNode(5);
    b->next = new ListNode(6);
    b->next->next = new ListNode(4);
    Solution s;
    ListNode* r = s.addTwoNumbers(a, b);
    while (r) { cout << r->val; r = r->next; }
    cout << endl;  // 708
    return 0;
}
