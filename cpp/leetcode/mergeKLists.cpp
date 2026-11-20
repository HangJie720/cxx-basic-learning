/*
合并 K 个升序链表
返回合并后的升序链表。
*/

#include <iostream>
#include <vector>
#include <queue>

using namespace std;

struct ListNode {
    int val;
    ListNode *next;
    ListNode(int x) : val(x), next(nullptr) {}
};

class Solution {
public:
    ListNode* mergeKLists(vector<ListNode*>& lists) {
        auto cmp = [](ListNode* a, ListNode* b) { return a->val > b->val; };
        priority_queue<ListNode*, vector<ListNode*>, decltype(cmp)> pq(cmp);
        for (auto* h : lists) if (h) pq.push(h);
        ListNode dummy(0);
        ListNode* cur = &dummy;
        while (!pq.empty()) {
            ListNode* t = pq.top(); pq.pop();
            cur->next = t;
            cur = cur->next;
            if (t->next) pq.push(t->next);
        }
        return dummy.next;
    }
};

int main() {
    ListNode* a = new ListNode(1); a->next = new ListNode(4); a->next->next = new ListNode(5);
    ListNode* b = new ListNode(1); b->next = new ListNode(3); b->next->next = new ListNode(4);
    ListNode* c = new ListNode(2); c->next = new ListNode(6);
    vector<ListNode*> v = {a, b, c};
    Solution s;
    ListNode* r = s.mergeKLists(v);
    while (r) { cout << r->val << " "; r = r->next; }
    cout << endl;  // 1 1 2 3 4 4 5 6
    return 0;
}
