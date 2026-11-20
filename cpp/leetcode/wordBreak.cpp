/*
单词拆分
判断字符串 s 能否被拆分为一个或多个字典中出现的单词。
*/

#include <iostream>
#include <string>
#include <vector>
#include <unordered_set>

using namespace std;

class Solution {
public:
    bool wordBreak(string s, vector<string>& wordDict) {
        unordered_set<string> dict(wordDict.begin(), wordDict.end());
        int n = s.size();
        vector<bool> dp(n + 1);
        dp[0] = true;
        for (int i = 1; i <= n; ++i)
            for (int j = 0; j < i; ++j)
                if (dp[j] && dict.count(s.substr(j, i - j))) { dp[i] = true; break; }
        return dp[n];
    }
};

int main() {
    Solution s;
    vector<string> d = {"leet", "code"};
    cout << s.wordBreak("leetcode", d) << endl;  // 1
    return 0;
}
