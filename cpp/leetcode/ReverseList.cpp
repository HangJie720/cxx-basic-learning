/*
反转链表
*/
#include <iostream>
#include <algorithm>  
#include <string>  

using namespace std;

struct ListNode {
	int val;
	ListNode *next;
	ListNode(int x) :
			val(x), next(NULL) {
	}
};
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
class Solution1 {
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

int main() {  
    // 创建链表 1 -> 2 -> 3 -> 4 -> 5  
    ListNode* head = new ListNode(1);  
    head->next = new ListNode(2);  
    head->next->next = new ListNode(3);  
    head->next->next->next = new ListNode(4);  
    head->next->next->next->next = new ListNode(5);  
  
    // 反转链表并打印结果
    Solution s;
    ListNode* reversedHead = s.ReverseList(head);  
    while (reversedHead != NULL) {  
        cout << reversedHead->val << " ";  
        reversedHead = reversedHead->next;  
    }  
    cout << endl;  
  
    return 0;  
}