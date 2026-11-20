/*
有效的数独
判断 9x9 数独是否有效：行、列、3x3 宫内数字不重复。
*/

#include <iostream>
#include <vector>
#include <array>

using namespace std;

class Solution {
public:
    bool isValidSudoku(vector<vector<char>>& board) {
        array<array<int, 9>, 9> row{}, col{}, box{};
        for (int i = 0; i < 9; ++i)
            for (int j = 0; j < 9; ++j) {
                if (board[i][j] == '.') continue;
                int d = board[i][j] - '1', b = i / 3 * 3 + j / 3;
                if (row[i][d] || col[j][d] || box[b][d]) return false;
                row[i][d] = col[j][d] = box[b][d] = 1;
            }
        return true;
    }
};

int main() {
    Solution s;
    vector<vector<char>> b = {
        {'5','3','.','.','7','.','.','.','.'},
        {'6','.','.','1','9','5','.','.','.'},
        {'.','9','8','.','.','.','.','6','.'},
        {'8','.','.','.','6','.','.','.','3'},
        {'4','.','.','8','.','3','.','.','1'},
        {'7','.','.','.','2','.','.','.','6'},
        {'.','6','.','.','.','.','2','8','.'},
        {'.','.','.','4','1','9','.','.','5'},
        {'.','.','.','.','8','.','.','7','9'}
    };
    cout << s.isValidSudoku(b) << endl;  // 1
    return 0;
}
