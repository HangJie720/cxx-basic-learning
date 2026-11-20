/*
K 个一组翻转链表
每 k 个节点一组翻转链表，不足 k 保持原样。
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
    ListNode* reverseKGroup(ListNode* head, int k) {
        ListNode dummy(0); dummy.next = head;
        ListNode* pre = &dummy;
        while (true) {
            ListNode* tail = pre;
            for (int i = 0; i < k && tail; ++i) tail = tail->next;
            if (!tail) break;
            ListNode* cur = pre->next;
            ListNode* next = tail->next;
            ListNode* p = cur;
            ListNode* prev = next;
            for (int i = 0; i < k; ++i) {
                ListNode* nx = p->next;
                p->next = prev;
                prev = p;
                p = nx;
            }
            pre->next = prev;
            pre = cur;
        }
        return dummy.next;
    }
};

int main() {
    ListNode* a = new ListNode(1);
    ListNode* t = a;
    for (int v : {2, 3, 4, 5}) { t->next = new ListNode(v); t = t->next; }
    Solution s;
    ListNode* r = s.reverseKGroup(a, 2);
    while (r) { cout << r->val << " "; r = r->next; }
    cout << endl;  // 2 1 4 3 5
    return 0;
}
