/*
回文链表
判断单链表是否为回文。
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
    bool isPalindrome(ListNode* head) {
        ListNode *slow = head, *fast = head;
        while (fast && fast->next) { slow = slow->next; fast = fast->next->next; }
        ListNode* prev = nullptr;
        while (slow) { ListNode* nx = slow->next; slow->next = prev; prev = slow; slow = nx; }
        while (prev) {
            if (head->val != prev->val) return false;
            head = head->next; prev = prev->next;
        }
        return true;
    }
};

int main() {
    ListNode* a = new ListNode(1);
    a->next = new ListNode(2);
    a->next->next = new ListNode(2);
    a->next->next->next = new ListNode(1);
    Solution s;
    cout << s.isPalindrome(a) << endl;  // 1
    return 0;
}
