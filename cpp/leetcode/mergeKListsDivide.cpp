/*
合并 K 个链表（分治版）
见 mergeKLists.cpp 的堆版本，此处用分治。
*/

#include <iostream>
#include <vector>

using namespace std;

struct ListNode {
    int val;
    ListNode *next;
    ListNode(int x) : val(x), next(nullptr) {}
};

class Solution {
public:
    ListNode* mergeKLists(vector<ListNode*>& lists) {
        if (lists.empty()) return nullptr;
        return merge(lists, 0, lists.size() - 1);
    }
    ListNode* merge(vector<ListNode*>& ls, int l, int r) {
        if (l == r) return ls[l];
        int m = (l + r) / 2;
        return mergeTwo(merge(ls, l, m), merge(ls, m + 1, r));
    }
    ListNode* mergeTwo(ListNode* a, ListNode* b) {
        ListNode dummy(0); ListNode* c = &dummy;
        while (a && b) {
            if (a->val <= b->val) { c->next = a; a = a->next; }
            else { c->next = b; b = b->next; }
            c = c->next;
        }
        c->next = a ? a : b;
        return dummy.next;
    }
};

int main() {
    ListNode* a = new ListNode(1); a->next = new ListNode(4);
    ListNode* b = new ListNode(2); b->next = new ListNode(5);
    vector<ListNode*> v = {a, b};
    Solution s;
    ListNode* r = s.mergeKLists(v);
    while (r) { cout << r->val << " "; r = r->next; }
    cout << endl;  // 1 2 4 5
    return 0;
}
