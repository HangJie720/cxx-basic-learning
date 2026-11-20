/*
最小栈
支持 push/pop/top 并能在 O(1) 取得栈中最小元素的栈。
*/

#include <iostream>
#include <stack>

using namespace std;

class MinStack {
public:
    void push(int x) {
        st.push(x);
        if (mn.empty() || x <= mn.top()) mn.push(x);
    }
    void pop() {
        if (st.top() == mn.top()) mn.pop();
        st.pop();
    }
    int top() { return st.top(); }
    int getMin() { return mn.top(); }

private:
    stack<int> st, mn;
};

int main() {
    MinStack s;
    s.push(-2);
    s.push(0);
    s.push(-3);
    cout << s.getMin() << endl;  // -3
    s.pop();
    cout << s.top() << endl;     // 0
    cout << s.getMin() << endl;  // -2
    return 0;
}
