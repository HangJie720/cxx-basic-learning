/*
删除链表的节点
*/

/**
 * struct ListNode {
 *	int val;
 *	struct ListNode *next;
 *	ListNode(int x) : val(x), next(nullptr) {}
 * };
 */
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
