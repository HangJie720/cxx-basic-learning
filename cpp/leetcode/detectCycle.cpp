/*
环形链表 II
返回链表入环节点，无环返回 nullptr。
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
    ListNode *detectCycle(ListNode *head) {
        ListNode *slow = head, *fast = head;
        while (fast && fast->next) {
            slow = slow->next;
            fast = fast->next->next;
            if (slow == fast) {
                ListNode* p = head;
                while (p != slow) { p = p->next; slow = slow->next; }
                return p;
            }
        }
        return nullptr;
    }
};

int main() {
    ListNode* a = new ListNode(3);
    a->next = new ListNode(2);
    a->next->next = new ListNode(0);
    a->next->next->next = new ListNode(-4);
    a->next->next->next->next = a->next;
    Solution s;
    cout << s.detectCycle(a)->val << endl;  // 2
    return 0;
}
