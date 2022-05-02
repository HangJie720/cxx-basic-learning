/*
从尾到头打印链表
*/

/**
*  struct ListNode {
*        int val;
*        struct ListNode *next;
*        ListNode(int x) :
*              val(x), next(NULL) {
*        }
*  };
*/
class Solution {
public:
    vector<int> printListFromTailToHead(ListNode* head) {
        vector<int> ans;
          // 从头节点开始进行遍历
        while(head){
            // 将每个节点的权值放入动态数组里面
            ans.push_back(head->val);
            // 指针后移动
            head=head->next;
        }
        // 反转整个数组
        reverse(ans.begin(),ans.end());
        return ans;
    }
};
// 方法2，俩数组
class Solution {
public:
    vector<int> printListFromTailToHead(ListNode* head) {
        vector<int> v,v2;
        ListNode *it=head;
        if(head==NULL)
        {
            return v2;
        }
        while(it!=NULL)
        {
            v.push_back(it->val);
            it=it->next;
        }
        for(int i=v.size()-1;i>-1;i--)
        {
            v2.push_back(v[i]);
        }
        return v2;
    }
};

// 方法3：数组+堆栈
class Solution {
public:
    vector<int> printListFromTailToHead(ListNode* head) {
        vector<int> v,v2;
        ListNode *it=head;
        if(head==NULL)
        {
            return v2;
        }
        while(it!=NULL)
        {
            v.push_back(it->val);
            it=it->next;
        }
        for(int i=v.size()-1;i>-1;i--)
        {
            v2.push_back(v[i]);
        }
        return v2;
    }
};

// 方法4：链表反转
class Solution {
public:
    vector<int> printListFromTailToHead(ListNode* head) {
        vector<int> result;
        if (head==nullptr){
            return result;
        }
        ListNode *curr = head->next;
        ListNode *temp;
        head->next = nullptr;
        while(curr){
            temp = curr->next;
            curr->next = head;
            head = curr;
            curr = temp;
        }
        while(head){
            result.push_back(head->val);
            head = head -> next;
        }
        return result;
    }
};


