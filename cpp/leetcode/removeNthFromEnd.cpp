/*
删除链表的倒数第 N 个节点
一次遍历完成，返回头节点。
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
    ListNode* removeNthFromEnd(ListNode* head, int n) {
        ListNode dummy(0); dummy.next = head;
        ListNode *fast = &dummy, *slow = &dummy;
        for (int i = 0; i < n; ++i) fast = fast->next;
        while (fast->next) { fast = fast->next; slow = slow->next; }
        slow->next = slow->next->next;
        return dummy.next;
    }
};

int main() {
    ListNode* a = new ListNode(1);
    ListNode* t = a;
    for (int v : {2, 3, 4, 5}) { t->next = new ListNode(v); t = t->next; }
    Solution s;
    ListNode* r = s.removeNthFromEnd(a, 2);
    while (r) { cout << r->val << " "; r = r->next; }
    cout << endl;  // 1 2 3 5
    return 0;
}
