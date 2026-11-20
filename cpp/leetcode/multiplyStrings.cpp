/*
字符串相乘
给定两个字符串表示的非负整数，返回它们的乘积字符串。
*/

#include <iostream>
#include <string>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    string multiply(string num1, string num2) {
        int n = num1.size(), m = num2.size();
        vector<int> res(n + m, 0);
        for (int i = n - 1; i >= 0; --i)
            for (int j = m - 1; j >= 0; --j) {
                int mul = (num1[i] - '0') * (num2[j] - '0');
                int p1 = i + j, p2 = i + j + 1;
                int sum = mul + res[p2];
                res[p2] = sum % 10;
                res[p1] += sum / 10;
            }
        string ans;
        for (int x : res) if (!(ans.empty() && x == 0)) ans.push_back(x + '0');
        return ans.empty() ? "0" : ans;
    }
};

int main() {
    Solution s;
    cout << s.multiply("123", "456") << endl;  // 56088
    return 0;
}
