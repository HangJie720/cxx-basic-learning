/*
删除链表的节点
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
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param head ListNode类 
     * @param val int整型 
     * @return ListNode类
     */
    ListNode* deleteNode(ListNode* head, int val) {
        // write code here
        if(head->val==val){
            head = head->next;
            return head;
        }
        ListNode *pre = head;
        while(pre->next){
            if(pre->next->val == val){
                pre->next = pre->next->next;
            }
            pre = pre->next;
        }
        return head;
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
    ListNode* reversedHead = s.deleteNode(head, 3);  
    while (reversedHead != NULL) {  
        cout << reversedHead->val << " ";  
        reversedHead = reversedHead->next;  
    }  
    cout << endl;  
  
    return 0;  
}