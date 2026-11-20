/*
环形链表
判断链表是否有环。
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
    bool hasCycle(ListNode *head) {
        ListNode *slow = head, *fast = head;
        while (fast && fast->next) {
            slow = slow->next;
            fast = fast->next->next;
            if (slow == fast) return true;
        }
        return false;
    }
};

int main() {
    ListNode* a = new ListNode(3);
    a->next = new ListNode(2);
    a->next->next = new ListNode(0);
    a->next->next->next = new ListNode(-4);
    a->next->next->next->next = a->next;  // 环
    Solution s;
    cout << s.hasCycle(a) << endl;  // 1
    return 0;
}
