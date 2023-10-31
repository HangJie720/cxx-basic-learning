/*
用两个栈实现队列
*/

#include <iostream>  
#include <queue>  
#include <stack>  
  
using namespace std;  
  

#include <iostream>  
#include <stack>  
  
using namespace std;  
  
class MyQueue {  
public:  
    MyQueue() {}  
  
    void push(int x) {  
        while (!s1.empty()) {  
            s2.push(s1.top());  
            s1.pop();  
        }  
        s1.push(x);  
        while (!s2.empty()) {  
            s1.push(s2.top());  
            s2.pop();  
        }  
    }  
  
    int pop() {  
        int x = s1.top();  
        s1.pop();  
        return x;  
    }  
  
    int peek() {  
        return s1.top();  
    }  
  
    bool empty() {  
        return s1.empty();  
    }  
  
private:  
    stack<int> s1, s2;  
};


int main() {  
    // queue<int> q;  
    MyQueue q;
  
    // 插入元素  
    q.push(10);  
    q.push(20);  
    q.push(30);  
  
    // 输出队列元素  
    while (!q.empty()) {  
        cout << q.pop() << " ";  
        // q.pop();  
    }  
    cout << endl;  
  
    return 0;  
}