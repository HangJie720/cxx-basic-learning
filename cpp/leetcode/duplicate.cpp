/*
数组中重复的数字
*/
#include <iostream>
#include <algorithm>  
#include <string>  
#include <vector>
#include <set>
#include <map>

using namespace std;

class Solution {
public:
    /**
     * 代码中的类名、方法名、参数名已经指定，请勿修改，直接返回方法规定的值即可
     *
     * 
     * @param numbers int整型vector 
     * @return int整型
     */
    int duplicate(vector<int>& numbers) {
        int len=numbers.size();
        for (int i=0; i<len; i++)
        {
            for(int j=i+1; j<len; j++)
            {
                if(numbers[i]==numbers[j])
                    return numbers[i];
            }
        }
        return -1;
    }
};

// 方法2: set, map, 唯一性
 int duplicate1(vector<int>& numbers) {
        // write code here
        set<int> n_set;
        for(auto t:numbers){
            if(n_set.count(t)) return t;
            n_set.insert(t);
        }
        return -1;
    }

int duplicate2(vector<int>& numbers) {
        // write code here
        map<int,int> list;
        for(int i=0;i<numbers.size();i++)
        {
            if(list[numbers[i]]!=-1)list[numbers[i]]=-1;
            else return numbers[i];
        }
        return -1;
    }
// 方法3：排序
int duplicate3(vector<int>& numbers) {
        // write code here
      sort(numbers.begin(),numbers.end());
      vector<int>::iterator it=adjacent_find(numbers.begin(),numbers.end());
      if(it==numbers.end()){
          return -1;
      }
      else{
          return *it;
      }
    }

int main() {  
    vector<int> nums = {5, 3, 8, 3, 2, 7, 1, 6};  
    int rep_v =  duplicate3(nums);  
    cout << "repeat value is: " << rep_v << endl; 
    cout << endl;  
    return 0;  
}