/*
用两个栈实现队列
*/
class Solution
{
public:
    void push(int node) {
        stack1.push(node);
    }

    int pop() {
        if (stack2.empty()){
            while(!stack1.empty()){
                stack2.push(stack1.top());
                stack1.pop();
            }
        }
        int res = stack2.top();
        stack2.pop();
        return res;
    }

private:
    stack<int> stack1;
    stack<int> stack2;
};
// 方法2：
class Solution
{
public:
    void push(int node) {
       while(!stack1.empty())//1压入2
        {
            stack2.push(stack1.top());
            stack1.pop();
        }
        stack2.push(node);
    }
 
    int pop() {
         while(!stack2.empty())//1压入2
        {
            stack1.push(stack2.top());
            stack2.pop();
        }
        int value=stack1.top();
        stack1.pop();
        return value;
    }
 
private:
    stack<int> stack1;
    stack<int> stack2;
};
