/*
二进制求和
给定两个二进制字符串，返回它们的和（二进制字符串）。
*/

#include <iostream>
#include <string>
#include <algorithm>

using namespace std;

class Solution {
public:
    string addBinary(string a, string b) {
        string ans;
        int i = a.size() - 1, j = b.size() - 1, carry = 0;
        while (i >= 0 || j >= 0 || carry) {
            int sum = carry;
            if (i >= 0) sum += a[i--] - '0';
            if (j >= 0) sum += b[j--] - '0';
            ans.push_back((sum % 2) + '0');
            carry = sum / 2;
        }
        reverse(ans.begin(), ans.end());
        return ans;
    }
};

int main() {
    Solution s;
    cout << s.addBinary("11", "1") << endl;    // 100
    cout << s.addBinary("1010", "1011") << endl; // 10101
    return 0;
}
