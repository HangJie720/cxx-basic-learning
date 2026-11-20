/*
无重复字符的最长子串
返回字符串中不含重复字符的最长子串长度。
*/

#include <iostream>
#include <string>
#include <unordered_set>

using namespace std;

class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        unordered_set<char> st;
        int left = 0, ans = 0;
        for (int right = 0; right < (int)s.size(); ++right) {
            while (st.count(s[right])) st.erase(s[left++]);
            st.insert(s[right]);
            ans = max(ans, right - left + 1);
        }
        return ans;
    }
};

int main() {
    Solution s;
    cout << s.lengthOfLongestSubstring("abcabcbb") << endl;  // 3
    cout << s.lengthOfLongestSubstring("bbbbb") << endl;    // 1
    return 0;
}
