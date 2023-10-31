/*
替换空格
*/
#include <iostream>
#include <algorithm>  
#include <string>  

using namespace std;

class Solution {
public:
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param s string字符串 
     * @return string字符串
     */
    string replaceSpace(string s) {
        // write code here
        for(int i = 0;i < s.size();i++){
            if(s[i] == ' '){
                s[i] = '%';
                s.insert(i + 1, "20");
            }
        }
        return s;
    }
};
// 方法2：
string replaceSpace1(string s) {
        unsigned long pos; 
        while((pos = s.find(" ")) != string::npos)
            s.replace(pos,1,"%20");
        return s;
    }
// 方法3：
string replaceSpace2(string s) {
        // write code here
        int index;
        while(s.find(" ") != -1){
            index = s.find(" ");
            s.replace(index,1,"%20");
        }
        return s;
         
         
    }
  
int main() {  
    std::string str = "Hello World!";  
    std::replace(str.begin(), str.end(), ' ', '_');  
    std::cout << str << std::endl;  
    return 0;  
}