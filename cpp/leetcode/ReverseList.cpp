/*
反转链表
*/

/*
struct ListNode {
	int val;
	struct ListNode *next;
	ListNode(int x) :
			val(x), next(NULL) {
	}
};*/
class Solution {
public:
    ListNode* ReverseList(ListNode* pHead) {
        if (pHead==nullptr){
            return pHead;
        }
        ListNode *curr = pHead->next;
        ListNode *temp;
        pHead->next = nullptr;
        while(curr){
            temp = curr->next;
            curr->next = pHead;
            pHead = curr;
            curr = temp;
        }
        return pHead;
    }
};
// 方法2：
class Solution {
public:
    ListNode* ReverseList(ListNode* pHead) {
          
        ListNode* pre = NULL;
        ListNode* cur = pHead;
         
        while (cur != NULL){
            ListNode* temp;
            temp = cur->next;
            cur->next = pre;
            pre = cur;
            cur = temp;
             
             
        }
         
        return pre;
    }
};